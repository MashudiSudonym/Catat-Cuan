import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/presentation/utils/error/error_message_mapper.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

/// Helper class for consistent error handling across the app
///
/// This class provides utility methods to:
/// - Unwrap Result<T> objects and throw on failure
/// - Convert errors to user-friendly messages with logging
///
/// Usage:
/// ```dart
/// try {
///   final result = await useCase.execute();
///   final data = ErrorHandler.unwrapResult(result, 'fetching data');
///   // Use data
/// } catch (e, stack) {
///   ErrorHandler.handleError(e, stack);
/// }
/// ```
class ErrorHandler {
  ErrorHandler._();

  /// Handle Result<T> and throw user-friendly exception if failed
  ///
  /// This is useful when you need to unwrap a Result and convert
  /// failures to exceptions for try-catch handling.
  ///
  /// Example:
  /// ```dart
  /// final result = await useCase.execute();
  /// final data = ErrorHandler.unwrapResult(result, 'loading transactions');
  /// ```
  static T unwrapResult<T>(Result<T> result, String context) {
    if (result.isFailure) {
      final message = result.failure?.message ?? 'Terjadi kesalahan';
      AppLogger.e('$context failed: $message');
      throw Exception(message);
    }
    return result.data!;
  }

  /// Convert error to user-friendly message with logging
  ///
  /// This method logs the technical error and returns a user-friendly
  /// message suitable for display in the UI.
  ///
  /// Example:
  /// ```dart
  /// } catch (e, stack) {
  ///   final message = ErrorHandler.handleError(e, stack);
  ///   showSnackBar(message);
  /// }
  /// ```
  static String handleError(dynamic error, [StackTrace? stackTrace]) {
    final userMessage = ErrorMessageMapper.getUserMessage(error);
    AppLogger.e(userMessage, error, stackTrace);
    return userMessage;
  }

  /// Handle error with context-specific messaging
  ///
  /// Returns a user-friendly error message with operation context.
  ///
  /// Example:
  /// ```dart
  /// } catch (e, stack) {
  ///   final message = ErrorHandler.handleErrorWithContext(
  ///     e, stack,
  ///     operation: 'menambahkan',
  ///     entity: 'transaksi',
  ///   );
  ///   showSnackBar(message);
  /// }
  /// ```
  static String handleErrorWithContext(
    dynamic error,
    StackTrace? stackTrace, {
    String? operation,
    String? entity,
  }) {
    final baseMessage = ErrorMessageMapper.getUserMessage(error);
    AppLogger.e('Error in ${operation ?? 'operation'}: $baseMessage', error, stackTrace);

    if (operation != null && entity != null) {
      return 'Gagal saat $operation $entity. $baseMessage';
    }

    if (operation != null) {
      return 'Gagal saat $operation. $baseMessage';
    }

    return baseMessage;
  }

  /// Check if Result is successful, throw if not
  ///
  /// Useful for validating results without unwrapping.
  ///
  /// Example:
  /// ```dart
  /// final result = await useCase.execute();
  /// ErrorHandler.checkResult(result, 'Operation failed');
  /// // result is guaranteed to be successful here
  /// ```
  static void checkResult<T>(Result<T> result, String errorMessage) {
    if (result.isFailure) {
      final message = result.failure?.message ?? errorMessage;
      AppLogger.e('Result check failed: $message');
      throw Exception(message);
    }
  }

  /// Safely unwrap Result with default value on failure
  ///
  /// Returns the data if successful, otherwise returns the default value.
  /// Does NOT throw - useful for optional operations.
  ///
  /// Example:
  /// ```dart
  /// final result = await useCase.execute();
  /// final data = ErrorHandler.unwrapResultOrDefault(result, defaultValue: []);
  /// ```
  static T unwrapResultOrDefault<T>(Result<T> result, {required T defaultValue}) {
    if (result.isFailure) {
      AppLogger.w('Result failed, returning default value: ${result.failure?.message}');
      return defaultValue;
    }
    return result.data ?? defaultValue;
  }

  /// Log error without converting to user message
  ///
  /// Use this when you want to log technical errors for debugging
  /// but don't need to show a message to the user.
  ///
  /// Example:
  /// ```dart
  /// } catch (e, stack) {
  ///   ErrorHandler.logError('Background sync failed', e, stack);
  ///   // No user notification needed
  /// }
  /// ```
  static void logError(String message, [Object? error, StackTrace? stackTrace]) {
    AppLogger.e(message, error, stackTrace);
  }

  /// Get user-friendly error title for dialogs
  ///
  /// Returns a title appropriate for error dialogs based on error type.
  ///
  /// Example:
  /// ```dart
  /// showErrorDialog(
  ///   title: ErrorHandler.getErrorTitle(error),
  ///   content: ErrorMessageMapper.getUserMessage(error),
  /// );
  /// ```
  static String getErrorTitle(dynamic error) {
    return ErrorMessageMapper.getErrorTitle(error);
  }

  /// Get recovery suggestion for common errors
  ///
  /// Returns null if no suggestion is available for the error type.
  ///
  /// Example:
  /// ```dart
  /// final suggestion = ErrorHandler.getRecoverySuggestion(error);
  /// if (suggestion != null) {
  ///   showRecoveryHint(suggestion);
  /// }
  /// ```
  static String? getRecoverySuggestion(dynamic error) {
    return ErrorMessageMapper.getRecoverySuggestion(error);
  }

  /// Handle multiple errors and return user-friendly messages
  ///
  /// Useful for batch operations where multiple errors may occur.
  ///
  /// Example:
  /// ```dart
  /// final errors = [error1, error2, error3];
  /// final messages = ErrorHandler.handleErrors(errors);
  /// showErrorsDialog(messages);
  /// ```
  static List<String> handleErrors(List<dynamic> errors) {
    return errors.map((e) => handleError(e)).toList();
  }

  /// Check if error is user-friendly (already translated)
  ///
  /// Useful for validation errors that should be shown as-is.
  ///
  /// Example:
  /// ```dart
  /// if (ErrorHandler.isUserFriendly(error)) {
  ///   showSnackBar(error.toString());
  /// } else {
  ///   showSnackBar(ErrorMessageMapper.getUserMessage(error));
  /// }
  /// ```
  static bool isUserFriendly(dynamic error) {
    return ErrorMessageMapper.isUserFriendly(error);
  }

  /// Get a pre-written user message for a common operation error
  ///
  /// Returns the message from ErrorMessageMapper.commonMessages.
  ///
  /// Example:
  /// ```dart
  /// final message = ErrorHandler.getCommonMessage('transaction_add_failed');
  /// showSnackBar(message);
  /// ```
  static String getCommonMessage(String key) {
    return ErrorMessageMapper.getCommonMessage(key);
  }
}
