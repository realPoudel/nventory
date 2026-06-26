import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/errors.dart';
import '../core/result.dart';
import '../design/typography.dart';
import '../models/item_model.dart';
import '../models/stock_movement_model.dart';
import '../models/repositories.dart';
import '../providers.dart';
import '../ui/app_components.dart';

/// Batch stock operations screen for applying the same operation to multiple items.
class BatchStockScreen extends ConsumerStatefulWidget {
  const BatchStockScreen({super.key});

  @override
  ConsumerState<BatchStockScreen> createState() => _BatchStockScreenState();
}

class _BatchStockScreenState extends ConsumerState<BatchStockScreen> {
  final Set<String> _selectedItemIds = {};
  MovementType _movementType = MovementType.stockIn;
  final _quantityController = TextEditingController();
  String? _reason;
  bool _isProcessing = false;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Batch Stock Operation')),
      body: Column(
        children: [
          // Operation config
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Operation', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 8),
                    SegmentedButton<MovementType>(
                      segments: const [
                        ButtonSegment<MovementType>(
                          value: MovementType.stockIn,
                          label: Text('Stock In'),
                          icon: Icon(Icons.add, size: 16),
                        ),
                        ButtonSegment<MovementType>(
                          value: MovementType.stockOut,
                          label: Text('Stock Out'),
                          icon: Icon(Icons.remove, size: 16),
                        ),
                      ],
                      selected: {_movementType},
                      onSelectionChanged: (Set<MovementType> selection) {
                        setState(() => _movementType = selection.first);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity *',
                        hintText: 'Enter quantity for all selected items',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Reason (optional)',
                        hintText: 'e.g., Received shipment #123',
                      ),
                      onChanged: (value) => _reason = value,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Item selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Select Items (${_selectedItemIds.length} selected)',
                  style: AppTextStyles.labelLarge,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    itemsAsync.whenData((items) {
                      setState(() {
                        if (_selectedItemIds.length == items.length) {
                          _selectedItemIds.clear();
                        } else {
                          _selectedItemIds.addAll(items.map((i) => i.id));
                        }
                      });
                    });
                  },
                  child: Text(
                    _selectedItemIds.length == (itemsAsync.value?.length ?? 0)
                        ? 'Deselect All'
                        : 'Select All',
                  ),
                ),
              ],
            ),
          ),

          // Item list
          Expanded(
            child: itemsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const EmptyState(
                    icon: AppIcons.inventory,
                    title: 'No items available',
                    subtitle: 'Add items before doing batch operations.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = _selectedItemIds.contains(item.id);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 4),
                      child: CheckboxListTile(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedItemIds.add(item.id);
                            } else {
                              _selectedItemIds.remove(item.id);
                            }
                          });
                        },
                        title: Text(item.name, style: AppTextStyles.body),
                        subtitle: Text(
                          'SKU: ${item.sku} · Current: ${item.quantity} ${item.unit.abbreviation}',
                          style: AppTextStyles.caption,
                        ),
                        secondary: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: item.isOutOfStock
                                ? Colors.red.withValues(alpha: 0.1)
                                : item.isLowStock
                                ? Colors.orange.withValues(alpha: 0.1)
                                : Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${item.quantity}',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: item.isOutOfStock
                                    ? Colors.red
                                    : item.isLowStock
                                    ? Colors.orange
                                    : Colors.green,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),

          // Bottom action bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _selectedItemIds.isEmpty || _isProcessing
                      ? null
                      : _applyBatch,
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(AppIcons.import),
                  label: Text(
                    _isProcessing
                        ? 'Processing...'
                        : 'Apply to ${_selectedItemIds.length} items',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _applyBatch() async {
    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      showPremiumSnackBar(
        context,
        message: 'Please enter a valid quantity',
        icon: AppIcons.error,
      );
      return;
    }

    if (_selectedItemIds.isEmpty) {
      showPremiumSnackBar(
        context,
        message: 'Please select at least one item',
        icon: AppIcons.error,
      );
      return;
    }

    setState(() => _isProcessing = true);

    int successCount = 0;
    int failCount = 0;

    for (final itemId in _selectedItemIds) {
      int adjustment;
      if (_movementType == MovementType.stockIn) {
        adjustment = quantity;
      } else {
        adjustment = -quantity;
      }

      final result = await ItemRepository.instance.adjustStock(
        itemId,
        adjustment,
        reason: _reason,
      );

      switch (result) {
        case Ok<Item, AppError>():
          successCount++;
        case Err<Item, AppError>():
          failCount++;
      }
    }

    setState(() => _isProcessing = false);

    if (!mounted) return;

    // Invalidate all relevant providers
    ref.invalidate(itemsProvider);
    ref.invalidate(filteredItemsProvider);
    ref.invalidate(lowStockItemsProvider);
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(movementSummaryProvider);
    ref.invalidate(recentMovementsProvider);

    if (failCount == 0) {
      showPremiumSnackBar(
        context,
        message: 'Updated $successCount items successfully',
        icon: AppIcons.success,
      );
      context.pop();
    } else {
      showPremiumSnackBar(
        context,
        message: '$successCount updated, $failCount failed',
        icon: AppIcons.warning,
      );
    }
  }
}
