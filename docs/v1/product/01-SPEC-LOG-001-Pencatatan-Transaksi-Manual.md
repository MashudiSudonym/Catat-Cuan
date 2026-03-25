# SPEC – Pencatatan Transaksi Manual

## Daftar Persyaratan Teknis (REQ-LOG)

### REQ-LOG-001: Form Input Transaksi Baru
Sistem menyediakan antarmuka pengguna untuk mencatat transaksi pemasukan atau pengeluaran baru.

#### AC-LOG-001.1: Field yang Tersedia
- [ ] Form menyediakan field input berikut:
  - [ ] Nominal (angka, desimal diperbolehkan)
  - [ ] Tipe transaksi (pilihan: Pemasukan / Pengeluaran)
  - [ ] Tanggal transaksi (date picker)
  - [ ] Waktu transaksi (time picker)
  - [ ] Kategori (dropdown pilihan)
  - [ ] Catatan (text input, opsional)

#### AC-LOG-001.2: Default Value yang Smart
- [ ] Saat form dibuka, tipe transaksi default adalah "Pengeluaran"
- [ ] Saat form dibuka, tanggal & waktu default adalah waktu saat ini
- [ ] Field catatan kosong secara default (opsional)

---

### REQ-LOG-002: Validasi Input Transaksi
Sistem memvalidasi semua input sebelum transaksi disimpan untuk memastikan data integrity.

#### AC-LOG-002.1: Validasi Field Wajib
- [ ] Nominal wajib diisi
- [ ] Nominal harus berupa angka yang valid
- [ ] Nominal harus > 0
- [ ] Tipe transaksi wajib dipilih (Pemasukan atau Pengeluaran)
- [ ] Tanggal transaksi wajib diisi
- [ ] Kategori wajib dipilih

#### AC-LOG-002.2: Pesan Error yang Jelas
- [ ] Jika nominal kosong, sistem menampilkan pesan error: "Nominal wajib diisi"
- [ ] Jika nominal ≤ 0, sistem menampilkan pesan error: "Nominal harus lebih dari 0"
- [ ] Jika kategori belum dipilih, sistem menampilkan pesan error: "Kategori wajib dipilih"
- [ ] Pesan error ditampilkan di dekat field yang bersangkutan

#### AC-LOG-002.3: Prevent Submit pada Data Tidak Valid
- [ ] Tombol simpan tidak dapat ditekan (disabled) jika field wajib belum terisi
- [ ] ATAU: Tombol simpan dapat ditekan tapi menampilkan pesan validasi dan tidak menyimpan data

---

### REQ-LOG-003: Penyimpanan Transaksi
Sistem menyimpan transaksi yang valid ke database lokal.

#### AC-LOG-003.1: Struktur Data Transaksi
- [ ] Setiap transaksi disimpan dengan atribut:
  - [ ] ID unik (primary key, auto-increment)
  - [ ] Nominal (decimal/numeric)
  - [ ] Tipe (enum: pemasukan/pengeluaran)
  - [ ] Tanggal & waktu (datetime)
  - [ ] Kategori (foreign key ke tabel kategori)
  - [ ] Catatan (text, nullable)
  - [ ] Timestamp created_at

#### AC-LOG-003.2: Keandalan Penyimpanan
- [ ] Transaksi hanya disimpan jika semua validasi terpenuhi
- [ ] Sistem menampilkan feedback sukses setelah transaksi berhasil disimpan
- [ ] Jika terjadi kegagalan penyimpanan (database error), sistem menampilkan pesan error yang jelas

---

### REQ-LOG-004: Perilaku Setelah Submit Transaksi
Sistem merespons setelah transaksi berhasil disimpan.

#### AC-LOG-004.1: Reset Form
- [ ] Setelah transaksi berhasil disimpan, form di-reset ke kondisi awal
- [ ] Field nominal dikosongkan
- [ ] Field catatan dikosongkan
- [ ] Tipe transaksi kembali ke default ("Pengeluaran")
- [ ] Tanggal & waktu kembali ke waktu saat ini

#### AC-LOG-004.2: Feedback Visual
- [ ] Sistem menampilkan pesan sukses (misalnya: snackbar/toast) berdurasi ≤ 3 detik
- [ ] Pesan sukses berisi konfirmasi penyimpanan transaksi

#### AC-LOG-004.3: Navigasi Pasca-Submit
- [ ] User tetap berada di form input (untuk input berikutnya)
- [ ] ATAU: User diarahkan kembali ke layar list transaksi (sesuai preferensi UX)

---

### REQ-LOG-005: Daftar Transaksi (List View)
Sistem menampilkan daftar transaksi yang telah dicatat.

