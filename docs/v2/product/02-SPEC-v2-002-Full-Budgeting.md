# SPEC v2 – Full Budgeting

## Daftar Persyaratan Teknis (REQ-BUD)

### REQ-BUD-001: Entitas Budget
Sistem mendefinisikan entitas budget dengan atribut lengkap.

#### AC-BUD-001.1: Struktur Data Budget
- [ ] Budget memiliki atribut:
  - ID unik (auto-generated)
  - Category ID (FK ke categories)
  - Amount (nominal budget)
  - Period (bulan dan tahun)
  - Created at
  - Updated at

#### AC-BUD-001.2: Budget Period
- [ ] Period menggunakan format: bulan (1-12) + tahun (YYYY)
- [ ] Satu kategori hanya boleh memiliki satu budget per periode
- [ ] Budget di-reset setiap awal bulan baru (tidak carry over)

---

### REQ-BUD-002: CRUD Budget
Sistem menyediakan operasi CRUD untuk budget.

#### AC-BUD-002.1: Create Budget
- [ ] User dapat membuat budget baru dengan memilih:
  - Kategori (hanya kategori pengeluaran)
  - Nominal budget
  - Periode (default: bulan ini)
- [ ] Validasi: nominal > 0
- [ ] Validasi: kategori belum memiliki budget di periode yang sama

#### AC-BUD-002.2: Read Budget
- [ ] Tampilkan list budget untuk periode aktif
- [ ] Setiap item menampilkan:
  - Nama kategori + icon
  - Budget amount
  - Spent amount
  - Remaining amount
  - Progress percentage
  - Visual indicator (progress bar)

#### AC-BUD-002.3: Update Budget
- [ ] User dapat mengubah nominal budget
- [ ] User tidak dapat mengubah kategori atau periode
- [ ] Timestamp updated_at diupdate

#### AC-BUD-002.4: Delete Budget
- [ ] User dapat menghapus budget
- [ ] Konfirmasi sebelum hapus
- [ ] Data transaksi tidak terpengaruh

---

### REQ-BUD-003: Budget Tracking
Sistem melacak pengeluaran terhadap budget.

#### AC-BUD-003.1: Real-time Tracking
- [ ] Spent amount diupdate setiap ada transaksi baru
- [ ] Progress percentage dihitung: (spent / budget) * 100
- [ ] Remaining amount dihitung: budget - spent

#### AC-BUD-003.2: Visual Indicators
- [ ] Progress bar warna:
  - Hijau: 0-75% terpakai
  - Kuning/Orange: 75-100% terpakai
  - Merah: >100% (overspending)
- [ ] Icon warning saat mendekati limit

#### AC-BUD-003.3: Budget Overview Card
- [ ] Tampilkan summary di Home Screen:
  - Total budget bulan ini
  - Total spent
  - Total remaining
  - Jumlah kategori yang overspending

---

### REQ-BUD-004: Budget Alerts
Sistem mengirimkan alert berdasarkan kondisi budget.

#### AC-BUD-004.1: Alert Types
- [ ] **Warning Alert** (75% tercapai):
  - Notifikasi: "Budget [Kategori] sudah terpakai 75%"
- [ ] **Limit Alert** (100% tercapai):
  - Notifikasi: "Budget [Kategori] sudah habis!"
- [ ] **Overspending Alert** (>100% terpakai):
  - Notifikasi: "Budget [Kategori] terlampaui sebesar Rp X"

#### AC-BUD-004.2: Alert Timing
- [ ] Alert ditrigger saat transaksi dicatat
- [ ] Alert tidak diulang untuk kondisi yang sama
- [ ] Alert hanya untuk budget periode aktif

#### AC-BUD-004.3: Alert Settings
- [ ] User dapat enable/disable alerts per kategori
- [ ] User dapat mengatur threshold alert (default: 75%, 100%)
- [ ] User dapat memilih jenis notifikasi (in-app, push)

#### AC-BUD-004.4: In-App Alert Display
- [ ] Badge di budget card untuk kategori yang exceed
- [ ] Warning icon di list transaksi untuk kategori yang exceed
- [ ] Summary alert di Home Screen

---

### REQ-BUD-005: Budget vs Actual Report
Sistem menyediakan laporan perbandingan budget vs actual.

#### AC-BUD-005.1: Budget Summary Screen
- [ ] Tampilkan semua budget untuk periode aktif
- [ ] Grouping: On Track, Near Limit, Overspending
- [ ] Sort by: highest spent, closest to limit, alphabetical

