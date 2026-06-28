import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/errors.dart';
import '../core/result.dart';
import '../design/typography.dart';
import '../models/item_model.dart';
import '../models/stock_movement_model.dart';
import '../providers.dart';
import '../ui/app_components.dart';

/// Full stock movement history for a single item.
class ItemHistoryScreen extends ConsumerWidget {
  const ItemHistoryScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(itemByIdProvider(itemId));
    final movementsAsync = ref.watch(movementsByItemProvider(itemId));

    return Scaffold(
      appBar: AppBar(
        title: itemAsync.when(
          data: (item) => Text(item?.name ?? 'Item History'),
          loading: () => const Text('Item History'),
          error: (_, _) => const Text('Item History'),
        ),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.refresh),
            onPressed: () {
              ref.invalidate(movementsByItemProvider(itemId));
            },
          ),
        ],
      ),
      body: movementsAsync.when(
        data: (movements) {
          if (movements.isEmpty) {
            return EmptyState(
              icon: AppIcons.inventory,
              title: 'No stock history',
              subtitle: 'Stock movements for this item will appear here.',
              actionLabel: 'Refresh',
              onAction: () {
                ref.invalidate(movementsByItemProvider(itemId));
              },
            );
          }
          return _HistoryContent(movements: movements, itemAsync: itemAsync);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Error: $error', style: AppTextStyles.body)),
      ),
    );
  }
}

class _HistoryContent extends StatelessWidget {
  const _HistoryContent({required this.movements, required this.itemAsync});

  final List<StockMovement> movements;
  final AsyncValue<dynamic> itemAsync;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Group movements by date
    final grouped = <String, List<StockMovement>>{};
    for (final m in movements) {
      final dateKey = _formatDateKey(m.createdAt);
      grouped.update(dateKey, (list) => list..add(m), ifAbsent: () => [m]);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary card
          _SummaryCard(movements: movements, cs: cs),
          const SizedBox(height: 24),

          // Timeline
          ...grouped.entries.expand((entry) {
            return [
              _DateHeader(dateKey: entry.key, cs: cs),
              ...entry.value.map((m) => _MovementTile(movement: m, cs: cs)),
              const SizedBox(height: 8),
            ];
          }),
        ],
      ),
    );
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.movements, required this.cs});

  final List<StockMovement> movements;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final stockIn = movements
        .where((m) => m.type == MovementType.stockIn)
        .fold<int>(0, (sum, m) => sum + m.quantity);
    final stockOut = movements
        .where((m) => m.type == MovementType.stockOut)
        .fold<int>(0, (sum, m) => sum + m.quantity);
    final adjustments = movements
        .where((m) => m.type == MovementType.adjustment)
        .length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Summary', style: AppTextStyles.labelLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SummaryStat(
                    label: 'Stock In',
                    value: stockIn.toString(),
                    color: cs.primary,
                    icon: Icons.add_circle_outline,
                  ),
                ),
                Expanded(
                  child: _SummaryStat(
                    label: 'Stock Out',
                    value: stockOut.toString(),
                    color: cs.error,
                    icon: Icons.remove_circle_outline,
                  ),
                ),
                Expanded(
                  child: _SummaryStat(
                    label: 'Adjustments',
                    value: adjustments.toString(),
                    color: Colors.orange,
                    icon: Icons.tune,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${movements.length} total movements',
              style: AppTextStyles.caption.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.h4.copyWith(color: color)),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.dateKey, required this.cs});

  final String dateKey;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateDay = DateTime(date.year, date.month, date.day);

    final label = dateDay == today
        ? 'Today'
        : dateDay == yesterday
        ? 'Yesterday'
        : _formatDateLong(date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 12),
      child: Text(
        label,
        style: AppTextStyles.labelLarge.copyWith(color: cs.onSurfaceVariant),
      ),
    );
  }

  String _formatDateLong(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _MovementTile extends ConsumerWidget {
  const _MovementTile({required this.movement, required this.cs});

  final StockMovement movement;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _getTypeColor(movement.type);
    final icon = _getTypeIcon(movement.type);
    final sign = movement.type == MovementType.stockIn ? '+' : '-';
    final isUndo = movement.reference.startsWith('UNDO-');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Type indicator
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            movement.type.label,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$sign${movement.quantity}',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: color,
                          ),
                        ),
                        if (movement.reference.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              movement.reference,
                              style: AppTextStyles.caption,
                            ),
                          ),
                        ],
                        if (isUndo) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'UNDO',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.purple,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${movement.previousQuantity} → ${movement.newQuantity}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    if (movement.reason.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        movement.reason,
                        style: AppTextStyles.caption.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (movement.notes.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        movement.notes,
                        style: AppTextStyles.caption.copyWith(
                          color: cs.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Time + Undo button
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTime(movement.createdAt),
                    style: AppTextStyles.caption.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  if (!isUndo && movement.type != MovementType.initial) ...[
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 28,
                      child: TextButton.icon(
                        onPressed: () => _undoMovement(context, ref),
                        icon: const Icon(Icons.undo, size: 14),
                        label: const Text(
                          'Undo',
                          style: TextStyle(fontSize: 11),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 28),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _undoMovement(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Undo Movement',
      message:
          'This will reverse the ${movement.type.label.toLowerCase()} of ${movement.quantity} units. Continue?',
      confirmLabel: 'Undo',
      cancelLabel: 'Cancel',
    );
    if (!confirmed || !context.mounted) {
      return;
    }

    final result = await ref
        .read(itemCrudProvider.notifier)
        .undoMovement(movement.id);

    switch (result) {
      case Ok<Item, AppError>():
        ref.invalidate(movementsByItemProvider(movement.itemId));
        ref.invalidate(itemByIdProvider(movement.itemId));
        ref.invalidate(itemsProvider);
        ref.invalidate(filteredItemsProvider);
        ref.invalidate(lowStockItemsProvider);
        ref.invalidate(dashboardStatsProvider);
        if (context.mounted) {
          showPremiumToast(
            context,
            message: 'Movement undone',
            type: ToastType.success,
          );
        }
      case Err<Item, AppError>(:final error):
        if (context.mounted) {
          showPremiumToast(
            context,
            message: error.message,
            type: ToastType.error,
          );
        }
    }
  }

  Color _getTypeColor(MovementType type) {
    return switch (type) {
      MovementType.stockIn => const Color(0xFF388E3C),
      MovementType.stockOut => const Color(0xFFD32F2F),
      MovementType.adjustment => Colors.orange,
      MovementType.initial => Colors.blue,
    };
  }

  IconData _getTypeIcon(MovementType type) {
    return switch (type) {
      MovementType.stockIn => Icons.add_circle_outline,
      MovementType.stockOut => Icons.remove_circle_outline,
      MovementType.adjustment => Icons.tune,
      MovementType.initial => Icons.flag_outlined,
    };
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
