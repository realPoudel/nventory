import '../persistence/hive_manager.dart';

/// Category model for organizing inventory items.
class Category {
  const Category({
    required this.id,
    required this.name,
    this.description = '',
    this.color = 0xFF556B2F,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final int color;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'color': color,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Category.fromMap(Map<String, dynamic> map) => Category(
    id: map['id'] as String,
    name: map['name'] as String,
    description: map['description'] as String? ?? '',
    color: map['color'] as int? ?? 0xFF556B2F,
    createdAt: DateTime.parse(map['createdAt'] as String),
    updatedAt: DateTime.parse(map['updatedAt'] as String),
  );

  Category copyWith({
    String? name,
    String? description,
    int? color,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create a new category with generated ID and timestamps.
  factory Category.create({
    required String name,
    String description = '',
    int color = 0xFF556B2F,
  }) {
    final now = DateTime.now();
    return Category(
      id: HiveManager.generateId(),
      name: name,
      description: description,
      color: color,
      createdAt: now,
      updatedAt: now,
    );
  }
}
