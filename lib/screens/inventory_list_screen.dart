import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../design/app_colors.dart';
import '../design/typography.dart';
import '../models/item_model.dart';
import '../models/category_model.dart';
import '../providers.dart';
import '../routing/app_router.dart';
import '../responsive_breakpoints.dart';
import '../ui/app_components.dart';

/// Inventory list screen with search, filter, and item cards.
class InventoryListScreen extends ConsumerStatefulWidget {
  const InventoryListScreen({super.key});

  @override
  ConsumerState<InventoryListScreen> createState() =>
      _InventoryListScreenState();
}

class _InventoryListScreenState extends ConsumerState<InventoryListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(filteredItemsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.import),
            tooltip: 'Batch Operation',
            onPressed: () => context.push('/inventory/batch'),
          ),
          IconButton(
            icon: const Icon(AppIcons.filter),
            onPressed: () => _showFilterSheet(context, categoriesAsync),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(context.responsivePadding),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search items or SKU...',
                prefixIcon: const Icon(AppIcons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(AppIcons.close),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
          ),
          // Category filter chips
          if (categoriesAsync.hasValue)
            _CategoryChips(categories: categoriesAsync.value ?? []),
          // Items list
          Expanded(
            child: ConstrainedContent(
              maxWidth: 1200,
              child: itemsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return EmptyState(
                    icon: AppIcons.inventory,
                    title: 'No items yet',
                    subtitle: 'Add your first inventory item to get started.',
                    actionLabel: 'Add Item',
                    onAction: () => context.push(AppRoutes.inventoryAdd),
                  );
                }
                return _ItemList(items: items);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(AppIcons.error, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    const Text(
                      'Error loading items',
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: 8),
                    Text('$error', style: AppTextStyles.caption),
                  ],
                ),
              ),
            ),
          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.inventoryAdd),
        icon: const Icon(AppIcons.add),
        label: const Text('Add Item'),
      ),
    );
  }

  void _showFilterSheet(
    BuildContext context,
    AsyncValue<List<Category>> categoriesAsync,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter by Category', style: AppTextStyles.h4),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  ref.read(selectedCategoryProvider.notifier).state = null;
                  context.pop();
                },
                child: const Text('All Items'),
              ),
              ...categoriesAsync.when(
                data: (categories) => categories.map(
                  (c) => ListTile(
                    title: Text(c.name),
                    trailing: ref.watch(selectedCategoryProvider) == c.id
                        ? const Icon(AppIcons.success)
                        : null,
                    onTap: () {
                      ref.read(selectedCategoryProvider.notifier).state = c.id;
                      context.pop();
                    },
                  ),
                ),
                loading: () => [],
                error: (_, _) => [],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedCategoryProvider);

    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          FilterChip(
            label: const Text('All'),
            selected: selectedId == null,
            onSelected: (_) {
              ref.read(selectedCategoryProvider.notifier).state = null;
            },
          ),
          const SizedBox(width: 8),
          for (final category in categories) ...[
            FilterChip(
              label: Text(category.name),
              selected: selectedId == category.id,
              onSelected: (_) {
                ref.read(selectedCategoryProvider.notifier).state = category.id;
              },
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _ItemList extends StatelessWidget {
  const _ItemList({required this.items});

  final List<Item> items;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (_) => _ItemListView(items: items),
      tablet: (_) => _ItemGridView(items: items),
      desktop: (_) => _ItemGridView(items: items),
    );
  }
}

/// Mobile layout: vertical ListView with ListTile cards.
class _ItemListView extends StatelessWidget {
  const _ItemListView({required this.items});

  final List<Item> items;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final statusColor = item.isOutOfStock
            ? cs.error
            : item.isLowStock
                ? const Color(0xFFFF9800)
                : cs.primary;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: InkWell(
              onTap: () => context.push('/inventory/${item.id}'),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    // Status dot
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Item initial
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: statusColor.withValues(alpha: 0.1),
                      child: Text(
                        item.name.substring(0, 1).toUpperCase(),
                        style: AppTextStyles.labelMedium.copyWith(color: statusColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Name + details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: AppTextStyles.body.copyWith(color: cs.onSurface),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.sku} · ${item.quantity} ${item.unit.abbreviation}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${item.sellingPrice.toStringAsFixed(2)}',
                          style: AppTextStyles.labelMedium.copyWith(color: cs.primary),
                        ),
                        if (item.isOutOfStock)
                          Text(
                            'OUT OF STOCK',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: cs.error,
                              fontSize: 9,
                              letterSpacing: 0.5,
                            ),
                          )
                        else if (item.isLowStock)
                          Text(
                            'LOW',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(0xFFFF9800),
                              fontSize: 9,
                              letterSpacing: 0.5,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    Icon(AppIcons.forward, size: 16, color: cs.outline),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Tablet/Desktop layout: responsive GridView with compact cards.
class _ItemGridView extends StatelessWidget {
  const _ItemGridView({required this.items});

  final List<Item> items;

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = context.gridColumns;
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: _ItemGridCard.aspectRatio,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _ItemGridCard(item: items[index]);
      },
    );
  }
}

/// Compact grid card for an inventory item.
class _ItemGridCard extends StatelessWidget {
  const _ItemGridCard({required this.item});

  final Item item;

  /// Aspect ratio for grid card sizing.
  static const double aspectRatio = 0.85;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = item.isOutOfStock
        ? cs.error
        : item.isLowStock
            ? const Color(0xFFFF9800)
            : cs.primary;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: () => context.push('/inventory/${item.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top: status dot + price
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '\$${item.sellingPrice.toStringAsFixed(2)}',
                    style: AppTextStyles.labelMedium.copyWith(color: cs.primary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Item name
              Text(
                item.name,
                style: AppTextStyles.body.copyWith(color: cs.onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // SKU + quantity
              Text(
                '${item.sku} · ${item.quantity} ${item.unit.abbreviation}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              // Status text
              if (item.isOutOfStock)
                Text(
                  'OUT OF STOCK',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: cs.error,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                )
              else if (item.isLowStock)
                Text(
                  'LOW STOCK',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: const Color(0xFFFF9800),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}


