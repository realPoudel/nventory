import 'errors.dart';
import 'result.dart';

/// Type-safe form validators that return [Result] types.
class Validators {
  Validators._();

  /// Validates that a string is not empty.
  static Result<String, ValidationError> required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return Err(RequiredFieldError(fieldName));
    }
    return Ok(value.trim());
  }

  /// Validates minimum length.
  static Result<String, ValidationError> minLength(
    String? value,
    String fieldName,
    int min,
  ) {
    if (value == null || value.trim().length < min) {
      return Err(RangeError(fieldName, min, double.infinity));
    }
    return Ok(value.trim());
  }

  /// Validates maximum length.
  static Result<String, ValidationError> maxLength(
    String? value,
    String fieldName,
    int max,
  ) {
    if (value != null && value.length > max) {
      return Err(RangeError(fieldName, 0, max));
    }
    return Ok(value ?? '');
  }

  /// Validates a numeric range.
  static Result<num, ValidationError> range(
    num? value,
    String fieldName,
    num min,
    num max,
  ) {
    if (value == null) {
      return Err(RequiredFieldError(fieldName));
    }
    if (value < min || value > max) {
      return Err(RangeError(fieldName, min, max));
    }
    return Ok(value);
  }

  /// Validates a positive number.
  static Result<num, ValidationError> positive(num? value, String fieldName) {
    if (value == null) {
      return Err(RequiredFieldError(fieldName));
    }
    if (value <= 0) {
      return Err(InvalidFormatError(fieldName, 'a positive number'));
    }
    return Ok(value);
  }

  /// Validates a non-negative number (zero or positive).
  static Result<num, ValidationError> nonNegative(num? value, String fieldName) {
    if (value == null) {
      return Err(RequiredFieldError(fieldName));
    }
    if (value < 0) {
      return Err(InvalidFormatError(fieldName, 'zero or a positive number'));
    }
    return Ok(value);
  }

  /// Validates an email format.
  static Result<String, ValidationError> email(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return Err(RequiredFieldError(fieldName));
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return Err(InvalidFormatError(fieldName, 'a valid email'));
    }
    return Ok(value.trim());
  }

  /// Validates a SKU format (alphanumeric, hyphens, underscores).
  static Result<String, ValidationError> sku(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return Err(RequiredFieldError(fieldName));
    }
    final skuRegex = RegExp(r'^[A-Za-z0-9\-_]+$');
    if (!skuRegex.hasMatch(value.trim())) {
      return Err(InvalidFormatError(fieldName, 'alphanumeric with hyphens or underscores'));
    }
    return Ok(value.trim().toUpperCase());
  }

  /// Combines multiple validators, returning the first error or the final value.
  static Result<T, ValidationError> combine<T>(
    Result<T, ValidationError> first,
    List<Result<T, ValidationError>> rest,
  ) {
    if (first.isErr) {
      return first;
    }
    for (final result in rest) {
      if (result.isErr) {
        return result;
      }
    }
    return first;
  }
}
