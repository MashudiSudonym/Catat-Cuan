import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/services/ocr_service.dart';
import 'package:catat_cuan/domain/usecases/scan_receipt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<OcrService>(),
])
import 'scan_receipt_usecase_test.mocks.dart';

void main() {
  late ScanReceiptUseCase useCase;
  late MockOcrService mockOcrService;

  setUp(() {
    mockOcrService = MockOcrService();
    useCase = ScanReceiptUseCase(mockOcrService);
  });

  group('ScanReceiptUseCase', () {
    test('should extract amount from receipt text successfully', () async {
      // Arrange
      const imagePath = '/path/to/receipt.jpg';
      const ocrText = 'INDOMARET 15/03/2024 Total 75000';

      when(mockOcrService.extractText(imagePath))
          .thenAnswer((_) async => Result.success(ocrText));

      // Act
      final result = await useCase(imagePath);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.rawText, equals(ocrText));
      expect(result.data?.extractedAmount, equals(75000.0));
      expect(result.data?.confidenceScore, greaterThan(0));
      verify(mockOcrService.extractText(imagePath)).called(1);
    });

    test('should extract amount with various Indonesian formats', () async {
      // Arrange
      const imagePath = '/path/to/receipt.jpg';
      const ocrText = 'Total Rp 75.000,-';

      when(mockOcrService.extractText(imagePath))
          .thenAnswer((_) async => Result.success(ocrText));

      // Act
      final result = await useCase(imagePath);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.extractedAmount, equals(75000.0));
    });

    test('should return OcrFailure when OCR fails', () async {
      // Arrange
      const imagePath = '/path/to/receipt.jpg';

      when(mockOcrService.extractText(imagePath))
          .thenAnswer((_) async => Result.failure(OcrFailure('Gagal membaca struk')));

      // Act
      final result = await useCase(imagePath);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<OcrFailure>());
      expect(result.failure?.message, contains('Gagal membaca struk'));
    });

    test('should handle receipt with no amount found', () async {
      // Arrange
      const imagePath = '/path/to/receipt.jpg';
      const ocrText = 'Some text without amount';

      when(mockOcrService.extractText(imagePath))
          .thenAnswer((_) async => Result.success(ocrText));

      // Act
      final result = await useCase(imagePath);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.extractedAmount, isNull);
    });

    test('should calculate confidence score from parsers', () async {
      // Arrange
      const imagePath = '/path/to/receipt.jpg';
      const ocrText = 'Total 75000 15/03/2024';

      when(mockOcrService.extractText(imagePath))
          .thenAnswer((_) async => Result.success(ocrText));

      // Act
      final result = await useCase(imagePath);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.confidenceScore, greaterThan(0));
      expect(result.data?.confidenceScore, lessThanOrEqualTo(1.0));
    });

    test('should set scannedAt timestamp', () async {
      // Arrange
      const imagePath = '/path/to/receipt.jpg';
      const ocrText = 'Total 50000';
      final beforeScan = DateTime.now();

      when(mockOcrService.extractText(imagePath))
          .thenAnswer((_) async => Result.success(ocrText));

      // Act
      final result = await useCase(imagePath);
      final afterScan = DateTime.now();

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.scannedAt, isNotNull);
      final scannedAt = result.data!.scannedAt;
      expect(scannedAt.isAfter(beforeScan.subtract(const Duration(seconds: 1))), isTrue);
      expect(scannedAt.isBefore(afterScan.add(const Duration(seconds: 1))), isTrue);
    });

    test('should initialize with empty items list', () async {
      // Arrange
      const imagePath = '/path/to/receipt.jpg';
      const ocrText = 'Total 50000';

      when(mockOcrService.extractText(imagePath))
          .thenAnswer((_) async => Result.success(ocrText));

      // Act
      final result = await useCase(imagePath);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.items, isEmpty);
    });

    test('should initialize with null merchantName', () async {
      // Arrange
      const imagePath = '/path/to/receipt.jpg';
      const ocrText = 'Total 50000';

      when(mockOcrService.extractText(imagePath))
          .thenAnswer((_) async => Result.success(ocrText));

      // Act
      final result = await useCase(imagePath);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.merchantName, isNull);
    });
  });
}
