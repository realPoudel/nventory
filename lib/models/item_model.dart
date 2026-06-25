import '../persistence/hive_manager.dart';

/// Unit of measure for inventory items.
enum UnitOfMeasure {
  pieces('pcs'),
  kilograms('kg'),
  grams('g'),
  liters('L'),
  milliliters('mL'),
  meters('m'),
  centimeters('cm'),
  boxes('box'),
  packs('pack'),
  sets('set');

  const UnitOfMeasure(this.abbreviation);
  final String abbreviation;
}

/// Inventory item model.
class Item {
  const Item({
    required this.id,
    required this.name,
    required this.sku,
    this.description = '',
    this.categoryId,
    this.quantity = 0,
    this.unit = UnitOfMeasure.pieces,
    this.costPrice = 0,
    this.sellingPrice = 0,
    this.lowStockThreshold = 10,
    this.location = '',
    this.imagePath = '',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String sku;
  final String description;
  final String? categoryId;
  final int quantity;
  final UnitOfMeasure unit;
  final double costPrice;
  final double sellingPrice;
  final int lowStockThreshold;
  final String location;
  final String imagePath;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Total value of this item in inventory (cost * quantity).
  double get inventoryValue => costPrice * quantity;

  /// Whether this item is low on stock.
  bool get isLowStock => quantity <= lowStockThreshold;

  /// Whether this item is out of stock.
  bool get isOutOfStock => quantity <= 0;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'sku': sku,
    'description': description,
    'categoryId': categoryId,
    'quantity': quantity,
    'unit': unit.name,
    'costPrice': costPrice,
    'sellingPrice': sellingPrice,
    'lowStockThreshold': lowStockThreshold,
    'location': location,
    'imagePath': imagePath,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Item.fromMap(Map<String, dynamic> map) => Item(
    id: map['id'] as String,
    name: map['name'] as String,
    sku: map['sku'] as String,
    description: map['description'] as String? ?? '',
    categoryId: map['categoryId'] as String?,
    quantity: map['quantity'] as int? ?? 0,
    unit: UnitOfMeasure.values.firstWhere(
      (u) => u.name == (map['unit'] as String? ?? 'pieces'),
      orElse: () => UnitOfMeasure.pieces,
    ),
    costPrice: (map['costPrice'] as num?)?.toDouble() ?? 0,
    sellingPrice: (map['sellingPrice'] as num?)?.toDouble() ?? 0,
    lowStockThreshold: map['lowStockThreshold'] as int? ?? 10,
    location: map['location'] as String? ?? '',
    imagePath: map['imagePath'] as String? ?? '',
    isActive: map['isActive'] as bool? ?? true,
    createdAt: DateTime.parse(map['createdAt'] as String),
    updatedAt: DateTime.parse(map['updatedAt'] as String),
  );

  Item copyWith({
    String? name,
    String? sku,
    String? description,
    String? categoryId,
    int? quantity,
    UnitOfMeasure? unit,
    double? costPrice,
    double? sellingPrice,
    int? lowStockThreshold,
    String? location,
    String? imagePath,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      location: location ?? this.location,
      imagePath: imagePath ?? this.imagePath,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create a new item with generated ID and timestamps.
  factory Item.create({
    required String name,
    required String sku,
    String description = '',
    String? categoryId,
    int quantity = 0,
    UnitOfMeasure unit = UnitOfMeasure.pieces,
    double costPrice = 0,
    double sellingPrice = 0,
    int lowStockThreshold = 10,
    String location = '',
    String imagePath = '',
  }) {
    final now = DateTime.now();
    return Item(
      id: HiveManager.generateId(),
      name: name,
      sku: sku,
      description: description,
      categoryId: categoryId,
      quantity: quantity,
      unit: unit,
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      lowStockThreshold: lowStockThreshold,
      location: location,
      imagePath: imagePath,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }
}
