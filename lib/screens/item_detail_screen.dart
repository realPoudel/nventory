import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/errors.dart';
import '../core/result.dart';
import '../design/app_colors.dart';
import '../design/typography.dart';
import '../models/item_model.dart';
import '../models/category_model.dart';
import '../models/stock_movement_model.dart';
import '../providers.dart';
import '../responsive_breakpoints.dart';
import '../routing/app_router.dart';
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
                case 'history':
                  context.push('/inventory/${item.id}/history');
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
                value: 'history',
                child: ListTile(
                  leading: Icon(Icons.history),
                  title: Text('Stock History'),
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
    MovementType selectedType = isAddition
        ? MovementType.stockIn
        : MovementType.stockOut;
    String? reason;
    String reference = '';

    final presetReasons = <String>[];
    if (isAddition) {
      presetReasons.addAll([
        'Received from supplier',
        'Returned by customer',
        'Physical count correction',
        'Other',
      ]);
    } else {
      presetReasons.addAll([
        'Sold',
        'Used internally',
        'Damaged / Expired',
        'Lost / Missing',
        'Physical count correction',
        'Other',
      ]);
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final cs = Theme.of(context).colorScheme;
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    selectedType == MovementType.stockIn
                        ? Icons.add_circle_outline
                        : selectedType == MovementType.stockOut
                        ? Icons.remove_circle_outline
                        : Icons.tune,
                    color: cs.primary,
                  ),
                  const SizedBox(width: 8),
                  const Text('Stock Adjustment'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current stock info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(AppIcons.inventory, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Current: ${item.quantity} ${item.unit.abbreviation}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Movement type selector
                    const Text('Type', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 8),
                    SegmentedButton<MovementType>(
                      segments: const [
                        ButtonSegment<MovementType>(
                          value: MovementType.stockIn,
                          label: Text('In'),
                          icon: Icon(Icons.add, size: 16),
                        ),
                        ButtonSegment<MovementType>(
                          value: MovementType.stockOut,
                          label: Text('Out'),
                          icon: Icon(Icons.remove, size: 16),
                        ),
                        ButtonSegment<MovementType>(
                          value: MovementType.adjustment,
                          label: Text('Adjust'),
                          icon: Icon(Icons.tune, size: 16),
                        ),
                      ],
                      selected: {selectedType},
                      onSelectionChanged: (Set<MovementType> selection) {
                        setDialogState(() {
                          selectedType = selection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Quantity
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: 'Quantity *',
                        suffixText: item.unit.abbreviation,
                      ),
                      keyboardType: TextInputType.number,
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),

                    // Preset reasons
                    const Text('Reason', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: presetReasons.map((preset) {
                        final isSelected = reason == preset;
                        return FilterChip(
                          label: Text(preset),
                          selected: isSelected,
                          onSelected: (_) {
                            setDialogState(() {
                              reason = preset == 'Other' ? null : preset;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    if (reason == null || reason == 'Other') ...[
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Custom reason',
                          hintText: 'Describe the reason...',
                        ),
                        onChanged: (value) => reason = value,
                      ),
                    ],
                    const SizedBox(height: 12),

                    // Reference
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Reference (optional)',
                        hintText: 'e.g., PO-123, Sale #456',
                        prefixIcon: Icon(AppIcons.barcode),
                      ),
                      onChanged: (value) => reference = value,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final quantity = int.tryParse(controller.text);
                    if (quantity == null || quantity <= 0) {
                      return;
                    }

                    int adjustment;
                    if (selectedType == MovementType.stockIn) {
                      adjustment = quantity;
                    } else if (selectedType == MovementType.stockOut) {
                      adjustment = -quantity;
                    } else {
                      // Adjustment: relative change
                      adjustment = quantity;
                    }

                    final result = await ref
                        .read(itemCrudProvider.notifier)
                        .adjustStock(
                          item.id,
                          adjustment,
                          reason: reason,
                          reference: reference.isNotEmpty ? reference : null,
                        );

                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }

                    switch (result) {
                      case Ok<Item, AppError>():
                        ref.invalidate(itemByIdProvider(item.id));
                        ref.invalidate(itemsProvider);
                        ref.invalidate(filteredItemsProvider);
                        ref.invalidate(lowStockItemsProvider);
                        ref.invalidate(dashboardStatsProvider);
                        ref.invalidate(movementsByItemProvider(item.id));
                        if (dialogContext.mounted) {
                          showPremiumToast(
                            context,
                            message: selectedType == MovementType.stockIn
                                ? 'Added $quantity ${item.unit.abbreviation}'
                                : selectedType == MovementType.stockOut
                                ? 'Removed $quantity ${item.unit.abbreviation}'
                                : 'Adjusted by $quantity',
                            type: ToastType.success,
                          );
                        }
                      case Err<Item, AppError>(:final error):
                        if (dialogContext.mounted) {
                          showPremiumToast(
                            context,
                            message: error.message,
                            type: ToastType.error,
                          );
                        }
                    }
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
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
          showPremiumToast(
            context,
            message: 'Item deleted',
            type: ToastType.success,
          );
          context.pop();
        }
      case Err<void, AppError>(:final error):
        if (context.mounted) {
          showPremiumToast(
            context,
            message: error.message,
            type: ToastType.error,
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
