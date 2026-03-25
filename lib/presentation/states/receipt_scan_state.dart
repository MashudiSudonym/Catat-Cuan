import 'package:catat_cuan/domain/entities/receipt_data_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'receipt_scan_state.freezed.dart';

/// State untuk receipt scan
@freezed
abstract class ReceiptScanState with _$ReceiptScanState {
  const ReceiptScanState._();

  const factory ReceiptScanState({
    /// Sedang memindai struk
    @Default(false) bool isScanning,

    /// Sedang memproses OCR
    @Default(false) bool isProcessing,

    /// Hasil scan struk
    ReceiptDataEntity? scanResult,

    /// Pesan error
    String? errorMessage,

    /// Path gambar struk
    String? imagePath,
  }) = _ReceiptScanState;

  /// Check apakah ada error
  bool get hasError => errorMessage != null;

  /// Check apakah sudah ada hasil scan
  bool get hasResult => scanResult != null;

  /// Check apakah sedang loading (scanning atau processing)
  bool get isLoading => isScanning || isProcessing;
}
