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
  return GetCategoriesUseCase(ref.read(categoryRepositoryProvider));
});

/// Provider untuk AddCategoryUseCase
final addCategoryUseCaseProvider = Provider<AddCategoryUseCase>((ref) {
  return AddCategoryUseCase(ref.read(categoryRepositoryProvider));
});

/// Provider untuk UpdateCategoryUseCase
final updateCategoryUseCaseProvider = Provider<UpdateCategoryUseCase>((ref) {
  return UpdateCategoryUseCase(ref.read(categoryRepositoryProvider));
});

/// Provider untuk DeactivateCategoryUseCase
final deactivateCategoryUseCaseProvider = Provider<DeactivateCategoryUseCase>((ref) {
  return DeactivateCategoryUseCase(ref.read(categoryRepositoryProvider));
});

/// Provider untuk ReactivateCategoryUseCase
final reactivateCategoryUseCaseProvider = Provider<ReactivateCategoryUseCase>((ref) {
  return ReactivateCategoryUseCase(ref.read(categoryRepositoryProvider));
});

/// Provider untuk ReorderCategoriesUseCase
final reorderCategoriesUseCaseProvider = Provider<ReorderCategoriesUseCase>((ref) {
  return ReorderCategoriesUseCase(ref.read(categoryRepositoryProvider));
});

/// Provider untuk SearchCategoriesUseCase
final searchCategoriesUseCaseProvider = Provider<SearchCategoriesUseCase>((ref) {
  return SearchCategoriesUseCase(ref.read(categoryRepositoryProvider));
});

/// Provider untuk GetCategoriesWithCountUseCase
final getCategoriesWithCountUseCaseProvider = Provider<GetCategoriesWithCountUseCase>((ref) {
  return GetCategoriesWithCountUseCase(ref.read(categoryRepositoryProvider));
});
