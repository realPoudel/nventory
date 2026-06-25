import '../persistence/hive_manager.dart';

/// Task status lifecycle.
enum TaskStatus {
  pending('Pending'),
  inProgress('In Progress'),
  completed('Completed'),
  cancelled('Cancelled');

  const TaskStatus(this.label);
  final String label;
}

/// Task priority levels.
enum TaskPriority {
  low('Low'),
  medium('Medium'),
  high('High'),
  urgent('Urgent');

  const TaskPriority(this.label);
  final String label;
}

/// Task type for inventory operations.
enum TaskType {
  restocking('Restocking'),
  auditing('Auditing'),
  picking('Picking'),
  receiving('Receiving'),
  organizing('Organizing'),
  cleaning('Cleaning'),
  other('Other');

  const TaskType(this.label);
  final String label;
}

/// Task model for assigning work to employees.
class Task {
  const Task({
    required this.id,
    required this.title,
    this.description = '',
    this.type = TaskType.other,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    this.assignedEmployeeId,
    this.dueDate,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final TaskType type;
  final TaskPriority priority;
  final TaskStatus status;
  final String? assignedEmployeeId;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.completed) {
      return false;
    }
    return DateTime.now().isAfter(dueDate!);
  }

  bool get isCompleted => status == TaskStatus.completed;

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type.name,
    'priority': priority.name,
    'status': status.name,
    'assignedEmployeeId': assignedEmployeeId,
    'dueDate': dueDate?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
    id: map['id'] as String,
    title: map['title'] as String,
    description: map['description'] as String? ?? '',
    type: TaskType.values.firstWhere(
      (t) => t.name == (map['type'] as String? ?? 'other'),
      orElse: () => TaskType.other,
    ),
    priority: TaskPriority.values.firstWhere(
      (p) => p.name == (map['priority'] as String? ?? 'medium'),
      orElse: () => TaskPriority.medium,
    ),
    status: TaskStatus.values.firstWhere(
      (s) => s.name == (map['status'] as String? ?? 'pending'),
      orElse: () => TaskStatus.pending,
    ),
    assignedEmployeeId: map['assignedEmployeeId'] as String?,
    dueDate: map['dueDate'] != null
        ? DateTime.parse(map['dueDate'] as String)
        : null,
    completedAt: map['completedAt'] != null
        ? DateTime.parse(map['completedAt'] as String)
        : null,
    createdAt: DateTime.parse(map['createdAt'] as String),
    updatedAt: DateTime.parse(map['updatedAt'] as String),
  );

  Task copyWith({
    String? title,
    String? description,
    TaskType? type,
    TaskPriority? priority,
    TaskStatus? status,
    String? assignedEmployeeId,
    DateTime? dueDate,
    DateTime? completedAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedEmployeeId: assignedEmployeeId ?? this.assignedEmployeeId,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Task.create({
    required String title,
    String description = '',
    TaskType type = TaskType.other,
    TaskPriority priority = TaskPriority.medium,
    String? assignedEmployeeId,
    DateTime? dueDate,
  }) {
    final now = DateTime.now();
    return Task(
      id: HiveManager.generateId(),
      title: title,
      description: description,
      type: type,
      priority: priority,
      status: TaskStatus.pending,
      assignedEmployeeId: assignedEmployeeId,
      dueDate: dueDate,
      createdAt: now,
      updatedAt: now,
    );
  }
}
