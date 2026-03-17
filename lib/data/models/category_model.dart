import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';

/// Model untuk mapping kategori dari/to database
class CategoryModel {
  final int? id;
  final String name;
  final String type;
  final String color;
  final String? icon;
  final int sortOrder;
  final int isActive;
  final String createdAt;
  final String updatedAt;

  const CategoryModel({
    this.id,
    required this.name,
    required this.type,
    required this.color,
    this.icon,
    this.sortOrder = 0,
    this.isActive = 1,
    required this.createdAt,
    required this.updatedAt,
  });

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

  /// CopyWith method untuk immutable updates
  CategoryModel copyWith({
    int? id,
    String? name,
    String? type,
    String? color,
    String? icon,
    int? sortOrder,
    int? isActive,
    String? createdAt,
    String? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'CategoryModel{id: $id, name: $name, type: $type, color: $color, icon: $icon, sortOrder: $sortOrder, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          type == other.type &&
          color == other.color &&
          icon == other.icon &&
          sortOrder == other.sortOrder &&
          isActive == other.isActive &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      type.hashCode ^
      color.hashCode ^
      icon.hashCode ^
      sortOrder.hashCode ^
      isActive.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
}
