import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

/// Base class for all Hive-persisted models.
abstract class HiveModel {
  /// Unique identifier for this model.
  String get id;

  /// Convert this model to a Map for Hive storage.
  Map<String, dynamic> toMap();

  /// Create an instance from a Map.
  static HiveModel fromMap(Map<String, dynamic> map) {
    throw UnimplementedError('fromMap must be implemented by subclasses');
  }
}

/// Manages Hive box lifecycle and provides type-safe access.
class HiveManager {
  HiveManager._();

  static final Map<String, Box> _openBoxes = {};
  static const _uuid = Uuid();

  /// Generate a unique ID.
  static String generateId() => _uuid.v4();

  /// Initialize Hive and open required boxes.
  static Future<void> init() async {
    // Boxes will be opened on demand
  }

  /// Get or open a Hive box.
  static Future<Box> getBox(String name) async {
    if (_openBoxes.containsKey(name)) {
      return _openBoxes[name]!;
    }
    final box = await Hive.openBox(name);
    _openBoxes[name] = box;
    return box;
  }

  /// Get an already-open box synchronously (for redirect guards).
  /// Returns null if the box hasn't been opened yet.
  static Box? getBoxSync(String name) {
    return _openBoxes[name];
  }

  /// Close a specific box.
  static Future<void> closeBox(String name) async {
    final box = _openBoxes.remove(name);
    if (box != null && box.isOpen) {
      await box.close();
    }
  }

  /// Close all open boxes.
  static Future<void> closeAll() async {
    for (final box in _openBoxes.values) {
      if (box.isOpen) {
        await box.close();
      }
    }
    _openBoxes.clear();
  }

  /// Delete a box entirely.
  static Future<void> deleteBox(String name) async {
    await closeBox(name);
    await Hive.deleteBoxFromDisk(name);
  }
}

/// Box names for different data types.
class HiveBoxes {
  HiveBoxes._();

  static const String items = 'items';
  static const String categories = 'categories';
  static const String settings = 'settings';
  static const String transactions = 'transactions';
  static const String employees = 'employees';
  static const String writeAheadLog = 'wal';
  static const String stockMovements = 'stock_movements';
}