#### AC-BUD-005.2: Budget Detail Screen
- [ ] Tampilkan detail per kategori:
  - Budget amount
  - Spent amount
  - Remaining
  - Progress bar
  - List transaksi untuk kategori tersebut
  - Daily average spending

#### AC-BUD-005.3: Historical Budget Data
- [ ] Tampilkan budget history (3 bulan terakhir)
- [ ] Budget adherence trend
- [ ] Average budget utilization

---

### REQ-BUD-006: Quick Budget Actions
Sistem menyediakan shortcut untuk aksi cepat.

#### AC-BUD-006.1: Quick Set Budget
- [ ] Dari transaction list, user dapat set budget untuk kategori
- [ ] Pre-fill kategori berdasarkan transaksi yang dipilih
- [ ] Input nominal dan langsung simpan

#### AC-BUD-006.2: Quick Edit from Home
- [ ] Tap budget card di Home untuk edit nominal
- [ ] Inline edit tanpa navigasi ke screen baru

---

## Non-Functional Requirements (NFR)

### NFR-BUD-001: Performa
- [ ] Budget list loading ≤500ms untuk 20 budget
- [ ] Real-time tracking update ≤100ms setelah transaksi
- [ ] Alert ditampilkan ≤200ms setelah transaksi

### NFR-BUD-002: Akurasi
- [ ] Perhitungan budget 100% akurat
- [ ] Tidak ada rounding error untuk nominal
- [ ] Progress percentage akurat hingga 2 desimal

### NFR-BUD-003: User Experience
- [ ] Set budget dalam ≤10 detik
- [ ] Visual indicators jelas dan intuitif
- [ ] Alert tidak intrusive (tidak mengganggu workflow)

### NFR-BUD-004: Data Integrity
- [ ] Budget data konsisten dengan transaksi data
- [ ] Tidak ada orphan budgets (kategori dihapus → budget dihapus)
- [ ] Migration dari v1 ke v2 tanpa data loss

---

## Verifikasi Checklist

**Total Requirements**: 6 (REQ-BUD-001 hingga REQ-BUD-006)
**Total NFR**: 4 (NFR-BUD-001 hingga NFR-BUD-004)

### Status Implementasi

| ID | Deskripsi | Status | Metode Verifikasi | Terakhir Diverifikasi |
|----|-----------|--------|-------------------|---------------------|
| REQ-BUD-001 | Entitas Budget | ⏳ | Code review | - |
| REQ-BUD-002 | CRUD Budget | ⏳ | Test + Manual | - |
| REQ-BUD-003 | Budget Tracking | ⏳ | Test execution | - |
| REQ-BUD-004 | Budget Alerts | ⏳ | Manual testing | - |
| REQ-BUD-005 | Budget vs Actual Report | ⏳ | Manual testing | - |
| REQ-BUD-006 | Quick Budget Actions | ⏳ | Manual testing | - |
| NFR-BUD-001 | Performa | ⏳ | Performance test | - |
| NFR-BUD-002 | Akurasi | ⏳ | Test execution | - |
| NFR-BUD-003 | User Experience | ⏳ | Usability test | - |
| NFR-BUD-004 | Data Integrity | ⏳ | Test execution | - |

### Ringkasan Implementasi

- **Total Requirements**: 6
- **Fully Implemented (✅)**: 0 (0%)
- **Partially Implemented (⚠️)**: 0 (0%)
- **Not Implemented (⏳)**: 6 (100%)

### File Implementasi yang Direncanakan

- **Entity**: `lib/domain/entities/budget/budget_entity.dart`
- **Repository Interface**: `lib/domain/repositories/budget/budget_repository.dart`
- **Repository Impl**: `lib/data/repositories/budget/budget_repository_impl.dart`
- **Use Cases**: `lib/domain/usecases/budget/`
- **Provider**: `lib/presentation/providers/budget/budget_provider.dart`
- **Screen**: `lib/presentation/screens/budget_screen.dart`
- **Widgets**: `lib/presentation/widgets/budget/`

### Database Schema

```sql
CREATE TABLE budgets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  category_id INTEGER NOT NULL,
  amount REAL NOT NULL,
  period_month INTEGER NOT NULL,
  period_year INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
  UNIQUE(category_id, period_month, period_year)
);

CREATE INDEX idx_budgets_period ON budgets(period_month, period_year);
```

---

**Status**: 📝 Draft - Ready for Implementation
**Created**: 8 April 2026
