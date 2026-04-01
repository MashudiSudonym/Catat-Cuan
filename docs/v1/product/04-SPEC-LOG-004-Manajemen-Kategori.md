# SPEC – Manajemen Kategori

## Daftar Persyaratan Teknis (REQ-LOG)

### REQ-LOG-022: Pre-defined Kategori
Sistem menyediakan kategori default saat pertama kali aplikasi diinstall.

#### AC-LOG-022.1: Kategori Default Pemasukan
Sistem menyediakan kategori default berikut untuk pemasukan:
- [x] Gaji
- [x] Bonus
- [x] Freelance
- [x] Hadiah
- [x] Investasi
- [x] Lainnya

#### AC-LOG-022.2: Kategori Default Pengeluaran
Sistem menyediakan kategori default berikut untuk pengeluaran:
- [x] Makan
- [x] Transport
- [x] Langganan
- [x] Belanja
- [x] Hiburan
- [x] Kesehatan
- [x] Pendidikan
- [x] Tagihan
- [x] Lainnya

#### AC-LOG-022.3: Inisialisasi Default Kategori
- [x] Saat pertama kali app dibuka, sistem membuat semua kategori default di database
- [x] Proses inisialisasi berjalan di background (tidak memblokir UI)
- [x] Kategori default hanya dibuat jika belum ada kategori di database

---

### REQ-LOG-023: Struktur Data Kategori
Sistem menyimpan kategori dengan struktur yang mendukung pengelompokan.

#### AC-LOG-023.1: Tabel Kategori
- [x] Setiap kategori disimpan dengan atribut:
  - [x] ID unik (primary key, auto-increment)
  - [x] Nama kategori (string, unique)
  - [x] Tipe kategori (enum: pemasukan/pengeluaran)
  - [x] Warna (hex color, untuk UI differentiation)
  - [x] Icon (string nama icon, opsional)
  - [x] Urutan (integer, untuk sorting)
  - [x] Status aktif (boolean, untuk soft delete)
  - [x] Timestamp created_at
  - [x] Timestamp updated_at

#### AC-LOG-023.2: Relasi dengan Transaksi
- [x] Tabel transaksi memiliki foreign key `kategori_id` yang merujuk ke tabel kategori
- [x] Relasi adalah many-to-one (banyak transaksi bisa memiliki satu kategori yang sama)
- [x] Foreign key constraint: ON DELETE RESTRICT (kategori tidak bisa dihapus jika masih ada transaksi yang menggunakannya)

---

### REQ-LOG-024: Create Kategori Baru
User dapat membuat kategori baru sesuai kebutuhan.

#### AC-LOG-024.1: Form Create Kategori
- [x] Sistem menyediakan form/screen untuk membuat kategori baru
- [x] Form menyediakan field:
  - [x] Nama kategori (text input, wajib)
  - [x] Tipe kategori (dropdown: pemasukan/pengeluaran, wajib)
  - [x] Warna (color picker, opsional - ada default)
  - [x] Icon (icon picker, opsional - ada default)

#### AC-LOG-024.2: Validasi Create Kategori
- [x] Nama kategori wajib diisi
- [x] Nama kategori harus unik (tidak boleh sama dengan kategori yang sudah ada)
- [x] Tipe kategori wajib dipilih
- [x] Jika nama kategori sudah ada, sistem menampilkan pesan error: "Kategori dengan nama ini sudah ada"

#### AC-LOG-024.3: Simpan Kategori Baru
- [x] Setelah validasi sukses, kategori disimpan ke database
- [x] User menerima feedback sukses
- [x] Kategori baru langsung muncul di daftar kategori dan di form input transaksi

---

### REQ-LOG-025: Read Daftar Kategori
Sistem menampilkan daftar semua kategori yang tersedia.

#### AC-LOG-025.1: List Kategori
- [x] Sistem menampilkan daftar kategori yang dikelompokkan berdasarkan tipe:
  - [x] Section "Pemasukan"
  - [x] Section "Pengeluaran"
- [x] Setiap item kategori menampilkan:
  - [x] Nama kategori
  - [x] Warna (color dot atau background)
  - [x] Icon (jika ada)
  - [x] Jumlah transaksi yang menggunakan kategori ini (opsional)

#### AC-LOG-025.2: Sorting Kategori
- [x] Kategori diurutkan berdasarkan kolom `urutan` (ascending)
- [x] Jika `urutan` sama, diurutkan berdasarkan nama (ascending)

