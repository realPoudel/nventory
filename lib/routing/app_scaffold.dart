import 'package:flutter/foundation.dart';
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
];

/// Adaptive scaffold — Bottom Nav on Mobile, Navigation Rail on Tablet/Desktop.
class AppScaffold extends ConsumerWidget {
  const AppScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final isSettingsActive = currentIndex >= navItems.length;

    // Mobile: Bottom navigation bar
    if (context.isMobile) {
      return Scaffold(
        body: SafeArea(child: child),
        bottomNavigationBar: NavigationBar(
          selectedIndex: isSettingsActive ? 0 : currentIndex,
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

    // Tablet: Navigation rail (icons + labels, compact)
    if (context.isTablet) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: isSettingsActive ? null : currentIndex,
              onDestinationSelected: (index) {
                ref.read(navigationIndexProvider.notifier).state = index;
                context.go(navItems[index].path);
              },
              labelType: NavigationRailLabelType.selected,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _AppLogo(),
              ),
              trailing: kIsWeb
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: IconButton(
                        icon: const Icon(Icons.account_circle_outlined, size: 28),
                        onPressed: () => context.go(AppRoutes.settings),
                      ),
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
            VerticalDivider(thickness: 1, width: 1, color: Theme.of(context).colorScheme.outlineVariant),
            Expanded(child: child),
          ],
        ),
      );
    }

    // Desktop: Navigation rail (icon-only, minimal)
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: isSettingsActive ? null : currentIndex,
            onDestinationSelected: (index) {
              ref.read(navigationIndexProvider.notifier).state = index;
              context.go(navItems[index].path);
            },
            labelType: NavigationRailLabelType.none,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: _AppLogo(),
            ),
            trailing: kIsWeb
                ? null
                : Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: IconButton(
                      icon: const Icon(Icons.account_circle_outlined, size: 28),
                      onPressed: () => context.go(AppRoutes.settings),
                    ),
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
          VerticalDivider(thickness: 1, width: 1, color: Theme.of(context).colorScheme.outlineVariant),
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
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Center(
        child: Text(
          'nV',
          style: AppTextStyles.labelSmall.copyWith(
            color: cs.onPrimaryContainer,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
// NAVIGATION RAIL — COMMENTED OUT (PRESERVED FOR LATER)
// ============================================================
