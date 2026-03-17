# PLAN – Manajemen Kategori

## 1. Ringkasan Singkat

Fitur Manajemen Kategori memungkinkan pengguna mengelola kategori transaksi (pemasukan/pengeluaran) meliputi: melihat daftar kategori, menambah kategori baru, mengedit kategori yang ada, menonaktifkan kategori, dan mengatur urutan kategori. Sistem menyediakan kategori default saat pertama kali aplikasi digunakan dan memastikan integritas data melalui soft delete untuk kategori yang masih digunakan oleh transaksi.

## 2. Asumsi & Dependency

### Asumsi Teknis:
- Aplikasi menggunakan Flutter + Riverpod untuk state management (berdasarkan konteks project).
- Storage lokal menggunakan SQLite (melalui Drift/database package).
- Struktur data transaksi sudah ada dan akan ditambahkan foreign key ke kategori.
- UI menggunakan Material Design dengan tema yang konsisten.

### Dependency dengan Fitur Lain:
- **Pencatatan Transaksi Manual (SPEC-LOG-001)**:
  - Form input transaksi memerlukan dropdown kategori yang dinamis.
  - Hanya kategori aktif yang muncul di dropdown.
  - Kategori difilter berdasarkan tipe transaksi (pemasukan/pengeluaran).

- **Input via Struk OCR (SPEC-LOG-002)**:
  - Hasil OCR perlu mapping ke kategori yang tersedia.

- **Ringkasan Bulanan/Insight (SPEC-LOG-003)**:
  - Insight akan mengelompokkan data berdasarkan kategori.
  - Perubahan nama kategori harus langsung ter-reflected di insight.

### Database Migration:
- Perlu migration untuk menambahkan tabel `categories`.
- Perlu migration untuk menambahkan foreign key `kategori_id` ke tabel `transactions`.

## 3. Fase Implementasi

### Phase 1: Model & Storage Kategori

- **TASK-CAT-001**
  - Deskripsi: Definisikan model/entitas `Category` dengan field sesuai REQ-LOG-023: id (int, auto-increment), nama (String, unique), tipe (enum: pemasukan/pengeluaran), warna (String hex), icon (String?), urutan (int), statusAktif (bool), createdAt (DateTime), updatedAt (DateTime).
  - Terkait: `lib/data/models/category.dart`
  - AC: AC-LOG-023.1

- **TASK-CAT-002**
  - Deskripsi: Buat database table definition untuk `categories` di SQLite/Drift dengan constraint UNIQUE(nama, tipe) dan proper indexes.
  - Terkait: `lib/data/database/schema.dart` atau `lib/data/database/tables.dart`
  - AC: AC-LOG-023.1, AC-LOG-023.2, NFR-LOG-020

- **TASK-CAT-003**
  - Deskripsi: Buat DAO/Repository untuk operasi CRUD kategori: insert, update, delete (soft), getAll, getById, getByType, getActiveOnly.
  - Terkait: `lib/data/repositories/category_repository.dart`
  - AC: AC-LOG-023.2 (relasi dengan transaksi)

- **TASK-CAT-004**
  - Deskripsi: Buat database migration untuk menambahkan tabel `categories` dan foreign key `kategori_id` ke tabel `transactions` dengan ON DELETE RESTRICT.
  - Terkait: `lib/data/database/migrations/`
  - AC: AC-LOG-023.2, NFR-LOG-021

- **TASK-CAT-005**
  - Deskripsi: Implementasi seeding kategori default sesuai AC-LOG-022.1 dan AC-LOG-022.2. Pastikan seeding hanya berjalan sekali (saat pertama kali app dibuka) dan di background.
  - Terkait: `lib/data/seeds/category_seed.dart`
  - AC: AC-LOG-022.1, AC-LOG-022.2, AC-LOG-022.3

### Phase 2: Service/Logic Manajemen Kategori

- **TASK-CAT-006**
  - Deskripsi: Buat Service/Notifier untuk manajemen kategori dengan Riverpod. Implementasi state management untuk: list kategori, loading state, error handling.
  - Terkait: `lib/presentation/providers/category_provider.dart`
  - AC: AC-LOG-025.1

