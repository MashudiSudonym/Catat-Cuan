# SPEC – Pencatatan Transaksi Manual

## Daftar Persyaratan Teknis (REQ-LOG)

### REQ-LOG-001: Form Input Transaksi Baru
Sistem menyediakan antarmuka pengguna untuk mencatat transaksi pemasukan atau pengeluaran baru.

#### AC-LOG-001.1: Field yang Tersedia
- [x] Form menyediakan field input berikut:
  - [x] Nominal (angka, desimal diperbolehkan)
  - [x] Tipe transaksi (pilihan: Pemasukan / Pengeluaran)
  - [x] Tanggal transaksi (date picker)
  - [x] Waktu transaksi (time picker)
  - [x] Kategori (dropdown pilihan)
  - [x] Catatan (text input, opsional)

#### AC-LOG-001.2: Default Value yang Smart
- [x] Saat form dibuka, tipe transaksi default adalah "Pengeluaran"
- [x] Saat form dibuka, tanggal & waktu default adalah waktu saat ini
- [x] Field catatan kosong secara default (opsional)

---

### REQ-LOG-002: Validasi Input Transaksi
Sistem memvalidasi semua input sebelum transaksi disimpan untuk memastikan data integrity.

#### AC-LOG-002.1: Validasi Field Wajib
- [x] Nominal wajib diisi
- [x] Nominal harus berupa angka yang valid
- [x] Nominal harus > 0
- [x] Tipe transaksi wajib dipilih (Pemasukan atau Pengeluaran)
- [x] Tanggal transaksi wajib diisi
- [x] Kategori wajib dipilih

#### AC-LOG-002.2: Pesan Error yang Jelas
- [x] Jika nominal kosong, sistem menampilkan pesan error: "Nominal wajib diisi"
- [x] Jika nominal ≤ 0, sistem menampilkan pesan error: "Nominal harus lebih dari 0"
- [x] Jika kategori belum dipilih, sistem menampilkan pesan error: "Kategori wajib dipilih"
- [x] Pesan error ditampilkan di dekat field yang bersangkutan

#### AC-LOG-002.3: Prevent Submit pada Data Tidak Valid
- [x] Tombol simpan tidak dapat ditekan (disabled) jika field wajib belum terisi
- [x] ATAU: Tombol simpan dapat ditekan tapi menampilkan pesan validasi dan tidak menyimpan data

---

### REQ-LOG-003: Penyimpanan Transaksi
Sistem menyimpan transaksi yang valid ke database lokal.

#### AC-LOG-003.1: Struktur Data Transaksi
- [x] Setiap transaksi disimpan dengan atribut:
  - [x] ID unik (primary key, auto-increment)
  - [x] Nominal (decimal/numeric)
  - [x] Tipe (enum: pemasukan/pengeluaran)
  - [x] Tanggal & waktu (datetime)
  - [x] Kategori (foreign key ke tabel kategori)
  - [x] Catatan (text, nullable)
  - [x] Timestamp created_at

#### AC-LOG-003.2: Keandalan Penyimpanan
- [x] Transaksi hanya disimpan jika semua validasi terpenuhi
- [x] Sistem menampilkan feedback sukses setelah transaksi berhasil disimpan
- [x] Jika terjadi kegagalan penyimpanan (database error), sistem menampilkan pesan error yang jelas

---

### REQ-LOG-004: Perilaku Setelah Submit Transaksi
Sistem merespons setelah transaksi berhasil disimpan.

#### AC-LOG-004.1: Reset Form
- [x] Setelah transaksi berhasil disimpan, form di-reset ke kondisi awal
- [x] Field nominal dikosongkan
- [x] Field catatan dikosongkan
- [x] Tipe transaksi kembali ke default ("Pengeluaran")
- [x] Tanggal & waktu kembali ke waktu saat ini

