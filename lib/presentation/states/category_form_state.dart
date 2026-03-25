import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_form_state.freezed.dart';

/// State untuk category form
@freezed
abstract class CategoryFormState with _$CategoryFormState {
  const CategoryFormState._();

  const factory CategoryFormState({
    /// Nama kategori
    @Default('') String name,

    /// Tipe kategori
    required CategoryType type,

    /// Warna kategori (hex code)
    @Default('') String color,

    /// Icon kategori
    String? icon,

    /// Validation errors map
    @Default({}) Map<String, String> validationErrors,

    /// Sedang mengirim data
    @Default(false) bool isSubmitting,

    /// Error message dari submit
    String? submitError,

    /// Mode edit
    @Default(false) bool isEditMode,

    /// Kategori yang sedang diedit
    CategoryEntity? editingCategory,
  }) = _CategoryFormState;

  /// Check apakah form valid
  bool get isValid {
    return name.trim().length >= 2 &&
        name.trim().length <= 50 &&
        validationErrors.isEmpty;
  }
}
