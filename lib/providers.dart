import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../persistence/hive_manager.dart';
import '../persistence/safe_hive.dart';
import '../persistence/write_ahead_log.dart';
import '../models/item_model.dart';
import '../models/category_model.dart';
import '../models/employee_model.dart';
import '../models/task_model.dart';
import '../models/repositories.dart';
import '../models/employee_repository.dart';
import '../models/stock_movement_model.dart';
import '../models/stock_movement_repository.dart';
import '../models/alert_log_model.dart';
import '../models/alert_log_repository.dart';
import '../core/errors.dart';
import '../core/result.dart';

// === App Initialization ===

final appInitProvider = FutureProvider<void>((ref) async {
  await HiveManager.init();
  await WriteAheadLog.recover();
  await WriteAheadLog.cleanup();
});

/// Checks if company onboarding is complete.
/// Returns true if the user has registered their company details.
final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final box = await HiveManager.getBox(HiveBoxes.settings);
  return box.safeGet<bool>('has_completed_onboarding') ?? false;
});

/// Theme mode provider (system, light, dark).
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// Navigation index provider.
final navigationIndexProvider = StateProvider<int>((ref) => 0);

/// App settings providers.
final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>(
  (ref) => AppSettingsNotifier(),
);

class AppSettings {
  const AppSettings({
    this.companyName = '',
    this.panNumber = '',
    this.registrationNumber = '',
    this.registrationLocation = '',
    this.currency = 'NPR',
    this.lowStockThreshold = 10,
    this.hasCompletedOnboarding = false,
  });

  final String companyName;
  final String panNumber;
  final String registrationNumber;
  final String registrationLocation;
  final String currency;
  final int lowStockThreshold;
  final bool hasCompletedOnboarding;

  AppSettings copyWith({
    String? companyName,
    String? panNumber,
    String? registrationNumber,
    String? registrationLocation,
    String? currency,
    int? lowStockThreshold,
    bool? hasCompletedOnboarding,
  }) {
    return AppSettings(
      companyName: companyName ?? this.companyName,
      panNumber: panNumber ?? this.panNumber,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      registrationLocation: registrationLocation ?? this.registrationLocation,
      currency: currency ?? this.currency,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }

  /// Returns the currency symbol for the current currency setting.
  String get currencySymbol => switch (currency) {
    'NPR' => '₨',
    'USD' => '\$',
    'EUR' => '€',
    'GBP' => '£',
    'JPY' => '¥',
    'INR' => '₹',
    'CAD' => 'C\$',
    'AUD' => 'A\$',
    _ => currency,
  };
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(const AppSettings());

  void updateCompanyName(String name) {
    state = state.copyWith(companyName: name);
  }

  void updatePanNumber(String pan) {
    state = state.copyWith(panNumber: pan);
  }

  void updateRegistrationNumber(String regNum) {
    state = state.copyWith(registrationNumber: regNum);
  }

  void updateRegistrationLocation(String location) {
    state = state.copyWith(registrationLocation: location);
  }

  void updateCurrency(String currency) {
    state = state.copyWith(currency: currency);
  }

  void updateLowStockThreshold(int threshold) {
    state = state.copyWith(lowStockThreshold: threshold);
  }

  void markOnboardingComplete() {
    state = state.copyWith(hasCompletedOnboarding: true);
  }
}

// === Item Providers ===

final itemsProvider = FutureProvider<List<Item>>((ref) async {
  return ItemRepository.instance.getActive();
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  return CategoryRepository.instance.getAll();
});

final itemByIdProvider =
    FutureProvider.family<Item?, String>((ref, id) async {
  return ItemRepository.instance.getById(id);
});

final itemsByCategoryProvider =
    FutureProvider.family<List<Item>, String>((ref, categoryId) async {
  return ItemRepository.instance.getByCategory(categoryId);
});

final lowStockItemsProvider = FutureProvider<List<Item>>((ref) async {
  return ItemRepository.instance.getLowStock();
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final filteredItemsProvider = FutureProvider<List<Item>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final categoryId = ref.watch(selectedCategoryProvider);
  if (query.isNotEmpty) {
    return ItemRepository.instance.search(query);
  }
  if (categoryId != null) {
    return ItemRepository.instance.getByCategory(categoryId);
  }
  return ItemRepository.instance.getActive();
});

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final items = await ItemRepository.instance.getActive();
  final lowStock = items.where((i) => i.isLowStock).length;
  final totalValue =
      items.fold<double>(0, (sum, item) => sum + item.inventoryValue);
  final outOfStock = items.where((i) => i.isOutOfStock).length;
  return DashboardStats(
    totalItems: items.length,
    lowStockCount: lowStock,
    outOfStockCount: outOfStock,
    totalValue: totalValue,
  );
});

