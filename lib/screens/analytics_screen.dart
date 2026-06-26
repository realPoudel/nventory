import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../design/app_colors.dart';
import '../design/typography.dart';
import '../models/item_model.dart';
import '../models/category_model.dart';
import '../models/stock_movement_model.dart';
import '../models/employee_model.dart';
import '../providers.dart';
import '../routing/app_router.dart';
import '../responsive_breakpoints.dart';
import '../ui/app_components.dart';

/// Analytics screen with stock movement trends, category breakdown, and KPIs.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final movementsAsync = ref.watch(recentMovementsProvider);
    final employeesAsync = ref.watch(employeesProvider);
    final workforceStatsAsync = ref.watch(workforceStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.refresh),
            onPressed: () {
              ref.invalidate(itemsProvider);
              ref.invalidate(categoriesProvider);
              ref.invalidate(recentMovementsProvider);
              ref.invalidate(employeesProvider);
              ref.invalidate(workforceStatsProvider);
              ref.invalidate(movementSummaryProvider);
            },
          ),
        ],
      ),
      body: ConstrainedContent(
        maxWidth: 1200,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.responsivePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inventory Analytics',
                style: AppTextStyles.h3.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Track performance and trends',
                style: AppTextStyles.body.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              // Inventory summary cards
              const SectionHeader(title: 'Inventory Summary'),
              const SizedBox(height: 8),
              itemsAsync.when(
                data: (items) => _InventorySummary(items: items),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, _) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // Category breakdown + Movement summary side-by-side on tablet/desktop
              ResponsiveBuilder(
                mobile: (_) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Stock by Category'),
                    const SizedBox(height: 8),
                    categoriesAsync.when(
                      data: (categories) => itemsAsync.when(
                        data: (items) => _CategoryBreakdown(
                          items: items,
                          categories: categories,
                        ),
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 24),
                    const SectionHeader(title: 'Stock Movement'),
                    const SizedBox(height: 8),
                    const _MovementSummaryCard(),
                  ],
                ),
                tablet: (_) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionHeader(title: 'Stock by Category'),
                              const SizedBox(height: 8),
                              categoriesAsync.when(
                                data: (categories) => itemsAsync.when(
                                  data: (items) => _CategoryBreakdown(
                                    items: items,
                                    categories: categories,
                                  ),
                                  loading: () => const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(32),
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  error: (_, _) => const SizedBox.shrink(),
                                ),
                                loading: () => const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32),
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                error: (_, _) => const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SectionHeader(title: 'Stock Movement'),
                              SizedBox(height: 8),
                              _MovementSummaryCard(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                desktop: (_) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionHeader(title: 'Stock by Category'),
                              const SizedBox(height: 8),
                              categoriesAsync.when(
                                data: (categories) => itemsAsync.when(
                                  data: (items) => _CategoryBreakdown(
                                    items: items,
                                    categories: categories,
                                  ),
                                  loading: () => const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(32),
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  error: (_, _) => const SizedBox.shrink(),
                                ),
                                loading: () => const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32),
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                error: (_, _) => const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SectionHeader(title: 'Stock Movement'),
                              SizedBox(height: 8),
                              _MovementSummaryCard(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Recent activity
              SectionHeader(
                title: 'Recent Activity',
                actionLabel: 'Reports',
                onAction: () => context.push(AppRoutes.reports),
              ),
              const SizedBox(height: 8),
              movementsAsync.when(
                data: (movements) {
                  if (movements.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'No recent activity',
                            style: AppTextStyles.body.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: movements.map((m) {
                      return _MovementTile(movement: m);
                    }).toList(),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, _) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // Workforce summary
              const SectionHeader(title: 'Workforce'),
              const SizedBox(height: 8),
              employeesAsync.when(
                data: (employees) => workforceStatsAsync.when(
                  data: (stats) =>
                      _WorkforceSummary(employees: employees, stats: stats),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InventorySummary extends StatelessWidget {
  const _InventorySummary({required this.items});

  final List<Item> items;

  @override
  Widget build(BuildContext context) {
    final totalValue = items.fold<double>(
      0,
      (sum, i) => sum + i.inventoryValue,
    );
    final totalQuantity = items.fold<int>(0, (sum, i) => sum + i.quantity);
    final lowStock = items.where((i) => i.isLowStock).length;
    final outOfStock = items.where((i) => i.isOutOfStock).length;

    final cards = [
      KpiCard(
        title: 'Total Value',
        value: '\$${_formatValue(totalValue)}',
        icon: Icons.account_balance_wallet_outlined,
      ),
      KpiCard(
        title: 'Total Units',
        value: totalQuantity.toString(),
        icon: AppIcons.inventory,
      ),
      KpiCard(
        title: 'Low Stock',
        value: lowStock.toString(),
        icon: AppIcons.warning,
      ),
      KpiCard(
        title: 'Out of Stock',
        value: outOfStock.toString(),
        icon: AppIcons.error,
      ),
    ];

    // On mobile, use 2-column grid; on tablet/desktop, use 4-column row
    if (context.isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 12),
              Expanded(child: cards[1]),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: cards[2]),
              const SizedBox(width: 12),
              Expanded(child: cards[3]),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: cards[i]),
        ],
      ],
    );
  }

  String _formatValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({required this.items, required this.categories});

  final List<Item> items;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Build category stats
    final categoryStats = <String, _CategoryStat>{};
    int uncategorizedCount = 0;
    double uncategorizedValue = 0;

    for (final item in items) {
      if (item.categoryId == null) {
        uncategorizedCount++;
        uncategorizedValue += item.inventoryValue;
        continue;
      }
      final cat = categories.where((c) => c.id == item.categoryId).firstOrNull;
      if (cat == null) {
        continue;
      }
      categoryStats.update(
        cat.id,
        (existing) => _CategoryStat(
          name: cat.name,
          itemCount: existing.itemCount + 1,
          totalValue: existing.totalValue + item.inventoryValue,
          color: cat.color,
        ),
        ifAbsent: () => _CategoryStat(
          name: cat.name,
          itemCount: 1,
          totalValue: item.inventoryValue,
          color: cat.color,
        ),
      );
    }

    final allStats = categoryStats.values.toList()
      ..sort((a, b) => b.totalValue.compareTo(a.totalValue));

    if (uncategorizedCount > 0) {
      allStats.add(
        _CategoryStat(
          name: 'Uncategorized',
          itemCount: uncategorizedCount,
          totalValue: uncategorizedValue,
          color: 0xFF9E9E9E,
        ),
      );
    }

    if (allStats.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No data available',
              style: AppTextStyles.body.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: allStats.map((stat) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Color(stat.color),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stat.name,
                          style: AppTextStyles.body.copyWith(
                            color: cs.onSurface,
                          ),
                        ),
                        Text(
                          '${stat.itemCount} items · \$${stat.totalValue.toStringAsFixed(2)}',
                          style: AppTextStyles.caption.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Simple bar visualization
                  SizedBox(
                    width: 80,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value:
                            stat.itemCount /
                            (allStats.first.itemCount > 0
                                ? allStats.first.itemCount
                                : 1),
                        backgroundColor: cs.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(Color(stat.color)),
                        minHeight: 8,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CategoryStat {
  const _CategoryStat({
    required this.name,
    required this.itemCount,
    required this.totalValue,
    required this.color,
  });

  final String name;
  final int itemCount;
  final double totalValue;
  final int color;
}

class _MovementSummaryCard extends ConsumerWidget {
  const _MovementSummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(movementSummaryProvider);

    return summaryAsync.when(
      data: (summary) {
        final cs = Theme.of(context).colorScheme;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _MovementStat(
                      label: 'Stock In',
                      value: summary.stockIn.toString(),
                      color: cs.primary,
                      icon: Icons.arrow_downward,
                    ),
                    _MovementStat(
                      label: 'Stock Out',
                      value: summary.stockOut.toString(),
                      color: cs.error,
                      icon: Icons.arrow_upward,
                    ),
                    _MovementStat(
                      label: 'Adjustments',
                      value: summary.adjustments.toString(),
                      color: AppColors.warning,
                      icon: Icons.tune,
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

class _MovementStat extends StatelessWidget {
  const _MovementStat({
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
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.h4.copyWith(color: color)),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _MovementTile extends StatelessWidget {
  const _MovementTile({required this.movement});

  final StockMovement movement;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isIn = movement.type == MovementType.stockIn;
    final color = isIn ? cs.primary : cs.error;
    final icon = isIn ? Icons.add : Icons.remove;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(
          movement.itemName,
          style: AppTextStyles.body.copyWith(color: cs.onSurface),
        ),
        subtitle: Text(
          '${movement.type.label} · ${movement.quantity} units${movement.reason.isNotEmpty ? " · ${movement.reason}" : ""}',
          style: AppTextStyles.caption.copyWith(color: cs.onSurfaceVariant),
        ),
        trailing: Text(
          _formatTime(movement.createdAt),
          style: AppTextStyles.caption.copyWith(color: cs.onSurfaceVariant),
        ),
        onTap: () => context.push('/inventory/${movement.itemId}/history'),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    return '${date.month}/${date.day}';
  }
}

class _WorkforceSummary extends StatelessWidget {
  const _WorkforceSummary({required this.employees, required this.stats});

  final List<Employee> employees;
  final WorkforceStats stats;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final roleCounts = <EmployeeRole, int>{};
    for (final emp in employees) {
      roleCounts.update(emp.role, (c) => c + 1, ifAbsent: () => 1);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _WorkforceStat(
                    label: 'Active Employees',
                    value: stats.activeEmployees.toString(),
                    color: cs.primary,
                    icon: AppIcons.people,
                  ),
                ),
                Expanded(
                  child: _WorkforceStat(
                    label: 'Pending Tasks',
                    value: stats.pendingTasks.toString(),
                    color: AppColors.warning,
                    icon: Icons.assignment_outlined,
                  ),
                ),
              ],
            ),
            if (roleCounts.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              ...roleCounts.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        entry.key.label,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          entry.value.toString(),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _WorkforceStat extends StatelessWidget {
  const _WorkforceStat({
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
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.h4.copyWith(color: color)),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
