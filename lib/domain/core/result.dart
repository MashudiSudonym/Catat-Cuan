/// Result type for operations that can fail
///
/// This is a functional programming pattern for handling errors
/// without throwing exceptions. It forces callers to handle both
/// success and failure cases explicitly.
///
/// Following SOLID principles:
/// - Single Responsibility: Only represents success/failure state
/// - Open/Closed: Can be extended with additional methods without modifying core
library;

import 'package:catat_cuan/domain/failures/failures.dart';

/// Result type for operations that can fail
///
/// Usage:
/// ```dart
/// Result<User> result = repository.getUser(id);
///
/// if (result.isSuccess) {
///   print('User: ${result.data?.name}');
/// } else {
///   print('Error: ${result.failure?.message}');
/// }
/// ```
class Result<T> {
  /// The success data value (null if failed)
  final T? data;

  /// The failure object (null if succeeded)
  final Failure? failure;

  const Result._({this.data, this.failure});

  /// Creates a successful result with data
  factory Result.success(T data) => Result._(data: data, failure: null);

  /// Creates a failed result with a Failure object
  factory Result.failure(Failure failure) => Result._(data: null, failure: failure);

  /// Whether the result is successful
  bool get isSuccess => failure == null;

  /// Whether the result is a failure
  bool get isFailure => failure != null;

  /// Get the data or throw if failure
  ///
  /// Use this when you're certain the result is successful
  T get dataOrThrow {
    if (failure != null) {
      throw failure!;
    }
    return data as T;
  }

  /// Get the data or return a default value
  T dataOr(T defaultValue) {
    return data ?? defaultValue;
  }

  /// Transform the data on success
  ///
  /// If this result is a failure, returns the same failure
  Result<R> map<R>(R Function(T data) mapper) {
    if (isFailure) {
      return Result.failure(failure!);
    }
    try {
      return Result.success(mapper(data as T));
    } catch (e) {
      return Result.failure(UnknownFailure('Map function failed: $e'));
    }
  }

  /// Chain another async operation on success
  ///
  /// If this result is a failure, returns the same failure
  Future<Result<R>> then<R>(Future<Result<R>> Function(T data) fn) async {
    if (isFailure) {
      return Result.failure(failure!);
    }
    try {
      return await fn(data as T);
    } catch (e) {
      return Result.failure(UnknownFailure('Then function failed: $e'));
    }
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'Result.success($data)';
    }
    return 'Result.failure($failure)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Result<T> &&
        other.data == data &&
        other.failure == failure;
  }

  @override
  int get hashCode => Object.hash(data, failure);
}

/// Helper class for creating failure results
class ResultFailures {
  /// Creates a validation failure result
  static Result<T> validation<T>(String message) {
    return Result.failure(ValidationFailure(message));
  }

  /// Creates a database failure result
  static Result<T> database<T>(String message) {
    return Result.failure(DatabaseFailure(message));
  }

  /// Creates a not found failure result
  static Result<T> notFound<T>(String message) {
    return Result.failure(NotFoundFailure(message));
  }

  /// Creates a permission failure result
  static Result<T> permission<T>(String message) {
    return Result.failure(PermissionFailure(message));
  }

  /// Creates an OCR failure result
  static Result<T> ocr<T>(String message) {
    return Result.failure(OcrFailure(message));
  }

  /// Creates an unknown failure result
  static Result<T> unknown<T>(String message) {
    return Result.failure(UnknownFailure(message));
  }
}
