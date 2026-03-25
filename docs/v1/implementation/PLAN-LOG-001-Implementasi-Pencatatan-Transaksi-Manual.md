# PLAN – Pencatatan Transaksi Manual

## 1. Ringkasan Singkat

Membangun fitur pencatatan transaksi manual (pemasukan/pengeluaran) pada aplikasi mobile Flutter dengan database SQLite lokal. Fitur ini mencakup form input dengan validasi real-time, operasi CRUD transaksi, daftar transaksi dengan filter/sort, serta manajemen kategori untuk pengorganisasian transaksi.

## 2. Asumsi & Dependency

### Asumsi Teknis
- Project Flutter belum ada, akan diinisiasi dari awal
- Menggunakan **Clean Architecture** dengan pemisahan layer: Domain, Data, Presentation
- **State Management**: Riverpod (final choice: ✅ Riverpod)
- **Database**: SQLite dengan package `sqflite`
- **Form Validation**: Menggunakan `flutter_form_validation` (final choice: ✅ flutter_form_validation)
- **Testing**: High priority dengan target 80%+ coverage (final choice: ✅ High priority)
- Tidak ada fitur sinkronisasi cloud pada versi ini (offline-first)

### Dependency dengan Fitur Lain
- **Kategori**: Fitur ini memerlukan manajemen kategori (SPEC-LOG-004) untuk dropdown pilihan kategori. Default categories akan di-seed saat first launch.
- **Dashboard**: Data transaksi yang dicatat akan dikonsumsi oleh fitur dashboard/summary (SPEC-LOG-003)
- **OCR**: Fitur pencatatan manual adalah baseline; OCR receipt (SPEC-LOG-002) adalah alternative input method yang terpisah

### Asumsi UX
- Aplikasi mobile-first, fokus pada Android
- Target waktu input: ≤ 20 detik per transaksi
- Bahasa: Indonesia
- Format mata uang: Rp (Rupiah) dengan pemisah ribuan
- Timezone: Menggunakan timezone device lokal

## 3. Fase Implementasi

---

### Phase 1: Project Setup & Foundation

**Tujuan**: Menyiapkan project structure Flutter dengan arsitektur Clean Architecture dan dependencies dasar.

#### TASK-LOG-001: Inisiasi Project Flutter
- **Deskripsi**: Buat project Flutter baru dengan nama `catat_cuan`, setup pubspec.yaml dengan dependencies yang diperlukan (sqflite, riverpod, path_provider, intl, dll).
- **File terkait**: `pubspec.yaml`, `android/`, `ios/`
- **Coverage**: N/A (setup awal)

#### TASK-LOG-002: Setup Struktur Folder Clean Architecture
- **Deskripsi**: Buat struktur folder: `lib/domain/`, `lib/data/`, `lib/presentation/`. Sub-folder: entities, repositories (domain); models, datasources, repositories (data); screens, widgets, providers (presentation).
- **File terkait**: `lib/domain/`, `lib/data/`, `lib/presentation/`
- **Coverage**: N/A (setup awal)

#### TASK-LOG-003: Setup Database Helper & Connection
- **Deskripsi**: Buat `DatabaseHelper` class untuk manage SQLite connection, create database, versioning. Setup nama database dan table structure.
- **File terkait**: `lib/data/datasources/local/database_helper.dart`
- **Coverage**: REQ-LOG-003, NFR-LOG-003

---

### Phase 2: Domain Layer - Entities & Use Cases

**Tujuan**: Mendefinisikan core business logic dan contract.

#### TASK-LOG-004: Buat Entity Transaction
- **Deskripsi**: Definisikan class `TransactionEntity` dengan field: id, amount, type (enum), dateTime, categoryId, note, createdAt, updatedAt.
- **File terkait**: `lib/domain/entities/transaction_entity.dart`
- **Coverage**: REQ-LOG-001.1, REQ-LOG-003.1

