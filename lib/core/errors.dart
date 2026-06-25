/// Sealed error hierarchy for type-safe error handling across nVentory.
/// 
/// All domain errors extend [AppError] and can be matched with
/// Dart 3 pattern matching for exhaustive handling.
sealed class AppError {
  const AppError(this.message);
  final String message;

  @override
  String toString() => message;
}

// === Validation Errors ===
class ValidationError extends AppError {
  const ValidationError(super.message, {this.field});
  final String? field;
}

class RequiredFieldError extends ValidationError {
  const RequiredFieldError(String field) : super('$field is required', field: field);
}

class InvalidFormatError extends ValidationError {
  const InvalidFormatError(String field, String expected)
      : super('$field must be $expected', field: field);
}

class RangeError extends ValidationError {
  const RangeError(String field, num min, num max)
      : super('$field must be between $min and $max', field: field);
}

// === Persistence Errors ===
class PersistenceError extends AppError {
  const PersistenceError(super.message, {this.originalError});
  final Object? originalError;
}

class HiveReadError extends PersistenceError {
  const HiveReadError(String key, [Object? original])
      : super('Failed to read "$key" from storage', originalError: original);
}

class HiveWriteError extends PersistenceError {
  const HiveWriteError(String key, [Object? original])
      : super('Failed to write "$key" to storage', originalError: original);
}

class HiveCorruptedError extends PersistenceError {
  const HiveCorruptedError(String key)
      : super('Data for "$key" is corrupted and was reset');
}

// === Network Errors ===
class NetworkError extends AppError {
  const NetworkError(super.message, {this.statusCode});
  final int? statusCode;
}

// === Business Logic Errors ===
class NotFoundError extends AppError {
  const NotFoundError(String entity, String id)
      : super('$entity with id "$id" not found');
}

class DuplicateError extends AppError {
  const DuplicateError(String entity, String field, String value)
      : super('$entity with $field "$value" already exists');
}

class InsufficientStockError extends AppError {
  const InsufficientStockError(String itemName, int available, int requested)
      : super('Insufficient stock for "$itemName": $available available, $requested requested');
}
