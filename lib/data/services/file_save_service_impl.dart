import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/services/file_save_service.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

/// Implementation of file save service using Storage Access Framework
///
/// This service uses platform channels to invoke native file picker:
/// - Android: ACTION_CREATE_DOCUMENT intent
/// - iOS: UIDocumentPickerViewController (export mode)
class FileSaveServiceImpl implements FileSaveService {
  /// Method channel for native communication
  static const _channel = MethodChannel('catat_cuan/file_save');

  /// Event channel for receiving async callbacks from native
  static const _eventChannel = EventChannel('catat_cuan/file_save_events');

  /// Method name for save file operation
  static const _methodSaveFile = 'saveFile';

  /// Stream subscription for file save events
  StreamSubscription<dynamic>? _eventSubscription;

  /// Completer for the current save operation
  Completer<Result<String>>? _saveCompleter;

  FileSaveServiceImpl() {
    _setupEventChannel();
  }

  /// Setup event channel to listen for native callbacks
  void _setupEventChannel() {
    // Only setup once
    if (_eventSubscription != null) return;

    AppLogger.d('Setting up file save event channel');

    try {
      final eventStream = _eventChannel.receiveBroadcastStream();
      _eventSubscription = eventStream.listen(
        (event) {
          AppLogger.d('Received file save event: $event');
          _handleEvent(event);
        },
        onError: (error) {
          AppLogger.e('File save event channel error', error, null);
          _completeWithError(UnknownFailure('Gagal menyimpan file'));
        },
        onDone: () {
          AppLogger.d('File save event channel done');
        },
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error setting up event channel', e, stackTrace);
    }
  }

  /// Handle events from native code
  void _handleEvent(dynamic event) {
    AppLogger.d('Handling event: $event, type: ${event.runtimeType}');

    if (_saveCompleter == null) {
      AppLogger.w('No active save operation, ignoring event');
      return;
    }

    try {
      // Handle different event formats
      if (event is Map) {
        final eventType = event['event'];
        final data = event['data'];

        AppLogger.d('Event type: $eventType, data: $data');

        switch (eventType) {
          case 'onSuccess':
            final path = data?['path']?.toString();
            if (path != null && path.isNotEmpty) {
              AppLogger.i('File save success: $path');
              _completeWithSuccess(path);
            } else {
              AppLogger.w('Success event but no path');
              _completeWithError(UnknownFailure('Path tidak ditemukan'));
            }
            break;

          case 'onCancelled':
            AppLogger.i('User cancelled file save');
            _completeWithError(const UserCancelledFailure('User cancelled'));
            break;

          case 'onError':
            final errorMessage = data?['error']?.toString();
            AppLogger.e('File save error: $errorMessage', null, null);
            _completeWithError(UnknownFailure(errorMessage ?? 'Terjadi kesalahan'));
            break;

          default:
            AppLogger.w('Unknown event type: $eventType');
        }
      } else {
        AppLogger.w('Event is not a Map: ${event.runtimeType}');
      }
    } catch (e, stackTrace) {
      AppLogger.e('Error handling event', e, stackTrace);
      _completeWithError(UnknownFailure('Gagal memproses respon'));
    }
  }

  /// Complete current operation with success
  void _completeWithSuccess(String path) {
    if (_saveCompleter != null && !_saveCompleter!.isCompleted) {
      _saveCompleter!.complete(Result.success(path));
      _saveCompleter = null;
    }
  }

  /// Complete current operation with error
  void _completeWithError(Failure failure) {
    if (_saveCompleter != null && !_saveCompleter!.isCompleted) {
      _saveCompleter!.complete(Result.failure(failure));
      _saveCompleter = null;
    }
  }

  /// Saves a file using Storage Access Framework
  ///
  /// Shows the system file picker dialog allowing the user to choose
  /// the save location and filename.
  @override
  Future<Result<String>> saveFile({
    required List<int> content,
    required String fileName,
    required String mimeType,
  }) async {
    AppLogger.d('Saving file via SAF: $fileName (${content.length} bytes)');

    // Check if platform supports the operation
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      AppLogger.w('SAF not supported on desktop platforms');
      return Result.failure(
        const UnknownFailure('Penyimpanan file tidak didukung pada platform ini'),
      );
    }

    // Check if there's already an ongoing save operation
    if (_saveCompleter != null) {
      AppLogger.w('Save operation already in progress');
      return Result.failure(
        const UnknownFailure('Operasi penyimpanan sedang berlangsung'),
      );
    }

    try {
      // Create completer for this operation
      _saveCompleter = Completer<Result<String>>();

      AppLogger.d('Invoking native saveFile method');

      // Invoke native method to show file picker
      await _channel.invokeMethod(
        _methodSaveFile,
        {
          'content': content,
          'fileName': fileName,
          'mimeType': mimeType,
        },
      );

      AppLogger.d('Native method invoked, waiting for event channel callback');

      // Wait for the operation to complete via event channel
      // Add timeout to prevent infinite waiting
      final result = await _saveCompleter!.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          AppLogger.e('File save operation timed out');
          _saveCompleter = null;
          return Result.failure(const UnknownFailure('Operasi timeout'));
        },
      );

      return result;
    } catch (e, stackTrace) {
      AppLogger.e('Error during file save operation', e, stackTrace);
      _saveCompleter = null;
      return Result.failure(
        UnknownFailure('Terjadi kesalahan saat menyimpan file'),
      );
    }
  }

  /// Dispose the service and clean up resources
  void dispose() {
    AppLogger.d('Disposing file save service');
    _eventSubscription?.cancel();
    _eventSubscription = null;
  }
}
