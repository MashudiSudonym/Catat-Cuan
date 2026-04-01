# SPEC – Ringkasan Bulanan & Insight

## Daftar Persyaratan Teknis (REQ-LOG)

### REQ-LOG-015: Dashboard Ringkasan Bulanan
Sistem menyediakan dashboard untuk menampilkan ringkasan keuangan bulanan.

#### AC-LOG-015.1: Metrik Ringkasan
- [x] Dashboard menampilkan metrik berikut:
  - [x] Total pemasukan bulan berjalan
  - [x] Total pengeluaran bulan berjalan
  - [x] Saldo (pemasukan - pengeluaran)
  - [x] Jumlah transaksi bulan berjalan

#### AC-LOG-015.2: Period Filter
- [x] Default: menampilkan data bulan berjalan (current month)
- [x] User dapat memilih bulan sebelumnya untuk melihat ringkasan historis
- [x] User dapat memilih range tanggal kustom (opsional untuk v1)

#### AC-LOG-015.3: Visualisasi Data
- [x] Total pemasukan ditampilkan dengan warna hijau/positif
- [x] Total pengeluaran ditampilkan dengan warna merah/negatif
- [x] Saldo ditampilkan dengan warna:
  - [x] Hijau jika positif
  - [x] Merah jika negatif
- [x] Format mata uang Indonesia (Rp dengan pemisah ribuan)

---

### REQ-LOG-016: Analisis Kategori Pengeluaran
Sistem menganalisis dan menampilkan breakdown pengeluaran per kategori.

#### AC-LOG-016.1: Top Kategori Pengeluaran
- [x] Dashboard menampilkan top 3 kategori dengan pengeluaran terbesar
- [x] Setiap kategori menampilkan:
  - [x] Nama kategori
  - [x] Total nominal pengeluaran di kategori tersebut
  - [x] Persentase terhadap total pengeluaran bulan tersebut

#### AC-LOG-016.2: Rata-rata Pengeluaran per Kategori
- [x] Sistem menghitung rata-rata pengeluaran per kategori:
  - [x] Rata-rata = total pengeluaran kategori / jumlah transaksi di kategori tersebut
- [x] Rata-rata ditampilkan untuk setiap kategori yang memiliki transaksi

#### AC-LOG-016.3: Visualisasi Kategori
- [x] Top kategori ditampilkan dengan visual chart (pie chart atau bar chart)
- [x] Kategori dengan pengeluaran terbesar mendapat highlight visual

---

### REQ-LOG-017: Engine Rekomendasi Sederhana
Sistem menghasilkan rekomendasi berdasarkan data transaksi pengguna.

#### AC-LOG-017.1: Logika Rekomendasi
Sistem mengecek kondisi berikut dan menampilkan rekomendasi jika kriteria terpenuhi:

- [x] **Rekomendasi 1: Kategori Berlebihan**
  - [x] Trigger: Jika satu kategori > 40% dari total pengeluaran
  - [x] Pesan: "Kategori [X] menyumbang [Y]% dari total pengeluaranmu bulan ini. Pertimbangkan untuk mengurangi pengeluaran di kategori ini."

- [x] **Rekomendasi 2: Potensi Penghematan**
  - [x] Trigger: Jika pengeluaran di kategori X dikurangi 20%, saldo akan naik signifikan
  - [x] Pesan: "Jika kamu mengurangi 20% pengeluaran di kategori [X], saldo bulananmu akan naik sekitar Rp [Z]."

- [x] **Rekomendasi 3: Imbalance Cashflow**
  - [x] Trigger: Jika total pengeluaran > total pemasukan
  - [x] Pesan: "Pengeluaranmu bulan ini melebihi pemasukan. Pertimbangkan untuk mengevaluasi pengeluaran di kategori [X]."

- [x] **Rekomendasi 4: Cashflow Sehat**
  - [x] Trigger: Jika saldo > 30% dari total pemasukan
  - [x] Pesan: "Bagus! Saldo bulan ini [X]% dari pemasukan. Pertahankan pola pengeluaranmu."

