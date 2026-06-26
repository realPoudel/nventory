import '../persistence/hive_manager.dart';

/// Represents a low stock alert that was triggered.
class AlertLog {
  const AlertLog({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.triggeredAt,
    this.acknowledged = false,
    this.acknowledgedAt,
  });

  final String id;
  final String itemId;
  final String itemName;
  final DateTime triggeredAt;
  final bool acknowledged;
  final DateTime? acknowledgedAt;

  Map<String, dynamic> toMap() => {
    'id': id,
    'itemId': itemId,
    'itemName': itemName,
    'triggeredAt': triggeredAt.toIso8601String(),
    'acknowledged': acknowledged,
    'acknowledgedAt': acknowledgedAt?.toIso8601String(),
  };

  factory AlertLog.fromMap(Map<String, dynamic> map) => AlertLog(
    id: map['id'] as String,
    itemId: map['itemId'] as String,
    itemName: map['itemName'] as String,
    triggeredAt: DateTime.parse(map['triggeredAt'] as String),
    acknowledged: map['acknowledged'] as bool? ?? false,
    acknowledgedAt: map['acknowledgedAt'] != null
        ? DateTime.parse(map['acknowledgedAt'] as String)
        : null,
  );

  factory AlertLog.create({
    required String itemId,
    required String itemName,
  }) {
    return AlertLog(
      id: HiveManager.generateId(),
      itemId: itemId,
      itemName: itemName,
      triggeredAt: DateTime.now(),
    );
  }

  AlertLog acknowledge() {
    return AlertLog(
      id: id,
      itemId: itemId,
      itemName: itemName,
      triggeredAt: triggeredAt,
      acknowledged: true,
      acknowledgedAt: DateTime.now(),
    );
  }
}
