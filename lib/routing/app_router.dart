import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../design/typography.dart';
import '../providers.dart';
import '../screens/dashboard_screen.dart';
import '../screens/inventory_list_screen.dart';
import '../screens/item_form_screen.dart';
import '../screens/item_detail_screen.dart';
import '../screens/employees_list_screen.dart';
import '../screens/employee_form_screen.dart';
import '../screens/employee_detail_screen.dart';
import '../screens/analytics_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/settings_screen.dart';
import 'app_scaffold.dart';

/// App route paths.
class AppRoutes {
  AppRoutes._();

  static const String dashboard = '/';
  static const String inventory = '/inventory';
  static const String inventoryAdd = '/inventory/add';
  static const String categories = '/categories';
  static const String employees = '/employees';
  static const String employeeAdd = '/employees/add';
  static const String analytics = '/analytics';
  static const String reports = '/reports';
  static const String settings = '/settings';
}

/// Maps a GoRouter location path to the index in navItems.
int locationToNavIndex(String location) {
  if (location.startsWith(AppRoutes.inventory)) {
    return 1;
  }
  if (location.startsWith(AppRoutes.employees)) {
    return 2;
  }
  if (location.startsWith(AppRoutes.analytics)) {
    return 3;
  }
  if (location.startsWith(AppRoutes.settings)) {
    return 4;
  }
  return 0; // dashboard or unknown
}

/// GoRouter configuration for nVentory with ShellRoute for adaptive navigation.
final appRouter = GoRouter(
  initialLocation: AppRoutes.dashboard,
  debugLogDiagnostics: true,
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return AppScaffoldWithSync(child: child);
      },
      routes: [
        // Dashboard (home)
        GoRoute(
          path: AppRoutes.dashboard,
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        // Inventory list
        GoRoute(
          path: AppRoutes.inventory,
          name: 'inventory',
          builder: (context, state) => const InventoryListScreen(),
          routes: [
            GoRoute(
              path: 'add',
              name: 'inventory-add',
              builder: (context, state) => const ItemFormScreen(),
            ),
            GoRoute(
              path: ':id',
              name: 'inventory-detail',
              builder: (context, state) {
                final id = state.pathParameters['id'] ?? '';
                return ItemDetailScreen(itemId: id);
              },
            ),
          ],
        ),
        // Categories
        GoRoute(
          path: AppRoutes.categories,
          name: 'categories',
          builder: (context, state) => const _PlaceholderScreen(
            title: 'Categories',
            icon: AppIcons.category,
          ),
        ),
        // Employees list
        GoRoute(
          path: AppRoutes.employees,
          name: 'employees',
          builder: (context, state) => const EmployeesListScreen(),
          routes: [
            GoRoute(
              path: 'add',
              name: 'employee-add',
              builder: (context, state) => const EmployeeFormScreen(),
            ),
            GoRoute(
              path: ':id',
              name: 'employee-detail',
              builder: (context, state) {
                final id = state.pathParameters['id'] ?? '';
                return EmployeeDetailScreen(employeeId: id);
              },
            ),
          ],
        ),
        // Analytics
        GoRoute(
          path: AppRoutes.analytics,
          name: 'analytics',
          builder: (context, state) => const AnalyticsScreen(),
        ),
        // Reports
        GoRoute(
          path: AppRoutes.reports,
          name: 'reports',
          builder: (context, state) => const ReportsScreen(),
        ),
        // Settings
        GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);

/// Wrapper that syncs the navigation index provider with the current route.
class AppScaffoldWithSync extends StatefulWidget {
  const AppScaffoldWithSync({super.key, required this.child});

  final Widget child;

  @override
  State<AppScaffoldWithSync> createState() => _AppScaffoldWithSyncState();
}

class _AppScaffoldWithSyncState extends State<AppScaffoldWithSync> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync the navigation highlight with the current location.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final location = GoRouterState.of(context).uri.toString();
      final index = locationToNavIndex(location);
      // Use read (not watch) to avoid rebuild loops.
      final container = ProviderScope.containerOf(context);
      final current = container.read(navigationIndexProvider);
      if (current != index) {
        container.read(navigationIndexProvider.notifier).state = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(child: widget.child);
  }
}

/// Placeholder screen for routes not yet implemented.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: cs.outline),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.h3.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon...',
              style: AppTextStyles.body.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
