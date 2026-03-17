# SPEC – Input via Struk (OCR)

## Daftar Persyaratan Teknis (REQ-LOG)

### REQ-LOG-008: Integrasi Google ML Kit Text Recognition v2
Sistem mengintegrasikan Google ML Kit untuk OCR struk fisik dan digital.

#### AC-LOG-008.1: Setup Dependency
- [ ] Project Flutter memiliki dependency `google_mlkit_text_recognition` versi terbaru
- [ ] Konfigurasi minimal SDK Android dan iOS sesuai requirement ML Kit
- [ ] Permission kamera dan storage sudah dikonfigurasi di AndroidManifest.xml dan Info.plist

#### AC-LOG-008.2: Inisialisasi ML Kit
- [ ] Text recognizer diinisialisasi saat app启动 (on-device mode)
- [ ] Inisialisasi tidak memblokir UI thread
- [ ] Fallback jika ML Kit gagal diinisialisasi (tampilkan pesan error)

---

### REQ-LOG-009: Flow Input via Kamera
Sistem menyediakan flow untuk memfoto struk kertas langsung dari aplikasi.

#### AC-LOG-009.1: Akses Kamera
- [ ] Form input transaksi menyediakan tombol/ikon untuk akses kamera
- [ ] Saat ditekan, sistem meminta izin kamera jika belum diberikan
- [ ] Jika izin ditolak, sistem menampilkan pesan bahwa izin diperlukan

#### AC-LOG-009.2: Preview Kamera
- [ ] Tampilan kamera full-screen atau dalam modal dialog
- [ ] Terdapat frame guide untuk memudahkan user mengarahkan ke struk
- [ ] Terdapat tombol capture dan tombol cancel

#### AC-LOG-009.3: Capture Gambar
- [ ] Saat tombol capture ditekan, gambar diambil dengan resolusi optimal untuk OCR
- [ ] Preview gambar ditampilkan sebelum proses OCR
- [ ] User dapat retake jika gambar tidak jelas

#### AC-LOG-009.4: Proses OCR
- [ ] Setelah gambar dikonfirmasi, sistem memproses gambar dengan ML Kit
- [ ] Sistem menampilkan indikator loading selama proses OCR
- [ ] Proses OCR berjalan di background thread (tidak memblokir UI)

---

### REQ-LOG-010: Flow Input via Galeri
Sistem menyediakan flow untuk memilih screenshot/gambar struk dari galeri.

#### AC-LOG-010.1: Akses Galeri
- [ ] Form input transaksi menyediakan tombol/ikon untuk akses galeri
- [ ] Saat ditekan, sistem membuka image picker native
- [ ] User dapat memilih gambar dari galeri device

#### AC-LOG-010.2: Preview Gambar Terpilih
- [ ] Setelah gambar dipilih, sistem menampilkan preview
- [ ] User dapat membatalkan atau melanjutkan ke proses OCR
- [ ] User dapat memilih ulang jika gambar salah

#### AC-LOG-010.3: Proses OCR
- [ ] Setelah dikonfirmasi, sistem memproses gambar dengan ML Kit
- [ ] Sistem menampilkan indikator loading selama proses OCR
- [ ] Proses OCR berjalan di background thread

---

### REQ-LOG-011: Ekstraksi Nominal dari Hasil OCR
Sistem menganalisis teks hasil OCR untuk menemukan nominal total transaksi.

#### AC-LOG-011.1: Deteksi Pola Nominal
- [ ] Sistem mencari teks yang mengandung kata kunci: "total", "jumlah", "amount", "grand total", atau pola numerik dengan mata uang (Rp, $, dll)
- [ ] Sistem mendukung format nominal Indonesia:
  - [ ] "Rp 50.000"
  - [ ] "50.000"
  - [ ] "50,000"
  - [ ] "50.000,00"
- [ ] Sistem membersihkan format (menghapus titik pemisah ribuan dan simbol mata uang)

#### AC-LOG-011.2: Validasi Nominal Terdeteksi
- [ ] Nominal yang terdeteksi harus berupa angka valid
- [ ] Nominal harus > 0
- [ ] Jika multiple nominal ditemukan, sistem mengambil yang terbesar atau yang dekat kata kunci "total"

#### AC-LOG-011.3: Pre-fill Form
- [ ] Nominal yang berhasil diekstraksi otomatis diisi ke field "Nominal" di form transaksi
- [ ] Nominal tetap dapat diedit oleh user
- [ ] Field lain (tipe, tanggal, kategori) menggunakan nilai default atau kosong

---

