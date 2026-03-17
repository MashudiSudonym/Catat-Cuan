# SPEC – Ringkasan Bulanan & Insight

## Daftar Persyaratan Teknis (REQ-LOG)

### REQ-LOG-015: Dashboard Ringkasan Bulanan
Sistem menyediakan dashboard untuk menampilkan ringkasan keuangan bulanan.

#### AC-LOG-015.1: Metrik Ringkasan
- [ ] Dashboard menampilkan metrik berikut:
  - [ ] Total pemasukan bulan berjalan
  - [ ] Total pengeluaran bulan berjalan
  - [ ] Saldo (pemasukan - pengeluaran)
  - [ ] Jumlah transaksi bulan berjalan

#### AC-LOG-015.2: Period Filter
- [ ] Default: menampilkan data bulan berjalan (current month)
- [ ] User dapat memilih bulan sebelumnya untuk melihat ringkasan historis
- [ ] User dapat memilih range tanggal kustom (opsional untuk v1)

#### AC-LOG-015.3: Visualisasi Data
- [ ] Total pemasukan ditampilkan dengan warna hijau/positif
- [ ] Total pengeluaran ditampilkan dengan warna merah/negatif
- [ ] Saldo ditampilkan dengan warna:
  - [ ] Hijau jika positif
  - [ ] Merah jika negatif
- [ ] Format mata uang Indonesia (Rp dengan pemisah ribuan)

---

### REQ-LOG-016: Analisis Kategori Pengeluaran
Sistem menganalisis dan menampilkan breakdown pengeluaran per kategori.

#### AC-LOG-016.1: Top Kategori Pengeluaran
- [ ] Dashboard menampilkan top 3 kategori dengan pengeluaran terbesar
- [ ] Setiap kategori menampilkan:
  - [ ] Nama kategori
  - [ ] Total nominal pengeluaran di kategori tersebut
  - [ ] Persentase terhadap total pengeluaran bulan tersebut

#### AC-LOG-016.2: Rata-rata Pengeluaran per Kategori
- [ ] Sistem menghitung rata-rata pengeluaran per kategori:
  - [ ] Rata-rata = total pengeluaran kategori / jumlah transaksi di kategori tersebut
- [ ] Rata-rata ditampilkan untuk setiap kategori yang memiliki transaksi

#### AC-LOG-016.3: Visualisasi Kategori
- [ ] Top kategori ditampilkan dengan visual chart (pie chart atau bar chart)
- [ ] Kategori dengan pengeluaran terbesar mendapat highlight visual

---

### REQ-LOG-017: Engine Rekomendasi Sederhana
Sistem menghasilkan rekomendasi berdasarkan data transaksi pengguna.

#### AC-LOG-017.1: Logika Rekomendasi
Sistem mengecek kondisi berikut dan menampilkan rekomendasi jika kriteria terpenuhi:

- [ ] **Rekomendasi 1: Kategori Berlebihan**
  - [ ] Trigger: Jika satu kategori > 40% dari total pengeluaran
  - [ ] Pesan: "Kategori [X] menyumbang [Y]% dari total pengeluaranmu bulan ini. Pertimbangkan untuk mengurangi pengeluaran di kategori ini."

- [ ] **Rekomendasi 2: Potensi Penghematan**
  - [ ] Trigger: Jika pengeluaran di kategori X dikurangi 20%, saldo akan naik signifikan
  - [ ] Pesan: "Jika kamu mengurangi 20% pengeluaran di kategori [X], saldo bulananmu akan naik sekitar Rp [Z]."

- [ ] **Rekomendasi 3: Imbalance Cashflow**
  - [ ] Trigger: Jika total pengeluaran > total pemasukan
  - [ ] Pesan: "Pengeluaranmu bulan ini melebihi pemasukan. Pertimbangkan untuk mengevaluasi pengeluaran di kategori [X]."

- [ ] **Rekomendasi 4: Cashflow Sehat**
  - [ ] Trigger: Jika saldo > 30% dari total pemasukan
  - [ ] Pesan: "Bagus! Saldo bulan ini [X]% dari pemasukan. Pertahankan pola pengeluaranmu."

#### AC-LOG-017.2: Prioritas Rekomendasi
- [ ] Jika multiple kriteria terpenuhi, tampilkan maksimal 3 rekomendasi teratas
- [ ] Prioritas: Imbalance > Berlebihan > Potensi Penghematan > Sehat

#### AC-LOG-017.3: Tampilan Rekomendasi
- [ ] Rekomendasi ditampilkan dalam card/list di dashboard
- [ ] Setiap rekomendasi bersifat actionable (ada saran konkret)
- [ ] Bahasa rekomendasi tidak menghakimi, tapi memberi insight

---

### REQ-LOG-018: Query & Agregasi Data
Sistem melakukan query dan agregasi data dari SQLite untuk menghasilkan insight.

#### AC-LOG-018.1: Query Total Pemasukan
- [ ] Sistem menjalankan query:
  ```sql
  SELECT SUM(nominal) FROM transaksi
  WHERE tipe = 'pemasukan'
  AND strftime('%Y-%m', tanggal_waktu) = '[bulan_terpilih]'
  ```
- [ ] Query harus optimal dengan index pada kolom `tipe` dan `tanggal_waktu`