- **TASK-CAT-007**
  - Deskripsi: Implementasi fungsi `createCategory()` dengan validasi: nama tidak boleh kosong, nama harus unik per tipe, tipe wajib dipilih.
  - Terkait: `lib/domain/use_cases/create_category_use_case.dart`
  - AC: AC-LOG-024.1, AC-LOG-024.2, AC-LOG-024.3, NFR-LOG-020

- **TASK-CAT-008**
  - Deskripsi: Implementasi fungsi `updateCategory()` dengan validasi: nama unik (kecuali untuk kategori itu sendiri), tipe tidak boleh diubah.
  - Terkait: `lib/domain/use_cases/update_category_use_case.dart`
  - AC: AC-LOG-026.1, AC-LOG-026.2, AC-LOG-026.3

- **TASK-CAT-009**
  - Deskripsi: Implementasi fungsi `deactivateCategory()` untuk soft delete (set statusAktif = false). Pastikan kategori yang masih digunakan transaksi tidak bisa dinonaktifkan.
  - Terkait: `lib/domain/use_cases/deactivate_category_use_case.dart`
  - AC: AC-LOG-027.1, AC-LOG-027.2, AC-LOG-027.4, AC-LOG-027.5, NFR-LOG-021

- **TASK-CAT-010**
  - Deskripsi: Implementasi fungsi `reorderCategories()` untuk update kolom `urutan` berdasarkan posisi drag & drop.
  - Terkait: `lib/domain/use_cases/reorder_categories_use_case.dart`
  - AC: AC-LOG-028.1, AC-LOG-028.2

- **TASK-CAT-011**
  - Deskripsi: Implementasi fungsi `getCategoriesForDropdown()` yang hanya mengembalikan kategori aktif dan difilter berdasarkan tipe transaksi.
  - Terkait: `lib/domain/use_cases/get_categories_for_dropdown_use_case.dart`
  - AC: AC-LOG-025.4

- **TASK-CAT-012**
  - Deskripsi: Implementasi fungsi `checkCategoryUsage()` untuk mengecek apakah kategori masih digunakan oleh transaksi (untuk validasi sebelum nonaktifkan).
  - Terkait: `lib/domain/use_cases/check_category_usage_use_case.dart`
  - AC: AC-LOG-027.2

### Phase 3: UI Manajemen Kategori

- **TASK-CAT-013**
  - Deskripsi: Buat screen `CategoryListScreen` yang menampilkan daftar kategori dikelompokkan berdasarkan tipe (section Pemasukan dan Pengeluaran).
  - Terkait: `lib/presentation/screens/category/category_list_screen.dart`
  - AC: AC-LOG-025.1

- **TASK-CAT-014**
  - Deskripsi: Implementasi item widget untuk setiap kategori yang menampilkan: nama, warna (color dot), icon, dan jumlah transaksi (opsional).
  - Terkait: `lib/presentation/widgets/category_item_widget.dart`
  - AC: AC-LOG-025.1

- **TASK-CAT-015**
  - Deskripsi: Implementasi sorting kategori berdasarkan kolom `urutan`, lalu nama secara ascending.
  - Terkait: `lib/presentation/screens/category/category_list_screen.dart`
  - AC: AC-LOG-025.2

- **TASK-CAT-016**
  - Deskripsi: Implementasi filter kategori berdasarkan tipe dan search bar untuk pencarian berdasarkan nama.
  - Terkait: `lib/presentation/screens/category/category_list_screen.dart`
  - AC: AC-LOG-025.3

- **TASK-CAT-017**
  - Deskripsi: Buat screen/form `CategoryFormScreen` untuk create dan edit kategori dengan field: nama (required), tipe (dropdown, required), warna (color picker, optional), icon (icon picker, optional).
  - Terkait: `lib/presentation/screens/category/category_form_screen.dart`
  - AC: AC-LOG-024.1, AC-LOG-026.1, AC-LOG-026.2

