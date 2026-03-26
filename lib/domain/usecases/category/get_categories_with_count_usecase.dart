import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/entities/category_with_count_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_management_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';
import 'categories_with_count_result.dart';

/// Use case untuk mengambil semua kategori dengan jumlah transaksi
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles getting categories with transaction count
/// - Dependency Inversion: Depends on CategoryReadRepository and CategoryManagementRepository abstractions
class GetCategoriesWithCountUseCase
    extends UseCase<CategoriesWithCountResult, NoParams> {
  final CategoryReadRepository _readRepository;
  final CategoryManagementRepository _managementRepository;

  GetCategoriesWithCountUseCase(this._readRepository, this._managementRepository);

  @override
  Future<Result<CategoriesWithCountResult>> call(NoParams params) async {
    try {
      // Ambil kategori aktif per tipe
      final incomeResult = await _getCategoriesWithCountByType(
        CategoryType.income,
      );

      if (incomeResult.isFailure) {
        return Result.failure(incomeResult.failure!);
      }

      final expenseResult = await _getCategoriesWithCountByType(
        CategoryType.expense,
      );

      if (expenseResult.isFailure) {
        return Result.failure(expenseResult.failure!);
      }

      // Ambil kategori tidak aktif
      final inactiveResult = await _getInactiveCategoriesWithCount();

      if (inactiveResult.isFailure) {
        return Result.failure(inactiveResult.failure!);
      }

      return Result.success(
        CategoriesWithCountResult(
          incomeCategories: incomeResult.data ?? [],
          expenseCategories: expenseResult.data ?? [],
          inactiveCategories: inactiveResult.data ?? [],
        ),
      );
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal mengambil kategori: $e'),
      );
    }
  }

  /// Internal method: ambil kategori dengan count berdasarkan tipe
  Future<Result<List<CategoryWithCountEntity>>> _getCategoriesWithCountByType(
    CategoryType type,
  ) async {
    try {
      final categoriesResult = await _readRepository.getCategoriesWithCount(type);

      if (categoriesResult.isFailure) {
        return Result.failure(categoriesResult.failure!);
      }

      final categories = categoriesResult.data ?? [];

      // Ambil transaction count untuk setiap kategori
      final result = <CategoryWithCountEntity>[];
      for (final category in categories) {
        if (category.id == null) continue;

        final countResult = await _readRepository.getTransactionCount(category.id!);

        final count = countResult.isSuccess
            ? (countResult.data ?? 0)
            : 0;

        result.add(CategoryWithCountEntity(
          category: category,
          transactionCount: count,
        ));
      }

      return Result.success(result);
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal mengambil kategori: $e'),
      );
    }
  }

  /// Internal method: ambil kategori tidak aktif dengan count
  Future<Result<List<CategoryWithCountEntity>>> _getInactiveCategoriesWithCount() async {
    try {
      final categoriesResult =
          await _managementRepository.getInactiveCategories();

      if (categoriesResult.isFailure) {
        return Result.failure(categoriesResult.failure!);
      }

      final categories = categoriesResult.data ?? [];

      // Ambil transaction count untuk setiap kategori
      final result = <CategoryWithCountEntity>[];
      for (final category in categories) {
        if (category.id == null) continue;

        final countResult = await _readRepository.getTransactionCount(category.id!);

        final count = countResult.isSuccess
            ? (countResult.data ?? 0)
            : 0;

        result.add(CategoryWithCountEntity(
          category: category,
          transactionCount: count,
        ));
      }

      return Result.success(result);
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal mengambil kategori: $e'),
      );
    }
  }
}