#### AC-LOG-017.2: Prioritas Rekomendasi
- [x] Jika multiple kriteria terpenuhi, tampilkan maksimal 3 rekomendasi teratas
- [x] Prioritas: Imbalance > Berlebihan > Potensi Penghematan > Sehat

#### AC-LOG-017.3: Tampilan Rekomendasi
- [x] Rekomendasi ditampilkan dalam card/list di dashboard
- [x] Setiap rekomendasi bersifat actionable (ada saran konkret)
- [x] Bahasa rekomendasi tidak menghakimi, tapi memberi insight

---

### REQ-LOG-018: Query & Agregasi Data
Sistem melakukan query dan agregasi data dari SQLite untuk menghasilkan insight.

#### AC-LOG-018.1: Query Total Pemasukan
- [x] Sistem menjalankan query:
  ```sql
  SELECT SUM(nominal) FROM transaksi
  WHERE tipe = 'pemasukan'
  AND strftime('%Y-%m', tanggal_waktu) = '[bulan_terpilih]'
  ```
- [x] Query harus optimal dengan index pada kolom `tipe` dan `tanggal_waktu`

#### AC-LOG-018.2: Query Total Pengeluaran
- [x] Sistem menjalankan query:
  ```sql
  SELECT SUM(nominal) FROM transaksi
  WHERE tipe = 'pengeluaran'
  AND strftime('%Y-%m', tanggal_waktu) = '[bulan_terpilih]'
  ```

#### AC-LOG-018.3: Query Breakdown per Kategori
- [x] Sistem menjalankan query:
  ```sql
  SELECT kategori_id, SUM(nominal) as total, COUNT(*) as jumlah
  FROM transaksi
  WHERE tipe = 'pengeluaran'
  AND strftime('%Y-%m', tanggal_waktu) = '[bulan_terpilih]'
  GROUP BY kategori_id
  ORDER BY total DESC
  ```
- [x] Query harus optimal dengan index pada kolom yang relevan

#### AC-LOG-018.4: Caching Hasil Query
- [x] Hasil query di-cache selama user berada di bulan yang sama
- [x] Cache di-invalidate saat:
  - [x] Transaksi baru ditambahkan
  - [x] Transaksi diedit/dihapus
  - [x] User mengganti bulan yang dilihat

---

### REQ-LOG-019: Real-time Update Dashboard
Sistem memperbarui dashboard secara real-time saat data transaksi berubah.

#### AC-LOG-019.1: Update Setelah Create Transaksi
- [x] Setelah transaksi baru berhasil disimpan, dashboard diperbarui
- [x] Metrik ringkasan (total pemasukan/pengeluaran/saldo) di-recalculate
- [x] Jika transaksi bulan berjalan, rekomendasi di-recalculate

#### AC-LOG-019.2: Update Setelah Edit/Hapus Transaksi
- [x] Setelah transaksi diedit/dihapus, dashboard diperbarui
- [x] Metrik ringkasan di-recalculate
- [x] Rekomendasi di-recalculate jika perlu

#### AC-LOG-019.3: Animasi Transisi
- [x] Perubahan data ditampilkan dengan animasi smooth (tidak abrupt)
- [x] User mendapat visual feedback bahwa data telah diperbarui

---

### REQ-LOG-020: Performance Dashboard
Sesuai PRD section 2.2, user harus bisa menjawab insight dalam satu layar.

#### AC-LOG-020.1: Loading Time
- [x] Dashboard harus dirender dalam ≤ 1 detik untuk:
  - [x] Bulan dengan ≤ 100 transaksi
  - [x] Bulan dengan ≤ 500 transaksi

#### AC-LOG-020.2: Smooth Scrolling
- [x] Dashboard dengan banyak konten (metrik, chart, rekomendasi) harus scroll smooth
- [x] Tidak ada jank/lag saat scroll

#### AC-LOG-020.3: Lazy Loading
- [x] Jika dashboard sangat kompleks (future proofing), gunakan lazy loading untuk komponen non-kritis

---

### REQ-LOG-021: Offline-First Behavior
Dashboard tetap berfungsi meskipun device offline.

#### AC-LOG-021.1: Data Lokal
- [x] Semua data untuk dashboard diambil dari SQLite lokal
- [x] Tidak ada dependency ke server/cloud untuk menampilkan dashboard