- **TASK-CAT-018**
  - Deskripsi: Implementasi validasi form dengan error message: "Kategori dengan nama ini sudah ada" jika nama duplikat.
  - Terkait: `lib/presentation/screens/category/category_form_screen.dart`
  - AC: AC-LOG-024.2, AC-LOG-026.2

- **TASK-CAT-019**
  - Deskripsi: Implementasi dialog konfirmasi untuk nonaktifkan kategori dengan pesan: "Apakah Anda yakin ingin menghapus kategori [nama]?"
  - Terkait: `lib/presentation/dialogs/deactivate_category_dialog.dart`
  - AC: AC-LOG-027.1, AC-LOG-027.3

- **TASK-CAT-020**
  - Deskripsi: Implementasi error dialog untuk kategori yang tidak bisa dinonaktifkan dengan pesan: "Kategori ini tidak dapat dihapus karena masih digunakan oleh [jumlah] transaksi."
  - Terkait: `lib/presentation/dialogs/category_error_dialog.dart`
  - AC: AC-LOG-027.4

- **TASK-CAT-021**
  - Deskripsi: Implementasi drag & drop reorder kategori di daftar kategori.
  - Terkait: `lib/presentation/screens/category/category_list_screen.dart` (menggunakan package seperti `reorderable_list` atau `flutter_reorderable_list_view`)
  - AC: AC-LOG-028.1

- **TASK-CAT-022**
  - Deskripsi: Buat FAB atau button di CategoryListScreen untuk navigasi ke form create kategori baru.
  - Terkait: `lib/presentation/screens/category/category_list_screen.dart`
  - AC: AC-LOG-024.1

### Phase 4: Integrasi dengan Pencatatan Transaksi

- **TASK-CAT-023**
  - Deskripsi: Update form input transaksi untuk menggunakan dropdown kategori dinamis dari `getCategoriesForDropdown()`.
  - Terkait: `lib/presentation/screens/transaction/transaction_form_screen.dart`
  - AC: AC-LOG-025.4, NFR-LOG-022

- **TASK-CAT-024**
  - Deskripsi: Implementasi filter kategori di dropdown berdasarkan tipe transaksi yang dipilih (pemasukan hanya menampilkan kategori pemasukan, dst).
  - Terkait: `lib/presentation/screens/transaction/transaction_form_screen.dart`
  - AC: AC-LOG-025.4

- **TASK-CAT-025**
  - Deskripsi: Update list transaksi untuk menampilkan kategori dengan warna dan icon yang sesuai.
  - Terkait: `lib/presentation/widgets/transaction_item_widget.dart`
  - AC: AC-LOG-025.1, NFR-LOG-023

- **TASK-CAT-026**
  - Deskripsi: Pastikan perubahan nama kategori langsung ter-reflected di tampilan transaksi lama (tanpa perlu update transaksi).
  - Terkait: `lib/presentation/screens/transaction/transaction_list_screen.dart`
  - AC: AC-LOG-026.3

- **TASK-CAT-027**
  - Deskripsi: Pastikan transaksi lama dengan kategori nonaktif tetap menampilkan nama kategori dengan benar (tidak blank atau error).
  - Terkait: `lib/presentation/widgets/transaction_item_widget.dart`
  - AC: AC-LOG-027.5

- **TASK-CAT-028**
  - Deskripsi: Tambahkan opsi/shortcut untuk membuat kategori baru langsung dari form transaksi (jika kategori yang diinginkan belum ada).
  - Terkait: `lib/presentation/screens/transaction/transaction_form_screen.dart`
  - AC: NFR-LOG-022

### Phase 5: Color & Icon Management

- **TASK-CAT-029**
  - Deskripsi: Buat predefined color palette (10-15 warna) untuk color picker kategori. Setiap kategori default harus memiliki warna berbeda.
  - Terkait: `lib/core/constants/category_colors.dart`
  - AC: AC-LOG-029.1, AC-LOG-029.3

