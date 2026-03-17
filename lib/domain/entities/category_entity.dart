/// Entity untuk merepresentasikan kategori transaksi
class CategoryEntity {
  final int? id;
  final String name;
  final CategoryType type;
  final String color;
  final String? icon;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryEntity({
    this.id,
    required this.name,
    required this.type,
    required this.color,
    this.icon,
    this.sortOrder = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// CopyWith method untuk immutable updates
  CategoryEntity copyWith({
    int? id,
    String? name,
    CategoryType? type,
    String? color,
    String? icon,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryEntity(
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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryEntity &&
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

  @override
  String toString() {
    return 'CategoryEntity{id: $id, name: $name, type: $type, color: $color, icon: $icon, sortOrder: $sortOrder, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

/// Enum untuk tipe kategori
enum CategoryType {
  income('income'),
  expense('expense');

  const CategoryType(this.value);

  final String value;

  /// Get enum dari string value
  static CategoryType fromString(String value) {
    return CategoryType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => CategoryType.expense,
    );
  }

  /// Get display name dalam Bahasa Indonesia
  String get displayName {
    switch (this) {
      case CategoryType.income:
        return 'Pemasukan';
      case CategoryType.expense:
        return 'Pengeluaran';
    }
  }
}