#### TASK-LOG-005: Buat Entity Category
- **Deskripsi**: Definisikan class `CategoryEntity` dengan field: id, name, type, color, icon, sortOrder, isActive.
- **File terkait**: `lib/domain/entities/category_entity.dart`
- **Coverage**: REQ-LOG-001.1 (kategori), dependency untuk fitur kategori

#### TASK-LOG-006: Definisikan Transaction Repository Interface
- **Deskripsi**: Buat abstract class `TransactionRepository` dengan method: addTransaction(), getTransactions(), getTransactionById(), updateTransaction(), deleteTransaction(), getTransactionsByFilter().
- **File terkait**: `lib/domain/repositories/transaction_repository.dart`
- **Coverage**: REQ-LOG-003, REQ-LOG-005, REQ-LOG-006, REQ-LOG-007

#### TASK-LOG-007: Buat Use Case Add Transaction
- **Deskripsi**: Implementasi use case untuk menambah transaksi baru dengan validasi input. Mengembalikan `Result<TransactionEntity, Failure>`.
- **File terkait**: `lib/domain/usecases/add_transaction.dart`
- **Coverage**: REQ-LOG-002, REQ-LOG-003, REQ-LOG-004

#### TASK-LOG-008: Buat Use Case Get Transactions
- **Deskripsi**: Implementasi use case untuk mengambil list transaksi dengan filter dan sorting. Default sort by dateTime descending.
- **File terkait**: `lib/domain/usecases/get_transactions.dart`
- **Coverage**: REQ-LOG-005.1, REQ-LOG-005.2, REQ-LOG-005.3

#### TASK-LOG-009: Buat Use Case Update & Delete Transaction
- **Deskripsi**: Implementasi use case untuk update dan delete transaksi dengan proper error handling.
- **File terkait**: `lib/domain/usecases/update_transaction.dart`, `lib/domain/usecases/delete_transaction.dart`
- **Coverage**: REQ-LOG-006, REQ-LOG-007

#### TASK-LOG-010: Buat Use Case Get Categories
- **Deskripsi**: Implementasi use case untuk mengambil list kategori aktif, filtered by type (pemasukan/pengeluaran).
- **File terkait**: `lib/domain/usecases/get_categories.dart`
- **Coverage**: REQ-LOG-001.1 (kategori)

---

### Phase 3: Data Layer - Models & Repository Implementation

**Tujuan**: Implementasi database operations dan data mapping.

#### TASK-LOG-011: Buat Transaction Model
- **Deskripsi**: Buat `TransactionModel` untuk mapping dari/to database rows. Include methods: fromMap(), toMap(), fromEntity(), toEntity().
- **File terkait**: `lib/data/models/transaction_model.dart`
- **Coverage**: REQ-LOG-003.1

#### TASK-LOG-012: Buat Category Model
- **Deskripsi**: Buat `CategoryModel` untuk mapping dari/to database rows. Include methods: fromMap(), toMap(), fromEntity(), toEntity().
- **File terkait**: `lib/data/models/category_model.dart`
- **Coverage**: Dependency untuk kategori

#### TASK-LOG-013: Implementasi Transaction Repository
- **Deskripsi**: Implement concrete class `TransactionRepositoryImpl` dengan SQLite operations. Include query builder untuk filter by date range, category, type.
- **File terkait**: `lib/data/repositories/transaction_repository_impl.dart`
- **Coverage**: REQ-LOG-003, REQ-LOG-005.3

#### TASK-LOG-014: Implementasi Category Repository
- **Deskripsi**: Implement concrete class `CategoryRepositoryImpl` dengan SQLite operations. Include method untuk seed default categories.
- **File terkait**: `lib/data/repositories/category_repository_impl.dart`
- **Coverage**: Dependency untuk kategori

#### TASK-LOG-015: Buat Database Schema & Migration
- **Deskripsi**: Implementasi CREATE TABLE statements untuk transactions dan categories. Setup indexing untuk performa query (index pada dateTime, categoryId).
- **File terkait**: `lib/data/datasources/local/database_helper.dart` (bagian schema)
- **Coverage**: REQ-LOG-003.1, NFR-LOG-002, NFR-LOG-004

