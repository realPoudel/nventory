import '../persistence/hive_manager.dart';

/// Type of stock movement.
enum MovementType {
  stockIn('Stock In'),
  stockOut('Stock Out'),
  adjustment('Adjustment'),
  initial('Initial Stock');

  const MovementType(this.label);
  final String label;
}

/// Represents a single stock movement transaction.
class StockMovement {
  const StockMovement({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.type,
    required this.quantity,
    this.previousQuantity = 0,
    this.newQuantity = 0,
    this.reason = '',
    required this.createdAt,
  });

  final String id;
  final String itemId;
  final String itemName;
  final MovementType type;
  final int quantity;
  final int previousQuantity;
  final int newQuantity;
  final String reason;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
    'id': id,
    'itemId': itemId,
    'itemName': itemName,
    'type': type.name,
    'quantity': quantity,
    'previousQuantity': previousQuantity,
    'newQuantity': newQuantity,
    'reason': reason,
    'createdAt': createdAt.toIso8601String(),
  };

  factory StockMovement.fromMap(Map<String, dynamic> map) => StockMovement(
    id: map['id'] as String,
    itemId: map['itemId'] as String,
    itemName: map['itemName'] as String,
    type: MovementType.values.firstWhere(
      (t) => t.name == (map['type'] as String? ?? 'adjustment'),
      orElse: () => MovementType.adjustment,
    ),
    quantity: map['quantity'] as int? ?? 0,
    previousQuantity: map['previousQuantity'] as int? ?? 0,
    newQuantity: map['newQuantity'] as int? ?? 0,
    reason: map['reason'] as String? ?? '',
    createdAt: DateTime.parse(map['createdAt'] as String),
  );

  factory StockMovement.create({
    required String itemId,
    required String itemName,
    required MovementType type,
    required int quantity,
    int previousQuantity = 0,
    int newQuantity = 0,
    String reason = '',
  }) {
    return StockMovement(
      id: HiveManager.generateId(),
      itemId: itemId,
      itemName: itemName,
      type: type,
      quantity: quantity,
      previousQuantity: previousQuantity,
      newQuantity: newQuantity,
      reason: reason,
      createdAt: DateTime.now(),
    );
  }
}
