/// Domain failures following Clean Architecture
///
/// Barrel export for all failure types.
///
/// This approach follows SOLID principles:
/// - Open/Closed: New failure types can be added without modifying existing code
/// - Single Responsibility: Each failure type represents one specific error category
library;

// Base failure class
export 'failure.dart';

// Specific failure types
export 'validation_failure.dart';
export 'database_failure.dart';
export 'network_failure.dart';
export 'permission_failure.dart';
export 'ocr_failure.dart';
export 'unknown_failure.dart';
export 'not_found_failure.dart';
export 'export_failure.dart';
export 'import_failure.dart';
export 'user_cancelled_failure.dart';