#### TASK-LOG-016: Seed Default Categories
- **Deskripsi**: Implementasi logic untuk insert default categories saat first launch atau jika tabel categories kosong.
- **File terkait**: `lib/data/datasources/local/category_seed.dart`
- **Coverage**: Dependency untuk kategori (default data)

---

### Phase 4: Presentation Layer - State Management

**Tujuan**: Setup Riverpod providers untuk state management.

#### TASK-LOG-017: Buat Transaction Form StateNotifier
- **Deskripsi**: Implementasi `TransactionFormNotifier` untuk manage form state: nominal, type, date, time, categoryId, note, validation errors, isSubmitting.
- **File terkait**: `lib/presentation/providers/transaction_form_provider.dart`
- **Coverage**: REQ-LOG-001, REQ-LOG-002, REQ-LOG-004

#### TASK-LOG-018: Buat Transaction List StateNotifier
- **Deskripsi**: Implementasi `TransactionListNotifier` untuk manage list state: transactions, loading, error, filter state.
- **File terkait**: `lib/presentation/providers/transaction_list_provider.dart`
- **Coverage**: REQ-LOG-005, NFR-LOG-004

#### TASK-LOG-019: Buat Category List Provider
- **Deskripsi**: Implementasi provider untuk mengambil list kategori aktif berdasarkan tipe (pemasukan/pengeluaran).
- **File terkait**: `lib/presentation/providers/category_provider.dart`
- **Coverage**: REQ-LOG-001.1 (kategori)

---

### Phase 5: Presentation Layer - UI Implementation

**Tujuan**: Build UI screens sesuai spesifikasi.

#### TASK-LOG-020: Buat Transaction Form Screen
- **Deskripsi**: Implementasi screen form input dengan field: nominal (TextInput + format currency), type (SegmentedButton/Segment), date (DatePicker), time (TimePicker), category (Dropdown), note (TextField). Setup smart defaults.
- **File terkait**: `lib/presentation/screens/transaction_form_screen.dart`
- **Coverage**: REQ-LOG-001.1, REQ-LOG-001.2, AC-LOG-001.1, AC-LOG-001.2

#### TASK-LOG-021: Implementasi Form Validation UI
- **Deskripsi**: Tambahkan validation feedback UI untuk setiap field. Error message display di bawah field. Disable submit button jika invalid.
- **File terkait**: `lib/presentation/screens/transaction_form_screen.dart` (bagian validation), `lib/presentation/widgets/validated_text_field.dart`
- **Coverage**: REQ-LOG-002, AC-LOG-002.1, AC-LOG-002.2, AC-LOG-002.3, NFR-LOG-006

#### TASK-LOG-022: Implementasi Form Submit Behavior
- **Deskripsi**: Implementasi submit handler dengan loading state. Show snackbar sukses. Reset form setelah sukses.
- **File terkait**: `lib/presentation/screens/transaction_form_screen.dart` (bagian submit)
- **Coverage**: REQ-LOG-004, AC-LOG-004.1, AC-LOG-004.2, AC-LOG-004.3, NFR-LOG-002

#### TASK-LOG-023: Buat Transaction List Screen
- **Deskripsi**: Implementasi screen list dengan ListView.builder. Setiap item menampilkan nominal (warna beda berdasarkan type), category icon+name, date, note (jika ada).
- **File terkait**: `lib/presentation/screens/transaction_list_screen.dart`
- **Coverage**: REQ-LOG-005.1, REQ-LOG-005.2, AC-LOG-005.1, AC-LOG-005.2

