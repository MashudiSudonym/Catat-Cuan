# SPEC – Input via Struk (OCR)

## Daftar Persyaratan Teknis (REQ-LOG)

### REQ-LOG-008: Integrasi Google ML Kit Text Recognition v2
Sistem mengintegrasikan Google ML Kit untuk OCR struk fisik dan digital.

#### AC-LOG-008.1: Setup Dependency
- [x] Project Flutter memiliki dependency `google_mlkit_text_recognition` versi terbaru
- [x] Konfigurasi minimal SDK Android dan iOS sesuai requirement ML Kit
- [x] Permission kamera dan storage sudah dikonfigurasi di AndroidManifest.xml dan Info.plist

#### AC-LOG-008.2: Inisialisasi ML Kit
- [x] Text recognizer diinisialisasi saat app启动 (on-device mode)
- [x] Inisialisasi tidak memblokir UI thread
- [x] Fallback jika ML Kit gagal diinisialisasi (tampilkan pesan error)

---

### REQ-LOG-009: Flow Input via Kamera
Sistem menyediakan flow untuk memfoto struk kertas langsung dari aplikasi.

#### AC-LOG-009.1: Akses Kamera
- [x] Form input transaksi menyediakan tombol/ikon untuk akses kamera
- [x] Saat ditekan, sistem meminta izin kamera jika belum diberikan
- [x] Jika izin ditolak, sistem menampilkan pesan bahwa izin diperlukan

#### AC-LOG-009.2: Preview Kamera
- [x] Tampilan kamera full-screen atau dalam modal dialog
- [x] Terdapat frame guide untuk memudahkan user mengarahkan ke struk
- [x] Terdapat tombol capture dan tombol cancel

#### AC-LOG-009.3: Capture Gambar
- [x] Saat tombol capture ditekan, gambar diambil dengan resolusi optimal untuk OCR
- [x] Preview gambar ditampilkan sebelum proses OCR
- [x] User dapat retake jika gambar tidak jelas

#### AC-LOG-009.4: Proses OCR
- [x] Setelah gambar dikonfirmasi, sistem memproses gambar dengan ML Kit
- [x] Sistem menampilkan indikator loading selama proses OCR
- [x] Proses OCR berjalan di background thread (tidak memblokir UI)

---

### REQ-LOG-010: Flow Input via Galeri
Sistem menyediakan flow untuk memilih screenshot/gambar struk dari galeri.

#### AC-LOG-010.1: Akses Galeri
- [x] Form input transaksi menyediakan tombol/ikon untuk akses galeri
- [x] Saat ditekan, sistem membuka image picker native
- [x] User dapat memilih gambar dari galeri device

#### AC-LOG-010.2: Preview Gambar Terpilih
- [x] Setelah gambar dipilih, sistem menampilkan preview
- [x] User dapat membatalkan atau melanjutkan ke proses OCR
- [x] User dapat memilih ulang jika gambar salah

#### AC-LOG-010.3: Proses OCR
- [x] Setelah dikonfirmasi, sistem memproses gambar dengan ML Kit
- [x] Sistem menampilkan indikator loading selama proses OCR
- [x] Proses OCR berjalan di background thread

---

### REQ-LOG-011: Ekstraksi Nominal dari Hasil OCR
Sistem menganalisis teks hasil OCR untuk menemukan nominal total transaksi.

#### AC-LOG-011.1: Deteksi Pola Nominal
- [x] Sistem mencari teks yang mengandung kata kunci: "total", "jumlah", "amount", "grand total", atau pola numerik dengan mata uang (Rp, $, dll)
- [x] Sistem mendukung format nominal Indonesia:
  - [x] "Rp 50.000"
  - [x] "50.000"
  - [x] "50,000"
  - [x] "50.000,00"
- [x] Sistem membersihkan format (menghapus titik pemisah ribuan dan simbol mata uang)

#### AC-LOG-011.2: Validasi Nominal Terdeteksi
- [x] Nominal yang terdeteksi harus berupa angka valid
- [x] Nominal harus > 0
- [x] Jika multiple nominal ditemukan, sistem mengambil yang terbesar atau yang dekat kata kunci "total"

#### AC-LOG-011.3: Pre-fill Form
- [x] Nominal yang berhasil diekstraksi otomatis diisi ke field "Nominal" di form transaksi
- [x] Nominal tetap dapat diedit oleh user
- [x] Field lain (tipe, tanggal, kategori) menggunakan nilai default atau kosong

---

### REQ-LOG-012: Error Handling OCR
Sistem menangani kasus ketika OCR gagal atau tidak menemukan nominal.

#### AC-LOG-012.1: OCR Gagal Total
- [x] Jika ML Kit gagal memproses gambar (error teknis), sistem menampilkan pesan error yang jelas
- [x] Pesan error tidak teknis: "Gagal membaca struk. Silakan coba lagi atau input manual."
- [x] User dapat mencapture ulang atau input manual

#### AC-LOG-012.2: Nominal Tidak Ditemukan
- [x] Jika OCR berhasil tapi tidak menemukan nominal, sistem menampilkan pesan: "Tidak dapat menemukan nominal pada struk"
- [x] User tetap dapat melihat hasil OCR untuk referensi
- [x] User dapat input manual atau mencoba dengan gambar lain

#### AC-LOG-012.3: Gambar Tidak Jelas
- [x] Sistem memberikan feedback jika gambar terlalu gelap, buram, atau miring
- [x] Suggestion: "Pastikan struk terbaca dengan jelas dan cahaya cukup"

---

