import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_model.freezed.dart';

/// Model untuk mapping kategori dari/to database
@freezed
abstract class CategoryModel with _$CategoryModel {
  const CategoryModel._();

  const factory CategoryModel({
    /// Primary key dari database (nullable untuk kategori baru)
    int? id,

    /// Nama kategori
    required String name,

    /// Tipe kategori sebagai string (income/expense) untuk database
    required String type,

    /// Warna kategori (hex code)
    required String color,

    /// Icon kategori (optional)
    String? icon,

    /// Urutan pengurutan
    @Default(0) int sortOrder,

    /// Status aktif/non-aktif sebagai integer (1/0) untuk database
    @Default(1) int isActive,

    /// Waktu pembuatan record sebagai ISO8601 string untuk database
    required String createdAt,

    /// Waktu terakhir update sebagai ISO8601 string untuk database
    required String updatedAt,
  }) = _CategoryModel;

  /// Convert dari Map (database row) ke CategoryModel
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map[CategoryFields.id] as int?,
      name: map[CategoryFields.name]?.toString() ?? 'Kategori Tanpa Nama',
      type: map[CategoryFields.type]?.toString() ?? 'expense',
      color: map[CategoryFields.color]?.toString() ?? '#6B7280',
      icon: map[CategoryFields.icon]?.toString(),
      sortOrder: map[CategoryFields.sortOrder] as int? ?? 0,
      isActive: map[CategoryFields.isActive] as int? ?? 1,
      createdAt: map[CategoryFields.createdAt]?.toString() ?? DateTime.now().toIso8601String(),
      updatedAt: map[CategoryFields.updatedAt]?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  /// Convert dari CategoryModel ke Map (untuk database insert/update)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) CategoryFields.id: id,
      CategoryFields.name: name,
      CategoryFields.type: type,
      CategoryFields.color: color,
      CategoryFields.icon: icon,
      CategoryFields.sortOrder: sortOrder,
      CategoryFields.isActive: isActive,
      CategoryFields.createdAt: createdAt,
      CategoryFields.updatedAt: updatedAt,
    };
  }

  /// Convert dari CategoryModel ke CategoryEntity
  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      type: CategoryType.fromString(type),
      color: color,
      icon: icon,
      sortOrder: sortOrder,
      isActive: isActive == 1,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  /// Convert dari CategoryEntity ke CategoryModel
  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      type: entity.type.value,
      color: entity.color,
      icon: entity.icon,
      sortOrder: entity.sortOrder,
      isActive: entity.isActive ? 1 : 0,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }
}