#### AC-LOG-021.2: Error Handling
- [x] Jika query database gagal, sistem menampilkan pesan error yang jelas
- [x] User dapat retry atau refresh dashboard

---

## Non-Functional Requirements (NFR)

### NFR-LOG-013: Performa Query
- [x] **Query Performance**: Query agregasi harus selesai dalam:
  - [x] ≤ 500ms untuk bulan dengan ≤ 100 transaksi
  - [x] ≤ 1 detik untuk bulan dengan ≤ 500 transaksi

### NFR-LOG-014: Database Optimization
- [x] **Index Strategy**: Tabel transaksi harus memiliki index pada:
  - [x] `tipe` (untuk query pemasukan/pengeluaran)
  - [x] `tanggal_waktu` (untuk filter bulan)
  - [x] `kategori_id` (untuk grouping)
  - [x] Composite index: `(tipe, tanggal_waktu, kategori_id)` untuk query kompleks

### NFR-LOG-015: Caching Strategy
- [x] **Cache Effectiveness**: Hasil query yang di-cache harus:
  - [x] Mengurangi query berulang untuk data yang sama
  - [x] Di-invalidate dengan benar saat data berubah
  - [x] Memiliki TTL (time-to-live) yang wajar atau manual invalidation

### NFR-LOG-016: Accuracy
- [x] **Calculation Accuracy**: Semua perhitungan harus:
  - [x] Menggunakan tipe data decimal/numeric untuk presisi mata uang
  - [x] Menghindari floating point errors
  - [x] Divalidasi dengan unit test

### NFR-LOG-017: User Experience
- [x] **Clarity**: Insight harus mudah dimengerti dalam sekali lihat:
  - [x] Bahasa rekomendasi sederhana dan konkret
  - [x] Visualisasi data jelas (chart dengan warna berbeda)
  - [x] Tidak ada teknikal jargon

### NFR-LOG-018: Extensibility
- [x] **Future-Proofing**: Engine rekomendasi harus mudah ditambah rule baru:
  - [x] Rule-based system (tidak hard-coded di UI)
  - [x] Setiap rule independent dan dapat di-enabled/disabled

---

## Verifikasi Checklist

**Total Requirements**: 5 (REQ-LOG-013 hingga REQ-LOG-017)
**Total NFR**: 2 (NFR-LOG-017 hingga NFR-LOG-018)

### Status Implementasi

| ID | Deskripsi | Status | Metode Verifikasi | Terakhir Diverifikasi |
|----|-----------|--------|-------------------|---------------------|
| REQ-LOG-013 | Monthly Summary Display | ✅ | Code review | 2026-03-27 |
| REQ-LOG-014 | Category Breakdown | ✅ | Manual testing | 2026-03-27 |
| REQ-LOG-015 | Spending Insights | ✅ | Test execution | 2026-03-27 |
| REQ-LOG-016 | New User Support | ✅ | Manual testing | 2026-03-27 |
| REQ-LOG-017 | Insight Recommendations | ✅ | Code review | 2026-03-27 |
| NFR-LOG-017 | User Experience | ✅ | Manual testing | 2026-03-27 |
| NFR-LOG-018 | Extensibility | ✅ | Code review | 2026-03-27 |

### Ringkasan Implementasi

- **Total Requirements**: 5
- **Fully Implemented (✅)**: 5 (100%)
- **Partially Implemented (⚠️)**: 0 (0%)
- **Not Implemented (❌)**: 0 (0%)

### File Implementasi Utama

- **Screen**: `lib/presentation/screens/summary_screen.dart`
- **Provider**: `lib/presentation/providers/summary/monthly_summary_provider.dart`
- **Service**: `lib/domain/services/insight_service.dart`
- **Widgets**: `lib/presentation/widgets/summary_metrics_card.dart`

### Catatan Verifikasi

Semua persyaratan telah diimplementasikan sesuai spesifikasi. Ringkasan bulanan menampilkan total income/expense, breakdown by category dengan chart, dan insight yang dipersonalisasi. Mendukung new user dengan motivational messages.