- **TASK-CAT-030**
  - Deskripsi: Buat predefined icon set (Material Icons atau custom icons) untuk icon picker kategori.
  - Terkait: `lib/core/constants/category_icons.dart`
  - AC: AC-LOG-029.2

- **TASK-CAT-031**
  - Deskripsi: Implementasi color picker widget untuk memilih warna kategori dari predefined palette.
  - Terkait: `lib/presentation/widgets/category_color_picker.dart`
  - AC: AC-LOG-029.1

- **TASK-CAT-032**
  - Deskripsi: Implementasi icon picker widget untuk memilih icon kategori dari predefined set.
  - Terkait: `lib/presentation/widgets/category_icon_picker.dart`
  - AC: AC-LOG-029.2

- **TASK-CAT-033**
  - Deskripsi: Implementasi logic default value: jika warna tidak dipilih, assign random dari palette; jika icon tidak dipilih, assign default icon berdasarkan tipe.
  - Terkait: `lib/domain/use_cases/create_category_use_case.dart`
  - AC: AC-LOG-029.3

- **TASK-CAT-034**
  - Deskripsi: Pastikan warna dan icon kategori konsisten di seluruh app (form transaksi, list transaksi, dashboard, insight).
  - Terkait: Semua UI terkait kategori
  - AC: NFR-LOG-023

### Phase 6: Testing & QA

- **TASK-CAT-035**
  - Deskripsi: Unit test untuk model `Category` (getter, setter, validation, copyWith, toJson, fromJson).
  - Terkait: `test/data/models/category_test.dart`
  - AC: AC-LOG-023.1

- **TASK-CAT-036**
  - Deskripsi: Unit test untuk CategoryRepository (CRUD operations, filtering, uniqueness check).
  - Terkait: `test/data/repositories/category_repository_test.dart`
  - AC: Semua REQ-LOG-023 sampai REQ-LOG-028

- **TASK-CAT-037**
  - Deskripsi: Unit test untuk use case createCategory (validasi nama unik, tipe required).
  - Terkait: `test/domain/use_cases/create_category_use_case_test.dart`
  - AC: AC-LOG-024.2, NFR-LOG-020

- **TASK-CAT-038**
  - Deskripsi: Unit test untuk use case deactivateCategory (cek kategori masih digunakan atau tidak).
  - Terkait: `test/domain/use_cases/deactivate_category_use_case_test.dart`
  - AC: AC-LOG-027.2, AC-LOG-027.4, NFR-LOG-021

- **TASK-CAT-039**
  - Deskripsi: Widget test untuk CategoryFormScreen (validasi form, error message, success feedback).
  - Terkait: `test/presentation/screens/category/category_form_screen_test.dart`
  - AC: AC-LOG-024.1, AC-LOG-024.2, AC-LOG-026.2

- **TASK-CAT-040**
  - Deskripsi: Widget test untuk CategoryListScreen (sorting, filtering, drag & drop).
  - Terkait: `test/presentation/screens/category/category_list_screen_test.dart`
  - AC: AC-LOG-025.2, AC-LOG-025.3, AC-LOG-028.1

- **TASK-CAT-041**
  - Deskripsi: Integration test untuk seeding kategori default (hanya berjalan sekali).
  - Terkait: `test/integration/category_seeding_test.dart`
  - AC: AC-LOG-022.3

- **TASK-CAT-042**
  - Deskripsi: Integration test untuk skenario: transaksi dengan kategori yang kemudian dinonaktifkan. Pastikan transaksi tetap terbaca dengan benar.
  - Terkait: `test/integration/category_transaction_test.dart`
  - AC: AC-LOG-027.5

- **TASK-CAT-043**
  - Deskripsi: Integration test untuk skenario: rename kategori yang sudah dipakai transaksi. Pastikan perubahan langsung ter-reflected.
  - Terkait: `test/integration/category_transaction_test.dart`
  - AC: AC-LOG-026.3

- **TASK-CAT-044**
  - Deskripsi: Manual test: Cek performa loading daftar kategori ≤ 500ms (NFR-LOG-019). Gunakan DevTools untuk profiling.
  - Terkait: Manual QA
  - AC: NFR-LOG-019

