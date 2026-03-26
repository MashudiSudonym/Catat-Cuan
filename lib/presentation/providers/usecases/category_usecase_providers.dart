import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/domain/usecases/add_category_usecase.dart';
import 'package:catat_cuan/domain/usecases/deactivate_category_usecase.dart';
import 'package:catat_cuan/domain/usecases/get_categories.dart';
import 'package:catat_cuan/domain/usecases/get_categories_with_count_usecase.dart';
import 'package:catat_cuan/domain/usecases/reactivate_category_usecase.dart';
import 'package:catat_cuan/domain/usecases/reorder_categories_usecase.dart';
import 'package:catat_cuan/domain/usecases/search_categories_usecase.dart';
import 'package:catat_cuan/domain/usecases/update_category_usecase.dart';
import 'package:catat_cuan/presentation/providers/repositories/repository_providers.dart';

/// Provider untuk GetCategoriesUseCase
final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  return GetCategoriesUseCase(
    ref.read(categoryReadRepositoryProvider),
  );
});

/// Provider untuk GetCategoriesByTypeUseCase
final getCategoriesByTypeUseCaseProvider = Provider<GetCategoriesByTypeUseCase>((ref) {
  return GetCategoriesByTypeUseCase(
    ref.read(categoryReadRepositoryProvider),
  );
});

/// Provider untuk GetCategoryByIdUseCase
final getCategoryByIdUseCaseProvider = Provider<GetCategoryByIdUseCase>((ref) {
  return GetCategoryByIdUseCase(
    ref.read(categoryReadRepositoryProvider),
  );
});

/// Provider untuk AddCategoryUseCase
final addCategoryUseCaseProvider = Provider<AddCategoryUseCase>((ref) {
  return AddCategoryUseCase(
    ref.read(categoryWriteRepositoryProvider),
    ref.read(categoryReadRepositoryProvider),
  );
});

/// Provider untuk UpdateCategoryUseCase
final updateCategoryUseCaseProvider = Provider<UpdateCategoryUseCase>((ref) {
  return UpdateCategoryUseCase(
    ref.read(categoryWriteRepositoryProvider),
    ref.read(categoryReadRepositoryProvider),
  );
});

/// Provider untuk DeactivateCategoryUseCase
final deactivateCategoryUseCaseProvider = Provider<DeactivateCategoryUseCase>((ref) {
  return DeactivateCategoryUseCase(
    ref.read(categoryWriteRepositoryProvider),
    ref.read(categoryReadRepositoryProvider),
  );
});

/// Provider untuk GetCategoryTransactionCountUseCase
final getCategoryTransactionCountUseCaseProvider = Provider<GetCategoryTransactionCountUseCase>((ref) {
  return GetCategoryTransactionCountUseCase(
    ref.read(categoryReadRepositoryProvider),
  );
});

/// Provider untuk ReactivateCategoryUseCase
final reactivateCategoryUseCaseProvider = Provider<ReactivateCategoryUseCase>((ref) {
  return ReactivateCategoryUseCase(
    ref.read(categoryManagementRepositoryProvider),
    ref.read(categoryReadRepositoryProvider),
  );
});

/// Provider untuk ReorderCategoriesUseCase
final reorderCategoriesUseCaseProvider = Provider<ReorderCategoriesUseCase>((ref) {
  return ReorderCategoriesUseCase(
    ref.read(categoryManagementRepositoryProvider),
    ref.read(categoryReadRepositoryProvider),
  );
});

/// Provider untuk SearchCategoriesUseCase
final searchCategoriesUseCaseProvider = Provider<SearchCategoriesUseCase>((ref) {
  return SearchCategoriesUseCase(
    ref.read(categoryReadRepositoryProvider),
  );
});

/// Provider untuk SearchCategoriesByTypeUseCase
final searchCategoriesByTypeUseCaseProvider = Provider<SearchCategoriesByTypeUseCase>((ref) {
  return SearchCategoriesByTypeUseCase(
    ref.read(categoryReadRepositoryProvider),
  );
});

/// Provider untuk GetCategoriesWithCountUseCase
final getCategoriesWithCountUseCaseProvider = Provider<GetCategoriesWithCountUseCase>((ref) {
  return GetCategoriesWithCountUseCase(
    ref.read(categoryReadRepositoryProvider),
    ref.read(categoryManagementRepositoryProvider),
  );
});

/// Provider untuk GetCategoriesByTypeWithCountUseCase
final getCategoriesByTypeWithCountUseCaseProvider = Provider<GetCategoriesByTypeWithCountUseCase>((ref) {
  return GetCategoriesByTypeWithCountUseCase(
    ref.read(categoryReadRepositoryProvider),
  );
});

/// Provider untuk GetInactiveCategoriesWithCountUseCase
final getInactiveCategoriesWithCountUseCaseProvider = Provider<GetInactiveCategoriesWithCountUseCase>((ref) {
  return GetInactiveCategoriesWithCountUseCase(
    ref.read(categoryReadRepositoryProvider),
    ref.read(categoryManagementRepositoryProvider),
  );
});
