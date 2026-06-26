import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/errors.dart';
import '../core/result.dart';
import '../design/app_colors.dart';
import '../design/typography.dart';
import '../models/item_model.dart';
import '../models/category_model.dart';
import '../providers.dart';
import '../routing/app_router.dart';
import '../responsive_breakpoints.dart';
import '../ui/app_components.dart';

/// Item detail screen with stock adjustment.
class ItemDetailScreen extends ConsumerWidget {
  const ItemDetailScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(itemByIdProvider(itemId));
    final categoriesAsync = ref.watch(categoriesProvider);

    return itemAsync.when(
      data: (item) {
        if (item == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Item Not Found')),
            body: const Center(child: Text('Item not found')),
          );
        }
        return _ItemDetailView(item: item, categoriesAsync: categoriesAsync);
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  AppIcons.error,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                const Text('Failed to load item', style: AppTextStyles.h4),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemDetailView extends ConsumerWidget {
  const _ItemDetailView({required this.item, required this.categoriesAsync});

  final Item item;
  final AsyncValue<List<Category>> categoriesAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final category = categoriesAsync.when(
      data: (categories) {
        if (item.categoryId == null) {
          return null;
        }
        return categories.where((c) => c.id == item.categoryId).firstOrNull;
      },
      loading: () => null,
      error: (_, _) => null,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.edit),
            onPressed: () {
              context.push('${AppRoutes.inventoryAdd}?id=${item.id}');
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(AppIcons.more),
            onSelected: (value) async {
              switch (value) {
                case 'stock_in':
                  _showStockAdjustment(context, ref, isAddition: true);
                case 'stock_out':
                  _showStockAdjustment(context, ref, isAddition: false);
                case 'delete':
                  _confirmDelete(context, ref);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'stock_in',
                child: ListTile(
                  leading: Icon(Icons.add_circle_outline),
                  title: Text('Stock In'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'stock_out',
                child: ListTile(
                  leading: Icon(Icons.remove_circle_outline),
                  title: Text('Stock Out'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(AppIcons.delete),
                  title: Text('Delete'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: ConstrainedContent(
        maxWidth: 900,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.responsivePadding),
          child: ResponsiveBuilder(
            mobile: (_) => _buildMobileLayout(context, ref, cs, category),
            tablet: (_) => _buildTabletLayout(context, ref, cs, category),
            desktop: (_) => _buildDesktopLayout(context, ref, cs, category),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    ColorScheme cs,
    Category? category,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.isOutOfStock)
          _StatusBanner(
            message: 'OUT OF STOCK',
            color: cs.error,
            icon: AppIcons.error,
          )
        else if (item.isLowStock)
          _StatusBanner(
            message:
                'LOW STOCK \u2014 ${item.quantity} ${item.unit.abbreviation} remaining',
            color: AppColors.warning,
            icon: AppIcons.warning,
          ),
        const SizedBox(height: 16),
        _buildSkuCard(cs),
        const SizedBox(height: 12),
        _buildStockCard(ref, cs),
        const SizedBox(height: 12),
        _buildPricingCard(cs),
        const SizedBox(height: 12),
        _buildInventoryValueCard(cs),
        if (category != null) ...[
          const SizedBox(height: 12),
          _buildCategoryCard(category, cs),
        ],
        if (item.location.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildLocationCard(cs),
        ],
        if (item.description.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildDescriptionCard(cs),
        ],
        const SizedBox(height: 12),
        _buildTimestampsCard(),
      ],
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    WidgetRef ref,
    ColorScheme cs,
    Category? category,
  ) {
    return _TwoColumnDetail(
      left: [
        if (item.isOutOfStock)
          _StatusBanner(
            message: 'OUT OF STOCK',
            color: cs.error,
            icon: AppIcons.error,
          )
        else if (item.isLowStock)
          _StatusBanner(
            message:
                'LOW STOCK \u2014 ${item.quantity} ${item.unit.abbreviation} remaining',
            color: AppColors.warning,
            icon: AppIcons.warning,
          ),
        const SizedBox(height: 16),
        _buildSkuCard(cs),
        const SizedBox(height: 12),
        _buildStockCard(ref, cs),
        const SizedBox(height: 12),
        _buildPricingCard(cs),
        const SizedBox(height: 12),
        _buildInventoryValueCard(cs),
      ],
      right: [
        if (category != null) ...[
          _buildCategoryCard(category, cs),
          const SizedBox(height: 12),
        ],
        if (item.location.isNotEmpty) ...[
          _buildLocationCard(cs),
          const SizedBox(height: 12),
        ],
        if (item.description.isNotEmpty) ...[
          _buildDescriptionCard(cs),
          const SizedBox(height: 12),
        ],
        _buildTimestampsCard(),
      ],
      rightWidth: 280,
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    WidgetRef ref,
    ColorScheme cs,
    Category? category,
  ) {
    return _TwoColumnDetail(
      left: [
        if (item.isOutOfStock)
          _StatusBanner(
            message: 'OUT OF STOCK',
            color: cs.error,
            icon: AppIcons.error,
          )
        else if (item.isLowStock)
          _StatusBanner(
            message:
                'LOW STOCK \u2014 ${item.quantity} ${item.unit.abbreviation} remaining',
            color: AppColors.warning,
            icon: AppIcons.warning,
          ),
        const SizedBox(height: 16),
        _buildSkuCard(cs),
        const SizedBox(height: 12),
        _buildStockCard(ref, cs),
        const SizedBox(height: 12),
        _buildPricingCard(cs),
        const SizedBox(height: 12),
        _buildInventoryValueCard(cs),
      ],
      right: [
        if (category != null) ...[
          _buildCategoryCard(category, cs),
          const SizedBox(height: 12),
        ],
        if (item.location.isNotEmpty) ...[
          _buildLocationCard(cs),
          const SizedBox(height: 12),
        ],
        if (item.description.isNotEmpty) ...[
          _buildDescriptionCard(cs),
          const SizedBox(height: 12),
        ],
        _buildTimestampsCard(),
      ],
      rightWidth: 320,
    );
  }

  // === Shared card builders ===

  Widget _buildSkuCard(ColorScheme cs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(AppIcons.barcode, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SKU', style: AppTextStyles.labelMedium),
                Text(
                  item.sku,
                  style: AppTextStyles.bodyLarge.copyWith(color: cs.onSurface),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockCard(WidgetRef ref, ColorScheme cs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current Stock', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${item.quantity} ${item.unit.abbreviation}',
                    style: AppTextStyles.h2.copyWith(
                      color: item.isOutOfStock
                          ? cs.error
                          : item.isLowStock
                          ? AppColors.warning
                          : cs.primary,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton.filled(
                  onPressed: () =>
                      _showStockAdjustment(ref.context, ref, isAddition: false),
                  icon: const Icon(Icons.remove),
                  style: IconButton.styleFrom(
                    backgroundColor: cs.errorContainer,
                    foregroundColor: cs.onErrorContainer,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () =>
                      _showStockAdjustment(ref.context, ref, isAddition: true),
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: cs.primaryContainer,
                    foregroundColor: cs.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCard(ColorScheme cs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cost Price', style: AppTextStyles.labelMedium),
                  Text(
                    '\$${item.costPrice.toStringAsFixed(2)}',
                    style: AppTextStyles.h4.copyWith(color: cs.onSurface),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selling Price', style: AppTextStyles.labelMedium),
                  Text(
                    '\$${item.sellingPrice.toStringAsFixed(2)}',
                    style: AppTextStyles.h4.copyWith(color: cs.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryValueCard(ColorScheme cs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.account_balance_wallet_outlined, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Inventory Value', style: AppTextStyles.labelMedium),
                Text(
                  '\$${item.inventoryValue.toStringAsFixed(2)}',
                  style: AppTextStyles.h4.copyWith(color: cs.onSurface),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Category category, ColorScheme cs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(AppIcons.category, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Category', style: AppTextStyles.labelMedium),
                Text(
                  category.name,
                  style: AppTextStyles.bodyLarge.copyWith(color: cs.onSurface),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(ColorScheme cs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(AppIcons.location, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Location', style: AppTextStyles.labelMedium),
                Text(
                  item.location,
                  style: AppTextStyles.bodyLarge.copyWith(color: cs.onSurface),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(ColorScheme cs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Description', style: AppTextStyles.labelMedium),
            const SizedBox(height: 4),
            Text(
              item.description,
              style: AppTextStyles.body.copyWith(color: cs.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimestampsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(AppIcons.clock, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Created: ${_formatDate(item.createdAt)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(AppIcons.refresh, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Updated: ${_formatDate(item.updatedAt)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStockAdjustment(
    BuildContext context,
    WidgetRef ref, {
    required bool isAddition,
  }) {
    final controller = TextEditingController();
    String? reason;

    AppDialog.show<void>(
      context: context,
      title: isAddition ? 'Stock In' : 'Stock Out',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Current stock: ${item.quantity} ${item.unit.abbreviation}',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Quantity',
              suffixText: item.unit.abbreviation,
            ),
            keyboardType: TextInputType.number,
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Reason (optional)',
              hintText: 'e.g., Received from supplier',
            ),
            onChanged: (value) => reason = value,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final quantity = int.tryParse(controller.text);
            if (quantity == null || quantity <= 0) {
              return;
            }

            final adjustment = isAddition ? quantity : -quantity;
            final result = await ref
                .read(itemCrudProvider.notifier)
                .adjustStock(item.id, adjustment, reason: reason);

            if (context.mounted) {
              Navigator.of(context).pop();
            }

            switch (result) {
              case Ok<Item, AppError>():
                ref.invalidate(itemByIdProvider(item.id));
                ref.invalidate(itemsProvider);
                ref.invalidate(filteredItemsProvider);
                ref.invalidate(lowStockItemsProvider);
                ref.invalidate(dashboardStatsProvider);
                if (context.mounted) {
                  showPremiumSnackBar(
                    context,
                    message: isAddition
                        ? 'Added $quantity ${item.unit.abbreviation}'
                        : 'Removed $quantity ${item.unit.abbreviation}',
                    icon: AppIcons.success,
                  );
                }
              case Err<Item, AppError>(:final error):
                if (context.mounted) {
                  showPremiumSnackBar(
                    context,
                    message: error.message,
                    icon: AppIcons.error,
                  );
                }
            }
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Item',
      message:
          'Are you sure you want to delete "${item.name}"? This cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      isDestructive: true,
    );

    if (!confirmed || !context.mounted) {
      return;
    }

    final result = await ref.read(itemCrudProvider.notifier).delete(item.id);

    switch (result) {
      case Ok<void, AppError>():
        ref.invalidate(itemsProvider);
        ref.invalidate(filteredItemsProvider);
        ref.invalidate(dashboardStatsProvider);
        if (context.mounted) {
          showPremiumSnackBar(
            context,
            message: 'Item deleted',
            icon: AppIcons.success,
          );
          context.pop();
        }
      case Err<void, AppError>(:final error):
        if (context.mounted) {
          showPremiumSnackBar(
            context,
            message: error.message,
            icon: AppIcons.error,
          );
        }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Two-column layout for tablet/desktop detail views.
class _TwoColumnDetail extends StatelessWidget {
  const _TwoColumnDetail({
    required this.left,
    required this.right,
    required this.rightWidth,
  });

  final List<Widget> left;
  final List<Widget> right;
  final double rightWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final leftWidth = constraints.maxWidth - rightWidth - 16;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: leftWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: left,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: rightWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: right,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.message,
    required this.color,
    required this.icon,
  });

  final String message;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(message, style: AppTextStyles.labelLarge.copyWith(color: color)),
        ],
      ),
    );
  }
}
