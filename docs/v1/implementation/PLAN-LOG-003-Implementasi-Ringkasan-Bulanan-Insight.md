# PLAN – Ringkasan Bulanan & Insight

## 1. Ringkasan Singkat

Membangun fitur **Dashboard Ringkasan Bulanan & Insight** yang memungkinkan pengguna melihat total pemasukan, pengeluaran, dan saldo per bulan, breakdown pengeluaran per kategori, serta mendapatkan rekomendasi keuangan sederhana berbasis data transaksi historis. Seluruh perhitungan dan insight dilakukan secara lokal menggunakan SQLite database dengan caching untuk performa optimal.

---

## 2. Asumsi & Dependency

### Asumsi
1. Data transaksi (pemasukan & pengeluaran) sudah tercatat dengan benar oleh fitur "Pencatatan Transaksi Manual".
2. Fitur "Input via Struk OCR" sudah berfungsi dan menyimpan data ke tabel `transactions`.
3. Tabel `categories` sudah memiliki data dengan proper categorization (income/expense).
4. Tidak ada requirement real-time sync ke server - semua perhitungan dilakukan lokal.
5. User akan terutama melihat ringkasan bulanan, bukan mingguan atau tahunan.

### Dependency dengan Fitur Lain
| Fitur | Dependency |
|-------|------------|
| Transaksi (Manual/OCR) | Sumber data utama untuk perhitungan summary |
| Kategori | Diperlukan untuk grouping dan breakdown pengeluaran |
| Database SQLite | Semua query agregasi dilakukan di sini |

---

## 3. Fase Implementasi

### Phase 1: Data Aggregation & Query

#### TASK-SUM-001: Implement Database Index Optimization
- **Deskripsi**: Menambahkan index pada tabel `transactions` untuk query agregasi bulanan: index pada kolom `type`, `dateTime`, dan `categoryId`, serta composite index `(type, dateTime, categoryId)`.
- **File Terkait**: `lib/data/datasources/local/database_helper.dart`
- **REQ Terkait**: NFR-LOG-014 (Database Optimization)

#### TASK-SUM-002: Implement Monthly Summary Query
- **Deskripsi**: Membuat method di `TransactionRepository` untuk query total pemasukan, total pengeluaran, dan saldo untuk satu bulan tertentu. Query harus menggunakan filter `strftime('%Y-%m', dateTime) = '[bulan_terpilih]'`.
- **File Terkait**:
  - `lib/domain/repositories/transaction_repository.dart` (interface)
  - `lib/data/repositories/transaction_repository_impl.dart` (implementation)
- **REQ Terkait**: REQ-LOG-015, AC-LOG-018.1, AC-LOG-018.2

#### TASK-SUM-003: Implement Category Breakdown Query
- **Deskripsi**: Membuat method di `TransactionRepository` untuk query breakdown pengeluaran per kategori dengan grouping dan sorting descending by total. Return: list of `{categoryId, total, count}`.
- **File Terkait**:
  - `lib/domain/repositories/transaction_repository.dart` (interface)
  - `lib/data/repositories/transaction_repository_impl.dart` (implementation)
- **REQ Terkait**: REQ-LOG-016, AC-LOG-016.1, AC-LOG-018.3

#### TASK-SUM-004: Create Domain Entities for Summary
- **Deskripsi**: Membuat entity `MonthlySummaryEntity` yang berisi: period (YYYY-MM), totalIncome, totalExpense, balance, transactionCount, dan `CategoryBreakdownEntity` untuk data per kategori.
- **File Terkait**: `lib/domain/entities/`
- **REQ Terkait**: REQ-LOG-015, REQ-LOG-016

#### TASK-SUM-005: Implement Use Cases for Monthly Data
- **Deskripsi**: Membuat use case `GetMonthlySummaryUseCase` yang memanggil repository untuk mendapatkan summary bulanan (income, expense, balance) dan `GetCategoryBreakdownUseCase` untuk breakdown per kategori.
- **File Terkait**: `lib/domain/usecases/`
- **REQ Terkait**: REQ-LOG-015, REQ-LOG-016, AC-LOG-015.1, AC-LOG-016.1

