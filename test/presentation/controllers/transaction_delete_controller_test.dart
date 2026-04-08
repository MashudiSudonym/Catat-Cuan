import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/presentation/controllers/transaction_delete_controller.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../presentation_mocks.mocks.dart';

void main() {
  // Initialize logger for tests
  setUpAll(() {
    AppLogger.initialize();
  });

  late TransactionDeleteController controller;
  late MockDeleteTransactionUseCase mockDeleteUseCase;
  late MockDeleteMultipleTransactionsUseCase mockBatchDeleteUseCase;

  setUp(() {
    mockDeleteUseCase = MockDeleteTransactionUseCase();
    mockBatchDeleteUseCase = MockDeleteMultipleTransactionsUseCase();
    controller = TransactionDeleteController(
      mockDeleteUseCase,
      mockBatchDeleteUseCase,
    );
  });

  group('TransactionDeleteController', () {
    test('should delete single transaction successfully', () async {
      // Arrange
      when(mockDeleteUseCase.execute(any))
          .thenAnswer((_) async => Result.success(null));

      // Act
      await controller.deleteTransaction(1);

      // Assert
      verify(mockDeleteUseCase.execute(1)).called(1);
    });

    test('should handle empty batch delete list', () async {
      // Arrange - Empty list
      final ids = <int>[];
      when(mockBatchDeleteUseCase.execute(any))
          .thenAnswer((_) async => Result.success(null));

      // Act
      await controller.deleteBatch(ids);

      // Assert - Should call the use case even with empty list
      verify(mockBatchDeleteUseCase.execute(ids)).called(1);
    });

    test('should call batch delete use case with IDs', () async {
      // Arrange
      final ids = [1, 2, 3];
      when(mockBatchDeleteUseCase.execute(any))
          .thenAnswer((_) async => Result.success(null));

      // Act
      await controller.deleteBatch(ids);

      // Assert
      verify(mockBatchDeleteUseCase.execute(ids)).called(1);
    });

    test('should handle single deletion failure gracefully', () async {
      // Arrange
      when(mockDeleteUseCase.execute(any))
          .thenAnswer((_) async => Result.failure(const DatabaseFailure('Delete failed')));

      // Act - No exception should be thrown
      await controller.deleteTransaction(1);

      // Assert - Use case was called despite failure
      verify(mockDeleteUseCase.execute(1)).called(1);
    });

    test('should handle batch deletion failure gracefully', () async {
      // Arrange
      final ids = [1, 2, 3];
      when(mockBatchDeleteUseCase.execute(any))
          .thenAnswer((_) async => Result.failure(const DatabaseFailure('Batch delete failed')));

      // Act - No exception should be thrown
      await controller.deleteBatch(ids);

      // Assert - Use case was called despite failure
      verify(mockBatchDeleteUseCase.execute(ids)).called(1);
    });
  });
}
