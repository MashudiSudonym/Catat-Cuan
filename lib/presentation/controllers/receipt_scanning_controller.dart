import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/domain/entities/receipt_data_entity.dart';
import 'package:catat_cuan/presentation/providers/scan/receipt_scan_provider.dart';

/// Controller for handling receipt scanning operations
///
/// Responsibility: Managing OCR scanning flow by delegating to
/// ReceiptScanNotifier provider
///
/// Following SRP - Only handles scanning operations coordination
class ReceiptScanningController {
  final WidgetRef _ref;

  ReceiptScanningController(this._ref);

  /// Scan receipt from camera
  ///
  /// Handles camera permission, image capture, and OCR processing
  /// Returns ReceiptDataEntity if successful, null if cancelled or failed
  Future<ReceiptDataEntity?> scanFromCamera(BuildContext context) async {
    final notifier = _ref.read(receiptScanProvider.notifier);
    await notifier.scanFromCamera();

    if (!context.mounted) return null;

    final state = _ref.read(receiptScanProvider);

    if (state.errorMessage != null) {
      _showErrorDialog(context, state.errorMessage!);
      return null;
    }

    return state.scanResult;
  }

  /// Scan receipt from gallery
  ///
  /// Handles gallery permission, image selection, and OCR processing
  /// Returns ReceiptDataEntity if successful, null if cancelled or failed
  Future<ReceiptDataEntity?> scanFromGallery(BuildContext context) async {
    final notifier = _ref.read(receiptScanProvider.notifier);
    await notifier.scanFromGallery();

    if (!context.mounted) return null;

    final state = _ref.read(receiptScanProvider);

    if (state.errorMessage != null) {
      _showErrorDialog(context, state.errorMessage!);
      return null;
    }

    return state.scanResult;
  }

  /// Reset scan state
  void reset() {
    final notifier = _ref.read(receiptScanProvider.notifier);
    notifier.reset();
  }

  /// Show error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gagal Memindai Struk'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Provider for ReceiptScanningController
///
/// This allows the controller to be used in UI components via Riverpod
final receiptScanningControllerProvider =
    Provider<ReceiptScanningController>((ref) {
  return ReceiptScanningController(ref as WidgetRef);
});