#### AC-LOG-025.3: Filter Kategori
- [x] User dapat memfilter kategori berdasarkan tipe (pemasukan/pengeluaran)
- [x] User dapat mencari kategori berdasarkan nama (search bar)

#### AC-LOG-025.4: Kategori untuk Dropdown Transaksi
- [x] Di form input transaksi, dropdown kategori hanya menampilkan kategori sesuai tipe transaksi:
  - [x] Jika tipe = "Pemasukan", hanya menampilkan kategori pemasukan
  - [x] Jika tipe = "Pengeluaran", hanya menampilkan kategori pengeluaran

---

### REQ-LOG-026: Update Kategori
User dapat mengedit kategori yang sudah ada.

#### AC-LOG-026.1: Akses Mode Edit
- [x] Setiap item kategori di daftar kategori memiliki tombol/ikon untuk edit
- [x] Saat tombol edit ditekan, form edit muncul dengan data kategori yang sudah ada terisi

#### AC-LOG-026.2: Proses Edit
- [x] Form edit memiliki semua field yang sama dengan form create
- [x] User dapat mengubah:
  - [x] Nama kategori (harus unik)
  - [x] Warna
  - [x] Icon
- [x] User TIDAK dapat mengubah tipe kategori (pemasukan/pengeluaran)

#### AC-LOG-026.3: Update Data
- [x] Setelah edit disimpan, data kategori di database diperbarui
- [x] Timestamp updated_at dicatat
- [x] User menerima feedback sukses
- [x] Perubahan langsung terlihat di:
  - [x] Daftar kategori
  - [x] Form input transaksi
  - [x] Dashboard dan insight (karena nama kategori berubah)

---

### REQ-LOG-027: Delete Kategori
User dapat menghapus kategori yang tidak digunakan.

#### AC-LOG-027.1: Akses Opsi Hapus
- [x] Setiap item kategori di daftar kategori memiliki tombol/ikon untuk hapus
- [x] Saat tombol hapus ditekan, sistem menampilkan dialog konfirmasi

#### AC-LOG-027.2: Validasi Sebelum Hapus
- [x] Sistem mengecek apakah kategori masih digunakan oleh transaksi:
  - [x] Jika ada transaksi yang menggunakan kategori ini, hapus DILARANG
  - [x] Jika tidak ada transaksi yang menggunakan kategori ini, hapus DIPERBOLEHKAN

#### AC-LOG-027.3: Dialog Konfirmasi (Jika Diperbolehkan)
- [x] Dialog menampilkan pesan: "Apakah Anda yakin ingin menghapus kategori [nama kategori]?"
- [x] Dialog menyediakan tombol "Batal" dan "Hapus"
- [x] Kategori hanya dihapus jika user menekan "Hapus"

#### AC-LOG-027.4: Error Handling (Jika Dilarang)
- [x] Jika kategori masih digunakan, sistem menampilkan pesan error:
  - [x] "Kategori ini tidak dapat dihapus karena masih digunakan oleh [jumlah] transaksi."
  - [x] "Gunakan opsi 'Nonaktifkan' jika Anda tidak ingin kategori ini muncul di dropdown."

#### AC-LOG-027.5: Soft Delete (Nonaktifkan Kategori)
- [x] Sebagai alternatif hard delete, sistem menyediakan opsi "Nonaktifkan"
- [x] Kategori yang dinonaktifkan memiliki `status_aktif = false`
- [x] Kategori nonaktif TIDAK muncul di dropdown form transaksi
- [x] Kategori nonaktif MASIH muncul di daftar kategori (dengan label "Nonaktif")
- [x] Transaksi yang sudah menggunakan kategori nonaktif TETAP menampilkan kategori tersebut

---

### REQ-LOG-028: Reorder Kategori
User dapat mengubah urutan kategori di dropdown.

#### AC-LOG-028.1: Drag & Drop Reorder
- [x] Di daftar kategori, user dapat drag & drop untuk mengubah urutan
- [x] Kolom `urutan` di-update sesuai posisi baru

#### AC-LOG-028.2: Persist Urutan
- [x] Urutan kategori disimpan ke database
- [x] Urutan baru langsung terlihat di dropdown form transaksi

---

### REQ-LOG-029: Color & Icon Management
Sistem menyediakan pilihan color dan icon untuk kategori.

