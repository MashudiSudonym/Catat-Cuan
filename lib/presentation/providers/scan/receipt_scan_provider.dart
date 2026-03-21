import 'package:catat_cuan/domain/entities/receipt_data_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:catat_cuan/presentation/utils/error/error_message_mapper.dart';

import 'package:catat_cuan/presentation/providers/services/service_providers.dart';

part 'receipt_scan_provider.g.dart';

/// State untuk receipt scan
class ReceiptScanState {
  final bool isScanning;
  final bool isProcessing;
  final ReceiptDataEntity? scanResult;
  final String? errorMessage;
  final String? imagePath;

  const ReceiptScanState({
    this.isScanning = false,
    this.isProcessing = false,
    this.scanResult,
    this.errorMessage,
    this.imagePath,
  });

  ReceiptScanState copyWith({
    bool? isScanning,
    bool? isProcessing,
    ReceiptDataEntity? scanResult,
    String? errorMessage,
    String? imagePath,
  }) {
    return ReceiptScanState(
      isScanning: isScanning ?? this.isScanning,
      isProcessing: isProcessing ?? this.isProcessing,
      scanResult: scanResult ?? this.scanResult,
      errorMessage: errorMessage ?? this.errorMessage,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  /// Check apakah ada error
  bool get hasError => errorMessage != null;

  /// Check apakah sudah ada hasil scan
  bool get hasResult => scanResult != null;

  /// Check apakah sedang loading (scanning atau processing)
  bool get isLoading => isScanning || isProcessing;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceiptScanState &&
          runtimeType == other.runtimeType &&
          isScanning == other.isScanning &&
          isProcessing == other.isProcessing &&
          scanResult == other.scanResult &&
          errorMessage == other.errorMessage &&
          imagePath == other.imagePath;

  @override
  int get hashCode =>
      isScanning.hashCode ^
      isProcessing.hashCode ^
      scanResult.hashCode ^
      errorMessage.hashCode ^
      imagePath.hashCode;
}

/// Provider untuk receipt scan
/// Following SRP: Only manages receipt scan state and OCR processing
/// Following DIP: Depends on UseCase and Service abstractions
/// Uses @riverpod annotation for modern Riverpod patterns without constructor side effects
@riverpod
class ReceiptScanNotifier extends _$ReceiptScanNotifier {
  @override
  ReceiptScanState build() {
    // No constructor side effects - initialize state in build()
    return const ReceiptScanState();
  }

  /// Scan struk dari kamera
  Future<void> scanFromCamera() async {
    AppLogger.d('Starting camera scan');

    // Reset state sebelum memulai
    state = state.copyWith(
      isScanning: true,
      errorMessage: null,
      scanResult: null,
    );

    final permissionService = ref.read(permissionServiceProvider);

    // 1. Request permission kamera
    AppLogger.d('Requesting camera permission');
    final permissionResult = await permissionService.requestCameraPermission();
    if (permissionResult.isFailure || !permissionResult.data!) {
      AppLogger.w('Camera permission denied');
      state = state.copyWith(
        isScanning: false,
        errorMessage: permissionResult.failure?.message ?? 'Izin kamera diperlukan',
      );
      return;
    }

    final imagePickerService = ref.read(imagePickerServiceProvider);

    // 2. Ambil gambar dari kamera
    AppLogger.d('Capturing image from camera');
    final imageResult = await imagePickerService.pickImageFromCamera();
    if (imageResult.isFailure) {
      AppLogger.w('Failed to capture image from camera');
      state = state.copyWith(
        isScanning: false,
        errorMessage: imageResult.failure?.message ?? 'Gagal mengambil gambar',
      );
      return;
    }

    final imagePath = imageResult.data!;
    AppLogger.i('Image captured: $imagePath');
    state = state.copyWith(imagePath: imagePath);

    // 3. Proses OCR
    await _processOcr(imagePath);
  }

  /// Scan struk dari galeri
  Future<void> scanFromGallery() async {
    AppLogger.d('Starting gallery scan');

    // Reset state sebelum memulai
    state = state.copyWith(
      isScanning: true,
      errorMessage: null,
      scanResult: null,
    );

    final permissionService = ref.read(permissionServiceProvider);

    // 1. Request permission galeri
    AppLogger.d('Requesting storage permission');
    final permissionResult = await permissionService.requestStoragePermission();
    if (permissionResult.isFailure || !permissionResult.data!) {
      AppLogger.w('Storage permission denied');
      state = state.copyWith(
        isScanning: false,
        errorMessage: permissionResult.failure?.message ?? 'Izin galeri diperlukan',
      );
      return;
    }

    final imagePickerService = ref.read(imagePickerServiceProvider);

    // 2. Ambil gambar dari galeri
    AppLogger.d('Picking image from gallery');
    final imageResult = await imagePickerService.pickImageFromGallery();
    if (imageResult.isFailure) {
      AppLogger.w('Failed to pick image from gallery');
      state = state.copyWith(
        isScanning: false,
        errorMessage: imageResult.failure?.message ?? 'Gagal memilih gambar',
      );
      return;
    }

    final imagePath = imageResult.data!;
    AppLogger.i('Image selected: $imagePath');
    state = state.copyWith(imagePath: imagePath);

    // 3. Proses OCR
    await _processOcr(imagePath);
  }

  /// Proses OCR dari gambar
  Future<void> _processOcr(String imagePath) async {
    AppLogger.d('Starting OCR processing');
    state = state.copyWith(isProcessing: true);

    final scanReceiptUseCase = ref.read(scanReceiptUseCaseProvider);

    try {
      // Gunakan use case untuk scan
      final result = await scanReceiptUseCase.execute(imagePath);

      AppLogger.i('OCR processing successful: extracted amount = ${result.extractedAmount}');
      state = state.copyWith(
        isScanning: false,
        isProcessing: false,
        scanResult: result,
        errorMessage: null,
      );
    } catch (e, stackTrace) {
      final userMessage = ErrorMessageMapper.getUserMessage(e);
      AppLogger.e('OCR processing failed', e, stackTrace);
      state = state.copyWith(
        isScanning: false,
        isProcessing: false,
        errorMessage: userMessage,
      );
    }
  }

  /// Reset state ke kondisi awal
  void reset() {
    state = const ReceiptScanState();
  }

  /// Update hasil scan (jika user ingin edit nominal)
  void updateScanResult(ReceiptDataEntity updatedResult) {
    state = state.copyWith(scanResult: updatedResult);
  }

  /// Ambil nominal yang diekstrak
  double? getExtractedAmount() {
    return state.scanResult?.extractedAmount;
  }

  /// Check apakah confidence score cukup tinggi
  bool isConfidentEnough() {
    final score = state.scanResult?.confidenceScore ?? 0.0;
    return score >= 0.7;
  }
}
