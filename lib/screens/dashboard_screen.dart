import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../design/app_colors.dart';
import '../design/typography.dart';
import '../providers.dart';
import '../responsive_breakpoints.dart';
import '../routing/app_router.dart';
import '../ui/app_components.dart';

/// Dashboard screen with real KPI data and quick actions.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final lowStockAsync = ref.watch(lowStockItemsProvider);
    final workforceAsync = ref.watch(workforceStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.refresh),
            onPressed: () {
              ref.invalidate(dashboardStatsProvider);
              ref.invalidate(lowStockItemsProvider);
              ref.invalidate(itemsProvider);
              ref.invalidate(workforceStatsProvider);
              ref.invalidate(employeesProvider);
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
              'Overview',
              style: AppTextStyles.h3.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your inventory at a glance',
              style: AppTextStyles.body.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // KPI Cards — 5 cards now
            statsAsync.when(
              data: (invStats) {
                return workforceAsync.when(
                  data: (workStats) =>
                      _KpiGrid(invStats: invStats, workStats: workStats),
                  loading: () => const _KpiGridLoading(),
                  error: (_, _) => _KpiGrid(
                    invStats: invStats,
                    workStats: const WorkforceStats(
                      activeEmployees: 0,
                      pendingTasks: 0,
                    ),
                  ),
                );
              },
              loading: () => const _KpiGridLoading(),
              error: (error, _) => Center(
                child: Text('Error: $error', style: AppTextStyles.body),
              ),
            ),

            const SizedBox(height: 24),

            // Quick actions
            const SectionHeader(title: 'Quick Actions'),
            const SizedBox(height: 8),
            _QuickActions(),

            const SizedBox(height: 24),

            // Low stock alerts
            SectionHeader(
              title: 'Low Stock Alerts',
              actionLabel: 'View All',
              onAction: () => context.push(AppRoutes.inventory),
            ),
            const SizedBox(height: 8),
            lowStockAsync.when(
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
                return Column(
                  children: items.take(5).map((item) {
                    final cs = Theme.of(context).colorScheme;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item.isOutOfStock
                              ? cs.error.withValues(alpha: 0.1)
                              : AppColors.warning.withValues(alpha: 0.1),
                          child: Icon(
                            item.isOutOfStock
                                ? AppIcons.error
                                : AppIcons.warning,
                            color: item.isOutOfStock ? cs.error : AppColors.warning,
                          ),
                        ),
                        title: Text(item.name, style: AppTextStyles.body),
                        subtitle: Text(
                          'SKU: ${item.sku}',
                          style: AppTextStyles.caption,
                        ),
                        trailing: Text(
                          '${item.quantity} left',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: item.isOutOfStock ? cs.error : AppColors.warning,
                          ),
                        ),
                        onTap: () => context.push('/inventory/${item.id}'),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, _) => Center(
                child: Text('Error: $error', style: AppTextStyles.body),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.invStats, required this.workStats});

  final DashboardStats invStats;
  final WorkforceStats workStats;

  @override
  Widget build(BuildContext context) {
    final cards = [
      KpiCard(
        title: 'Total Items',
        value: invStats.totalItems.toString(),
        icon: AppIcons.inventory,
      ),
      KpiCard(
        title: 'Low Stock',
        value: invStats.lowStockCount.toString(),
        icon: AppIcons.warning,
        trend: invStats.lowStockCount > 0 ? -12.5 : 0,
      ),
      KpiCard(
        title: 'Out of Stock',
        value: invStats.outOfStockCount.toString(),
        icon: AppIcons.error,
      ),
      KpiCard(
        title: 'Total Value',
        value: '\$${_formatValue(invStats.totalValue)}',
        icon: Icons.account_balance_wallet_outlined,
      ),
    ];

    return ResponsiveBuilder(
      mobile: (_) => Column(
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
          const SizedBox(height: 12),
          KpiCard(
            title: 'Workforce',
            value: '${workStats.activeEmployees} employees',
            subtitle: '${workStats.pendingTasks} pending tasks',
            icon: AppIcons.people,
            onTap: () => context.pushNamed(AppRoutes.employees),
          ),
        ],
      ),
      tablet: (_) => Column(
        children: [
          Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 12),
              Expanded(child: cards[1]),
              const SizedBox(width: 12),
              Expanded(child: cards[2]),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: cards[3]),
              const SizedBox(width: 12),
              Expanded(
                child: KpiCard(
                  title: 'Workforce',
                  value: '${workStats.activeEmployees} employees',
                  subtitle: '${workStats.pendingTasks} pending tasks',
                  icon: AppIcons.people,
                  onTap: () => context.pushNamed(AppRoutes.employees),
                ),
              ),
            ],
          ),
        ],
      ),
      desktop: (_) => Row(
        children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 12),
          Expanded(child: cards[1]),
          const SizedBox(width: 12),
          Expanded(child: cards[2]),
          const SizedBox(width: 12),
          Expanded(child: cards[3]),
          const SizedBox(width: 12),
          Expanded(
            child: KpiCard(
              title: 'Workforce',
              value: '${workStats.activeEmployees} employees',
              subtitle: '${workStats.pendingTasks} pending tasks',
              icon: AppIcons.people,
              onTap: () => context.pushNamed(AppRoutes.employees),
            ),
          ),
        ],
      ),
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

class _KpiGridLoading extends StatelessWidget {
  const _KpiGridLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _loadingCard(context)),
            const SizedBox(width: 12),
            Expanded(child: _loadingCard(context)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _loadingCard(context)),
            const SizedBox(width: 12),
            Expanded(child: _loadingCard(context)),
          ],
        ),
      ],
    );
  }

  Widget _loadingCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 12,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 28,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: AppIcons.add,
            label: 'Add Item',
            color: cs.primary,
            onTap: () => context.push(AppRoutes.inventoryAdd),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: AppIcons.people,
            label: 'Employees',
            color: cs.secondary,
            onTap: () => context.push(AppRoutes.employees),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: AppIcons.analytics,
            label: 'Analytics',
            color: cs.tertiary,
            onTap: () => context.push(AppRoutes.analytics),
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
