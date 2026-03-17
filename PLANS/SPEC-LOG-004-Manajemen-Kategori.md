# SPEC – Manajemen Kategori

## Daftar Persyaratan Teknis (REQ-LOG)

### REQ-LOG-022: Pre-defined Kategori
Sistem menyediakan kategori default saat pertama kali aplikasi diinstall.

#### AC-LOG-022.1: Kategori Default Pemasukan
Sistem menyediakan kategori default berikut untuk pemasukan:
- [ ] Gaji
- [ ] Bonus
- [ ] Freelance
- [ ] Hadiah
- [ ] Investasi
- [ ] Lainnya

#### AC-LOG-022.2: Kategori Default Pengeluaran
Sistem menyediakan kategori default berikut untuk pengeluaran:
- [ ] Makan
- [ ] Transport
- [ ] Langganan
- [ ] Belanja
- [ ] Hiburan
- [ ] Kesehatan
- [ ] Pendidikan
- [ ] Tagihan
- [ ] Lainnya

#### AC-LOG-022.3: Inisialisasi Default Kategori
- [ ] Saat pertama kali app dibuka, sistem membuat semua kategori default di database
- [ ] Proses inisialisasi berjalan di background (tidak memblokir UI)
- [ ] Kategori default hanya dibuat jika belum ada kategori di database

---

### REQ-LOG-023: Struktur Data Kategori
Sistem menyimpan kategori dengan struktur yang mendukung pengelompokan.

#### AC-LOG-023.1: Tabel Kategori
- [ ] Setiap kategori disimpan dengan atribut:
  - [ ] ID unik (primary key, auto-increment)
  - [ ] Nama kategori (string, unique)
  - [ ] Tipe kategori (enum: pemasukan/pengeluaran)
  - [ ] Warna (hex color, untuk UI differentiation)
  - [ ] Icon (string nama icon, opsional)
  - [ ] Urutan (integer, untuk sorting)
  - [ ] Status aktif (boolean, untuk soft delete)
  - [ ] Timestamp created_at
  - [ ] Timestamp updated_at

#### AC-LOG-023.2: Relasi dengan Transaksi
- [ ] Tabel transaksi memiliki foreign key `kategori_id` yang merujuk ke tabel kategori
- [ ] Relasi adalah many-to-one (banyak transaksi bisa memiliki satu kategori yang sama)
- [ ] Foreign key constraint: ON DELETE RESTRICT (kategori tidak bisa dihapus jika masih ada transaksi yang menggunakannya)

---

### REQ-LOG-024: Create Kategori Baru
User dapat membuat kategori baru sesuai kebutuhan.

#### AC-LOG-024.1: Form Create Kategori
- [ ] Sistem menyediakan form/screen untuk membuat kategori baru
- [ ] Form menyediakan field:
  - [ ] Nama kategori (text input, wajib)
  - [ ] Tipe kategori (dropdown: pemasukan/pengeluaran, wajib)
  - [ ] Warna (color picker, opsional - ada default)
  - [ ] Icon (icon picker, opsional - ada default)

#### AC-LOG-024.2: Validasi Create Kategori
- [ ] Nama kategori wajib diisi
- [ ] Nama kategori harus unik (tidak boleh sama dengan kategori yang sudah ada)
- [ ] Tipe kategori wajib dipilih
- [ ] Jika nama kategori sudah ada, sistem menampilkan pesan error: "Kategori dengan nama ini sudah ada"

#### AC-LOG-024.3: Simpan Kategori Baru
- [ ] Setelah validasi sukses, kategori disimpan ke database
- [ ] User menerima feedback sukses
- [ ] Kategori baru langsung muncul di daftar kategori dan di form input transaksi

---

### REQ-LOG-025: Read Daftar Kategori
Sistem menampilkan daftar semua kategori yang tersedia.

#### AC-LOG-025.1: List Kategori
- [ ] Sistem menampilkan daftar kategori yang dikelompokkan berdasarkan tipe:
  - [ ] Section "Pemasukan"
  - [ ] Section "Pengeluaran"
- [ ] Setiap item kategori menampilkan:
  - [ ] Nama kategori
  - [ ] Warna (color dot atau background)
  - [ ] Icon (jika ada)
  - [ ] Jumlah transaksi yang menggunakan kategori ini (opsional)

#### AC-LOG-025.2: Sorting Kategori
- [ ] Kategori diurutkan berdasarkan kolom `urutan` (ascending)
- [ ] Jika `urutan` sama, diurutkan berdasarkan nama (ascending)

#### AC-LOG-025.3: Filter Kategori
- [ ] User dapat memfilter kategori berdasarkan tipe (pemasukan/pengeluaran)
- [ ] User dapat mencari kategori berdasarkan nama (search bar)

#### AC-LOG-025.4: Kategori untuk Dropdown Transaksi
- [ ] Di form input transaksi, dropdown kategori hanya menampilkan kategori sesuai tipe transaksi:
  - [ ] Jika tipe = "Pemasukan", hanya menampilkan kategori pemasukan
  - [ ] Jika tipe = "Pengeluaran", hanya menampilkan kategori pengeluaran

---

### REQ-LOG-026: Update Kategori
User dapat mengedit kategori yang sudah ada.

#### AC-LOG-026.1: Akses Mode Edit
- [ ] Setiap item kategori di daftar kategori memiliki tombol/ikon untuk edit
- [ ] Saat tombol edit ditekan, form edit muncul dengan data kategori yang sudah ada terisi

#### AC-LOG-026.2: Proses Edit
- [ ] Form edit memiliki semua field yang sama dengan form create
- [ ] User dapat mengubah:
  - [ ] Nama kategori (harus unik)
  - [ ] Warna
  - [ ] Icon
