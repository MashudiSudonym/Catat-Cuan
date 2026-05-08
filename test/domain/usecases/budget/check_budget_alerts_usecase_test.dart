import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/budget_alert_status_entity.dart';
import 'package:catat_cuan/domain/entities/budget_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/budget/budget_read_repository.dart';
import 'package:catat_cuan/domain/repositories/budget/budget_query_repository.dart';
import 'package:catat_cuan/domain/repositories/budget/budget_write_repository.dart';
import 'package:catat_cuan/domain/usecases/budget/check_budget_alerts_usecase.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<BudgetReadRepository>(),
  MockSpec<BudgetQueryRepository>(),
  MockSpec<BudgetWriteRepository>(),
])
import 'check_budget_alerts_usecase_test.mocks.dart';

void main() {
  late CheckBudgetAlertsUseCase useCase;
  late MockBudgetReadRepository mockReadRepo;
  late MockBudgetQueryRepository mockQueryRepo;
  late MockBudgetWriteRepository mockWriteRepo;

  setUp(() {
    AppLogger.initialize();
    mockReadRepo = MockBudgetReadRepository();
    mockQueryRepo = MockBudgetQueryRepository();
    mockWriteRepo = MockBudgetWriteRepository();
    useCase = CheckBudgetAlertsUseCase(
      readRepository: mockReadRepo,
      queryRepository: mockQueryRepo,
      writeRepository: mockWriteRepo,
    );
  });

  group('CheckBudgetAlertsUseCase', () {
    final now = DateTime.now();
    const categoryId = 1;
    const year = 2026;
    const month = 5;

    BudgetEntity makeBudget({
      int id = 1,
      double amount = 1000000.0,
    }) =>
        BudgetEntity(
          id: id,
          categoryId: categoryId,
          year: year,
          month: month,
          amount: amount,
          createdAt: now,
          updatedAt: now,
        );

    BudgetAlertStatus makeAlertStatus({
      int budgetId = 1,
      DateTime? warningShownAt,
      DateTime? limitShownAt,
      DateTime? overShownAt,
    }) =>
        BudgetAlertStatus(
          budgetId: budgetId,
          warningShownAt: warningShownAt,
          limitShownAt: limitShownAt,
          overShownAt: overShownAt,
        );

    void stubBudgetExists(BudgetEntity budget) {
      when(mockReadRepo.getBudgetByCategoryAndMonth(
        categoryId: anyNamed('categoryId'),
        year: anyNamed('year'),
        month: anyNamed('month'),
      )).thenAnswer((_) async => Result.success(budget));
    }

    void stubNoBudget() {
      when(mockReadRepo.getBudgetByCategoryAndMonth(
        categoryId: anyNamed('categoryId'),
        year: anyNamed('year'),
        month: anyNamed('month'),
      )).thenAnswer((_) async => Result.failure(
        NotFoundFailure('Budget not found'),
      ));
    }

    void stubSpent(double amount) {
      when(mockQueryRepo.getBudgetSpentForCategory(
        categoryId: anyNamed('categoryId'),
        year: anyNamed('year'),
        month: anyNamed('month'),
      )).thenAnswer((_) async => Result.success(amount));
    }

    void stubAlertStatus(BudgetAlertStatus status) {
      when(mockReadRepo.getAlertStatus(any)).thenAnswer(
        (_) async => Result.success(status),
      );
    }

    void stubUpdateAlertStatus() {
      when(mockWriteRepo.updateAlertStatus(
        budgetId: anyNamed('budgetId'),
        warningShownAt: anyNamed('warningShownAt'),
        limitShownAt: anyNamed('limitShownAt'),
        overShownAt: anyNamed('overShownAt'),
      )).thenAnswer((_) async => Result.success(null));
    }

    test('should return none when no budget exists for category+month', () async {
      // Arrange
      stubNoBudget();

      // Act
      final result = await useCase(const BudgetAlertParams(
        categoryId: categoryId,
        year: year,
        month: month,
      ));

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.type, equals(BudgetAlertType.none));
    });

    test('should return none when budget at 50% (below 75%)', () async {
      // Arrange
      final budget = makeBudget(amount: 1000000.0);
      stubBudgetExists(budget);
      stubSpent(500000.0); // 50%
      stubAlertStatus(makeAlertStatus());
      stubUpdateAlertStatus();

      // Act
      final result = await useCase(const BudgetAlertParams(
        categoryId: categoryId,
        year: year,
        month: month,
      ));

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.type, equals(BudgetAlertType.none));
    });

    test('should return warning when budget at 75% (first time)', () async {
      // Arrange
      final budget = makeBudget(amount: 1000000.0);
      stubBudgetExists(budget);
      stubSpent(750000.0); // 75%
      stubAlertStatus(makeAlertStatus()); // no alerts shown yet
      stubUpdateAlertStatus();

      // Act
      final result = await useCase(const BudgetAlertParams(
        categoryId: categoryId,
        year: year,
        month: month,
      ));

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.type, equals(BudgetAlertType.warning));
      expect(result.data?.spentAmount, equals(750000.0));
      verify(mockWriteRepo.updateAlertStatus(
        budgetId: 1,
        warningShownAt: anyNamed('warningShownAt'),
      )).called(1);
    });

    test('should return none when budget at 75% (already shown)', () async {
      // Arrange
      final budget = makeBudget(amount: 1000000.0);
      stubBudgetExists(budget);
      stubSpent(750000.0); // 75%
      stubAlertStatus(makeAlertStatus(warningShownAt: now)); // already shown!
      stubUpdateAlertStatus();

      // Act
      final result = await useCase(const BudgetAlertParams(
        categoryId: categoryId,
        year: year,
        month: month,
      ));

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.type, equals(BudgetAlertType.none));
      verifyNever(mockWriteRepo.updateAlertStatus(
        budgetId: anyNamed('budgetId'),
        warningShownAt: anyNamed('warningShownAt'),
        limitShownAt: anyNamed('limitShownAt'),
        overShownAt: anyNamed('overShownAt'),
      ));
    });

    test('should return limit when budget at 100% (first time)', () async {
      // Arrange
      final budget = makeBudget(amount: 1000000.0);
      stubBudgetExists(budget);
      stubSpent(1000000.0); // 100%
      stubAlertStatus(makeAlertStatus(warningShownAt: now)); // warning already shown
      stubUpdateAlertStatus();

      // Act
      final result = await useCase(const BudgetAlertParams(
        categoryId: categoryId,
        year: year,
        month: month,
      ));

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.type, equals(BudgetAlertType.limit));
      verify(mockWriteRepo.updateAlertStatus(
        budgetId: 1,
        limitShownAt: anyNamed('limitShownAt'),
      )).called(1);
    });

    test('should return over when budget exceeds 100% (first time)', () async {
      // Arrange
      final budget = makeBudget(amount: 1000000.0);
      stubBudgetExists(budget);
      stubSpent(1100000.0); // 110%
      stubAlertStatus(makeAlertStatus(
        warningShownAt: now,
        limitShownAt: now,
      )); // warning+limit already shown
      stubUpdateAlertStatus();

      // Act
      final result = await useCase(const BudgetAlertParams(
        categoryId: categoryId,
        year: year,
        month: month,
      ));

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.type, equals(BudgetAlertType.over));
      verify(mockWriteRepo.updateAlertStatus(
        budgetId: 1,
        overShownAt: anyNamed('overShownAt'),
      )).called(1);
    });

    test('should return none when budget exceeds 100% (already shown)', () async {
      // Arrange
      final budget = makeBudget(amount: 1000000.0);
      stubBudgetExists(budget);
      stubSpent(1100000.0); // 110%
      stubAlertStatus(makeAlertStatus(
        warningShownAt: now,
        limitShownAt: now,
        overShownAt: now, // all already shown
      ));
      stubUpdateAlertStatus();

      // Act
      final result = await useCase(const BudgetAlertParams(
        categoryId: categoryId,
        year: year,
        month: month,
      ));

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.type, equals(BudgetAlertType.none));
      verifyNever(mockWriteRepo.updateAlertStatus(
        budgetId: anyNamed('budgetId'),
        warningShownAt: anyNamed('warningShownAt'),
        limitShownAt: anyNamed('limitShownAt'),
        overShownAt: anyNamed('overShownAt'),
      ));
    });

    test('should not block on exception - returns none gracefully', () async {
      // Arrange
      when(mockReadRepo.getBudgetByCategoryAndMonth(
        categoryId: anyNamed('categoryId'),
        year: anyNamed('year'),
        month: anyNamed('month'),
      )).thenThrow(Exception('Database error'));

      // Act
      final result = await useCase(const BudgetAlertParams(
        categoryId: categoryId,
        year: year,
        month: month,
      ));

      // Assert - T-02-04: Alert check must not block, returns none on error
      expect(result.isSuccess, isTrue);
      expect(result.data?.type, equals(BudgetAlertType.none));
    });
  });
}
