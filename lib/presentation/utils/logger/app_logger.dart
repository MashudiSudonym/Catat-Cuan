import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Centralized logger utility for the Catat Cuan application.
///
/// Features:
/// - Structured logging with multiple levels (trace, debug, info, warning, error, fatal)
/// - Pretty printing with emojis and colors
/// - Automatic stack trace capture for errors
/// - Production-friendly filtering (only warning+ in release mode)
/// - Consistent log format across the application
///
/// Usage:
/// ```dart
/// AppLogger.d('Debug message');
/// AppLogger.i('Info message');
/// AppLogger.w('Warning message');
/// AppLogger.e('Error message', error, stackTrace);
/// AppLogger.t('Trace message');
/// ```
class AppLogger {
  AppLogger._();

  static Logger? _logger;

  /// Initialize the logger with appropriate configuration.
  /// Should be called once at app startup (in main.dart).
  /// Safe to call multiple times - will only initialize once.
  static void initialize() {
    _logger ??= Logger(
      level: kReleaseMode ? Level.warning : Level.trace,
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      filter: kReleaseMode ? ProductionFilter() : DevelopmentFilter(),
    );
  }

  /// Get the logger instance, throwing if not initialized.
  static Logger get _log {
    return _logger ?? (throw StateError('AppLogger not initialized. Call AppLogger.initialize() first.'));
  }

  /// Log trace level message.
  /// Use for very detailed debugging information.
  static void t(
    dynamic message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _log.t(
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log debug level message.
  /// Use for general debugging information.
  static void d(
    dynamic message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _log.d(
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log info level message.
  /// Use for general informational messages.
  static void i(
    dynamic message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _log.i(
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log warning level message.
  /// Use for warnings that don't prevent the app from functioning.
  static void w(
    dynamic message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _log.w(
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log error level message.
  /// Use for errors that affect functionality but don't crash the app.
  static void e(
    dynamic message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _log.e(
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log fatal level message.
  /// Use for critical errors that may cause the app to crash.
  static void f(
    dynamic message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _log.f(
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log a structured data object.
  /// Useful for logging JSON, maps, or complex objects.
  static void data(String message, dynamic data) {
    _log.d(message);
    _log.d(data.toString());
  }
}

/// Filter for development mode - logs everything.
class DevelopmentFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true;
  }
}

/// Filter for production mode - only logs warnings and above.
class ProductionFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return event.level.index >= Level.warning.index;
  }
}