class DashboardStats {
  const DashboardStats({
    required this.totalItems,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.totalValue,
  });

  final int totalItems;
  final int lowStockCount;
  final int outOfStockCount;
  final double totalValue;
}

// === Workforce Providers ===

final employeesProvider = FutureProvider<List<Employee>>((ref) async {
  return EmployeeRepository.instance.getActive();
});

final employeeByIdProvider =
    FutureProvider.family<Employee?, String>((ref, id) async {
  return EmployeeRepository.instance.getById(id);
});

final tasksByEmployeeProvider =
    FutureProvider.family<List<Task>, String>((ref, employeeId) async {
  return TaskRepository.instance.getByEmployee(employeeId);
});

final employeeSearchQueryProvider = StateProvider<String>((ref) => '');
final selectedEmployeeRoleProvider =
    StateProvider<EmployeeRole?>((ref) => null);

final filteredEmployeesProvider =
    FutureProvider<List<Employee>>((ref) async {
  final query = ref.watch(employeeSearchQueryProvider);
  final role = ref.watch(selectedEmployeeRoleProvider);
  if (query.isNotEmpty) {
    return EmployeeRepository.instance.search(query);
  }
  if (role != null) {
    return EmployeeRepository.instance.getByRole(role);
  }
  return EmployeeRepository.instance.getActive();
});

final workforceStatsProvider =
    FutureProvider<WorkforceStats>((ref) async {
  final employeeCount =
      await EmployeeRepository.instance.getActiveCount();
  final pendingTasks = await TaskRepository.instance.getPendingCount();
  return WorkforceStats(
    activeEmployees: employeeCount,
    pendingTasks: pendingTasks,
  );
});

class WorkforceStats {
  const WorkforceStats({
    required this.activeEmployees,
    required this.pendingTasks,
  });

  final int activeEmployees;
  final int pendingTasks;
}

// === Item CRUD Notifier ===

class ItemCrudNotifier extends StateNotifier<AsyncValue<void>> {
  ItemCrudNotifier() : super(const AsyncValue.data(null));

  Future<Result<Item, AppError>> create(Item item) async {
    state = const AsyncValue.loading();
    final result = await ItemRepository.instance.create(item);
    state = const AsyncValue.data(null);
    return result;
  }

  Future<Result<Item, AppError>> update(Item item) async {
    state = const AsyncValue.loading();
    final result = await ItemRepository.instance.update(item);
    state = const AsyncValue.data(null);
    return result;
  }

  Future<Result<void, AppError>> delete(String id) async {
    state = const AsyncValue.loading();
    final result = await ItemRepository.instance.delete(id);
    state = const AsyncValue.data(null);
    return result;
  }

  Future<Result<Item, AppError>> deactivate(String id) async {
    state = const AsyncValue.loading();
    final result = await ItemRepository.instance.deactivate(id);
    state = const AsyncValue.data(null);
    return result;
  }

  Future<Result<Item, AppError>> adjustStock(
    String itemId,
    int adjustment, {
    String? reason,
    String? reference,
  }) async {
    state = const AsyncValue.loading();
    final result = await ItemRepository.instance.adjustStock(
      itemId,
      adjustment,
      reason: reason,
      reference: reference,
    );
    state = const AsyncValue.data(null);
    return result;
  }

  /// Undo a previous stock movement.
  Future<Result<Item, AppError>> undoMovement(String movementId) async {
    state = const AsyncValue.loading();
    final result = await ItemRepository.instance.undoMovement(movementId);
    state = const AsyncValue.data(null);
    return result;
  }
}

final itemCrudProvider =
    StateNotifierProvider<ItemCrudNotifier, AsyncValue<void>>(
  (ref) => ItemCrudNotifier(),
);

// === Category CRUD Notifier ===

class CategoryCrudNotifier extends StateNotifier<AsyncValue<void>> {
  CategoryCrudNotifier() : super(const AsyncValue.data(null));

  Future<Result<Category, AppError>> create(Category category) async {
    state = const AsyncValue.loading();
    final result = await CategoryRepository.instance.create(category);
    state = const AsyncValue.data(null);
    return result;
  }

  Future<Result<Category, AppError>> update(Category category) async {
    state = const AsyncValue.loading();
    final result = await CategoryRepository.instance.update(category);
    state = const AsyncValue.data(null);
    return result;
  }

  Future<Result<void, AppError>> delete(String id) async {
    state = const AsyncValue.loading();
    final result = await CategoryRepository.instance.delete(id);
    state = const AsyncValue.data(null);
    return result;
  }
}

final categoryCrudProvider =
    StateNotifierProvider<CategoryCrudNotifier, AsyncValue<void>>(
  (ref) => CategoryCrudNotifier(),
);

