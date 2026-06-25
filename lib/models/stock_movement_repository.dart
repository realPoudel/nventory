import 'package:hive/hive.dart';
import '../persistence/hive_manager.dart';
import '../persistence/safe_hive.dart';
import '../persistence/write_ahead_log.dart';
import '../models/stock_movement_model.dart';

/// Repository for stock movement tracking and analytics.
class StockMovementRepository {
  StockMovementRepository._();

  static final StockMovementRepository instance = StockMovementRepository._();

  static const _boxName = HiveBoxes.stockMovements;

  Future<Box> get _box => HiveManager.getBox(_boxName);

  /// Get all stock movements.
  Future<List<StockMovement>> getAll() async {
    final box = await _box;
    return box.safeValues<Map<String, dynamic>>()
        .map((m) => StockMovement.fromMap(m))
        .toList();
  }

  /// Get movements by item ID.
  Future<List<StockMovement>> getByItem(String itemId) async {
    final movements = await getAll();
    return movements.where((m) => m.itemId == itemId).toList();
  }

  /// Get movements by type.
  Future<List<StockMovement>> getByType(MovementType type) async {
    final movements = await getAll();
    return movements.where((m) => m.type == type).toList();
  }

  /// Get movements within a date range.
  Future<List<StockMovement>> getByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final movements = await getAll();
    return movements.where((m) {
      return m.createdAt.isAfter(start) && m.createdAt.isBefore(end);
    }).toList();
  }

  /// Get recent movements (last N).
  Future<List<StockMovement>> getRecent(int limit) async {
    final movements = await getAll();
    movements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return movements.take(limit).toList();
  }

  /// Log a new stock movement.
  Future<void> log(StockMovement movement) async {
    final box = await _box;

    await WriteAheadLog.log(
      operation: WalOperation.put,
      boxName: _boxName,
      key: movement.id,
      data: movement.toMap(),
    );

    try {
      await box.put(movement.id, movement.toMap());
      await WriteAheadLog.markCompleted(movement.id);
    } catch (e) {
      // Best effort logging — don't throw
    }
  }

  /// Get summary stats for a date range.
  Future<MovementSummary> getSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final movements = await getAll();
    final filtered = movements.where((m) {
      if (startDate != null && m.createdAt.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && m.createdAt.isAfter(endDate)) {
        return false;
      }
      return true;
    }).toList();

    final stockIn = filtered
        .where((m) => m.type == MovementType.stockIn)
        .fold<int>(0, (sum, m) => sum + m.quantity);
    final stockOut = filtered
        .where((m) => m.type == MovementType.stockOut)
        .fold<int>(0, (sum, m) => sum + m.quantity);
    final adjustments = filtered
        .where((m) => m.type == MovementType.adjustment)
        .length;

    return MovementSummary(
      totalMovements: filtered.length,
      stockIn: stockIn,
      stockOut: stockOut,
      adjustments: adjustments,
    );
  }
}

class MovementSummary {
  const MovementSummary({
    required this.totalMovements,
    required this.stockIn,
    required this.stockOut,
    required this.adjustments,
  });

  final int totalMovements;
  final int stockIn;
  final int stockOut;
  final int adjustments;
}
