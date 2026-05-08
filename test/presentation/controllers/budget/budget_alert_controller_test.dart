import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/budget_entity.dart';
import 'package:catat_cuan/domain/usecases/budget/check_budget_alerts_usecase.dart';
import 'package:catat_cuan/presentation/controllers/budget/budget_alert_controller.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<CheckBudgetAlertsUseCase>(),
])
import 'budget_alert_controller_test.mocks.dart';

void main() {
  late BudgetAlertController controller;
  late MockCheckBudgetAlertsUseCase mockUseCase;

  setUp(() {
    AppLogger.initialize();
    mockUseCase = MockCheckBudgetAlertsUseCase();
    controller = BudgetAlertController(mockUseCase);
  });

  group('BudgetAlertController', () {
    test('returns none when no budget exists', () async {
      // Arrange
      when(mockUseCase(any)).thenAnswer(
        (_) async => Result.success(const BudgetAlertResult(
          type: BudgetAlertType.none,
        )),
      );

      // Act
      final result = await controller.checkAlertsAfterTransaction(
        categoryId: 99,
        year: 2026,
        month: 5,
      );

      // Assert
      expect(result, equals(BudgetAlertType.none));
    });

    test('returns warning when 75% crossed', () async {
      // Arrange
      final budget = BudgetEntity(
        id: 1,
        categoryId: 1,
        year: 2026,
        month: 5,
        amount: 1000000.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockUseCase(any)).thenAnswer(
        (_) async => Result.success(BudgetAlertResult(
          type: BudgetAlertType.warning,
          budget: budget,
          spentAmount: 750000.0,
        )),
      );

      // Act
      final result = await controller.checkAlertsAfterTransaction(
        categoryId: 1,
        year: 2026,
        month: 5,
      );

      // Assert
      expect(result, equals(BudgetAlertType.warning));
    });

    test('returns none when alert already shown', () async {
      // Arrange
      when(mockUseCase(any)).thenAnswer(
        (_) async => Result.success(const BudgetAlertResult(
          type: BudgetAlertType.none,
        )),
      );

      // Act
      final result = await controller.checkAlertsAfterTransaction(
        categoryId: 1,
        year: 2026,
        month: 5,
      );

      // Assert
      expect(result, equals(BudgetAlertType.none));
    });

    test('returns none on exception (does not block)', () async {
      // Arrange
      when(mockUseCase(any)).thenThrow(Exception('Database error'));

      // Act
      final result = await controller.checkAlertsAfterTransaction(
        categoryId: 1,
        year: 2026,
        month: 5,
      );

      // Assert - per T-02-04: must not block, returns none on error
      expect(result, equals(BudgetAlertType.none));
    });
  });
}
