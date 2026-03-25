import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:catat_cuan/presentation/utils/error/error_message_mapper.dart';
import 'package:catat_cuan/presentation/states/category_form_state.dart';

// Export the state for use in UI
export 'package:catat_cuan/presentation/states/category_form_state.dart';

import 'package:catat_cuan/presentation/providers/usecases/category_usecase_providers.dart';

part 'category_form_provider.g.dart';

/// Provider untuk category form
/// Following SRP: Only manages form state and submission
/// Following DIP: Depends on UseCase abstractions
/// Uses @riverpod annotation for modern Riverpod patterns without constructor side effects
@riverpod
class CategoryFormNotifier extends _$CategoryFormNotifier {
  @override
  CategoryFormState build() {
    // No constructor side effects - initialize state in build()
    return const CategoryFormState(
      type: CategoryType.expense, // Default: Pengeluaran
    );
  }

  /// Set nama kategori
  void setName(String value) {
    final errors = Map<String, String>.from(state.validationErrors);

    // Validasi nama (min 2, max 50 karakter)
    if (value.trim().length < 2) {
      errors['name'] = 'Nama kategori minimal 2 karakter';
    } else if (value.trim().length > 50) {
      errors['name'] = 'Nama kategori maksimal 50 karakter';
    } else {
      errors.remove('name');
    }

    state = state.copyWith(
      name: value,
      validationErrors: errors,
    );
  }

  /// Set tipe kategori (hanya untuk mode create)
  void setType(CategoryType type) {
    if (state.isEditMode) {
      // Tipe tidak boleh diubah saat edit mode
      return;
    }
    state = state.copyWith(type: type);
  }

  /// Set warna kategori
  void setColor(String color) {
    state = state.copyWith(color: color);
  }

  /// Set icon kategori
  void setIcon(String? icon) {
    state = state.copyWith(icon: icon);
  }

  /// Load kategori untuk edit
  void loadForEdit(CategoryEntity category) {
    state = CategoryFormState(
      name: category.name,
      type: category.type,
      color: category.color,
      icon: category.icon,
      isEditMode: true,
      editingCategory: category,
    );
  }

  /// Load kategori untuk edit berdasarkan ID
  Future<void> loadById(int categoryId) async {
    final getCategoriesUseCase = ref.read(getCategoriesUseCaseProvider);
    try {
      final category = await getCategoriesUseCase.executeById(categoryId);
      if (category != null) {
        loadForEdit(category);
      } else {
        throw Exception('Kategori tidak ditemukan');
      }
    } catch (e, stackTrace) {
      AppLogger.e('Failed to load category by ID: $categoryId', e, stackTrace);
      rethrow;
    }
  }

  /// Initialize dengan tipe tertentu (untuk quick add dari transaction form)
  void initializeWithType(CategoryType type) {
    state = CategoryFormState(
      type: type,
    );
  }

  /// Reset form ke default
  void resetForm() {
    ref.invalidateSelf();
  }

  /// Submit form
  Future<bool> submit() async {
    AppLogger.d('Submitting category form: ${state.isEditMode ? "edit" : "add"} mode');

    // Clear previous error
    state = state.copyWith(submitError: null);

    // Validasi form
    if (!state.isValid) {
      AppLogger.w('Category form validation failed');
      state = state.copyWith(
        submitError: 'Mohon lengkapi semua field yang wajib diisi',
      );
      return false;
    }

    state = state.copyWith(
      isSubmitting: true,
      submitError: null,
    );

    final addCategoryUseCase = ref.read(addCategoryUseCaseProvider);
    final updateCategoryUseCase = ref.read(updateCategoryUseCaseProvider);

    try {
      // Buat entity kategori
      final category = CategoryEntity(
        id: state.editingCategory?.id,
        name: state.name.trim(),
        type: state.type,
        color: state.color,
        icon: state.icon,
        sortOrder: state.editingCategory?.sortOrder ?? 999,
        isActive: true,
        createdAt: state.editingCategory?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      AppLogger.i('Executing category use case: '
          '${state.type.value} - ${state.name.trim()}');

      // Execute use case
      if (state.isEditMode) {
        await updateCategoryUseCase.execute(category);
        AppLogger.i('Category updated successfully');
      } else {
        await addCategoryUseCase.execute(category);
        AppLogger.i('Category added successfully');
      }

      // Reset form setelah sukses
      state = const CategoryFormState(
        type: CategoryType.expense,
      );
      return true;
    } catch (e, stackTrace) {
      final userMessage = ErrorMessageMapper.getUserMessage(e);
      AppLogger.e('Category form submit failed', e, stackTrace);
      state = state.copyWith(
        submitError: userMessage,
        isSubmitting: false,
      );
      return false;
    } finally {
      if (state.submitError == null) {
        state = state.copyWith(isSubmitting: false);
      }
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(submitError: null);
  }
}
