# PLAN – Input via Struk OCR

## 1. Ringkasan Singkat

Fitur ini memungkinkan pengguna mencatat transaksi pengeluaran dengan cara memindai struk belanja menggunakan kamera atau memilih gambar dari galeri. Aplikasi menggunakan Google ML Kit Text Recognition v2 untuk melakukan OCR on-device, mengekstrak nominal transaksi dari teks struk, dan mengisi otomatis field nominal pada form transaksi pengeluaran.

## 2. Asumsi & Dependency

### Asumsi Teknis
- Fitur "Pencatatan Transaksi Manual" sudah ada dan form transaksi pengeluaran sudah berfungsi penuh.
- Aplikasi menggunakan Flutter dengan minimal SDK yang mendukung Google ML Kit.
- Permission kamera (camera) dan akses galeri (storage/photos) dapat diminta dan dikelola melalui permission handler.
- Aplikasi sudah memiliki mekanisme penyimpanan transaksi lokal (SharedPreferences/SQLite/Hive).
- State management sudah ada (Provider/Riverpod/BLoC) untuk mengelola form transaksi.

### Dependency dengan Fitur Lain
- **Form Transaksi Manual**: Field "Nominal", "Tipe", "Tanggal", "Kategori", dan "Catatan" sudah tersedia dan dapat diisi secara programatik.
- **Manajemen Kategori**: Kategori default "Belanja" sudah ada atau sistem dapat menggunakan kategori terakhir yang dipakai user.
- **Validasi Input**: Validasi nominal (angka > 0) sudah ada di form transaksi.

## 3. Fase Implementasi

### Phase 1: Integrasi OCR & Akses Gambar

**Tujuan**: Menyiapkan infrastruktur OCR dan kemampuan untuk mengambil/memilih gambar.

- **TASK-OCR-001: Tambah Dependency Google ML Kit Text Recognition v2**
  - Deskripsi: Tambahkan dependency `google_mlkit_text_recognition` ke `pubspec.yaml` dan lakukan `flutter pub get`.
  - File Terkait: `pubspec.yaml`
  - AC Terkait: AC-LOG-008.1

- **TASK-OCR-002: Konfigurasi Permission Kamera dan Storage**
  - Deskripsi: Tambahkan permission kamera dan storage di `AndroidManifest.xml` (Android) dan `Info.plist` (iOS).
  - File Terkait: `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`
  - AC Terkait: AC-LOG-008.1

- **TASK-OCR-003: Buat Service `ReceiptOcrService` untuk ML Kit Wrapper**
  - Deskripsi: Buat service class yang membungkus inisialisasi dan eksekusi Google ML Kit Text Recognition v2. Pastikan inisialisasi tidak blok UI thread dan ada fallback error handling.
  - File Terkait: `lib/data/services/receipt_ocr_service.dart` (baru)
  - AC Terkait: AC-LOG-008.2, AC-LOG-012.1, NFR-LOG-008

- **TASK-OCR-004: Buat Service `ImagePickerService` untuk Kamera dan Galeri**
  - Deskripsi: Buat service untuk mengambil gambar dari kamera (camera picker) dan memilih gambar dari galeri (image picker) menggunakan package image_picker.
  - File Terkait: `lib/data/services/image_picker_service.dart` (baru)
  - AC Terkait: AC-LOG-009.1, AC-LOG-010.1

- **TASK-OCR-005: Buat Permission Handler Service**
  - Deskripsi: Buat service untuk meminta permission kamera dan storage, serta handle kasus permission denied (tampilkan pesan yang jelas).
  - File Terkait: `lib/data/services/permission_service.dart` (baru)
  - AC Terkait: AC-LOG-009.1, NFR-LOG-011

---

### Phase 2: Parsing Teks Struk → Nominal

**Tujuan**: Menganalisis hasil OCR dan mengekstrak nominal transaksi.

- **TASK-OCR-006: Buat Domain Model `ReceiptData`**
  - Deskripsi: Buat data class untuk menyimpan hasil parsing OCR, termasuk field: `fullText` (String), `detectedAmount` (double?), `confidenceScore` (double?).
  - File Terkait: `lib/domain/models/receipt_data.dart` (baru)
  - AC Terkait: AC-LOG-011.1

