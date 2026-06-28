import 'package:hive/hive.dart';
import '../persistence/hive_manager.dart';
import '../persistence/safe_hive.dart';
import '../persistence/write_ahead_log.dart';
import '../models/alert_log_model.dart';

/// Repository for alert log persistence.
class AlertLogRepository {
  AlertLogRepository._();

  static final AlertLogRepository instance = AlertLogRepository._();

  static const _boxName = 'alert_logs';

  Future<Box> get _box => HiveManager.getBox(_boxName);

  /// Get all alert logs, newest first.
  Future<List<AlertLog>> getAll() async {
    final box = await _box;
    final logs = box.safeValues<Map<String, dynamic>>()
        .map((m) => AlertLog.fromMap(m))
        .toList();
    logs.sort((a, b) => b.triggeredAt.compareTo(a.triggeredAt));
    return logs;
  }

  /// Get unacknowledged alerts.
  Future<List<AlertLog>> getUnacknowledged() async {
    final logs = await getAll();
    return logs.where((l) => !l.acknowledged).toList();
  }

  /// Trigger a new low stock alert.
  Future<void> triggerAlert({
    required String itemId,
    required String itemName,
  }) async {
    final box = await _box;

    // Check if there's already an unacknowledged alert for this item
    final existing = await getUnacknowledged();
    if (existing.any((l) => l.itemId == itemId)) {
      return; // Don't duplicate
    }

    final alert = AlertLog.create(itemId: itemId, itemName: itemName);

    await WriteAheadLog.log(
      operation: WalOperation.put,
      boxName: _boxName,
      key: alert.id,
      data: alert.toMap(),
    );

    try {
      await box.put(alert.id, alert.toMap());
      await WriteAheadLog.markCompleted(alert.id);
    } catch (e) {
      // Best effort
    }
  }

  /// Acknowledge an alert.
  Future<void> acknowledge(String alertId) async {
    final box = await _box;
    final data = box.safeGet<Map<String, dynamic>>(alertId);
    if (data == null) {
      return;
    }

    final alert = AlertLog.fromMap(data).acknowledge();
    await box.put(alertId, alert.toMap());
  }
}