#### AC-LOG-005.1: Tampilan List Transaksi
- [ ] Sistem menampilkan daftar semua transaksi yang tersimpan
- [ ] Setiap item transaksi menampilkan:
  - [ ] Nominal
  - [ ] Tipe (pemasukan/pengeluaran) dengan visual distinction (warna berbeda)
  - [ ] Kategori
  - [ ] Tanggal & waktu
  - [ ] Catatan (jika ada)

#### AC-LOG-005.2: Pengurutan (Sorting)
- [ ] Transaksi diurutkan berdasarkan tanggal & waktu secara descending (terbaru di atas)

#### AC-LOG-005.3: Filter Transaksi
- [ ] Sistem menyediakan filter berdasarkan:
  - [ ] Rentang tanggal
  - [ ] Kategori
  - [ ] Tipe transaksi (pemasukan/pengeluaran)

---

### REQ-LOG-006: Edit Transaksi
Sistem memungkinkan pengguna mengedit transaksi yang sudah ada.

#### AC-LOG-006.1: Akses Mode Edit
- [ ] Setiap item transaksi memiliki tombol/ikon untuk edit
- [ ] Saat tombol edit ditekan, form input muncul dengan data transaksi yang sudah ada terisi

#### AC-LOG-006.2: Proses Edit
- [ ] Form edit memiliki semua field yang sama dengan form create
- [ ] User dapat mengubah semua field kecuali ID (auto-generated)
- [ ] Validasi yang sama dengan form create diterapkan

#### AC-LOG-006.3: Update Data
- [ ] Setelah edit disimpan, data transaksi di database diperbarui
- [ ] Timestamp updated_at dicatat
- [ ] User menerima feedback sukses
- [ ] List transaksi diperbarui untuk menampilkan data yang telah diubah

---

### REQ-LOG-007: Hapus Transaksi
Sistem memungkinkan pengguna menghapus transaksi.

#### AC-LOG-007.1: Akses Opsi Hapus
- [ ] Setiap item transaksi memiliki tombol/ikon untuk hapus
- [ ] Saat tombol hapus ditekan, sistem menampilkan dialog konfirmasi

#### AC-LOG-007.2: Dialog Konfirmasi
- [ ] Dialog menampilkan pesan: "Apakah Anda yakin ingin menghapus transaksi ini?"
- [ ] Dialog menyediakan tombol "Batal" dan "Hapus"
- [ ] Transaksi hanya dihapus jika user menekan "Hapus"

#### AC-LOG-007.3: Proses Penghapusan
- [ ] Setelah dikonfirmasi, transaksi dihapus dari database
- [ ] User menerima feedback sukses (transaksi berhasil dihapus)
- [ ] List transaksi diperbarui untuk menghapus item yang dihapus

---

## Non-Functional Requirements (NFR)

### NFR-LOG-001: Performa UI
- [ ] **Responsiveness**: Form input transaksi harus terasa responsif
  - [ ] Waktu respon tap ≤ 100ms untuk setiap interaksi
  - [ ] Animasi transisi antar form ≤ 300ms

### NFR-LOG-002: Performa Penyimpanan
- [ ] **Kecepatan Simpan**: Operasi penyimpanan transaksi harus selesai dalam:
  - [ ] ≤ 500ms untuk penyimpanan lokal (SQLite)
  - [ ] Feedback sukses ditampilkan dalam ≤ 1 detik setelah tap tombol simpan

### NFR-LOG-003: Keandalan Penyimpanan Lokal
- [ ] **Data Integrity**: Database lokal harus menjamin:
  - [ ] ACID compliance untuk operasi transaksi
  - [ ] Tidak ada data loss saat aplikasi tertutup secara tidak terduga
  - [ ] Backup data otomatis (opsional namun direkomendasikan)

### NFR-LOG-004: Performa Query List Transaksi
- [ ] **Loading Time**: Loading list transaksi harus:
  - [ ] ≤ 1 detik untuk menampilkan 100 transaksi terbaru
  - [ ] Mendukung pagination atau lazy loading jika jumlah transaksi sangat besar

### NFR-LOG-005: User Experience (UX)
- [ ] **Kecepatan Input Manual**: Sesuai PRD section 5:
  - [ ] Input transaksi manual harus bisa diselesaikan dalam ≤ 20 detik
  - [ ] Minimal friction: jumlah tap minimal untuk selesaikan satu transaksi

### NFR-LOG-006: Validasi & Error Handling
- [ ] **Error Prevention**: Sistem harus mencegah input invalid sebelum submit
  - [ ] Validasi real-time saat user mengetik (jika memungkinkan)
  - [ ] Pesan error yang spesifik dan actionable
