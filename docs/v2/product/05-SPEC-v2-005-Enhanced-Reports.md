# SPEC v2 – Enhanced Reports

## Daftar Persyaratan Teknis (REQ-RPT)

### REQ-RPT-001: Report Time Frames
Sistem menyediakan laporan dengan berbagai time frame.

#### AC-RPT-001.1: Daily Report
- [ ] Tampilkan ringkasan transaksi hari ini
- [ ] Total pemasukan hari ini
- [ ] Total pengeluaran hari ini
- [ ] Jumlah transaksi hari ini
- [ ] Top kategori hari ini

#### AC-RPT-001.2: Weekly Report
- [ ] Tampilkan ringkasan minggu ini (Senin-Minggu)
- [ ] Daily breakdown chart (7 bars)
- [ ] Total pemasukan/pengeluaran minggu ini
- [ ] Perbandingan dengan minggu lalu (±%)
- [ ] Rata-rata pengeluaran per hari

#### AC-RPT-001.3: Monthly Report
- [ ] Tampilkan ringkasan bulan ini
- [ ] Weekly breakdown chart (4-5 bars)
- [ ] Category breakdown pie chart
- [ ] Total pemasukan/pengeluaran bulan ini
- [ ] Perbandingan dengan bulan lalu (±%)
- [ ] Budget vs Actual comparison (jika ada budget)

#### AC-RPT-001.4: Yearly Report
- [ ] Tampilkan ringkasan tahun ini
- [ ] Monthly breakdown chart (12 bars)
- [ ] Total pemasukan/pengeluaran tahun ini
- [ ] Perbandingan dengan tahun lalu (±%)
- [ ] Best/worst month identification

---

### REQ-RPT-002: Trend Analysis
Sistem menyediakan analisis trend pengeluaran.

#### AC-RPT-002.1: Month-over-Month Comparison
- [ ] Bar chart side-by-side: bulan ini vs bulan lalu
- [ ] Persentase perubahan (↑ X% atau ↓ Y%)
- [ ] Highlight kategori dengan perubahan signifikan

#### AC-RPT-002.2: Trend Indicators
- [ ] Visual indicators: naik (↑), turun (↓), stabil (→)
- [ ] Color coding: hijau (baik), merah (perlu perhatian)
- [ ] Trend line chart untuk 6 bulan terakhir

#### AC-RPT-002.3: Spending Velocity
- [ ] Calculate daily average spending
- [ ] Project end-of-month spending based on current pace
- [ ] Warning jika projected > income

---

### REQ-RPT-003: Category Breakdown
Sistem menyediakan breakdown detail per kategori.

#### AC-RPT-003.1: Category Pie Chart
- [ ] Pie chart dengan semua kategori
- [ ] Legend dengan nama kategori dan persentase
- [ ] Tap slice untuk detail kategori
- [ ] Highlight slice saat hover/focus

#### AC-RPT-003.2: Category Bar Chart
- [ ] Horizontal bar chart untuk top categories
- [ ] Sort by amount (default) atau alphabetical
- [ ] Show amount dan percentage per bar
- [ ] Color coded by category

#### AC-RPT-003.3: Category Detail View
- [ ] Tap kategori untuk detail view
- [ ] List transaksi untuk kategori tersebut
- [ ] Daily/weekly breakdown untuk kategori
- [ ] Comparison dengan periode sebelumnya

---

### REQ-RPT-004: Enhanced Insights
Sistem memberikan insight yang lebih actionable.

#### AC-RPT-004.1: Spending Pattern Insights
- [ ] "Kamu cenderung boros di hari [X]"
- [ ] "Pengeluaran tertinggi biasanya di minggu [X]"
- [ ] "Kategori [X] naik [Y]% dibanding bulan lalu"

#### AC-RPT-004.2: Anomaly Detection
- [ ] Detect unusual spending (outliers)
- [ ] Alert untuk transaksi yang jauh di atas rata-rata
- [ ] Highlight hari dengan spending tidak normal

#### AC-RPT-004.3: Recommendations
- [ ] "Kurangi [X]% di kategori [Y] untuk menabung Rp Z"
- [ ] "Budget [X] hampir habis, pertimbangkan untuk membatasi"
- [ ] "Kamu bisa hemat Rp X jika mengurangi [Y]"

---

### REQ-RPT-005: Interactive Charts
Chart interaktif untuk eksplorasi data.

#### AC-RPT-005.1: Chart Interactions
- [ ] Tap bar/pie slice untuk detail
- [ ] Pinch to zoom (untuk time series)
- [ ] Swipe untuk navigate between periods
- [ ] Long press untuk tooltip

#### AC-RPT-005.2: Chart Tooltips
- [ ] Tooltip menampilkan detail data point
- [ ] Tooltip dismissable
- [ ] Accessible via keyboard/screen reader