## 4. Checklist Verifikasi Internal

Sebelum merge ke main/production, pastikan:

- [ ] Semua REQ-LOG-022 s/d REQ-LOG-029 di SPEC memiliki minimal satu TASK-CAT yang mengimplementasikannya.
- [ ] Semua AC-LOG-xxx tercakup dalam kombinasi satu atau beberapa TASK-CAT.
- [ ] Kategori default (Pemasukan dan Pengeluaran) tersedia saat pertama kali app dibuka.
- [ ] Kategori nonaktif TIDAK muncul di dropdown form transaksi baru.
- [ ] Kategori nonaktif MASIH muncul di daftar kategori (dengan label "Nonaktif").
- [ ] Transaksi lama yang menggunakan kategori nonaktif tetap tampil dengan nama kategori yang benar.
- [ ] Nama kategori unik per tipe (tidak boleh ada 2 kategori pemasukan dengan nama sama).
- [ ] Kategori yang masih digunakan transaksi TIDAK bisa dinonaktifkan (error message jelas).
- [ ] Dropdown kategori di form transaksi hanya menampilkan kategori sesuai tipe transaksi.
- [ ] Urutan kategori (reorder) persist dan langsung ter-reflected di dropdown.
- [ ] Warna dan icon kategori konsisten di seluruh app (form, list, dashboard, insight).
- [ ] Performa loading daftar kategori ≤ 500ms.
- [ ] Semua unit test dan widget test pass.
- [ ] Integration test untuk seeding kategori default pass.
- [ ] Integration test untuk skenario kategori-transaksi pass.

## 5. Open Questions

Berikut adalah pertanyaan yang perlu diklarifikasi sebelum implementasi:

1. **Hard Delete vs Soft Delete**:
   - Di SPEC AC-LOG-027.5 disebutkan opsi "Nonaktifkan" (soft delete). Apakah kita akan menghapus opsi hard delete sama sekali? Atau tetap menyediakan opsi hard delete untuk kategori yang belum pernah digunakan?

2. **Recover Kategori Nonaktif**:
   - Apakah pengguna bisa mengaktifkan kembali kategori yang sudah dinonaktifkan? Jika ya, di mana UI untuk fitur ini?

3. **Sub-Kategori**:
   - NFR-LOG-024 menyebutkan kemungkinan sub-kategori untuk versi mendatang. Apakah kita perlu menyiapkan struktur data dari sekarang (misalnya menambahkan field `parentId`) atau nanti saja saat requirement jelas?

4. **Jumlah Transaksi di List Kategori**:
   - AC-LOG-025.1 menyebutkan menampilkan jumlah transaksi per kategori sebagai opsional. Apakah kita akan mengimplementasikannya di versi ini? Jika ya, perlu hitungan real-time atau cached?

5. **Edit Tipe Kategori**:
   - AC-LOG-026.2 menyatakan user TIDAK dapat mengubah tipe kategori. Apakah ini termasuk constraint database atau hanya UI validation? Jika constraint database, perlu handle migrasi jika ada transaksi yang sudah menggunakan kategori tersebut.

6. **Default Color Assignment**:
   - AC-LOG-029.3 menyebutkan default color random dari palette. Apakah benar-benar random atau ada urutan/pattern tertentu untuk menghindari dua kategori default memiliki warna sama?

7. **Icon Set**:
   - Icon set apa yang akan digunakan? Material Icons? Custom SVG icons? Atau kita gunakan emoji untuk simplisitas?

8. **Urutan Kategori Default**:
   - Urutan default untuk kategori default (Gaji, Bonus, dll) bagaimana? Berdasarkan urutan di SPEC atau alphabetically?

9. **Search Performance**:
   - Untuk NFR-LOG-019 (≤ 500ms), apakah perlu implementasi search index atau sederhana SQL LIKE query cukup?

10. **Feedback Sukses**:
    - Format feedback sukses apa yang diinginkan? SnackBar? Dialog? Toast? Apakah auto-dismiss atau perlu user action?
