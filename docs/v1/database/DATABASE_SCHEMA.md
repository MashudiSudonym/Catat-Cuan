# Database Schema Documentation (v1)

## Overview

Catat Cuan uses SQLite as its local database for persistent storage. The database follows Clean Architecture principles with a clear separation between the data layer (repositories, data sources) and the domain layer (entities).

### Technology Stack
- **Database**: SQLite (`catat_cuan.db`)
- **Package**: `sqflite` 2.4.1
- **Current Version**: 2
- **Location**: Platform-specific app data directory

### Database Files
- **Schema Manager**: `lib/data/datasources/local/schema_manager.dart`
- **Database Helper**: `lib/data/datasources/local/database_helper.dart`

---

## Tables

### 1. Categories Table

Stores expense/income categories with their visual attributes.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique identifier |
| `name` | TEXT | NOT NULL | Category name (e.g., "Food", "Transport") |
| `type` | TEXT | NOT NULL CHECK | `'income'` or `'expense'` |
| `color` | TEXT | NOT NULL | Hex color code (e.g., `"#FF5722"`) |
| `icon` | TEXT | NULLABLE | Icon identifier (optional) |
| `sort_order` | INTEGER | NOT NULL DEFAULT 0 | Display sort order |
| `is_active` | INTEGER | NOT NULL DEFAULT 1 | Soft delete flag (1 = active, 0 = deleted) |
| `created_at` | TEXT | NOT NULL | ISO8601 timestamp |
| `updated_at` | TEXT | NOT NULL | ISO8601 timestamp |

#### Constraints
```sql
CHECK(type IN ('income', 'expense'))
```

#### Field Constants
```dart
// Defined in lib/data/datasources/local/schema_manager.dart
class CategoryFields {
  static const String id = 'id';
  static const String name = 'name';
  static const String type = 'type';
  static const String color = 'color';
  static const String icon = 'icon';
  static const String sortOrder = 'sort_order';
  static const String isActive = 'is_active';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}
```

---

### 2. Transactions Table

Stores individual financial transactions linked to categories.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique identifier |
| `amount` | REAL | NOT NULL CHECK | Transaction amount (must be > 0) |
| `type` | TEXT | NOT NULL CHECK | `'income'` or `'expense'` |
| `date_time` | TEXT | NOT NULL | ISO8601 timestamp of transaction |
| `category_id` | INTEGER | NOT NULL FK | References `categories(id)` |
| `note` | TEXT | NULLABLE | Optional notes |
| `created_at` | TEXT | NOT NULL | ISO8601 timestamp |
| `updated_at` | TEXT | NOT NULL | ISO8601 timestamp |

#### Constraints
```sql
CHECK(type IN ('income', 'expense'))
CHECK(amount > 0)
FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT
```

#### Field Constants
```dart
// Defined in lib/data/datasources/local/schema_manager.dart
class TransactionFields {
  static const String id = 'id';
  static const String amount = 'amount';
  static const String type = 'type';
  static const String dateTime = 'date_time';
  static const String categoryId = 'category_id';
  static const String note = 'note';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}
```

---

## Indexes

### Categories Indexes

| Index Name | Columns | Purpose |
|------------|---------|---------|
| `idx_categories_type` | `type` | Fast filtering by income/expense |
| `idx_categories_is_active` | `is_active` | Soft delete queries |

### Transactions Indexes

| Index Name | Columns | Purpose |
|------------|---------|---------|
| `idx_transactions_date_time` | `date_time DESC` | Chronological ordering |
| `idx_transactions_category_id` | `category_id` | Category-based filtering |
| `idx_transactions_type` | `type` | Income/expense filtering |
| `idx_transactions_date_type` | `(date_time DESC, type)` | Combined date + type queries |
| `idx_transactions_month_type` | `(strftime('%Y-%m', date_time), type DESC)` | Monthly aggregation (v2) |

---

## Relationships

### Entity-Relationship Diagram

```
┌─────────────────┐       ┌──────────────────┐
│   categories    │       │  transactions    │
├─────────────────┤       ├──────────────────┤
│ id (PK)         │──┐    │ id (PK)          │
│ name            │  └────│ category_id (FK) │
│ type            │       │ amount           │
│ color           │       │ type             │
│ icon            │       │ date_time        │
│ sort_order      │       │ note             │
│ is_active       │       │ created_at       │
│ created_at      │       │ updated_at       │
│ updated_at      │       └──────────────────┘
└─────────────────┘
         │
         │ 1:N
         │
         ▼
    One category has
    many transactions
```

### Relationship Rules
- **Type**: One-to-Many
- **Direction**: One Category → Many Transactions
- **Foreign Key**: `transactions.category_id` → `categories.id`
- **Delete Constraint**: `ON DELETE RESTRICT` (prevents orphaned transactions)

---

## Constraints Summary

| Table | Constraint | Rule |
|-------|-----------|------|
| categories | CHECK | `type IN ('income', 'expense')` |
| transactions | CHECK | `type IN ('income', 'expense')` |
| transactions | CHECK | `amount > 0` |
| transactions | FOREIGN KEY | `category_id` → `categories.id)` |

---

## Migration History

### Version 1 → Version 2
**Added**: Monthly aggregation index

```sql
CREATE INDEX idx_transactions_month_type
ON transactions(strftime('%Y-%m', date_time), type DESC);
```

**Purpose**: Optimize monthly summary queries for the analytics dashboard.

### Future Migrations
When adding new migrations in `schema_manager.dart`:

```dart
static Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    await _createMonthlyAggregationIndex(db);
  }
  // Add next migration here
  // if (oldVersion < 3) { ... }
}
```

---

## Entity Mapping

### CategoryEntity
```dart
// Location: lib/domain/entities/category_entity.dart
class CategoryEntity {
  final int? id;
  final String name;
  final String type;  // 'income' or 'expense'
  final String color;
  final String? icon;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### TransactionEntity
```dart
// Location: lib/domain/entities/transaction_entity.dart
class TransactionEntity {
  final int? id;
  final double amount;
  final String type;  // 'income' or 'expense'
  final DateTime dateTime;
  final int categoryId;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

---

## Best Practices

### Timestamp Format
All timestamps are stored as ISO8601 strings:
```dart
final isoTimestamp = dateTime.toIso8601String();
// Example: "2026-03-27T10:30:00.000Z"
```

### Soft Delete
Categories use soft delete via `is_active` flag:
```sql
-- Instead of DELETE
UPDATE categories SET is_active = 0 WHERE id = ?;

-- Query only active categories
SELECT * FROM categories WHERE is_active = 1;
```

### Foreign Key Safety
The `ON DELETE RESTRICT` constraint prevents accidental data loss:
```sql
-- This will FAIL if transactions reference the category
DELETE FROM categories WHERE id = ?;
```

---

## Related Documentation

- **[Architecture Guide](../guides/ARCHITECTURE.md)** - Data layer implementation
- **[SOLID Principles](../guides/SOLID.md)** - SRP in schema management
- **[AI Assistant Guide](../AI_ASSISTANT_GUIDE.md)** - Quick reference

---

**Last Updated**: 2026-03-27
**Schema Version**: 2
**Maintained By**: Data Layer Team
