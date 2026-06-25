import '../persistence/hive_manager.dart';

/// Employee role within the organization.
enum EmployeeRole {
  admin('Admin'),
  manager('Manager'),
  supervisor('Supervisor'),
  staff('Staff'),
  viewer('Viewer');

  const EmployeeRole(this.label);
  final String label;
}

/// Department within the organization.
enum Department {
  warehouse('Warehouse'),
  sales('Sales'),
  logistics('Logistics'),
  management('Management'),
  maintenance('Maintenance'),
  qualityControl('Quality Control');

  const Department(this.label);
  final String label;
}

/// Employee model for workforce management.
class Employee {
  const Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone = '',
    this.role = EmployeeRole.staff,
    this.department = Department.warehouse,
    this.hourlyRate = 0,
    this.isActive = true,
    this.avatarColor = 0xFF556B2F,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final EmployeeRole role;
  final Department department;
  final double hourlyRate;
  final bool isActive;
  final int avatarColor;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get fullName => '$firstName $lastName';

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'role': role.name,
    'department': department.name,
    'hourlyRate': hourlyRate,
    'isActive': isActive,
    'avatarColor': avatarColor,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Employee.fromMap(Map<String, dynamic> map) => Employee(
    id: map['id'] as String,
    firstName: map['firstName'] as String,
    lastName: map['lastName'] as String,
    email: map['email'] as String,
    phone: map['phone'] as String? ?? '',
    role: EmployeeRole.values.firstWhere(
      (r) => r.name == (map['role'] as String? ?? 'staff'),
      orElse: () => EmployeeRole.staff,
    ),
    department: Department.values.firstWhere(
      (d) => d.name == (map['department'] as String? ?? 'warehouse'),
      orElse: () => Department.warehouse,
    ),
    hourlyRate: (map['hourlyRate'] as num?)?.toDouble() ?? 0,
    isActive: map['isActive'] as bool? ?? true,
    avatarColor: map['avatarColor'] as int? ?? 0xFF556B2F,
    createdAt: DateTime.parse(map['createdAt'] as String),
    updatedAt: DateTime.parse(map['updatedAt'] as String),
  );

  Employee copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    EmployeeRole? role,
    Department? department,
    double? hourlyRate,
    bool? isActive,
    int? avatarColor,
    DateTime? updatedAt,
  }) {
    return Employee(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      department: department ?? this.department,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      isActive: isActive ?? this.isActive,
      avatarColor: avatarColor ?? this.avatarColor,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Employee.create({
    required String firstName,
    required String lastName,
    required String email,
    String phone = '',
    EmployeeRole role = EmployeeRole.staff,
    Department department = Department.warehouse,
    double hourlyRate = 0,
    int avatarColor = 0xFF556B2F,
  }) {
    final now = DateTime.now();
    return Employee(
      id: HiveManager.generateId(),
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      role: role,
      department: department,
      hourlyRate: hourlyRate,
      isActive: true,
      avatarColor: avatarColor,
      createdAt: now,
      updatedAt: now,
    );
  }
}