#### AC-RPT-005.3: Chart Legends
- [ ] Interactive legend (tap untuk highlight)
- [ ] Show/hide data series
- [ ] Legend scrollable untuk banyak kategori

---

### REQ-RPT-006: Report Export
Sistem menyediakan export laporan.

#### AC-RPT-006.1: Export to Image
- [ ] Export chart sebagai PNG
- [ ] Include title, period, dan summary
- [ ] Share directly to social media/messaging apps

#### AC-RPT-006.2: Export to PDF (Optional)
- [ ] Generate PDF report dengan charts
- [ ] Include summary statistics
- [ ] Include transaction list

---

### REQ-RPT-007: Report Navigation
Navigasi yang intuitif untuk reports.

#### AC-RPT-007.1: Tab Navigation
- [ ] Tabs: Daily | Weekly | Monthly | Yearly
- [ ] Swipe gesture untuk switch tabs
- [ ] Indicator untuk tab aktif

#### AC-RPT-007.2: Period Navigation
- [ ] Arrow buttons untuk navigate period (← →)
- [ ] Current period clearly labeled
- [ ] Quick jump to current period

#### AC-RPT-007.3: Report Home Screen Card
- [ ] Summary card di Home Screen
- [ ] Quick link ke full report
- [ ] Preview chart terkecil

---

## Non-Functional Requirements (NFR)

### NFR-RPT-001: Performa
- [ ] Report loading ≤2 detik untuk 1 tahun data
- [ ] Chart rendering ≤500ms
- [ ] Smooth scrolling dan interactions (60fps)

### NFR-RPT-002: Akurasi
- [ ] Semua kalkulasi 100% akurat
- [ ] Rounding konsisten (2 desimal)
- [ ] Tidak ada data yang hilang

### NFR-RPT-003: User Experience
- [ ] Intuitive navigation
- [ ] Clear visual hierarchy
- [ ] Accessible untuk screen readers

### NFR-RPT-004: Visual Quality
- [ ] Charts readable di berbagai ukuran layar
- [ ] Colors distinguishable
- [ ] Text readable (minimum 12sp)

---

## Verifikasi Checklist

**Total Requirements**: 7 (REQ-RPT-001 hingga REQ-RPT-007)
**Total NFR**: 4 (NFR-RPT-001 hingga NFR-RPT-004)

### Status Implementasi

| ID | Deskripsi | Status | Metode Verifikasi | Terakhir Diverifikasi |
|----|-----------|--------|-------------------|---------------------|
| REQ-RPT-001 | Report Time Frames | ⏳ | Manual testing | - |
| REQ-RPT-002 | Trend Analysis | ⏳ | Test + Manual | - |
| REQ-RPT-003 | Category Breakdown | ⏳ | Manual testing | - |
| REQ-RPT-004 | Enhanced Insights | ⏳ | Manual testing | - |
| REQ-RPT-005 | Interactive Charts | ⏳ | Manual testing | - |
| REQ-RPT-006 | Report Export | ⏳ | Manual testing | - |
| REQ-RPT-007 | Report Navigation | ⏳ | Manual testing | - |
| NFR-RPT-001 | Performa | ⏳ | Performance test | - |
| NFR-RPT-002 | Akurasi | ⏳ | Test execution | - |
| NFR-RPT-003 | User Experience | ⏳ | Usability test | - |
| NFR-RPT-004 | Visual Quality | ⏳ | Design review | - |

### Ringkasan Implementasi

- **Total Requirements**: 7
- **Fully Implemented (✅)**: 0 (0%)
- **Partially Implemented (⚠️)**: 0 (0%)
- **Not Implemented (⏳)**: 7 (100%)

### File Implementasi yang Direncanakan

- **Screen**: `lib/presentation/screens/reports_screen.dart`
- **Widgets**: `lib/presentation/widgets/reports/`
  - `weekly_chart.dart`
  - `monthly_chart.dart`
  - `yearly_chart.dart`
  - `category_pie_chart.dart`
  - `trend_line_chart.dart`
  - `report_summary_card.dart`
- **Provider**: `lib/presentation/providers/reports/reports_provider.dart`
- **Use Cases**: `lib/domain/usecases/reports/`
- **Analyzer**: `lib/domain/analyzers/trend_analyzer.dart`

### Chart Components

| Chart Type | Purpose | Library |
|------------|---------|---------|
| Bar Chart | Daily/Weekly/Monthly breakdown | fl_chart |
| Pie Chart | Category breakdown | fl_chart |
| Line Chart | Trend analysis | fl_chart |
| Combined Chart | Comparison | fl_chart |

### Dependencies

| Package | Versi | Tujuan |
|---------|-------|--------|
| fl_chart | ^0.66.0 | Charts (existing, upgrade if needed) |
| screenshot | ^2.1.0 | Export chart as image |
| share_plus | ^7.2.1 | Share functionality |

---

**Status**: 📝 Draft - Ready for Implementation
**Created**: 8 April 2026