#### TASK-LOG-024: Implementasi Filter UI
- **Deskripsi**: Tambahkan filter chip/bottom sheet untuk filter by date range, category, type. Apply filter ke list.
- **File terkait**: `lib/presentation/screens/transaction_list_screen.dart` (bagian filter), `lib/presentation/widgets/transaction_filter_sheet.dart`
- **Coverage**: REQ-LOG-005.3, AC-LOG-005.3

#### TASK-LOG-025: Implementasi Edit Transaction
- **Deskripsi**: Tambahkan tombol edit di setiap item. Navigate ke form dengan pre-filled data. Simpan perubahan dan update list.
- **File terkait**: `lib/presentation/screens/transaction_form_screen.dart` (mode edit)
- **Coverage**: REQ-LOG-006, AC-LOG-006.1, AC-LOG-006.2, AC-LOG-006.3

#### TASK-LOG-026: Implementasi Delete Transaction
- **Deskripsi**: Tambahkan tombol delete di setiap item. Show dialog konfirmasi. Hapus jika confirmed dan update list.
- **File terkait**: `lib/presentation/screens/transaction_list_screen.dart` (bagian delete), `lib/presentation/widgets/delete_confirmation_dialog.dart`
- **Coverage**: REQ-LOG-007, AC-LOG-007.1, AC-LOG-007.2, AC-LOG-007.3

#### TASK-LOG-027: Implementasi Empty State & Loading State
- **Deskripsi**: Tambahkan UI untuk empty state (belum ada transaksi) dan loading state (shimmer/loading indicator).
- **File terkait**: `lib/presentation/screens/transaction_list_screen.dart` (bagian states)
- **Coverage**: UX enhancement

---

### Phase 6: Testing

**Tujuan**: Memastikan kualitas kode dan memenuhi NFR.

#### TASK-LOG-028: Unit Test - Entity & Model
- **Deskripsi**: Test entity equality, model serialization from/to Map, model-to-entity conversion.
- **File terkait**: `test/unit/models/transaction_model_test.dart`, `test/unit/models/category_model_test.dart`
- **Coverage**: REQ-LOG-003.1, NFR-LOG-003

#### TASK-LOG-029: Unit Test - Repository Implementation
- **Deskripsi**: Test CRUD operations pada repository dengan mock database. Test filter dan sorting logic.
- **File terkait**: `test/unit/repositories/transaction_repository_impl_test.dart`
- **Coverage**: REQ-LOG-003, REQ-LOG-005, NFR-LOG-004

#### TASK-LOG-030: Unit Test - Use Cases
- **Deskripsi**: Test use case logic termasuk validation, success path, dan error handling.
- **File terkait**: `test/unit/usecases/add_transaction_test.dart`, `test/unit/usecases/get_transactions_test.dart`
- **Coverage**: REQ-LOG-002, REQ-LOG-003

#### TASK-LOG-031: Widget Test - Form Input
- **Deskripsi**: Test form widget rendering, input interaction, validation display, submit button behavior.
- **File terkait**: `test/widget/transaction_form_screen_test.dart`
- **Coverage**: REQ-LOG-001, REQ-LOG-002, NFR-LOG-006

#### TASK-LOG-032: Widget Test - Transaction List
- **Deskripsi**: Test list rendering, item display, empty state, filter behavior.
- **File terkait**: `test/widget/transaction_list_screen_test.dart`
- **Coverage**: REQ-LOG-005

#### TASK-LOG-033: Integration Test - Transaction Flow
- **Deskripsi**: Test complete flow: buka form → input data → submit → verifikasi di list → edit → verifikasi update → delete → verifikasi hapus.
- **File terkait**: `integration_test/transaction_flow_test.dart`
- **Coverage**: End-to-end verification

---

### Phase 7: Performance Optimization & Polish

**Tujuan**: Memenuhi NFR performa dan UX.

#### TASK-LOG-034: Optimasi Query Performance
- **Deskripsi**: Tambahkan database index pada field yang sering di-query (dateTime, categoryId, type). Test query time ≤ 1 detik untuk 100 transaksi.
- **File terkait**: `lib/data/datasources/local/database_helper.dart`
- **Coverage**: NFR-LOG-002, NFR-LOG-004

