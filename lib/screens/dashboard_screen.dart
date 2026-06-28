import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../design/typography.dart';
import '../providers.dart';
import '../responsive_breakpoints.dart';
import '../routing/app_router.dart';
import '../ui/app_components.dart';
import '../ui/hero_section.dart';

/// Dashboard screen with real KPI data and quick actions.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final statsAsync = ref.watch(dashboardStatsProvider);
    final lowStockAsync = ref.watch(lowStockItemsProvider);
    final workforceAsync = ref.watch(workforceStatsProvider);

    return Scaffold(
      body: ConstrainedContent(
        maxWidth: 1200,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: context.responsivePadding,
            right: context.responsivePadding,
            bottom: context.responsivePadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section
              HeroSection(
                title: 'Overview',
                subtitle: 'Your inventory at a glance',
                showLogo: true,
                showDate: true,
                stats: [
                  HeroStat(
                    label: 'Items',
                    value: statsAsync.value?.totalItems.toString() ?? '—',
                    color: cs.primary,
                  ),
                  HeroStat(
                    label: 'Low Stock',
                    value: statsAsync.value?.lowStockCount.toString() ?? '—',
                    color: const Color(0xFFFF9800),
                  ),
                  HeroStat(
                    label: 'Out of Stock',
                    value: statsAsync.value?.outOfStockCount.toString() ?? '—',
                    color: cs.error,
                  ),
                  HeroStat(
                    label: 'Workforce',
                    value:
                        workforceAsync.value?.activeEmployees.toString() ?? '—',
                    color: cs.secondary,
                  ),
                ],
              ),

              const SizedBox(height: 8),

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
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: cs.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(AppIcons.success, size: 20, color: cs.primary),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'All items are well stocked!',
                                style: AppTextStyles.body,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: items.take(5).map((item) {
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: cs.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        child: InkWell(
                          onTap: () => context.push('/inventory/${item.id}'),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: item.isOutOfStock
                                        ? cs.error
                                        : const Color(0xFFFF9800),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: AppTextStyles.body.copyWith(
                                          color: cs.onSurface,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'SKU: ${item.sku}',
                                        style: AppTextStyles.labelSmall
                                            .copyWith(
                                              color: cs.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${item.quantity} left',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: item.isOutOfStock
                                        ? cs.error
                                        : const Color(0xFFFF9800),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