#### AC-LOG-018.2: Query Total Pengeluaran
- [ ] Sistem menjalankan query:
  ```sql
  SELECT SUM(nominal) FROM transaksi
  WHERE tipe = 'pengeluaran'
  AND strftime('%Y-%m', tanggal_waktu) = '[bulan_terpilih]'
  ```

#### AC-LOG-018.3: Query Breakdown per Kategori
- [ ] Sistem menjalankan query:
  ```sql
  SELECT kategori_id, SUM(nominal) as total, COUNT(*) as jumlah
  FROM transaksi
  WHERE tipe = 'pengeluaran'
  AND strftime('%Y-%m', tanggal_waktu) = '[bulan_terpilih]'
  GROUP BY kategori_id
  ORDER BY total DESC
  ```
- [ ] Query harus optimal dengan index pada kolom yang relevan

#### AC-LOG-018.4: Caching Hasil Query
- [ ] Hasil query di-cache selama user berada di bulan yang sama
- [ ] Cache di-invalidate saat:
  - [ ] Transaksi baru ditambahkan
  - [ ] Transaksi diedit/dihapus
  - [ ] User mengganti bulan yang dilihat

---

### REQ-LOG-019: Real-time Update Dashboard
Sistem memperbarui dashboard secara real-time saat data transaksi berubah.

#### AC-LOG-019.1: Update Setelah Create Transaksi
- [ ] Setelah transaksi baru berhasil disimpan, dashboard diperbarui
- [ ] Metrik ringkasan (total pemasukan/pengeluaran/saldo) di-recalculate
- [ ] Jika transaksi bulan berjalan, rekomendasi di-recalculate

#### AC-LOG-019.2: Update Setelah Edit/Hapus Transaksi
- [ ] Setelah transaksi diedit/dihapus, dashboard diperbarui
- [ ] Metrik ringkasan di-recalculate
- [ ] Rekomendasi di-recalculate jika perlu

#### AC-LOG-019.3: Animasi Transisi
- [ ] Perubahan data ditampilkan dengan animasi smooth (tidak abrupt)
- [ ] User mendapat visual feedback bahwa data telah diperbarui

---

### REQ-LOG-020: Performance Dashboard
Sesuai PRD section 2.2, user harus bisa menjawab insight dalam satu layar.

#### AC-LOG-020.1: Loading Time
- [ ] Dashboard harus dirender dalam ≤ 1 detik untuk:
  - [ ] Bulan dengan ≤ 100 transaksi
  - [ ] Bulan dengan ≤ 500 transaksi

#### AC-LOG-020.2: Smooth Scrolling
- [ ] Dashboard dengan banyak konten (metrik, chart, rekomendasi) harus scroll smooth
- [ ] Tidak ada jank/lag saat scroll

#### AC-LOG-020.3: Lazy Loading
- [ ] Jika dashboard sangat kompleks (future proofing), gunakan lazy loading untuk komponen non-kritis

---

### REQ-LOG-021: Offline-First Behavior
Dashboard tetap berfungsi meskipun device offline.

#### AC-LOG-021.1: Data Lokal
- [ ] Semua data untuk dashboard diambil dari SQLite lokal
- [ ] Tidak ada dependency ke server/cloud untuk menampilkan dashboard

#### AC-LOG-021.2: Error Handling
- [ ] Jika query database gagal, sistem menampilkan pesan error yang jelas
- [ ] User dapat retry atau refresh dashboard

---

## Non-Functional Requirements (NFR)

### NFR-LOG-013: Performa Query
- [ ] **Query Performance**: Query agregasi harus selesai dalam:
  - [ ] ≤ 500ms untuk bulan dengan ≤ 100 transaksi
  - [ ] ≤ 1 detik untuk bulan dengan ≤ 500 transaksi

### NFR-LOG-014: Database Optimization
- [ ] **Index Strategy**: Tabel transaksi harus memiliki index pada:
  - [ ] `tipe` (untuk query pemasukan/pengeluaran)
  - [ ] `tanggal_waktu` (untuk filter bulan)
  - [ ] `kategori_id` (untuk grouping)
  - [ ] Composite index: `(tipe, tanggal_waktu, kategori_id)` untuk query kompleks

### NFR-LOG-015: Caching Strategy
- [ ] **Cache Effectiveness**: Hasil query yang di-cache harus:
  - [ ] Mengurangi query berulang untuk data yang sama
  - [ ] Di-invalidate dengan benar saat data berubah
  - [ ] Memiliki TTL (time-to-live) yang wajar atau manual invalidation

### NFR-LOG-016: Accuracy
- [ ] **Calculation Accuracy**: Semua perhitungan harus:
  - [ ] Menggunakan tipe data decimal/numeric untuk presisi mata uang
  - [ ] Menghindari floating point errors
  - [ ] Divalidasi dengan unit test

### NFR-LOG-017: User Experience
- [ ] **Clarity**: Insight harus mudah dimengerti dalam sekali lihat:
  - [ ] Bahasa rekomendasi sederhana dan konkret
  - [ ] Visualisasi data jelas (chart dengan warna berbeda)
  - [ ] Tidak ada teknikal jargon

### NFR-LOG-018: Extensibility
- [ ] **Future-Proofing**: Engine rekomendasi harus mudah ditambah rule baru:
  - [ ] Rule-based system (tidak hard-coded di UI)
  - [ ] Setiap rule independent dan dapat di-enabled/disabled
