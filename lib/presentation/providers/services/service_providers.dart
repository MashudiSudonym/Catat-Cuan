import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/data/services/image_picker_service_impl.dart';
import 'package:catat_cuan/data/services/permission_service_impl.dart';
import 'package:catat_cuan/data/services/receipt_ocr_service_impl.dart';
import 'package:catat_cuan/data/services/file_save_service_impl.dart';
import 'package:catat_cuan/data/services/indonesian_merchant_pattern_service_impl.dart';
import 'package:catat_cuan/domain/services/ocr_service.dart';
import 'package:catat_cuan/domain/services/image_picker_service.dart';
import 'package:catat_cuan/domain/services/permission_service.dart';
import 'package:catat_cuan/domain/services/file_save_service.dart';
import 'package:catat_cuan/domain/services/merchant_pattern_service.dart';
import 'package:catat_cuan/domain/usecases/scan_receipt.dart';
import 'package:catat_cuan/domain/services/insight_service.dart';
import 'package:catat_cuan/domain/parsers/receipt_merchant_parser.dart';

/// Provider for OcrService (abstract type - DIP)
///
/// Following the Dependency Inversion Principle, this provider
/// exposes the abstraction (OcrService) rather than the concrete
/// implementation (ReceiptOcrServiceImpl).
final ocrServiceProvider = Provider<OcrService>((ref) {
  return ReceiptOcrServiceImpl();
});

/// Provider for ImagePickerService (abstract type - DIP)
///
/// Following the Dependency Inversion Principle, this provider
/// exposes the abstraction (ImagePickerService) rather than the concrete
/// implementation (ImagePickerServiceImpl).
final imagePickerServiceProvider = Provider<ImagePickerService>((ref) {
  return ImagePickerServiceImpl();
});

/// Provider for PermissionService (abstract type - DIP)
///
/// Following the Dependency Inversion Principle, this provider
/// exposes the abstraction (PermissionService) rather than the concrete
/// implementation (PermissionServiceImpl).
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionServiceImpl();
});

/// Provider for FileSaveService (abstract type - DIP)
///
/// Following the Dependency Inversion Principle, this provider
/// exposes the abstraction (FileSaveService) rather than the concrete
/// implementation (FileSaveServiceImpl).
///
/// This service uses Storage Access Framework (SAF) to save files,
/// allowing users to choose the save location through system file picker.
final fileSaveServiceProvider = Provider<FileSaveService>((ref) {
  return FileSaveServiceImpl();
});

/// Provider for ScanReceiptUseCase
final scanReceiptUseCaseProvider = Provider<ScanReceiptUseCase>((ref) {
  final ocrService = ref.read(ocrServiceProvider);
  final merchantParser = ref.read(receiptMerchantParserProvider);
  return ScanReceiptUseCase(ocrService, merchantParser);
});

/// Provider for InsightService
final insightServiceProvider = Provider<InsightService>((ref) {
  return InsightService();
});

/// Provider for MerchantPatternService (abstract type - DIP)
///
/// Following the Dependency Inversion Principle, this provider
/// exposes the abstraction (MerchantPatternService) rather than the concrete
/// implementation (IndonesianMerchantPatternServiceImpl).
final merchantPatternServiceProvider = Provider<MerchantPatternService>((ref) {
  return IndonesianMerchantPatternServiceImpl();
});

/// Provider for ReceiptMerchantParser
///
/// Parser for extracting merchant name from receipt text.
final receiptMerchantParserProvider = Provider<ReceiptMerchantParser>((ref) {
  final patternService = ref.read(merchantPatternServiceProvider);
  return ReceiptMerchantParser(patternService);
});