#### TASK-SUM-006: Implement Caching Layer
- **Deskripsi**: Membuat simple caching mechanism untuk hasil query summary. Cache di-invalidate saat transaksi baru ditambahkan/ diedit/dihapus, atau saat user mengganti bulan yang dilihat.
- **File Terkait**: `lib/data/repositories/transaction_repository_impl.dart` atau `lib/domain/usecases/`
- **REQ Terkait**: AC-LOG-018.4, NFR-LOG-015

---

### Phase 2: Insight & Recommendation Engine

#### TASK-SUM-007: Create Recommendation Rule Engine
- **Deskripsi**: Membuat class `RecommendationEngine` dengan rule-based system untuk menghasilkan insight. Rules: (1) Kategori berlebihan (>40% total pengeluaran), (2) Potensi penghematan (20% reduksi), (3) Imbalance cashflow, (4) Cashflow sehat.
- **File Terkait**: `lib/domain/services/recommendation_engine.dart` (new folder)
- **REQ Terkait**: REQ-LOG-017, AC-LOG-017.1

#### TASK-SUM-008: Implement Recommendation Priority Logic
- **Deskripsi**: Menambahkan logika prioritas rekomendasi: Imbalance > Berlebihan > Potensi Penghematan > Sehat. Maksimal 3 rekomendasi ditampilkan.
- **File Terkait**: `lib/domain/services/recommendation_engine.dart`
- **REQ Terkait**: AC-LOG-017.2

#### TASK-SUM-009: Create Recommendation Entity & Use Case
- **Deskripsi**: Membuat entity `RecommendationEntity` dengan field: type, message, priority. Buat use case `GetRecommendationsUseCase` yang mengambil data summary dan menghasilkan list rekomendasi.
- **File Terkait**: `lib/domain/entities/`, `lib/domain/usecases/`
- **REQ Terkait**: AC-LOG-017.3, NFR-LOG-017

---

### Phase 3: UI Ringkasan Bulanan

#### TASK-SUM-010: Create Monthly Summary Notifier (Riverpod)
- **Deskripsi**: Membuat `MonthlySummaryNotifier` yang extends `StateNotifier` untuk mengelola state: loading, loaded (dengan data summary), error. Handle period selection dan refresh data.
- **File Terkait**: `lib/presentation/providers/monthly_summary_provider.dart`
- **REQ Terkait**: AC-LOG-019.1, AC-LOG-019.2

#### TASK-SUM-011: Create Summary Metrics Widget
- **Deskripsi**: Membuat widget untuk menampilkan 4 metrik utama: Total Pemasukan (hijau), Total Pengeluaran (merah), Saldo (hijau/merah based on sign), Jumlah Transaksi. Format mata uang Indonesia (Rp dengan pemisah ribuan).
- **File Terkait**: `lib/presentation/widgets/summary_metrics_card.dart` (new)
- **REQ Terkait**: AC-LOG-015.1, AC-LOG-015.3, NFR-LOG-017

#### TASK-SUM-012: Create Category Breakdown Widget
- **Deskripsi**: Membuat widget untuk menampilkan top 3 kategori pengeluaran terbesar dengan: nama kategori, nominal, dan persentase terhadap total pengeluaran. Tambahkan highlight visual untuk kategori terbesar.
- **File Terkait**: `lib/presentation/widgets/category_breakdown_card.dart` (new)
- **REQ Terkait**: AC-LOG-016.1, AC-LOG-016.3

#### TASK-SUM-013: Create Recommendation Card Widget
- **Deskripsi**: Membuat widget untuk menampilkan rekomendasi dalam bentuk card/list. Setiap rekomendasi harus actionable dengan bahasa yang tidak menghakimi.
- **File Terkait**: `lib/presentation/widgets/recommendation_card.dart` (new)
- **REQ Terkait**: AC-LOG-017.3, NFR-LOG-017

#### TASK-SUM-014: Create Monthly Summary Screen
- **Deskripsi**: Membuat `MonthlySummaryScreen` yang menggabungkan semua widget: metrics, category breakdown, recommendations. Gunakan `CustomScrollView` dengan `SliverList` untuk smooth scrolling.
- **File Terkait**: `lib/presentation/screens/monthly_summary_screen.dart` (new)
- **REQ Terkait**: AC-LOG-015, AC-LOG-020.2

---

### Phase 4: Navigasi & Pemilihan Periode