// === Employee CRUD Notifier ===

class EmployeeCrudNotifier extends StateNotifier<AsyncValue<void>> {
  EmployeeCrudNotifier() : super(const AsyncValue.data(null));

  Future<Result<Employee, AppError>> create(Employee employee) async {
    state = const AsyncValue.loading();
    final result = await EmployeeRepository.instance.create(employee);
    state = const AsyncValue.data(null);
    return result;
  }

  Future<Result<Employee, AppError>> update(Employee employee) async {
    state = const AsyncValue.loading();
    final result = await EmployeeRepository.instance.update(employee);
    state = const AsyncValue.data(null);
    return result;
  }

  Future<Result<void, AppError>> delete(String id) async {
    state = const AsyncValue.loading();
    final result = await EmployeeRepository.instance.delete(id);
    state = const AsyncValue.data(null);
    return result;
  }

  Future<Result<Employee, AppError>> deactivate(String id) async {
    state = const AsyncValue.loading();
    final result = await EmployeeRepository.instance.deactivate(id);
    state = const AsyncValue.data(null);
    return result;
  }
}

final employeeCrudProvider =
    StateNotifierProvider<EmployeeCrudNotifier, AsyncValue<void>>(
  (ref) => EmployeeCrudNotifier(),
);

// === Task CRUD Notifier ===

class TaskCrudNotifier extends StateNotifier<AsyncValue<void>> {
  TaskCrudNotifier() : super(const AsyncValue.data(null));

  Future<Result<Task, AppError>> create(Task task) async {
    state = const AsyncValue.loading();
    final result = await TaskRepository.instance.create(task);
    state = const AsyncValue.data(null);
    return result;
  }

  Future<Result<Task, AppError>> update(Task task) async {
    state = const AsyncValue.loading();
    final result = await TaskRepository.instance.update(task);
    state = const AsyncValue.data(null);
    return result;
  }

  Future<Result<void, AppError>> delete(String id) async {
    state = const AsyncValue.loading();
    final result = await TaskRepository.instance.delete(id);
    state = const AsyncValue.data(null);
    return result;
  }

  Future<Result<Task, AppError>> complete(String taskId) async {
    state = const AsyncValue.loading();
    final result = await TaskRepository.instance.complete(taskId);
    state = const AsyncValue.data(null);
    return result;
  }
}

final taskCrudProvider =
    StateNotifierProvider<TaskCrudNotifier, AsyncValue<void>>(
  (ref) => TaskCrudNotifier(),
);

// === Stock Movement Providers ===

final recentMovementsProvider = FutureProvider<List<StockMovement>>((ref) async {
  return StockMovementRepository.instance.getRecent(10);
});

final movementSummaryProvider = FutureProvider<MovementSummary>((ref) async {
  return StockMovementRepository.instance.getSummary();
});

/// Filtered movements provider for Reports screen.
/// Fetches movements by optional date range, then filters by type and search query.
final filteredMovementsProvider =
    FutureProvider.family<List<StockMovement>, MovementFilter>((ref, filter) async {
  var movements = <StockMovement>[];
  if (filter.dateRange != null) {
    movements = await StockMovementRepository.instance.getByDateRange(
      filter.dateRange!.start,
      filter.dateRange!.end,
    );
  } else {
    movements = await StockMovementRepository.instance.getRecent(100);
  }
  if (filter.movementType != null) {
    movements = movements.where((m) => m.type == filter.movementType).toList();
  }
  if (filter.searchQuery.isNotEmpty) {
    final q = filter.searchQuery.toLowerCase();
    movements = movements
        .where((m) => m.itemName.toLowerCase().contains(q))
        .toList();
  }
  return movements;
});

@immutable
class MovementFilter {
  const MovementFilter({
    this.dateRange,
    this.movementType,
    this.searchQuery = '',
  });

  final DateTimeRange? dateRange;
  final MovementType? movementType;
  final String searchQuery;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovementFilter &&
          dateRange == other.dateRange &&
          movementType == other.movementType &&
          searchQuery == other.searchQuery;

  @override
  int get hashCode => Object.hash(dateRange, movementType, searchQuery);
}

/// All stock movements for a specific item, newest first.
final movementsByItemProvider =
    FutureProvider.family<List<StockMovement>, String>((ref, itemId) async {
  final movements = await StockMovementRepository.instance.getByItem(itemId);
  movements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return movements;
});

/// Alert log providers
final alertLogProvider = FutureProvider<List<AlertLog>>((ref) async {
  return AlertLogRepository.instance.getAll();
});

final unacknowledgedAlertsProvider = FutureProvider<List<AlertLog>>((ref) async {
  return AlertLogRepository.instance.getUnacknowledged();
});
