import 'package:hive/hive.dart';
import '../persistence/hive_manager.dart';
import '../persistence/safe_hive.dart';
import '../persistence/write_ahead_log.dart';
import '../core/errors.dart';
import '../core/result.dart';
import '../models/stock_movement_model.dart';
import 'stock_movement_repository.dart';
import 'item_model.dart';
import 'category_model.dart';

/// Repository for Item CRUD operations with Hive persistence.
class ItemRepository {
  ItemRepository._();

  static final ItemRepository instance = ItemRepository._();

  static const _boxName = HiveBoxes.items;

  Future<Box> get _box => HiveManager.getBox(_boxName);

  /// Get all items.
  Future<List<Item>> getAll() async {
    final box = await _box;
    return box.safeValues<Map<String, dynamic>>()
        .map((m) => Item.fromMap(m))
        .toList();
  }

  /// Get only active items.
  Future<List<Item>> getActive() async {
    final items = await getAll();
    return items.where((i) => i.isActive).toList();
  }

  /// Get a single item by ID.
  Future<Item?> getById(String id) async {
    final box = await _box;
    final data = box.safeGet<Map<String, dynamic>>(id);
    if (data == null) {
      return null;
    }
    return Item.fromMap(data);
  }

  /// Get items by category ID.
  Future<List<Item>> getByCategory(String categoryId) async {
    final items = await getActive();
    return items.where((i) => i.categoryId == categoryId).toList();
  }

  /// Get low stock items.
  Future<List<Item>> getLowStock() async {
    final items = await getActive();
    return items.where((i) => i.isLowStock).toList();
  }

  /// Search items by name or SKU.
  Future<List<Item>> search(String query) async {
    final items = await getActive();
    final lowerQuery = query.toLowerCase();
    return items.where((i) {
      return i.name.toLowerCase().contains(lowerQuery) ||
          i.sku.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Create a new item.
  Future<Result<Item, AppError>> create(Item item) async {
    final box = await _box;

    await WriteAheadLog.log(
      operation: WalOperation.put,
      boxName: _boxName,
      key: item.id,
      data: item.toMap(),
    );

    try {
      await box.put(item.id, item.toMap());
      await WriteAheadLog.markCompleted(item.id);
      return Ok(item);
    } catch (e) {
      return Err(HiveWriteError(item.id, e));
    }
  }

  /// Update an existing item.
  Future<Result<Item, AppError>> update(Item item) async {
    final box = await _box;
    final updated = item.copyWith(updatedAt: DateTime.now());

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

  /// Adjust stock quantity (add or remove).
  Future<Result<Item, AppError>> adjustStock(
    String itemId,
    int adjustment, {
    String? reason,
    String? reference,
  }) async {
    final item = await getById(itemId);
    if (item == null) {
      return Err(NotFoundError('Item', itemId));
    }

    final newQuantity = item.quantity + adjustment;
    if (newQuantity < 0) {
      return Err(
        InsufficientStockError(item.name, item.quantity, -adjustment),
      );
    }

    final updated = item.copyWith(
      quantity: newQuantity,
      updatedAt: DateTime.now(),
    );
    final result = await update(updated);
    if (result.isOk) {
      final movementType = adjustment > 0
          ? MovementType.stockIn
          : MovementType.stockOut;
      await StockMovementRepository.instance.log(
        StockMovement.create(
          itemId: itemId,
          itemName: item.name,
          type: movementType,
          quantity: adjustment.abs(),
          previousQuantity: item.quantity,
          newQuantity: newQuantity,
          reason: reason ?? '',
          reference: reference ?? '',
        ),
      );
    }
    return result;
  }

  /// Undo a stock movement by creating a reverse movement.
  /// Returns the updated item, or an error if the movement doesn't exist.
  Future<Result<Item, AppError>> undoMovement(String movementId) async {
    final movementsBox = await HiveManager.getBox(HiveBoxes.stockMovements);
    final data = movementsBox.safeGet<Map<String, dynamic>>(movementId);
    if (data == null) {
      return Err(NotFoundError('Stock movement', movementId));
    }
    final movement = StockMovement.fromMap(data);

    // Calculate the reverse adjustment
    int reverseAdjustment;
    if (movement.type == MovementType.stockIn) {
      reverseAdjustment = -movement.quantity;
    } else if (movement.type == MovementType.stockOut) {
      reverseAdjustment = movement.quantity;
    } else {
      reverseAdjustment = -movement.quantity;
    }

    final item = await getById(movement.itemId);
    if (item == null) {
      return Err(NotFoundError('Item', movement.itemId));
    }

    final newQuantity = item.quantity + reverseAdjustment;
    if (newQuantity < 0) {
      return Err(
        InsufficientStockError(item.name, item.quantity, -reverseAdjustment),
      );
    }

    final updated = item.copyWith(
      quantity: newQuantity,
      updatedAt: DateTime.now(),
    );
    final result = await update(updated);
    if (result.isOk) {
      // Log the undo as a new movement
      await StockMovementRepository.instance.log(
        StockMovement.create(
          itemId: movement.itemId,
          itemName: movement.itemName,
          type: MovementType.adjustment,
          quantity: movement.quantity,
          previousQuantity: item.quantity,
          newQuantity: newQuantity,
          reason: 'Undo: ${movement.reason}',
          reference: 'UNDO-$movementId',
        ),
      );
      // Mark original movement as reversed (by deleting it)
      await movementsBox.delete(movementId);
    }
    return result;
  }

  /// Soft delete (deactivate) an item.
  Future<Result<Item, AppError>> deactivate(String id) async {
    final item = await getById(id);
    if (item == null) {
      return Err(HiveWriteError(id));
    }
    final updated = item.copyWith(isActive: false, updatedAt: DateTime.now());
    return update(updated);
  }

  /// Hard delete an item.
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

  /// Get total inventory value.
  Future<double> getTotalValue() async {
    final items = await getActive();
    return items.fold<double>(0, (sum, item) => sum + item.inventoryValue);
  }

  /// Get total item count.
  Future<int> getCount() async {
    final items = await getActive();
    return items.length;
  }

  /// Get low stock count.
  Future<int> getLowStockCount() async {
    final items = await getLowStock();
    return items.length;
  }
}

/// Repository for Category CRUD operations.
class CategoryRepository {
  CategoryRepository._();

  static final CategoryRepository instance = CategoryRepository._();

  static const _boxName = HiveBoxes.categories;

  Future<Box> get _box => HiveManager.getBox(_boxName);

  /// Get all categories.
  Future<List<Category>> getAll() async {
    final box = await _box;
    return box.safeValues<Map<String, dynamic>>()
        .map((m) => Category.fromMap(m))
        .toList();
  }

  /// Get a single category by ID.
  Future<Category?> getById(String id) async {
    final box = await _box;
    final data = box.safeGet<Map<String, dynamic>>(id);
    if (data == null) {
      return null;
    }
    return Category.fromMap(data);
  }

  /// Create a new category.
  Future<Result<Category, AppError>> create(Category category) async {
    final box = await _box;

    await WriteAheadLog.log(
      operation: WalOperation.put,
      boxName: _boxName,
      key: category.id,
      data: category.toMap(),
    );

    try {
      await box.put(category.id, category.toMap());
      await WriteAheadLog.markCompleted(category.id);
      return Ok(category);
    } catch (e) {
      return Err(HiveWriteError(category.id, e));
    }
  }

  /// Update an existing category.
  Future<Result<Category, AppError>> update(Category category) async {
    final box = await _box;
    final updated = category.copyWith(updatedAt: DateTime.now());

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

  /// Delete a category.
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