#### AC-LOG-029.1: Color Picker
- [x] Sistem menyediakan palette warna predefined (misalnya 10-15 warna)
- [x] User dapat memilih warna dari palette
- [x] Setiap kategori default sudah memiliki warna yang berbeda

#### AC-LOG-029.2: Icon Picker
- [x] Sistem menyediakan set icon predefined (misalnya menggunakan Material Icons atau FontAwesome)
- [x] User dapat memilih icon dari list
- [x] Icon ditampilkan di dashboard dan list transaksi

#### AC-LOG-029.3: Default Values
- [x] Jika user tidak memilih warna, sistem memberikan warna default random dari palette
- [x] Jika user tidak memilih icon, sistem memberikan icon default berdasarkan tipe kategori

---

## Non-Functional Requirements (NFR)

### NFR-LOG-019: Performa Query Kategori
- [x] **Loading Time**: Loading daftar kategori harus:
  - [x] ≤ 500ms untuk menampilkan semua kategori (biasanya < 50 kategori)
  - [x] Mendukung pencarian kategori dengan real-time filter

### NFR-LOG-020: Uniqueness Constraint
- [x] **Data Integrity**: Nama kategori harus unik per tipe:
  - [x] Tidak boleh ada dua kategori pemasukan dengan nama sama
  - [x] Tidak boleh ada dua kategori pengeluaran dengan nama sama
  - [x] Database constraint: UNIQUE(nama, tipe)

### NFR-LOG-021: Foreign Key Constraint
- [x] **Referential Integrity**: Relasi kategori-transaksi harus:
  - [x] Mencegah hard delete kategori yang masih digunakan
  - [x] Menggunakan soft delete sebagai alternatif

### NFR-LOG-022: User Experience
- [x] **Minimal Friction**: Manajemen kategori harus mudah:
  - [x] User dapat membuat kategori baru langsung dari form transaksi (jika kategori yang diinginkan belum ada)
  - [x] Dropdown kategori di form transaksi harus mudah di-navigate

### NFR-LOG-023: Visual Consistency
- [x] **Color & Icon**: Warna dan icon kategori harus:
  - [x] Konsisten di seluruh app (form transaksi, list transaksi, dashboard)
  - [x] Memiliki contrast yang cukup untuk aksesibilitas

### NFR-LOG-024: Scalability
- [x] **Future-Proofing**: Struktur kategori harus mendukung:
  - [x] Sub-kategori (opsional untuk versi mendatang)
  - [x] Pengelompokan kategori (opsional untuk versi mendatang)

---

## Verifikasi Checklist

**Total Requirements**: 5 (REQ-LOG-018 hingga REQ-LOG-022)
**Total NFR**: 2 (NFR-LOG-023 hingga NFR-LOG-024)

### Status Implementasi

| ID | Deskripsi | Status | Metode Verifikasi | Terakhir Diverifikasi |
|----|-----------|--------|-------------------|---------------------|
| REQ-LOG-018 | Category CRUD Operations | ✅ | Code review | 2026-03-27 |
| REQ-LOG-019 | Default Categories | ✅ | Test execution | 2026-03-27 |
| REQ-LOG-020 | Category Customization | ✅ | Manual testing | 2026-03-27 |
| REQ-LOG-021 | Drag-Drop Reorder | ✅ | Manual testing | 2026-03-27 |
| REQ-LOG-022 | Visual Customization | ✅ | Manual testing | 2026-03-27 |
| NFR-LOG-023 | Visual Consistency | ✅ | Code review | 2026-03-27 |
| NFR-LOG-024 | Scalability | ✅ | Code review | 2026-03-27 |

### Ringkasan Implementasi

- **Total Requirements**: 5
- **Fully Implemented (✅)**: 5 (100%)
- **Partially Implemented (⚠️)**: 0 (0%)
- **Not Implemented (❌)**: 0 (0%)

### File Implementasi Utama

- **Screen**: `lib/presentation/screens/category_management_screen.dart`
- **Provider**: `lib/presentation/providers/category/category_management_provider.dart`
- **Controller**: `lib/presentation/controllers/category_management_controller.dart`
- **Repositories**: 4 segregated category repositories

### Catatan Verifikasi

Semua persyaratan telah diimplementasisi sesuai spesifikasi. Category management mendukung full CRUD dengan soft delete, default categories untuk new user, drag-drop reorder, dan visual customization (warna dan icon). Repositories telah disegregasi sesuai SRP.
