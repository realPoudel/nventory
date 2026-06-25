import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../design/typography.dart';
import '../models/stock_movement_model.dart';
import '../models/stock_movement_repository.dart';
import '../providers.dart';
import '../responsive_breakpoints.dart';
import '../ui/app_components.dart';

/// Reports screen with filterable data tables and date range selection.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  DateTimeRange? _dateRange;
  MovementType? _movementTypeFilter;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Default to last 30 days
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.filter),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter summary bar
          _FilterBar(
            dateRange: _dateRange,
            movementType: _movementTypeFilter,
            onClear: () {
              setState(() {
                _movementTypeFilter = null;
                _searchQuery = '';
                final now = DateTime.now();
                _dateRange = DateTimeRange(
                  start: now.subtract(const Duration(days: 30)),
                  end: now,
                );
              });
            },
          ),
          // Content
          Expanded(
            child: ConstrainedContent(
              maxWidth: 1200,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(context.responsivePadding),
                child: ResponsiveBuilder(
                  mobile: (_) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Stock Movements'),
                      const SizedBox(height: 8),
                      _MovementReport(
                        dateRange: _dateRange,
                        movementType: _movementTypeFilter,
                        searchQuery: _searchQuery,
                      ),
                      const SizedBox(height: 24),
                      const SectionHeader(title: 'Low Stock Report'),
                      const SizedBox(height: 8),
                      const _LowStockReport(),
                      const SizedBox(height: 24),
                      const SectionHeader(title: 'Inventory Valuation'),
                      const SizedBox(height: 8),
                      const _ValuationReport(),
                    ],
                  ),
                  tablet: (_) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Stock Movements'),
                      const SizedBox(height: 8),
                      _MovementReport(
                        dateRange: _dateRange,
                        movementType: _movementTypeFilter,
                        searchQuery: _searchQuery,
                      ),
                      const SizedBox(height: 24),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _LowStockReport()),
                          SizedBox(width: 16),
                          Expanded(child: _ValuationReport()),
                        ],
                      ),
                    ],
                  ),
                  desktop: (_) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Stock Movements'),
                      const SizedBox(height: 8),
                      _MovementReport(
                        dateRange: _dateRange,
                        movementType: _movementTypeFilter,
                        searchQuery: _searchQuery,
                      ),
                      const SizedBox(height: 24),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _LowStockReport()),
                          SizedBox(width: 16),
                          Expanded(child: _ValuationReport()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    final searchController = TextEditingController(text: _searchQuery);
    MovementType? selectedType = _movementTypeFilter;

    AppDialog.show<void>(
      context: context,
      title: 'Filters',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: searchController,
            decoration: const InputDecoration(
              labelText: 'Search items',
              prefixIcon: Icon(AppIcons.search),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Movement Type', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: selectedType == null,
                onSelected: (_) => selectedType = null,
              ),
              ...MovementType.values.map((type) {
                return FilterChip(
                  label: Text(type.label),
                  selected: selectedType == type,
                  onSelected: (_) => selectedType = type,
                );
              }),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _searchQuery = searchController.text;
              _movementTypeFilter = selectedType;
            });
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.dateRange,
    required this.movementType,
    required this.onClear,
  });

  final DateTimeRange? dateRange;
  final MovementType? movementType;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasFilters = movementType != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Last ${dateRange?.duration.inDays ?? 30} days'
              '${movementType != null ? ' · ${movementType!.label}' : ''}',
              style: AppTextStyles.bodySmall.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          if (hasFilters)
            TextButton(onPressed: onClear, child: const Text('Clear')),
        ],
      ),
    );
  }
}

class _MovementReport extends StatelessWidget {
  const _MovementReport({
    required this.dateRange,
    required this.movementType,
    required this.searchQuery,
  });

  final DateTimeRange? dateRange;
  final MovementType? movementType;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StockMovement>>(
      future: _fetchMovements(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final movements = snapshot.data!;
        if (movements.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No movements in this period',
                  style: AppTextStyles.body.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }
        return Card(
          child: Column(
            children: movements.take(20).map((m) {
              final cs = Theme.of(context).colorScheme;
              final isIn = m.type == MovementType.stockIn;
              return ListTile(
                leading: Icon(
                  isIn ? Icons.add_circle_outline : Icons.remove_circle_outline,
                  color: isIn ? cs.primary : cs.error,
                ),
                title: Text(m.itemName, style: AppTextStyles.body),
                subtitle: Text(
                  '${m.type.label} · ${m.quantity} units',
                  style: AppTextStyles.caption,
                ),
                trailing: Text(
                  '${m.createdAt.month}/${m.createdAt.day}',
                  style: AppTextStyles.caption,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<List<StockMovement>> _fetchMovements() async {
    var movements = <StockMovement>[];
    if (dateRange != null) {
      movements = await StockMovementRepository.instance.getByDateRange(
        dateRange!.start,
        dateRange!.end,
      );
    } else {
      movements = await StockMovementRepository.instance.getRecent(100);
    }
    if (movementType != null) {
      movements = movements.where((m) => m.type == movementType).toList();
    }
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      movements = movements
          .where((m) => m.itemName.toLowerCase().contains(q))
          .toList();
    }
    return movements;
  }
}

class _LowStockReport extends ConsumerWidget {
  const _LowStockReport();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(lowStockItemsProvider);

    return itemsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Icon(
                    AppIcons.success,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'All items are well stocked!',
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            ),
          );
        }
        return Card(
          child: Column(
            children: items.map((item) {
              final cs = Theme.of(context).colorScheme;
              return ListTile(
                leading: Icon(
                  item.isOutOfStock ? AppIcons.error : AppIcons.warning,
                  color: item.isOutOfStock ? cs.error : Colors.orange,
                ),
                title: Text(item.name, style: AppTextStyles.body),
                subtitle: Text(
                  'SKU: ${item.sku}',
                  style: AppTextStyles.caption,
                ),
                trailing: Text(
                  '${item.quantity} / ${item.lowStockThreshold}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: item.isOutOfStock ? cs.error : Colors.orange,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _ValuationReport extends ConsumerWidget {
  const _ValuationReport();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsProvider);

    return itemsAsync.when(
      data: (items) {
        final totalValue = items.fold<double>(
          0,
          (sum, i) => sum + i.inventoryValue,
        );
        final totalItems = items.length;
        final avgValue = totalItems > 0 ? totalValue / totalItems : 0;
        final cs = Theme.of(context).colorScheme;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ValStat(
                      label: 'Total Value',
                      value: '\$${totalValue.toStringAsFixed(2)}',
                      color: cs.primary,
                    ),
                    _ValStat(
                      label: 'Items',
                      value: totalItems.toString(),
                      color: cs.secondary,
                    ),
                    _ValStat(
                      label: 'Avg Value',
                      value: '\$${avgValue.toStringAsFixed(2)}',
                      color: cs.tertiary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _ValStat extends StatelessWidget {
  const _ValStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.h4.copyWith(color: color)),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
