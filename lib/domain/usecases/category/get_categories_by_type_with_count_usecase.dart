import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/entities/category_with_count_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';

/// Use case untuk mengambil kategori dengan count berdasarkan tipe
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles getting categories by type with count
/// - Dependency Inversion: Depends on CategoryReadRepository abstraction
class GetCategoriesByTypeWithCountUseCase extends UseCase<List<CategoryWithCountEntity>, CategoryType> {
  final CategoryReadRepository _readRepository;

  GetCategoriesByTypeWithCountUseCase(this._readRepository);

  @override
  Future<Result<List<CategoryWithCountEntity>>> call(CategoryType type) async {
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
}