- **TASK-OCR-007: Buat Parser `ReceiptAmountParser` dengan Keyword Matching**
  - Deskripsi: Implementasi parser untuk mencari baris yang mengandung keyword total ("TOTAL", "Jumlah", "Grand Total", "amount", dll) dan ekstrak angka nominal dari baris tersebut.
  - File Terkait: `lib/domain/receipt_parsers/receipt_amount_parser.dart` (baru)
  - AC Terkait: AC-LOG-011.1, AC-LOG-011.2

- **TASK-OCR-008: Implementasi Regex untuk Format Nominal Indonesia**
  - Deskripsi: Tambahkan fungsi untuk membersihkan format nominal Indonesia: hapus "Rp", titik pemisah ribuan, ganti koma desimal dengan titik, dan parse ke double.
  - File Terkait: `lib/domain/receipt_parsers/currency_formatter.dart` (baru)
  - AC Terkait: AC-LOG-011.1

- **TASK-OCR-009: Implementasi Fallback Logic (Angka Terbesar)**
  - Deskripsi: Jika keyword total tidak ditemukan, ambil angka terbesar yang wajar dari teks (dengan threshold min/max) sebagai kandidat nominal.
  - File Terkait: `lib/domain/receipt_parsers/receipt_amount_parser.dart`
  - AC Terkait: AC-LOG-011.2

- **TASK-OCR-010: Buat Unit Test untuk ReceiptAmountParser**
  - Deskripsi: Buat unit test dengan berbagai sample teks struk (berbagai format, keyword, dan edge case) untuk memverifikasi akurasi parser.
  - File Terkait: `test/domain/receipt_parsers/receipt_amount_parser_test.dart` (baru)
  - AC Terkait: AC-LOG-011.1, AC-LOG-011.2, NFR-LOG-009

---

### Phase 3: Integrasi dengan Form Transaksi

**Tujuan**: Menghubungkan hasil OCR ke form transaksi yang sudah ada.

- **TASK-OCR-011: Buat Screen `ScanReceiptScreen` dengan Preview**
  - Deskripsi: Buat screen baru dengan preview gambar struk, tombol "Use this photo"/"Retake", dan loading indicator selama OCR berjalan.
  - File Terkait: `lib/ui/screens/scan_receipt_screen.dart` (baru)
  - AC Terkait: AC-LOG-009.2, AC-LOG-009.3, AC-LOG-010.2, AC-LOG-013.1

- **TASK-OCR-012: Integrasi `ReceiptOcrService` ke `ScanReceiptScreen`**
  - Deskripsi: Panggil `ReceiptOcrService.processImage()` saat user konfirmasi gambar, tampilkan loading, dan handle error/hasil.
  - File Terkait: `lib/ui/screens/scan_receipt_screen.dart`
  - AC Terkait: AC-LOG-009.4, AC-LOG-010.3, AC-LOG-012.1, NFR-LOG-007

- **TASK-OCR-013: Implementasi Pre-fill Form Transaksi**
  - Deskripsi: Setelah OCR selesai, buka form transaksi pengeluaran dengan field yang diisi: Tipe=Pengeluaran, Nominal=hasil parsing (editable), Tanggal=hari ini, Kategori=default/kategori terakhir.
  - File Terkait: `lib/ui/screens/transaction_form_screen.dart` (edit existing), `lib/ui/screens/scan_receipt_screen.dart`
  - AC Terkait: AC-LOG-011.3, AC-LOG-013.3, AC-LOG-014.1

- **TASK-OCR-014: Handle Kasus Gagal Parsing (Nominal Tidak Ditemukan)**
  - Deskripsi: Jika OCR berhasil tapi tidak menemukan nominal, tampilkan pesan "Tidak dapat menemukan nominal pada struk" dan buka form dengan nominal kosong.
  - File Terkait: `lib/ui/screens/scan_receipt_screen.dart`
  - AC Terkait: AC-LOG-012.2, AC-LOG-014.1

