import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../persistence/hive_manager.dart';
import '../persistence/safe_hive.dart';
import '../providers.dart';
import '../screens/dashboard_screen.dart';
import '../screens/inventory_list_screen.dart';
import '../screens/item_form_screen.dart';
import '../screens/item_detail_screen.dart';
import '../screens/item_history_screen.dart';
import '../screens/batch_stock_screen.dart';
import '../screens/employees_list_screen.dart';
import '../screens/employee_form_screen.dart';
import '../screens/employee_detail_screen.dart';
import '../screens/analytics_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/company_registration_screen.dart';
import 'app_scaffold.dart';

/// App route paths.
class AppRoutes {
  AppRoutes._();

  static const String dashboard = '/';
  static const String inventory = '/inventory';
  static const String inventoryAdd = '/inventory/add';
  static const String employees = '/employees';
  static const String employeeAdd = '/employees/add';
  static const String analytics = '/analytics';
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String companySetup = '/setup';
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
  initialLocation: AppRoutes.companySetup,
  redirect: (context, state) {
    // Allow the setup screen to always be accessible
    if (state.matchedLocation == AppRoutes.companySetup) {
      return null;
    }
    // Check onboarding status synchronously from Hive
    // This runs on every navigation — Hive box is already open by main()
    try {
      final box = HiveManager.getBoxSync(HiveBoxes.settings);
      if (box != null) {
        final hasCompletedOnboarding =
            box.safeGet<bool>('has_completed_onboarding') ?? false;
        if (!hasCompletedOnboarding) {
          return AppRoutes.companySetup;
        }
      }
    } catch (_) {
      // If Hive isn't ready yet, allow navigation (app init provider handles it)
    }
    return null;
  },
  routes: [
    // Company Setup (outside shell, no nav bar)
    GoRoute(
      path: AppRoutes.companySetup,
      name: 'company-setup',
      builder: (context, state) => const CompanyRegistrationScreen(),
    ),
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
              path: 'batch',
              name: 'inventory-batch',
              builder: (context, state) => const BatchStockScreen(),
            ),
            GoRoute(
              path: ':id',
              name: 'inventory-detail',
              builder: (context, state) {
                final id = state.pathParameters['id'] ?? '';
                return ItemDetailScreen(itemId: id);
              },
              routes: [
                GoRoute(
                  path: 'history',
                  name: 'inventory-history',
                  builder: (context, state) {
                    final id = state.pathParameters['id'] ?? '';
                    return ItemHistoryScreen(itemId: id);
                  },
                ),
              ],
            ),
          ],
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
class AppScaffoldWithSync extends ConsumerStatefulWidget {
  const AppScaffoldWithSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppScaffoldWithSync> createState() =>
      _AppScaffoldWithSyncState();
}

class _AppScaffoldWithSyncState extends ConsumerState<AppScaffoldWithSync> {
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