### REQ-LOG-012: Error Handling OCR
Sistem menangani kasus ketika OCR gagal atau tidak menemukan nominal.

#### AC-LOG-012.1: OCR Gagal Total
- [ ] Jika ML Kit gagal memproses gambar (error teknis), sistem menampilkan pesan error yang jelas
- [ ] Pesan error tidak teknis: "Gagal membaca struk. Silakan coba lagi atau input manual."
- [ ] User dapat mencapture ulang atau input manual

#### AC-LOG-012.2: Nominal Tidak Ditemukan
- [ ] Jika OCR berhasil tapi tidak menemukan nominal, sistem menampilkan pesan: "Tidak dapat menemukan nominal pada struk"
- [ ] User tetap dapat melihat hasil OCR untuk referensi
- [ ] User dapat input manual atau mencoba dengan gambar lain

#### AC-LOG-012.3: Gambar Tidak Jelas
- [ ] Sistem memberikan feedback jika gambar terlalu gelap, buram, atau miring
- [ ] Suggestion: "Pastikan struk terbaca dengan jelas dan cahaya cukup"

---

### REQ-LOG-013: UX Performance untuk Input via Struk
Sesuai PRD section 5, input via struk harus selesai dalam ≤ 30 detik.

#### AC-LOG-013.1: Waktu Proses OCR
- [ ] Proses OCR harus selesai dalam ≤ 5 detik untuk gambar standar
- [ ] Loading indicator memberikan feedback bahwa sistem sedang bekerja

#### AC-LOG-013.2: Minimal Tap
- [ ] Flow input via struk membutuhkan minimal:
  - [ ] 1 tap untuk buka kamera/galeri
  - [ ] 1 tap untuk capture/pilih gambar
  - [ ] 1 tap untuk konfirmasi hasil
  - [ ] Total: 3-4 tap (excluding input manual correction)

#### AC-LOG-013.3: Smart Defaults
- [ ] Setelah nominal terisi, tipe transaksi default ke "Pengeluaran"
- [ ] Tanggal & waktu default ke waktu saat ini
- [ ] User tinggal memilih kategori dan menambahkan catatan (opsional)

---

### REQ-LOG-014: Validasi Hasil OCR
Sistem memberikan kesempatan kepada user untuk mengoreksi hasil OCR.

#### AC-LOG-014.1: Edit Hasil OCR
- [ ] Setelah OCR selesai, form ditampilkan dengan nominal yang terdeteksi
- [ ] Nominal dapat diedit dengan tap
- [ ] User dapat membatalkan dan kembali ke capture/pilih gambar

#### AC-LOG-014.2: Preview Hasil OCR
- [ ] Sistem menampilkan teks lengkap yang diekstrak dari struk (opsional)
- [ ] User dapat memverifikasi bahwa nominal yang terdeteksi benar

#### AC-LOG-014.3: Confidence Check
- [ ] Jika confidence score ML Kit rendah, sistem memberi tahu user: "Pastikan nominal yang terdeteksi sudah benar"

---

## Non-Functional Requirements (NFR)

### NFR-LOG-007: Performa OCR
- [ ] **Processing Time**: ML Kit text recognition harus selesai dalam:
  - [ ] ≤ 3 detik untuk gambar standar struk
  - [ ] ≤ 5 detik untuk gambar kompleks atau resolusi tinggi

### NFR-LOG-008: Resource Usage
- [ ] **Memory Usage**: Proses OCR tidak boleh menyebabkan:
  - [ ] Memory leak
  - [ ] App crash karena memory overflow
  - [ ] UI freeze selama proses OCR

### NFR-LOG-009: Accuracy
- [ ] **OCR Accuracy**: Untuk struk standar yang jelas:
  - [ ] Tingkat keberhasilan ekstraksi nominal ≥ 80%
  - [ ] False positive rate ≤ 10% (tidak salah mendeteksi nominal)

### NFR-LOG-010: Privacy
- [ ] **Data Privacy**: Semua proses OCR dilakukan on-device:
  - [ ] Gambar struk tidak dikirim ke server eksternal
  - [ ] Gambar struk tidak disimpan secara permanen di device (opsional: hanya temporary untuk proses)

### NFR-LOG-011: User Experience
- [ ] **Fallback Graceful**: Jika OCR gagal:
  - [ ] User dapat dengan mudah beralih ke input manual
  - [ ] Tidak ada friction berlebihan
  - [ ] Pesan error tidak menyalahkan user

### NFR-LOG-012: Cross-Platform Consistency
- [ ] **Platform Parity**: Fitur OCR harus bekerja konsisten di:
  - [ ] Android
  - [ ] iOS (jika didukung di v1)