- **TASK-OCR-015: Tambah Tombol "Scan Struk" di Form Transaksi**
  - Deskripsi: Tambahkan tombol/ikon di form transaksi untuk membuka `ScanReceiptScreen` (opsi kamera atau galeri).
  - File Terkait: `lib/ui/screens/transaction_form_screen.dart`
  - AC Terkait: AC-LOG-009.1, AC-LOG-010.1

---

### Phase 4: UX & Error Handling

**Tujuan**: Memastikan pengalaman pengguna yang smooth dan feedback error yang jelas.

- **TASK-OCR-016: Implementasi Loading Indicator dengan Progress**
  - Deskripsi: Tampilkan loading indicator yang jelas selama OCR berjalan, dengan pesan "Membaca struk..." atau similar.
  - File Terkait: `lib/ui/screens/scan_receipt_screen.dart`, `lib/ui/widgets/loading_indicator.dart` (baru/join existing)
  - AC Terkait: AC-LOG-009.4, AC-LOG-010.3, AC-LOG-013.1

- **TASK-OCR-017: Implementasi Error Messages yang User-Friendly**
  - Deskripsi: Tampilkan pesan error non-teknis untuk berbagai kasus: "Gagal membaca struk. Silakan coba lagi atau input manual.", "Pastikan struk terbaca dengan jelas dan cahaya cukup", dll.
  - File Terkait: `lib/ui/screens/scan_receipt_screen.dart`, `lib/core/constants/error_messages.dart` (baru/join existing)
  - AC Terkait: AC-LOG-012.1, AC-LOG-012.2, AC-LOG-012.3, NFR-LOG-011

- **TASK-OCR-018: Implementasi Confidence Score Warning**
  - Deskripsi: Jika confidence score ML Kit rendah (< threshold), tampilkan warning "Pastikan nominal yang terdeteksi sudah benar" sebelum user submit form.
  - File Terkait: `lib/ui/screens/transaction_form_screen.dart`, `lib/domain/models/receipt_data.dart`
  - AC Terkait: AC-LOG-014.3

- **TASK-OCR-019: Implementasi Preview Hasil OCR (Optional)**
  - Deskripsi: Tampilkan teks lengkap hasil OCR dalam modal/bottom sheet untuk user verifikasi (opsional feature).
  - File Terkait: `lib/ui/screens/scan_receipt_screen.dart`, `lib/ui/widgets/ocr_result_preview.dart` (baru)
  - AC Terkait: AC-LOG-014.2

- **TASK-OCR-020: Implementasi Fallback ke Input Manual**
  - Deskripsi: Pastikan user selalu bisa membatalkan proses OCR dan kembali ke input manual dengan mudah (tombol "Cancel", "Input Manual", dll).
  - File Terkait: `lib/ui/screens/scan_receipt_screen.dart`
  - AC Terkait: AC-LOG-012.1, AC-LOG-012.2, NFR-LOG-011

---

### Phase 5: Testing & Optimization

**Tujuan**: Memastikan fitur bekerja sesuai spesifikasi dan performa yang diharapkan.

- **TASK-OCR-021: Unit Test untuk `ReceiptOcrService`**
  - Deskripsi: Test inisialisasi ML Kit, pemanggilan `processImage()`, dan error handling (mock ML Kit response).
  - File Terkait: `test/data/services/receipt_ocr_service_test.dart` (baru)
  - AC Terkait: AC-LOG-008.2, AC-LOG-012.1, NFR-LOG-008

- **TASK-OCR-022: Unit Test untuk `ReceiptAmountParser` (Extended)**
  - Deskripsi: Tambahkan test case untuk edge cases: struk tanpa nominal, multiple nominal, format mata uang berbeda, teks noise, dll.
  - File Terkait: `test/domain/receipt_parsers/receipt_amount_parser_test.dart`
  - AC Terkait: AC-LOG-011.1, AC-LOG-011.2, NFR-LOG-009

- **TASK-OCR-023: Integration Test untuk Flow "Scan Struk → Form Transaksi"**
  - Deskripsi: Test alur lengkap dari tap tombol scan, pilih gambar, OCR, hingga form terbuka dengan nominal terisi (widget test/integration test).
  - File Terkait: `integration_test/app_test.dart` (baru/join existing)
  - AC Terkait: AC-LOG-009, AC-LOG-010, AC-LOG-011, AC-LOG-013