#### AC-LOG-004.2: Feedback Visual
- [x] Sistem menampilkan pesan sukses (misalnya: snackbar/toast) berdurasi ≤ 3 detik
- [x] Pesan sukses berisi konfirmasi penyimpanan transaksi

#### AC-LOG-004.3: Navigasi Pasca-Submit
- [x] User tetap berada di form input (untuk input berikutnya)
- [x] ATAU: User diarahkan kembali ke layar list transaksi (sesuai preferensi UX)

---

### REQ-LOG-005: Daftar Transaksi (List View)
Sistem menampilkan daftar transaksi yang telah dicatat.

#### AC-LOG-005.1: Tampilan List Transaksi
- [x] Sistem menampilkan daftar semua transaksi yang tersimpan
- [x] Setiap item transaksi menampilkan:
  - [x] Nominal
  - [x] Tipe (pemasukan/pengeluaran) dengan visual distinction (warna berbeda)
  - [x] Kategori
  - [x] Tanggal & waktu
  - [x] Catatan (jika ada)

#### AC-LOG-005.2: Pengurutan (Sorting)
- [x] Transaksi diurutkan berdasarkan tanggal & waktu secara descending (terbaru di atas)

#### AC-LOG-005.3: Filter Transaksi
- [x] Sistem menyediakan filter berdasarkan:
  - [x] Rentang tanggal
  - [x] Kategori
  - [x] Tipe transaksi (pemasukan/pengeluaran)

---

### REQ-LOG-006: Edit Transaksi
Sistem memungkinkan pengguna mengedit transaksi yang sudah ada.

#### AC-LOG-006.1: Akses Mode Edit
- [x] Setiap item transaksi memiliki tombol/ikon untuk edit
- [x] Saat tombol edit ditekan, form input muncul dengan data transaksi yang sudah ada terisi

#### AC-LOG-006.2: Proses Edit
- [x] Form edit memiliki semua field yang sama dengan form create
- [x] User dapat mengubah semua field kecuali ID (auto-generated)
- [x] Validasi yang sama dengan form create diterapkan

#### AC-LOG-006.3: Update Data
- [x] Setelah edit disimpan, data transaksi di database diperbarui
- [x] Timestamp updated_at dicatat
- [x] User menerima feedback sukses
- [x] List transaksi diperbarui untuk menampilkan data yang telah diubah

---

### REQ-LOG-007: Hapus Transaksi
Sistem memungkinkan pengguna menghapus transaksi.

#### AC-LOG-007.1: Akses Opsi Hapus
- [x] Setiap item transaksi memiliki tombol/ikon untuk hapus
- [x] Saat tombol hapus ditekan, sistem menampilkan dialog konfirmasi

#### AC-LOG-007.2: Dialog Konfirmasi
- [x] Dialog menampilkan pesan: "Apakah Anda yakin ingin menghapus transaksi ini?"
- [x] Dialog menyediakan tombol "Batal" dan "Hapus"
- [x] Transaksi hanya dihapus jika user menekan "Hapus"

#### AC-LOG-007.3: Proses Penghapusan
- [x] Setelah dikonfirmasi, transaksi dihapus dari database
- [x] User menerima feedback sukses (transaksi berhasil dihapus)
- [x] List transaksi diperbarui untuk menghapus item yang dihapus

---

## Non-Functional Requirements (NFR)

### NFR-LOG-001: Performa UI
- [x] **Responsiveness**: Form input transaksi harus terasa responsif
  - [x] Waktu respon tap ≤ 100ms untuk setiap interaksi
  - [x] Animasi transisi antar form ≤ 300ms

### NFR-LOG-002: Performa Penyimpanan
- [x] **Kecepatan Simpan**: Operasi penyimpanan transaksi harus selesai dalam:
  - [x] ≤ 500ms untuk penyimpanan lokal (SQLite)
  - [x] Feedback sukses ditampilkan dalam ≤ 1 detik setelah tap tombol simpan

