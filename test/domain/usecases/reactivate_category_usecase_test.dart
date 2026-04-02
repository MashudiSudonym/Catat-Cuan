import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_management_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';
import 'package:catat_cuan/domain/usecases/reactivate_category_usecase.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import '../../helpers/test_fixtures.dart';

@GenerateNiceMocks([
  MockSpec<CategoryManagementRepository>(),
  MockSpec<CategoryReadRepository>(),
])
import 'reactivate_category_usecase_test.mocks.dart';

void main() {
  late ReactivateCategoryUseCase useCase;
  late MockCategoryManagementRepository mockManagementRepository;
  late MockCategoryReadRepository mockReadRepository;

  setUp(() {
    mockManagementRepository = MockCategoryManagementRepository();
    mockReadRepository = MockCategoryReadRepository();
    useCase = ReactivateCategoryUseCase(mockManagementRepository, mockReadRepository);
  });

  group('ReactivateCategoryUseCase', () {
    test('should reactivate category successfully', () async {
      // Arrange
      final category = TestFixtures.categoryFood(id: 1, isActive: false);

      when(mockReadRepository.getCategoryById(1))
          .thenAnswer((_) async => Result.success(category));

      when(mockManagementRepository.reactivateCategory(1))
          .thenAnswer((_) async => Result.success(null));

      // Act
      final result = await useCase(1);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(mockReadRepository.getCategoryById(1)).called(1);
      verify(mockManagementRepository.reactivateCategory(1)).called(1);
    });

    test('should return not found failure when category does not exist', () async {
      // Arrange
      when(mockReadRepository.getCategoryById(999))
          .thenAnswer((_) async => Result.failure(NotFoundFailure('Kategori tidak ditemukan')));

      // Act
      final result = await useCase(999);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<NotFoundFailure>());
      verify(mockReadRepository.getCategoryById(999)).called(1);
      verifyNever(mockManagementRepository.reactivateCategory(any));
    });

    test('should return validation failure when category is already active', () async {
      // Arrange
      final category = TestFixtures.categoryFood(id: 1, isActive: true);

      when(mockReadRepository.getCategoryById(1))
          .thenAnswer((_) async => Result.success(category));

      // Act
      final result = await useCase(1);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, contains('Kategori sudah aktif'));
      verifyNever(mockManagementRepository.reactivateCategory(any));
    });

    test('should return database failure when management repository throws exception', () async {
      // Arrange
      final category = TestFixtures.categoryFood(id: 1, isActive: false);

      when(mockReadRepository.getCategoryById(1))
          .thenAnswer((_) async => Result.success(category));

      when(mockManagementRepository.reactivateCategory(1))
          .thenThrow(Exception('Database error'));

      // Act
      final result = await useCase(1);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<DatabaseFailure>());
      expect(result.failure?.message, contains('Gagal mengaktifkan kembali kategori'));
    });

    test('should return database failure when read repository throws exception', () async {
      // Arrange
      when(mockReadRepository.getCategoryById(1))
          .thenThrow(Exception('Database error'));

      // Act
      final result = await useCase(1);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<DatabaseFailure>());
      expect(result.failure?.message, contains('Gagal mengaktifkan kembali kategori'));
      verifyNever(mockManagementRepository.reactivateCategory(any));
    });

    test('should return database failure when getCategoryById returns null', () async {
      // Arrange
      when(mockReadRepository.getCategoryById(1))
          .thenAnswer((_) async => Result.failure(NotFoundFailure('Kategori tidak ditemukan')));

      // Act
      final result = await useCase(1);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<NotFoundFailure>());
      verifyNever(mockManagementRepository.reactivateCategory(any));
    });

    test('should return failure when reactivateCategory fails', () async {
      // Arrange
      final category = TestFixtures.categoryFood(id: 1, isActive: false);

      when(mockReadRepository.getCategoryById(1))
          .thenAnswer((_) async => Result.success(category));

      when(mockManagementRepository.reactivateCategory(1))
          .thenAnswer((_) async => Result.failure(DatabaseFailure('Failed to reactivate')));

      // Act
      final result = await useCase(1);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<DatabaseFailure>());
    });

    test('should extend UseCase with correct types', () {
      // Assert
      expect(useCase, isA<UseCase<void, int>>());
    });
  });
}