### REQ-LOG-013: UX Performance untuk Input via Struk
Sesuai PRD section 5, input via struk harus selesai dalam ≤ 30 detik.

#### AC-LOG-013.1: Waktu Proses OCR
- [x] Proses OCR harus selesai dalam ≤ 5 detik untuk gambar standar
- [x] Loading indicator memberikan feedback bahwa sistem sedang bekerja

#### AC-LOG-013.2: Minimal Tap
- [x] Flow input via struk membutuhkan minimal:
  - [x] 1 tap untuk buka kamera/galeri
  - [x] 1 tap untuk capture/pilih gambar
  - [x] 1 tap untuk konfirmasi hasil
  - [x] Total: 3-4 tap (excluding input manual correction)

#### AC-LOG-013.3: Smart Defaults
- [x] Setelah nominal terisi, tipe transaksi default ke "Pengeluaran"
- [x] Tanggal & waktu default ke waktu saat ini
- [x] User tinggal memilih kategori dan menambahkan catatan (opsional)

---

### REQ-LOG-014: Validasi Hasil OCR
Sistem memberikan kesempatan kepada user untuk mengoreksi hasil OCR.

#### AC-LOG-014.1: Edit Hasil OCR
- [x] Setelah OCR selesai, form ditampilkan dengan nominal yang terdeteksi
- [x] Nominal dapat diedit dengan tap
- [x] User dapat membatalkan dan kembali ke capture/pilih gambar

#### AC-LOG-014.2: Preview Hasil OCR
- [x] Sistem menampilkan teks lengkap yang diekstrak dari struk (opsional)
- [x] User dapat memverifikasi bahwa nominal yang terdeteksi benar

#### AC-LOG-014.3: Confidence Check
- [x] Jika confidence score ML Kit rendah, sistem memberi tahu user: "Pastikan nominal yang terdeteksi sudah benar"

---

## Non-Functional Requirements (NFR)

### NFR-LOG-007: Performa OCR
- [x] **Processing Time**: ML Kit text recognition harus selesai dalam:
  - [x] ≤ 3 detik untuk gambar standar struk
  - [x] ≤ 5 detik untuk gambar kompleks atau resolusi tinggi

### NFR-LOG-008: Resource Usage
- [x] **Memory Usage**: Proses OCR tidak boleh menyebabkan:
  - [x] Memory leak
  - [x] App crash karena memory overflow
  - [x] UI freeze selama proses OCR

### NFR-LOG-009: Accuracy
- [x] **OCR Accuracy**: Untuk struk standar yang jelas:
  - [x] Tingkat keberhasilan ekstraksi nominal ≥ 80%
  - [x] False positive rate ≤ 10% (tidak salah mendeteksi nominal)

### NFR-LOG-010: Privacy
- [x] **Data Privacy**: Semua proses OCR dilakukan on-device:
  - [x] Gambar struk tidak dikirim ke server eksternal
  - [x] Gambar struk tidak disimpan secara permanen di device (opsional: hanya temporary untuk proses)

### NFR-LOG-011: User Experience
- [x] **Fallback Graceful**: Jika OCR gagal:
  - [x] User dapat dengan mudah beralih ke input manual
  - [x] Tidak ada friction berlebihan
  - [x] Pesan error tidak menyalahkan user

### NFR-LOG-012: Cross-Platform Consistency
- [x] **Platform Parity**: Fitur OCR harus bekerja konsisten di:
  - [x] Android
  - [x] iOS (jika didukung di v1)


---

## Verifikasi Checklist

**Total Requirements**: 5 (REQ-LOG-008 hingga REQ-LOG-012)
**Total NFR**: 4 (NFR-LOG-009 hingga NFR-LOG-012)

### Status Implementasi

| ID | Deskripsi | Status | Metode Verifikasi | Terakhir Diverifikasi |
|----|-----------|--------|-------------------|---------------------|
| REQ-LOG-008 | Integrasi Google ML Kit | ✅ | Code review | 2026-03-27 |
| REQ-LOG-009 | Flow Input via Kamera | ✅ | Manual testing | 2026-03-27 |
| REQ-LOG-010 | Flow Input via Galeri | ✅ | Manual testing | 2026-03-27 |
| REQ-LOG-011 | Ekstraksi Nominal | ✅ | Test execution | 2026-03-27 |
| REQ-LOG-012 | Error Handling | ✅ | Manual testing | 2026-03-27 |
| NFR-LOG-009 | Accuracy | ✅ | Performance test | 2026-03-27 |
| NFR-LOG-010 | Privacy | ✅ | Code review | 2026-03-27 |
| NFR-LOG-011 | User Experience | ✅ | Manual testing | 2026-03-27 |
| NFR-LOG-012 | Cross-Platform | ✅ | Test execution | 2026-03-27 |

### Ringkasan Implementasi

- **Total Requirements**: 5
- **Fully Implemented (✅)**: 5 (100%)
- **Partially Implemented (⚠️)**: 0 (0%)
- **Not Implemented (❌)**: 0 (0%)

### File Implementasi Utama

- **Screen**: `lib/presentation/screens/scan_receipt_screen.dart`
- **Controller**: `lib/presentation/controllers/receipt_scanning_controller.dart`
- **Service**: `lib/data/services/receipt_ocr_service_impl.dart`
- **Parser**: `lib/domain/parsers/receipt_amount_parser.dart`

### Catatan Verifikasi

Semua persyaratan telah diimplementasikan sesuai spesifikasi. OCR berjalan on-device dengan Google ML Kit, mendukung kamera dan galeri, dan memiliki error handling yang baik. Ekstraksi nominal mendukung berbagai format Indonesia.
