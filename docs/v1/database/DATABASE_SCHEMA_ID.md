# Dokumentasi Skema Database (v1)

## Ringkasan

Catat Cuan menggunakan SQLite sebagai database lokal untuk penyimpanan data persisten. Database mengikuti prinsip Clean Architecture dengan pemisahan yang jelas antara data layer (repositories, data sources) dan domain layer (entities).

### Teknologi
- **Database**: SQLite (`catat_cuan.db`)
- **Package**: `sqflite` 2.4.1
- **Versi Saat Ini**: 2
- **Lokasi**: Direktori data aplikasi spesifik platform

### File Database
- **Schema Manager**: `lib/data/datasources/local/schema_manager.dart`
- **Database Helper**: `lib/data/datasources/local/database_helper.dart`

---

## Tabel

### 1. Tabel Categories

Menyimpan kategori pengeluaran/pemasukan dengan atribut visualnya.

| Kolom | Tipe | Konstrain | Deskripsi |
|-------|------|-----------|-----------|
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Identifier unik |
| `name` | TEXT | NOT NULL | Nama kategori (misalnya "Makanan", "Transport") |
| `type` | TEXT | NOT NULL CHECK | `'income'` atau `'expense'` |
| `color` | TEXT | NOT NULL | Kode warna hex (misalnya `"#FF5722"`) |
| `icon` | TEXT | NULLABLE | Identifier icon (opsional) |
| `sort_order` | INTEGER | NOT NULL DEFAULT 0 | Urutan tampilan |
| `is_active` | INTEGER | NOT NULL DEFAULT 1 | Flag soft delete (1 = aktif, 0 = dihapus) |
| `created_at` | TEXT | NOT NULL | Timestamp ISO8601 |
| `updated_at` | TEXT | NOT NULL | Timestamp ISO8601 |

#### Konstrain
```sql
CHECK(type IN ('income', 'expense'))
```

#### Konstanta Field
```dart
// Didefinisikan dalam lib/data/datasources/local/schema_manager.dart
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

### 2. Tabel Transactions

Menyimpan transaksi keuangan individual yang terhubung dengan kategori.

| Kolom | Tipe | Konstrain | Deskripsi |
|-------|------|-----------|-----------|
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Identifier unik |
| `amount` | REAL | NOT NULL CHECK | Jumlah transaksi (harus > 0) |
| `type` | TEXT | NOT NULL CHECK | `'income'` atau `'expense'` |
| `date_time` | TEXT | NOT NULL | Timestamp ISO8601 transaksi |
| `category_id` | INTEGER | NOT NULL FK | Referensi `categories(id)` |
| `note` | TEXT | NULLABLE | Catatan opsional |
| `created_at` | TEXT | NOT NULL | Timestamp ISO8601 |
| `updated_at` | TEXT | NOT NULL | Timestamp ISO8601 |

#### Konstrain
```sql
CHECK(type IN ('income', 'expense'))
CHECK(amount > 0)
FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT
```

#### Konstanta Field
```dart
// Didefinisikan dalam lib/data/datasources/local/schema_manager.dart
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

## Index

### Index Categories

| Nama Index | Kolom | Tujuan |
|------------|-------|--------|
| `idx_categories_type` | `type` | Filter cepat berdasarkan income/expense |
| `idx_categories_is_active` | `is_active` | Query soft delete |

### Index Transactions

| Nama Index | Kolom | Tujuan |
|------------|-------|--------|
| `idx_transactions_date_time` | `date_time DESC` | Pengurutan kronologis |
| `idx_transactions_category_id` | `category_id` | Filter berdasarkan kategori |
| `idx_transactions_type` | `type` | Filter income/expense |
| `idx_transactions_date_type` | `(date_time DESC, type)` | Query gabungan tanggal + tipe |
| `idx_transactions_month_type` | `(strftime('%Y-%m', date_time), type DESC)` | Agregasi bulanan (v2) |

---

## Relasi

### Diagram Entity-Relationship

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
   Satu kategori memiliki
   banyak transaksi
```

### Aturan Relasi
- **Tipe**: One-to-Many
- **Arah**: Satu Category → Banyak Transaction
- **Foreign Key**: `transactions.category_id` → `categories.id`
- **Konstrain Delete**: `ON DELETE RESTRICT` (mencegah transaksi orphan)

---

## Ringkasan Konstrain

| Tabel | Konstrain | Aturan |
|-------|-----------|-------|
| categories | CHECK | `type IN ('income', 'expense')` |
| transactions | CHECK | `type IN ('income', 'expense')` |
| transactions | CHECK | `amount > 0` |
| transactions | FOREIGN KEY | `category_id` → `categories.id)` |

---

## Riwayat Migrasi

### Versi 1 → Versi 2
**Ditambahkan**: Index agregasi bulanan

```sql
CREATE INDEX idx_transactions_month_type
ON transactions(strftime('%Y-%m', date_time), type DESC);
```

**Tujuan**: Mengoptimalkan query ringkasan bulanan untuk dashboard analitik.

### Migrasi Mendatang
Saat menambahkan migrasi baru di `schema_manager.dart`:

```dart
static Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    await _createMonthlyAggregationIndex(db);
  }
  // Tambahkan migrasi berikutnya di sini
  // if (oldVersion < 3) { ... }
}
```

---

## Mapping Entity

### CategoryEntity
```dart
// Lokasi: lib/domain/entities/category_entity.dart
class CategoryEntity {
  final int? id;
  final String name;
  final String type;  // 'income' atau 'expense'
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
// Lokasi: lib/domain/entities/transaction_entity.dart
class TransactionEntity {
  final int? id;
  final double amount;
  final String type;  // 'income' atau 'expense'
  final DateTime dateTime;
  final int categoryId;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

---

## Praktik Terbaik

### Format Timestamp
Semua timestamp disimpan sebagai string ISO8601:
```dart
final isoTimestamp = dateTime.toIso8601String();
// Contoh: "2026-03-27T10:30:00.000Z"
```

### Soft Delete
Kategori menggunakan soft delete melalui flag `is_active`:
```sql
-- Alih-alih DELETE
UPDATE categories SET is_active = 0 WHERE id = ?;

-- Query hanya kategori aktif
SELECT * FROM categories WHERE is_active = 1;
```

### Keamanan Foreign Key
Konstrain `ON DELETE RESTRICT` mencegah kehilangan data tidak disengaja:
```sql
-- Ini akan GAGAL jika transaksi mereferensi kategori
DELETE FROM categories WHERE id = ?;
```

---

## Dokumentasi Terkait

- **[Panduan Arsitektur](../guides/ARCHITECTURE.md)** - Implementasi data layer
- **[Prinsip SOLID](../guides/SOLID.md)** - SRP dalam manajemen skema
- **[Panduan AI Assistant](../AI_ASSISTANT_GUIDE.md)** - Referensi cepat

---

**Terakhir Diperbarui**: 2026-03-27
**Versi Skema**: 2
**Dikelola Oleh**: Tim Data Layer
