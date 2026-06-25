import 'package:hive/hive.dart';
import '../persistence/hive_manager.dart';
import '../persistence/safe_hive.dart';
import '../persistence/write_ahead_log.dart';
import '../core/errors.dart';
import '../core/result.dart';
import 'employee_model.dart';
import 'task_model.dart';

/// Repository for Employee CRUD operations.
class EmployeeRepository {
  EmployeeRepository._();

  static final EmployeeRepository instance = EmployeeRepository._();

  static const _boxName = HiveBoxes.employees;

  Future<Box> get _box => HiveManager.getBox(_boxName);

  /// Get all employees.
  Future<List<Employee>> getAll() async {
    final box = await _box;
    return box.safeValues<Map<String, dynamic>>()
        .map((m) => Employee.fromMap(m))
        .toList();
  }

  /// Get only active employees.
  Future<List<Employee>> getActive() async {
    final employees = await getAll();
    return employees.where((e) => e.isActive).toList();
  }

  /// Get a single employee by ID.
  Future<Employee?> getById(String id) async {
    final box = await _box;
    final data = box.safeGet<Map<String, dynamic>>(id);
    if (data == null) {
      return null;
    }
    return Employee.fromMap(data);
  }

  /// Get employees by role.
  Future<List<Employee>> getByRole(EmployeeRole role) async {
    final employees = await getActive();
    return employees.where((e) => e.role == role).toList();
  }

  /// Get employees by department.
  Future<List<Employee>> getByDepartment(Department department) async {
    final employees = await getActive();
    return employees.where((e) => e.department == department).toList();
  }

  /// Search employees by name or email.
  Future<List<Employee>> search(String query) async {
    final employees = await getActive();
    final lowerQuery = query.toLowerCase();
    return employees.where((e) {
      return e.fullName.toLowerCase().contains(lowerQuery) ||
          e.email.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Create a new employee.
  Future<Result<Employee, AppError>> create(Employee employee) async {
    final box = await _box;

    await WriteAheadLog.log(
      operation: WalOperation.put,
      boxName: _boxName,
      key: employee.id,
      data: employee.toMap(),
    );

    try {
      await box.put(employee.id, employee.toMap());
      await WriteAheadLog.markCompleted(employee.id);
      return Ok(employee);
    } catch (e) {
      return Err(HiveWriteError(employee.id, e));
    }
  }

  /// Update an existing employee.
  Future<Result<Employee, AppError>> update(Employee employee) async {
    final box = await _box;
    final updated = employee.copyWith(updatedAt: DateTime.now());

    await WriteAheadLog.log(
      operation: WalOperation.put,
      boxName: _boxName,
      key: updated.id,
      data: updated.toMap(),
    );

    try {
      await box.put(updated.id, updated.toMap());
      await WriteAheadLog.markCompleted(updated.id);
      return Ok(updated);
    } catch (e) {
      return Err(HiveWriteError(updated.id, e));
    }
  }

  /// Soft delete (deactivate) an employee.
  Future<Result<Employee, AppError>> deactivate(String id) async {
    final employee = await getById(id);
    if (employee == null) {
      return Err(NotFoundError('Employee', id));
    }
    final updated = employee.copyWith(isActive: false, updatedAt: DateTime.now());
    return update(updated);
  }

  /// Hard delete an employee.
  Future<Result<void, AppError>> delete(String id) async {
    final box = await _box;

    await WriteAheadLog.log(
      operation: WalOperation.delete,
      boxName: _boxName,
      key: id,
      data: {},
    );

    try {
      await box.delete(id);
      await WriteAheadLog.markCompleted(id);
      return const Ok(null);
    } catch (e) {
      return Err(HiveWriteError(id, e));
    }
  }

  /// Get active employee count.
  Future<int> getActiveCount() async {
    final employees = await getActive();
    return employees.length;
  }
}

/// Repository for Task CRUD operations.
class TaskRepository {
  TaskRepository._();

  static final TaskRepository instance = TaskRepository._();

  static const _boxName = HiveBoxes.transactions;

  Future<Box> get _box => HiveManager.getBox(_boxName);

  /// Get all tasks.
  Future<List<Task>> getAll() async {
    final box = await _box;
    return box.safeValues<Map<String, dynamic>>()
        .map((m) => Task.fromMap(m))
        .toList();
  }

  /// Get tasks by employee ID.
  Future<List<Task>> getByEmployee(String employeeId) async {
    final tasks = await getAll();
    return tasks.where((t) => t.assignedEmployeeId == employeeId).toList();
  }

  /// Get tasks by status.
  Future<List<Task>> getByStatus(TaskStatus status) async {
    final tasks = await getAll();
    return tasks.where((t) => t.status == status).toList();
  }

  /// Get pending tasks count.
  Future<int> getPendingCount() async {
    final tasks = await getByStatus(TaskStatus.pending);
    return tasks.length;
  }

  /// Create a new task.
  Future<Result<Task, AppError>> create(Task task) async {
    final box = await _box;

    await WriteAheadLog.log(
      operation: WalOperation.put,
      boxName: _boxName,
      key: task.id,
      data: task.toMap(),
    );

    try {
      await box.put(task.id, task.toMap());
      await WriteAheadLog.markCompleted(task.id);
      return Ok(task);
    } catch (e) {
      return Err(HiveWriteError(task.id, e));
    }
  }

  /// Update an existing task.
  Future<Result<Task, AppError>> update(Task task) async {
    final box = await _box;
    final updated = task.copyWith(updatedAt: DateTime.now());

    await WriteAheadLog.log(
      operation: WalOperation.put,
      boxName: _boxName,
      key: updated.id,
      data: updated.toMap(),
    );

    try {
      await box.put(updated.id, updated.toMap());
      await WriteAheadLog.markCompleted(updated.id);
      return Ok(updated);
    } catch (e) {
      return Err(HiveWriteError(updated.id, e));
    }
  }

  /// Mark a task as completed.
  Future<Result<Task, AppError>> complete(String taskId) async {
    final box = await _box;
    final data = box.safeGet<Map<String, dynamic>>(taskId);
    if (data == null) {
      return Err(NotFoundError('Task', taskId));
    }
    final task = Task.fromMap(data);
    final updated = task.copyWith(
      status: TaskStatus.completed,
      completedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return update(updated);
  }

  /// Delete a task.
  Future<Result<void, AppError>> delete(String id) async {
    final box = await _box;

    await WriteAheadLog.log(
      operation: WalOperation.delete,
      boxName: _boxName,
      key: id,
      data: {},
    );

    try {
      await box.delete(id);
      await WriteAheadLog.markCompleted(id);
      return const Ok(null);
    } catch (e) {
      return Err(HiveWriteError(id, e));
    }
  }
}
