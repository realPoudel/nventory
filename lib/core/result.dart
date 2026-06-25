import 'errors.dart';

/// A result type that is either [Ok] with a value of type [T]
/// or [Err] with an error of type [E].
/// 
/// This enables type-safe error handling without exceptions.
sealed class Result<T, E extends AppError> {
  const Result();

  /// Returns true if this is an [Ok] result.
  bool get isOk => this is Ok<T, E>;

  /// Returns true if this is an [Err] result.
  bool get isErr => this is Err<T, E>;

  /// Returns the value if [Ok], otherwise returns null.
  T? get value => switch (this) {
    Ok<T, E>(:final value) => value,
    Err<T, E>() => null,
  };

  /// Returns the error if [Err], otherwise returns null.
  E? get error => switch (this) {
    Ok<T, E>() => null,
    Err<T, E>(:final error) => error,
  };

  /// Returns the value if [Ok], otherwise returns [defaultValue].
  T unwrapOr(T defaultValue) => switch (this) {
    Ok<T, E>(:final value) => value,
    Err<T, E>() => defaultValue,
  };

  /// Maps the value if [Ok], otherwise returns the error.
  Result<U, E> map<U>(U Function(T value) fn) => switch (this) {
    Ok<T, E>(:final value) => Ok(fn(value)),
    Err<T, E>(:final error) => Err(error),
  };

  /// Maps the error if [Err], otherwise returns the value.
  Result<T, F> mapErr<F extends AppError>(F Function(E error) fn) => switch (this) {
    Ok<T, E>(:final value) => Ok(value),
    Err<T, E>(:final error) => Err(fn(error)),
  };

  /// Chains another Result-producing operation.
  Result<U, E> andThen<U>(Result<U, E> Function(T value) fn) => switch (this) {
    Ok<T, E>(:final value) => fn(value),
    Err<T, E>(:final error) => Err(error),
  };
}

/// A successful result containing a value.
class Ok<T, E extends AppError> extends Result<T, E> {
  const Ok(this.value);

  @override
  final T value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Ok<T, E> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Ok($value)';
}

/// A failed result containing an error.
class Err<T, E extends AppError> extends Result<T, E> {
  const Err(this.error);

  @override
  final E error;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Err<T, E> && other.error == error);

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Err($error)';
}