- [ ] User TIDAK dapat mengubah tipe kategori (pemasukan/pengeluaran)

#### AC-LOG-026.3: Update Data
- [ ] Setelah edit disimpan, data kategori di database diperbarui
- [ ] Timestamp updated_at dicatat
- [ ] User menerima feedback sukses
- [ ] Perubahan langsung terlihat di:
  - [ ] Daftar kategori
  - [ ] Form input transaksi
  - [ ] Dashboard dan insight (karena nama kategori berubah)

---

### REQ-LOG-027: Delete Kategori
User dapat menghapus kategori yang tidak digunakan.

#### AC-LOG-027.1: Akses Opsi Hapus
- [ ] Setiap item kategori di daftar kategori memiliki tombol/ikon untuk hapus
- [ ] Saat tombol hapus ditekan, sistem menampilkan dialog konfirmasi

#### AC-LOG-027.2: Validasi Sebelum Hapus
- [ ] Sistem mengecek apakah kategori masih digunakan oleh transaksi:
  - [ ] Jika ada transaksi yang menggunakan kategori ini, hapus DILARANG
  - [ ] Jika tidak ada transaksi yang menggunakan kategori ini, hapus DIPERBOLEHKAN

#### AC-LOG-027.3: Dialog Konfirmasi (Jika Diperbolehkan)
- [ ] Dialog menampilkan pesan: "Apakah Anda yakin ingin menghapus kategori [nama kategori]?"
- [ ] Dialog menyediakan tombol "Batal" dan "Hapus"
- [ ] Kategori hanya dihapus jika user menekan "Hapus"

#### AC-LOG-027.4: Error Handling (Jika Dilarang)
- [ ] Jika kategori masih digunakan, sistem menampilkan pesan error:
  - [ ] "Kategori ini tidak dapat dihapus karena masih digunakan oleh [jumlah] transaksi."
  - [ ] "Gunakan opsi 'Nonaktifkan' jika Anda tidak ingin kategori ini muncul di dropdown."

#### AC-LOG-027.5: Soft Delete (Nonaktifkan Kategori)
- [ ] Sebagai alternatif hard delete, sistem menyediakan opsi "Nonaktifkan"
- [ ] Kategori yang dinonaktifkan memiliki `status_aktif = false`
- [ ] Kategori nonaktif TIDAK muncul di dropdown form transaksi
- [ ] Kategori nonaktif MASIH muncul di daftar kategori (dengan label "Nonaktif")
- [ ] Transaksi yang sudah menggunakan kategori nonaktif TETAP menampilkan kategori tersebut

---

### REQ-LOG-028: Reorder Kategori
User dapat mengubah urutan kategori di dropdown.

#### AC-LOG-028.1: Drag & Drop Reorder
- [ ] Di daftar kategori, user dapat drag & drop untuk mengubah urutan
- [ ] Kolom `urutan` di-update sesuai posisi baru

#### AC-LOG-028.2: Persist Urutan
- [ ] Urutan kategori disimpan ke database
- [ ] Urutan baru langsung terlihat di dropdown form transaksi

---

### REQ-LOG-029: Color & Icon Management
Sistem menyediakan pilihan color dan icon untuk kategori.

#### AC-LOG-029.1: Color Picker
- [ ] Sistem menyediakan palette warna predefined (misalnya 10-15 warna)
- [ ] User dapat memilih warna dari palette
- [ ] Setiap kategori default sudah memiliki warna yang berbeda

#### AC-LOG-029.2: Icon Picker
- [ ] Sistem menyediakan set icon predefined (misalnya menggunakan Material Icons atau FontAwesome)
- [ ] User dapat memilih icon dari list
- [ ] Icon ditampilkan di dashboard dan list transaksi

#### AC-LOG-029.3: Default Values
- [ ] Jika user tidak memilih warna, sistem memberikan warna default random dari palette
- [ ] Jika user tidak memilih icon, sistem memberikan icon default berdasarkan tipe kategori

---

## Non-Functional Requirements (NFR)

### NFR-LOG-019: Performa Query Kategori
- [ ] **Loading Time**: Loading daftar kategori harus:
  - [ ] ≤ 500ms untuk menampilkan semua kategori (biasanya < 50 kategori)
  - [ ] Mendukung pencarian kategori dengan real-time filter

### NFR-LOG-020: Uniqueness Constraint
- [ ] **Data Integrity**: Nama kategori harus unik per tipe:
  - [ ] Tidak boleh ada dua kategori pemasukan dengan nama sama
  - [ ] Tidak boleh ada dua kategori pengeluaran dengan nama sama
  - [ ] Database constraint: UNIQUE(nama, tipe)

### NFR-LOG-021: Foreign Key Constraint
- [ ] **Referential Integrity**: Relasi kategori-transaksi harus:
  - [ ] Mencegah hard delete kategori yang masih digunakan
  - [ ] Menggunakan soft delete sebagai alternatif

### NFR-LOG-022: User Experience
- [ ] **Minimal Friction**: Manajemen kategori harus mudah:
  - [ ] User dapat membuat kategori baru langsung dari form transaksi (jika kategori yang diinginkan belum ada)
  - [ ] Dropdown kategori di form transaksi harus mudah di-navigate

### NFR-LOG-023: Visual Consistency
- [ ] **Color & Icon**: Warna dan icon kategori harus:
  - [ ] Konsisten di seluruh app (form transaksi, list transaksi, dashboard)
  - [ ] Memiliki contrast yang cukup untuk aksesibilitas

### NFR-LOG-024: Scalability
- [ ] **Future-Proofing**: Struktur kategori harus mendukung:
  - [ ] Sub-kategori (opsional untuk versi mendatang)
  - [ ] Pengelompokan kategori (opsional untuk versi mendatang)