#### TASK-SUM-015: Create Period Selector Widget
- **Deskripsi**: Membuat widget untuk pemilihan periode: dropdown atau carousel untuk memilih bulan (bulan ini, bulan lalu, dst). Default ke bulan berjalan.
- **File Terkait**: `lib/presentation/widgets/period_selector.dart` (new)
- **REQ Terkait**: AC-LOG-015.2

#### TASK-SUM-016: Implement Period Change Handler
- **Deskripsi**: Menghubungkan period selector dengan `MonthlySummaryNotifier` untuk refresh data saat periode berubah. Invalidasi cache saat periode berubah.
- **File Terkait**: `lib/presentation/providers/monthly_summary_provider.dart`
- **REQ Terkait**: AC-LOG-015.2, AC-LOG-018.4

#### TASK-SUM-017: Add Navigation to Summary Screen
- **Deskripsi**: Menambahkan navigasi ke `MonthlySummaryScreen` dari main screen (TransactionListScreen). Bisa melalui bottom navigation bar atau FAB/menu button.
- **File Terkait**: `lib/presentation/screens/transaction_list_screen.dart`, `lib/main.dart`
- **REQ Terkait**: (Implicit requirement untuk mengakses fitur)

---

### Phase 5: Testing & Performance

#### TASK-SUM-018: Prepare Test Data
- **Deskripsi**: Membuat test data helper untuk mengenerate transaksi dengan berbagai kategori dan periode untuk testing.
- **File Terkait**: `test/helpers/test_data_helper.dart` (new)
- **REQ Terkait**: NFR-LOG-016 (Accuracy)

#### TASK-SUM-019: Unit Tests for Calculation Logic
- **Deskripsi**: Membuat unit test untuk: (1) Perhitungan total income/expense/balance, (2) Perhitungan breakdown per kategori, (3) Perhitungan persentase, (4) Rule engine recommendations.
- **File Terkait**: `test/domain/usecases/get_monthly_summary_usecase_test.dart` (new)
- **REQ Terkait**: NFR-LOG-016 (Accuracy), AC-LOG-015.1, AC-LOG-016.1

#### TASK-SUM-020: Widget Tests for UI Components
- **Deskripsi**: Membuat widget test untuk: (1) SummaryMetricsCard, (2) CategoryBreakdownCard, (3) RecommendationCard, (4) PeriodSelector.
- **File Terkait**: `test/presentation/widgets/` (new files)
- **REQ Terkait**: AC-LOG-015.3, AC-LOG-016.3, NFR-LOG-017

#### TASK-SUM-021: Performance Testing
- **Deskripsi**: Membuat performance test untuk memastikan query agregasi selesai dalam ≤500ms untuk 100 transaksi dan ≤1 detik untuk 500 transaksi.
- **File Terkait**: `test/data/repositories/transaction_repository_impl_performance_test.dart` (new)
- **REQ Terkait**: NFR-LOG-013, AC-LOG-020.1

#### TASK-SUM-022: Integration Testing
- **Deskripsi**: Membuat integration test untuk flow lengkap: buka summary screen → ganti periode → verifikasi data → tambah transaksi baru → verifikasi real-time update.
- **File Terkata**: `integration_test/app_test.dart` (extend existing)
- **REQ Terkait**: AC-LOG-019.1, AC-LOG-019.2, AC-LOG-019.3

---

### Phase 6: Polish & Optimization

#### TASK-SUM-023: Implement Real-time Update Animation
- **Deskripsi**: Menambahkan animasi smooth untuk transisi data saat dashboard diperbarui setelah transaksi baru/ edit/ hapus. Gunakan `AnimatedSwitcher` atau `TweenAnimationBuilder`.
- **File Terkait**: `lib/presentation/widgets/` (summary widgets)
- **REQ Terkait**: AC-LOG-019.3

#### TASK-SUM-024: Error Handling & Empty States
- **Deskripsi**: Menambahkan error handling dengan pesan yang jelas dan empty state untuk bulan tanpa transaksi. User dapat retry atau refresh.
- **File Terkait**: `lib/presentation/providers/monthly_summary_provider.dart`, `lib/presentation/screens/monthly_summary_screen.dart`
- **REQ Terkait**: AC-LOG-021.2

#### TASK-SUM-025: Offline-First Verification
- **Deskripsi**: Verifikasi bahwa seluruh fitur berfungsi offline tanpa dependency ke server. Pastikan tidak ada network call yang tidak perlu.
- **File Terkait**: Semua files dalam fitur ini
- **REQ Terkait**: AC-LOG-021.1

