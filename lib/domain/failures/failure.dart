/// Domain failures following Clean Architecture
///
/// Base failure class for all error types in the domain layer.
/// Failures represent error states that can occur during business operations.
///
/// This approach follows SOLID principles:
/// - Open/Closed: New failure types can be added without modifying existing code
/// - Single Responsibility: Each failure type represents one specific error category
library;

/// Base failure class for all error types
abstract class Failure {
  /// Human-readable error message
  final String message;

  const Failure(this.message);

  @override
  String toString() => message;
}
