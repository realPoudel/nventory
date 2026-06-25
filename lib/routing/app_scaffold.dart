import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../design/typography.dart';
import '../providers.dart';
import '../responsive_breakpoints.dart';
import 'app_router.dart';

/// Navigation item data.
class NavItem {
  const NavItem({
    required this.path,
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// Main navigation items.
const navItems = [
  NavItem(
    path: AppRoutes.dashboard,
    label: 'Dashboard',
    icon: AppIcons.dashboard,
    activeIcon: AppIcons.dashboardFilled,
  ),
  NavItem(
    path: AppRoutes.inventory,
    label: 'Inventory',
    icon: AppIcons.inventory,
    activeIcon: AppIcons.inventoryFilled,
  ),
  NavItem(
    path: AppRoutes.employees,
    label: 'Employees',
    icon: AppIcons.people,
    activeIcon: AppIcons.peopleFilled,
  ),
  NavItem(
    path: AppRoutes.analytics,
    label: 'Analytics',
    icon: AppIcons.analytics,
    activeIcon: AppIcons.analyticsFilled,
  ),
  NavItem(
    path: AppRoutes.settings,
    label: 'Settings',
    icon: AppIcons.settings,
    activeIcon: AppIcons.settingsFilled,
  ),
];

/// Adaptive scaffold that switches between bottom nav and navigation rail.
class AppScaffold extends ConsumerWidget {
  const AppScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final cs = Theme.of(context).colorScheme;

    // Mobile: Bottom navigation bar
    if (context.isMobile) {
      return Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            ref.read(navigationIndexProvider.notifier).state = index;
            context.go(navItems[index].path);
          },
          destinations: [
            for (final item in navItems)
              NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.activeIcon),
                label: item.label,
              ),
          ],
        ),
      );
    }

    // Tablet/Desktop: Navigation rail
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              ref.read(navigationIndexProvider.notifier).state = index;
              context.go(navItems[index].path);
            },
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: _AppLogo(),
            ),
            destinations: [
              for (final item in navItems)
                NavigationRailDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.activeIcon),
                  label: Text(item.label),
                ),
            ],
          ),
          VerticalDivider(thickness: 1, width: 1, color: cs.outlineVariant),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _AppLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'nV',
          style: AppTextStyles.h4.copyWith(color: cs.onPrimaryContainer),
        ),
      ),
    );
  }
}