---

## 4. Checklist Verifikasi Internal

Sebelum masuk ke fase VERIFY:

- [ ] Semua REQ-LOG-015 s/d REQ-LOG-021 memiliki minimal satu TASK-SUM yang mengimplementasikannya.
- [ ] Semua AC-LOG-0xx tercakup dalam kombinasi satu atau beberapa TASK-SUM.
- [ ] Perhitungan tidak double-counting transaksi dan respect filter periode.
- [ ] Insight yang dihasilkan selalu berbasis data aktual (tidak keluar dari scope).
- [ ] Semua index database telah ditambahkan sesuai NFR-LOG-014.
- [ ] Caching layer di-invalidate dengan benar saat data berubah.
- [ ] Semua perhitungan menggunakan tipe data decimal/numeric untuk presisi mata uang.

---

## 5. Open Questions

1. **Chart Library**: Apakah perlu menggunakan external chart library seperti `fl_chart` untuk visualisasi kategori pengeluaran, atau cukup dengan progress bar custom yang lebih sederhana?

2. **Batas Minimal Transaksi**: Apakah ada batas minimal transaksi untuk menampilkan insight? Misalnya, jangan tampilkan saran kalau cuma ada 1-3 transaksi dalam bulan tersebut.

3. **Multi-Period Support**: Di v1, apakah cukup bulanan saja atau perlu mendukung periode mingguan dan tahunan juga? (SPEC menyebut "opsional untuk v1" untuk custom range)

4. **Historical Data Preservation**: Bagaimana handle data transaksi dari bulan sebelum migration ke fitur ini - apakah perlu migration script untuk existing data?

5. **Currency Precision**: Untuk perhitungan persentase dan rata-rata, berapa banyak decimal places yang harus ditampilkan ke user?

6. **Insight Persistence**: Apakah rekomendasi perlu di-save ke database atau di-generate on-the-fly setiap kali buka dashboard?

---

## Critical Files to be Modified/Created

### Existing Files to Modify:
| File Path | Purpose |
|-----------|---------|
| `lib/data/datasources/local/database_helper.dart` | Add database indexes for aggregation queries |
| `lib/domain/repositories/transaction_repository.dart` | Add new query method signatures |
| `lib/data/repositories/transaction_repository_impl.dart` | Implement new aggregation queries with caching |
| `lib/presentation/providers/app_providers.dart` | Add new providers for summary feature |
| `lib/presentation/screens/transaction_list_screen.dart` | Add navigation to summary screen |

### New Files to Create:
| File Path | Purpose |
|-----------|---------|
| `lib/domain/entities/monthly_summary_entity.dart` | Entity for monthly summary data |
| `lib/domain/entities/category_breakdown_entity.dart` | Entity for category breakdown |
| `lib/domain/entities/recommendation_entity.dart` | Entity for recommendations |
| `lib/domain/services/recommendation_engine.dart` | Rule-based recommendation engine |
| `lib/domain/usecases/get_monthly_summary_usecase.dart` | Use case for monthly summary |
| `lib/domain/usecases/get_category_breakdown_usecase.dart` | Use case for category breakdown |
| `lib/domain/usecases/get_recommendations_usecase.dart` | Use case for recommendations |
| `lib/presentation/providers/monthly_summary_provider.dart` | Riverpod provider for summary state |
| `lib/presentation/screens/monthly_summary_screen.dart` | Main summary screen |
| `lib/presentation/widgets/summary_metrics_card.dart` | Widget for summary metrics |
| `lib/presentation/widgets/category_breakdown_card.dart` | Widget for category breakdown |
| `lib/presentation/widgets/recommendation_card.dart` | Widget for recommendations |
| `lib/presentation/widgets/period_selector.dart` | Widget for period selection |

---

## Dependencies to Add

Consider adding these packages if not already present:
- `fl_chart` ^0.66.0 (if chart visualization is needed)
- `collection` ^1.18.0 (for additional collection operations)
- Note: `intl`, `sqflite`, `flutter_riverpod` should already be in the project

---

*Dokumen PLAN ini dibuat berdasarkan SPEC-LOG-003. Untuk implementasi, ikuti TASK-SUM secara berurutan dari Phase 1 hingga Phase 6.*
