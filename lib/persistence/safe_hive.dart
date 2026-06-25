import 'package:hive/hive.dart';
import '../core/errors.dart';
import '../core/result.dart';

/// Safe Hive read operations that prevent crashes from corrupted data.
/// 
/// Use these instead of direct Hive reads to ensure graceful handling
/// of corrupted or missing data.
class SafeHive {
  SafeHive._();

  /// Safely get a value from a Hive box.
  /// Returns null if the key doesn't exist or data is corrupted.
  static T? safeGet<T>(Box box, String key, {T? defaultValue}) {
    try {
      final value = box.get(key);
      if (value is T) {
        return value;
      }
      return defaultValue;
    } catch (e) {
      // Data is corrupted — delete it and return default
      box.delete(key);
      return defaultValue;
    }
  }

  /// Safely get all values from a Hive box.
  /// Filters out corrupted entries.
  static Iterable<T> safeValues<T>(Box box) {
    final results = <T>[];
    for (var i = 0; i < box.length; i++) {
      try {
        final value = box.getAt(i);
        if (value is T) {
          results.add(value);
        }
      } catch (e) {
        // Skip corrupted entries
        box.deleteAt(i);
      }
    }
    return results;
  }

  /// Safely put a value into a Hive box.
  static Future<Result<void, HiveWriteError>> safePut(
    Box box,
    String key,
    dynamic value,
  ) async {
    try {
      await box.put(key, value);
      return const Ok(null);
    } catch (e) {
      return Err(HiveWriteError(key, e));
    }
  }

  /// Safely delete a value from a Hive box.
  static Future<Result<void, HiveWriteError>> safeDelete(Box box, String key) async {
    try {
      await box.delete(key);
      return const Ok(null);
    } catch (e) {
      return Err(HiveWriteError(key, e));
    }
  }

  /// Safely get all keys from a Hive box.
  static Iterable<String> safeKeys(Box box) {
    try {
      return box.keys.cast<String>();
    } catch (e) {
      return [];
    }
  }
}

/// Extension on Box for safe operations.
extension SafeHiveBox on Box {
  /// Safely get a value with type checking.
  T? safeGet<T>(String key, {T? defaultValue}) =>
      SafeHive.safeGet<T>(this, key, defaultValue: defaultValue);

  /// Safely get all values with type checking.
  Iterable<T> safeValues<T>() => SafeHive.safeValues<T>(this);

  /// Safely put a value.
  Future<Result<void, HiveWriteError>> safePut(String key, dynamic value) =>
      SafeHive.safePut(this, key, value);

  /// Safely delete a value.
  Future<Result<void, HiveWriteError>> safeDelete(String key) =>
      SafeHive.safeDelete(this, key);

  /// Safely get all keys.
  Iterable<String> get safeKeys => SafeHive.safeKeys(this);
}