### NFR-LOG-003: Keandalan Penyimpanan Lokal
- [x] **Data Integrity**: Database lokal harus menjamin:
  - [x] ACID compliance untuk operasi transaksi
  - [x] Tidak ada data loss saat aplikasi tertutup secara tidak terduga
  - [x] Backup data otomatis (opsional namun direkomendasikan)

### NFR-LOG-004: Performa Query List Transaksi
- [x] **Loading Time**: Loading list transaksi harus:
  - [x] ≤ 1 detik untuk menampilkan 100 transaksi terbaru
  - [x] Mendukung pagination atau lazy loading jika jumlah transaksi sangat besar

### NFR-LOG-005: User Experience (UX)
- [x] **Kecepatan Input Manual**: Sesuai PRD section 5:
  - [x] Input transaksi manual harus bisa diselesaikan dalam ≤ 20 detik
  - [x] Minimal friction: jumlah tap minimal untuk selesaikan satu transaksi

### NFR-LOG-006: Validasi & Error Handling
- [x] **Error Prevention**: Sistem harus mencegah input invalid sebelum submit
  - [x] Validasi real-time saat user mengetik (jika memungkinkan)
  - [x] Pesan error yang spesifik dan actionable

---

## Verifikasi Checklist

**Total Requirements**: 7 (REQ-LOG-001 hingga REQ-LOG-007)
**Total NFR**: 6 (NFR-LOG-001 hingga NFR-LOG-006)

### Status Implementasi

| ID | Deskripsi | Status | Metode Verifikasi | Terakhir Diverifikasi |
|----|-----------|--------|-------------------|---------------------|
| REQ-LOG-001 | Form Input Transaksi Baru | ✅ | Code review | 2026-03-27 |
| REQ-LOG-002 | Validasi Input Transaksi | ✅ | Test + Manual | 2026-03-27 |
| REQ-LOG-003 | Penyimpanan Transaksi | ✅ | Test execution | 2026-03-27 |
| REQ-LOG-004 | Perilaku Setelah Submit | ✅ | Manual testing | 2026-03-27 |
| REQ-LOG-005 | Daftar Transaksi | ✅ | Code review | 2026-03-27 |
| REQ-LOG-006 | Edit Transaksi | ✅ | Manual testing | 2026-03-27 |
| REQ-LOG-007 | Hapus Transaksi | ✅ | Manual testing | 2026-03-27 |
| NFR-LOG-001 | Performa UI | ✅ | Performance test | 2026-03-27 |
| NFR-LOG-002 | Performa Penyimpanan | ✅ | Performance test | 2026-03-27 |
| NFR-LOG-003 | Keandalan Penyimpanan Lokal | ✅ | Test execution | 2026-03-27 |
| NFR-LOG-004 | Performa Query List | ✅ | Performance test | 2026-03-27 |
| NFR-LOG-005 | User Experience | ✅ | Manual testing | 2026-03-27 |
| NFR-LOG-006 | Validasi & Error Handling | ✅ | Code review | 2026-03-27 |

### Ringkasan Implementasi

- **Total Requirements**: 7
- **Fully Implemented (✅)**: 7 (100%)
- **Partially Implemented (⚠️)**: 0 (0%)
- **Not Implemented (❌)**: 0 (0%)

### File Implementasi Utama

- **Screen**: `lib/presentation/screens/transaction_form_screen.dart`
- **Provider**: `lib/presentation/providers/transaction/transaction_form_provider.dart`
- **State**: `lib/presentation/states/transaction_form_state.dart`
- **Validator**: `lib/presentation/states/validators/transaction_form_validator.dart`
- **Controller**: `lib/presentation/controllers/transaction_form_submission_controller.dart`

### Catatan Verifikasi

Semia persyaratan telah diimplementasikan sesuai spesifikasi. Validasi real-time berfungsi dengan baik, pesan error jelas dan ditampilkan dekat field yang relevan, dan feedback visual diberikan untuk semua operasi.