- **TASK-OCR-024: Performance Test untuk Waktu OCR**
  - Deskripsi: Measure waktu proses OCR untuk berbagai ukuran/resolusi gambar dan pastikan ≤ 5 detik untuk gambar standar.
  - File Terkait: `test/performance/ocr_performance_test.dart` (baru)
  - AC Terkait: AC-LOG-013.1, NFR-LOG-007

- **TASK-OCR-025: Memory Leak Check**
  - Deskripsi: Pastikan tidak ada memory leak setelah proses OCR berulang kali (check dengan DevTools memory profiling).
  - File Terkait: Manual testing/DevTools
  - AC Terkait: NFR-LOG-008

- **TASK-OCR-026: Cross-Platform Testing (Android & iOS)**
  - Deskripsi: Test fitur OCR di Android dan iOS untuk memastikan konsistensi behavior (permission, camera, OCR accuracy).
  - File Terkait: Manual testing
  - AC Terkait: NFR-LOG-012

---

## 4. Checklist Verifikasi Internal

Sebelum masuk ke fase VERIFY, pastikan:

- [ ] Semua REQ-LOG-008 sampai REQ-LOG-014 memiliki minimal satu TASK-OCR yang mengimplementasikannya.
- [ ] Semua AC-LOG-008.1 sampai AC-LOG-014.3 tercakup dalam kombinasi satu atau beberapa TASK-OCR.
- [ ] Semua NFR-LOG-007 sampai NFR-LOG-012 teraddress oleh task yang relevan.
- [ ] Tidak ada TASK yang keluar dari scope fitur "Input via Struk OCR".
- [ ] Fallback ke input manual tertangani untuk semua kasus error (OCR gagal, nominal tidak ditemukan, permission denied).
- [ ] Semua TASK bersifat atomik dan dapat diselesaikan dalam 30–90 menit.
- [ ] Unit test dan integration test sudah direncanakan untuk critical path.

---

## 5. Open Questions

- **Q1**: Apakah foto struk perlu disimpan permanen di device storage setelah OCR selesai? Atau hanya diproses di memori dan dibuang?
  - **Implikasi**: Jika disimpan permanen, perlu fitur "History Struk" dan manajemen storage. Jika tidak, lebih hemat storage tapi user tidak bisa review struk lama.
  - **Rekomendasi**: Untuk v1, simpan temporary saja (hapus setelah OCR). Pertimbangkan fitur "Attachment Struk" untuk versi mendatang.

- **Q2**: Apakah ada batas maksimal ukuran file gambar yang boleh di-upload untuk OCR?
  - **Implikasi**: Gambar terlalu besar bisa memperlambat OCR atau menyebabkan memory issue. Perlu kompresi sebelum OCR.
  - **Rekomendasi**: Batasi maksimal 5 MB, atau implementasi kompresi otomatis jika > 2 MB.

- **Q3**: Apakah perlu mendukung crop gambar sebelum OCR?
  - **Implikasi**: User bisa crop area struk saja untuk mengurangi noise dan meningkatkan akurasi OCR. Tapi menambah complexity UX.
  - **Rekomendasi**: Untuk v1, skip crop feature (sesuai AC-LOG-013.2: minimal tap). Pertimbangkan untuk v2 jika user feedback minta.

- **Q4**: Apakah confidence score ML Kit perlu ditampilkan ke user?
  - **Implikasi**: Jika ya, perlu UI untuk menampilkan confidence score. Jika tidak, cukup internal logic untuk warning.
  - **Rekomendasi**: Tidak perlu tampilkan score numerik, cukup warning jika rendah (AC-LOG-014.3 sudah handle).

- **Q5**: Apakah perlu mendukung batch scan (multiple struk dalam satu foto)?
  - **Implikasi**: Sangat meningkatkan complexity parsing dan UX.
  - **Rekomendasi**: Untuk v1, hanya support satu struk per foto. Batch scan bisa jadi feature enhancement di masa depan.

---

**Dokumen ini dibuat berdasarkan SPEC-LOG-002-Input-via-Struk-OCR.md dan siap digunakan sebagai panduan implementasi oleh developer/Dev Agent.**
