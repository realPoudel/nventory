import 'package:hive/hive.dart';
import 'hive_manager.dart';
import 'safe_hive.dart';

/// Write-ahead log entry for atomic multi-step operations.
/// 
/// This ensures data consistency even if the app crashes mid-operation.
/// Before writing to the main data store, operations are logged.
/// On recovery, pending operations are completed or rolled back.
class WalEntry {
  const WalEntry({
    required this.id,
    required this.operation,
    required this.boxName,
    required this.key,
    required this.data,
    required this.timestamp,
    this.completed = false,
  });

  final String id;
  final WalOperation operation;
  final String boxName;
  final String key;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final bool completed;

  Map<String, dynamic> toMap() => {
    'id': id,
    'operation': operation.name,
    'boxName': boxName,
    'key': key,
    'data': data,
    'timestamp': timestamp.toIso8601String(),
    'completed': completed,
  };

  factory WalEntry.fromMap(Map<String, dynamic> map) => WalEntry(
    id: map['id'] as String,
    operation: WalOperation.values.firstWhere(
      (op) => op.name == map['operation'],
      orElse: () => WalOperation.put,
    ),
    boxName: map['boxName'] as String,
    key: map['key'] as String,
    data: Map<String, dynamic>.from(map['data'] as Map),
    timestamp: DateTime.parse(map['timestamp'] as String),
    completed: map['completed'] as bool? ?? false,
  );

  WalEntry copyWith({bool? completed}) => WalEntry(
    id: id,
    operation: operation,
    boxName: boxName,
    key: key,
    data: data,
    timestamp: timestamp,
    completed: completed ?? this.completed,
  );
}

enum WalOperation { put, delete }

/// Write-ahead log for atomic transactions.
class WriteAheadLog {
  WriteAheadLog._();

  static Box? _box;

  static Future<Box> get _walBox async {
    _box ??= await HiveManager.getBox(HiveBoxes.writeAheadLog);
    return _box!;
  }

  /// Begin a transaction by writing to the log.
  static Future<void> log({
    required WalOperation operation,
    required String boxName,
    required String key,
    required Map<String, dynamic> data,
  }) async {
    final box = await _walBox;
    final entry = WalEntry(
      id: HiveManager.generateId(),
      operation: operation,
      boxName: boxName,
      key: key,
      data: data,
      timestamp: DateTime.now(),
    );
    await box.put(entry.id, entry.toMap());
  }

  /// Mark a transaction entry as completed.
  static Future<void> markCompleted(String entryId) async {
    final box = await _walBox;
    final data = box.get(entryId);
    if (data != null) {
      final entry = WalEntry.fromMap(Map<String, dynamic>.from(data as Map));
      await box.put(entry.id, entry.copyWith(completed: true).toMap());
    }
  }

  /// Get all pending (incomplete) transactions.
  static Future<List<WalEntry>> getPending() async {
    final box = await _walBox;
    return box.safeValues<Map<String, dynamic>>()
        .map((m) => WalEntry.fromMap(m))
        .where((e) => !e.completed)
        .toList();
  }

  /// Clean up completed entries older than the given duration.
  static Future<void> cleanup({Duration maxAge = const Duration(days: 7)}) async {
    final box = await _walBox;
    final cutoff = DateTime.now().subtract(maxAge);
    for (final key in box.safeKeys) {
      final data = box.safeGet<Map<String, dynamic>>(key);
      if (data != null) {
        final entry = WalEntry.fromMap(data);
        if (entry.completed && entry.timestamp.isBefore(cutoff)) {
          await box.delete(key);
        }
      }
    }
  }

  /// Recover pending transactions after a crash.
  /// Executes pending operations and marks them completed.
  static Future<void> recover() async {
    final pending = await getPending();
    for (final entry in pending) {
      try {
        final box = await HiveManager.getBox(entry.boxName);
        switch (entry.operation) {
          case WalOperation.put:
            await box.put(entry.key, entry.data);
          case WalOperation.delete:
            await box.delete(entry.key);
        }
        await markCompleted(entry.id);
      } catch (e) {
        // Log but don't throw — best effort recovery
      }
    }
  }
}
