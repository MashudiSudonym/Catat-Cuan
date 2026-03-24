import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/usecases/add_category_usecase.dart';
import 'package:catat_cuan/domain/usecases/update_category_usecase.dart';
import 'package:catat_cuan/presentation/providers/usecases/category_usecase_providers.dart';

/// Provider untuk CategoryFormNotifier
/// Following DIP: Injects UseCase dependencies through constructor
final categoryFormProvider =
    StateNotifierProvider<CategoryFormNotifier, CategoryFormState>((ref) {
  return CategoryFormNotifier(
    ref.read(addCategoryUseCaseProvider),
    ref.read(updateCategoryUseCaseProvider),
  );
});

/// State untuk category form
class CategoryFormState {
  final String name;
  final CategoryType type;
  final String color;
  final String? icon;
  final Map<String, String> validationErrors;
  final bool isSubmitting;
  final String? submitError;
  final bool isEditMode;
  final CategoryEntity? editingCategory;

  const CategoryFormState({
    this.name = '',
    required this.type,
    this.color = '',
    this.icon,
    this.validationErrors = const {},
    this.isSubmitting = false,
    this.submitError,
    this.isEditMode = false,
    this.editingCategory,
  });

  CategoryFormState copyWith({
    String? name,
    CategoryType? type,
    String? color,
    String? icon,
    Map<String, String>? validationErrors,
    bool? isSubmitting,
    String? submitError,
    bool? isEditMode,
    CategoryEntity? editingCategory,
  }) {
    return CategoryFormState(
      name: name ?? this.name,
      type: type ?? this.type,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      validationErrors: validationErrors ?? this.validationErrors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError ?? this.submitError,
      isEditMode: isEditMode ?? this.isEditMode,
      editingCategory: editingCategory ?? this.editingCategory,
    );
  }

  /// Check apakah form valid
  bool get isValid {
    return name.trim().length >= 2 &&
        name.trim().length <= 50 &&
        validationErrors.isEmpty;
  }
}

/// Notifier untuk category form
class CategoryFormNotifier extends StateNotifier<CategoryFormState> {
  final AddCategoryUseCase _addCategoryUseCase;
  final UpdateCategoryUseCase _updateCategoryUseCase;

  CategoryFormNotifier(
    this._addCategoryUseCase,
    this._updateCategoryUseCase,
  ) : super(const CategoryFormState(
          type: CategoryType.expense, // Default: Pengeluaran
        ));

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
  Future<void> loadById(Ref ref, int categoryId) async {
    final getCategoriesUseCase = ref.read(getCategoriesUseCaseProvider);
    try {
      final category = await getCategoriesUseCase.executeById(categoryId);
      if (category != null) {
        loadForEdit(category);
      } else {
        throw Exception('Kategori tidak ditemukan');
      }
    } catch (e) {
      state = state.copyWith(submitError: e.toString());
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
    state = const CategoryFormState(
      type: CategoryType.expense,
    );
  }

  /// Submit form
  Future<bool> submit() async {
    // Clear previous error
    state = state.copyWith(submitError: null);

    // Validasi form
    if (!state.isValid) {
      state = state.copyWith(
        submitError: 'Mohon lengkapi semua field yang wajib diisi',
      );
      return false;
    }

    state = state.copyWith(
      isSubmitting: true,
      submitError: null,
    );

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

      // Execute use case
      if (state.isEditMode) {
        await _updateCategoryUseCase.execute(category);
      } else {
        await _addCategoryUseCase.execute(category);
      }

      // Reset form setelah sukses
      resetForm();
      return true;
    } catch (e) {
      state = state.copyWith(
        submitError: e.toString(),
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