#### TASK-LOG-035: Optimasi UI Responsiveness
- **Deskripsi**: Ensure tap response ≤ 100ms, gunakan const constructor, optimasi rebuild dengan Riverpod select.
- **File terkait**: `lib/presentation/screens/`, `lib/presentation/widgets/`
- **Coverage**: NFR-LOG-001, NFR-LOG-005

#### TASK-LOG-036: Implementasi Format Mata Uang Indonesia
- **Deskripsi**: Format nominal sebagai "Rp 1.000.000" dengan proper grouping symbol. Input formatter untuk nominal field.
- **File terkait**: `lib/presentation/widgets/currency_input_formatter.dart`
- **Coverage**: UX enhancement (format mata uang)

---

### Phase 8: Documentation & Handoff

**Tujuan**: Dokumentasi untuk developer berikutnya.

#### TASK-LOG-037: Update README dengan Setup Instructions
- **Deskripsi**: Dokumentasikan cara setup project, run app, dan run tests.
- **File terkait**: `README.md`
- **Coverage**: Developer onboarding

#### TASK-LOG-038: Dokumentasi Database Schema
- **Deskripsi**: Buat dokumentasi schema dalam `docs/database-schema.md` dengan ERD sederhana.
- **File terkait**: `docs/database-schema.md`
- **Coverage**: Technical documentation

---

## 4. Checklist Verifikasi Internal

Sebelum masuk ke fase VERIFY, pastikan:

- [ ] Semua REQ-LOG-001 sampai REQ-LOG-007 memiliki minimal satu TASK yang mengimplementasikannya
- [ ] Semua AC-LOG-xxx tercakup dalam kombinasi satu atau beberapa TASK
- [ ] Semua NFR-LOG-001 sampai NFR-LOG-006 tercakup dalam TASK terkait
- [ ] Tidak ada TASK yang keluar dari scope "Pencatatan Transaksi Manual"
- [ ] Setiap TASK bersifat atomik (dapat diselesaikan dalam 30-90 menit)
- [ ] Dependency dengan fitur kategori sudah diidentifikasi
- [ ] Open questions dicatat untuk keputusan di awal implementasi

---

## 5. Keputusan Teknis & Open Questions

### Keputusan Teknis (Sudah Ditentukan)

1. ✅ **State Management**: Riverpod
2. ✅ **Form Validation Library**: flutter_form_validation
3. ✅ **Testing Target**: High priority (80%+ coverage)

### Open Questions (Masih Perlu Keputusan)

Pertanyaan berikut masih perlu dijawab sebelum implementasi dimulai:

1. **Date/Time Handling**: Apakah perlu support untuk timezone berbeda (misal user input transaksi di timezone berbeda)?
   - **Rekomendasi**: Gunakan device timezone saja untuk versi 1, simpan sebagai UTC di database

2. **Category Seeding**: Kapan default categories di-seed?
   - **Rekomendasi**: Saat first launch, cek jika tabel categories kosong

3. **Delete Behavior**: Soft delete (mark sebagai deleted) atau hard delete dari database?
   - **Rekomendasi**: Hard delete untuk simplicitas versi 1

4. **Navigation Pattern**: Gunakan package (auto_route, go_router) atau Navigator 1.0 basic?
   - **Rekomendasi**: Navigator 2.0 dengan go_router untuk scalability

5. **Error Reporting**: Bagaimana menangani database error pada user side?
   - **Rekomendasi**: Generic user-friendly message, log detail untuk debugging

6. **Form Input Method**: Untuk nominal, apakah numeric keypad atau text input dengan formatter?
   - **Rekomendasi**: Text input dengan currency formatter untuk UX terbaik

7. **Filter Persistence**: Apakah filter selection perlu disimpan antar session?
   - **Rekomendasi**: Tidak perlu untuk versi 1, reset filter setiap buka app
