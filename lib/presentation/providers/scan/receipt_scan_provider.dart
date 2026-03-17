import 'package:catat_cuan/domain/entities/receipt_data_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
    // Reset state sebelum memulai
    state = state.copyWith(
      isScanning: true,
      errorMessage: null,
      scanResult: null,
    );

    final permissionService = ref.read(permissionServiceProvider);

    // 1. Request permission kamera
    final permissionResult = await permissionService.requestCameraPermission();
    if (permissionResult.isFailure || !permissionResult.data!) {
      state = state.copyWith(
        isScanning: false,
        errorMessage: permissionResult.failure?.message ?? 'Izin kamera diperlukan',
      );
      return;
    }

    final imagePickerService = ref.read(imagePickerServiceProvider);

    // 2. Ambil gambar dari kamera
    final imageResult = await imagePickerService.pickImageFromCamera();
    if (imageResult.isFailure) {
      state = state.copyWith(
        isScanning: false,
        errorMessage: imageResult.failure?.message ?? 'Gagal mengambil gambar',
      );
      return;
    }

    final imagePath = imageResult.data!;
    state = state.copyWith(imagePath: imagePath);

    // 3. Proses OCR
    await _processOcr(imagePath);
  }

  /// Scan struk dari galeri
  Future<void> scanFromGallery() async {
    // Reset state sebelum memulai
    state = state.copyWith(
      isScanning: true,
      errorMessage: null,
      scanResult: null,
    );

    final permissionService = ref.read(permissionServiceProvider);

    // 1. Request permission galeri
    final permissionResult = await permissionService.requestStoragePermission();
    if (permissionResult.isFailure || !permissionResult.data!) {
      state = state.copyWith(
        isScanning: false,
        errorMessage: permissionResult.failure?.message ?? 'Izin galeri diperlukan',
      );
      return;
    }

    final imagePickerService = ref.read(imagePickerServiceProvider);

    // 2. Ambil gambar dari galeri
    final imageResult = await imagePickerService.pickImageFromGallery();
    if (imageResult.isFailure) {
      state = state.copyWith(
        isScanning: false,
        errorMessage: imageResult.failure?.message ?? 'Gagal memilih gambar',
      );
      return;
    }

    final imagePath = imageResult.data!;
    state = state.copyWith(imagePath: imagePath);

    // 3. Proses OCR
    await _processOcr(imagePath);
  }

  /// Proses OCR dari gambar
  Future<void> _processOcr(String imagePath) async {
    state = state.copyWith(isProcessing: true);

    final scanReceiptUseCase = ref.read(scanReceiptUseCaseProvider);

    try {
      // Gunakan use case untuk scan
      final result = await scanReceiptUseCase.execute(imagePath);

      state = state.copyWith(
        isScanning: false,
        isProcessing: false,
        scanResult: result,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isScanning: false,
        isProcessing: false,
        errorMessage: e.toString(),
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
