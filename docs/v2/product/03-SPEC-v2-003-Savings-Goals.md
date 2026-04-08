# SPEC v2 – Savings Goals

## Daftar Persyaratan Teknis (REQ-SAV)

### REQ-SAV-001: Entitas Savings Goal
Sistem mendefinisikan entitas savings goal dengan atribut lengkap.

#### AC-SAV-001.1: Struktur Data Goal
- [ ] Goal memiliki atribut:
  - ID unik (auto-generated)
  - Name (nama target tabungan)
  - Target amount (nominal target)
  - Current amount (saldo saat ini)
  - Target date (opsional, deadline)
  - Icon (emoji atau icon identifier)
  - Color (warna untuk visual)
  - Status (active, completed, cancelled)
  - Created at
  - Updated at

#### AC-SAV-001.2: Goal Status
- [ ] Status values: `active`, `completed`, `cancelled`
- [ ] Auto-set ke `completed` saat current >= target
- [ ] User dapat cancel goal kapan saja

---

### REQ-SAV-002: CRUD Savings Goal
Sistem menyediakan operasi CRUD untuk savings goals.

#### AC-SAV-002.1: Create Goal
- [ ] Form create goal dengan field:
  - Nama goal (wajib)
  - Target amount (wajib, > 0)
  - Target date (opsional)
  - Icon selection (default: 🎯)
  - Color selection (default: primary color)
- [ ] Validasi: nama tidak kosong
- [ ] Validasi: target amount > 0

#### AC-SAV-002.2: Read Goals
- [ ] Tampilkan list goals dengan:
  - Icon + nama
  - Progress indicator (circular)
  - Current / Target amount
  - Percentage complete
  - Days remaining (jika ada target date)
  - Status badge (active/completed/cancelled)
- [ ] Grouping: Active, Completed, Cancelled
- [ ] Sort: by created date (default), by progress, by deadline

#### AC-SAV-002.3: Update Goal
- [ ] Edit: nama, target amount, target date, icon, color
- [ ] Tidak dapat mengubah current amount langsung (gunakan contribution)
- [ ] Jika target amount diubah < current, set status ke completed

#### AC-SAV-002.4: Delete Goal
- [ ] Soft delete (status = cancelled)
- [ ] Konfirmasi sebelum delete
- [ ] Contribution history tetap tersimpan

---

### REQ-SAV-003: Goal Contributions
Sistem melacak kontribusi ke savings goals.

#### AC-SAV-003.1: Add Contribution
- [ ] Form add contribution dengan field:
  - Goal (dropdown, hanya active goals)
  - Amount (> 0)
  - Date (default: hari ini)
  - Note (opsional)
- [ ] Current amount goal diupdate (+ contribution amount)
- [ ] Cek jika goal tercapai setelah contribution

#### AC-SAV-003.2: Withdraw from Goal
- [ ] Form withdraw dengan field:
  - Goal (dropdown)
  - Amount (> 0, ≤ current amount)
  - Reason (opsional)
  - Date
- [ ] Current amount goal diupdate (- withdrawal amount)
- [ ] Withdrawal dicatat sebagai contribution dengan amount negatif

#### AC-SAV-003.3: Contribution History
- [ ] Tampilkan history per goal:
  - Date
  - Type (contribution/withdrawal)
  - Amount (+ / -)
  - Running balance
  - Note/reason
- [ ] Filter by type, date range
- [ ] Export history (opsional)

---

### REQ-SAV-004: Progress Tracking
Sistem menyediakan visualisasi progress goal.

#### AC-SAV-004.1: Circular Progress Indicator
- [ ] Progress = (current / target) * 100
- [ ] Color gradient berdasarkan progress:
  - 0-25%: Merah
  - 25-50%: Orange
  - 50-75%: Kuning
  - 75-100%: Hijau
- [ ] Center text: percentage

#### AC-SAV-004.2: Goal Detail View
- [ ] Tampilkan:
  - Progress chart (circular)
  - Current amount / Target amount
  - Remaining amount
  - Progress percentage
  - Days remaining / Days elapsed
  - Average contribution per month
  - Projected completion date (estimasi)
  - Contribution history (recent 5)

#### AC-SAV-004.3: Goals Overview Card
- [ ] Di Home Screen, tampilkan:
  - Total goals (active)
  - Total saved
  - Total target
  - Overall progress percentage
  - Quick add contribution button

---

### REQ-SAV-005: Goal Completion
Sistem merayakan pencapaian goal.

#### AC-SAV-005.1: Completion Detection
- [ ] Auto-detect saat current >= target
- [ ] Set status ke `completed`
- [ ] Set completion date

#### AC-SAV-005.2: Completion Celebration
- [ ] Tampilkan celebration animation (confetti)
- [ ] Tampilkan congratulation dialog
- [ ] Summary: total saved, time to complete, total contributions

#### AC-SAV-005.3: Post-Completion
- [ ] Goal completed tetap visible di section "Completed"
- [ ] User dapat archive (hide dari list)
- [ ] User dapat create new goal dengan template dari completed goal

---

### REQ-SAV-006: Goal Insights
Sistem memberikan insight terkait goals.

#### AC-SAV-006.1: Progress Insights
- [ ] "Anda sudah menabung X% dari target!"
- [ ] "Tinggal Rp X lagi untuk mencapai target!"
- [ ] "Dengan rata-rata tabungan Rp X/bulan, target tercapai dalam Y bulan"

#### AC-SAV-006.2: Deadline Insights
- [ ] "X hari lagi menuju deadline!"
- [ ] "Anda perlu menabung Rp X/hari untuk mencapai target tepat waktu"
- [ ] Warning jika behind schedule

#### AC-SAV-006.3: Motivational Messages
- [ ] Random motivational quotes saat buka goals screen
- [ ] Celebration messages saat milestone (25%, 50%, 75%)

---

## Non-Functional Requirements (NFR)

### NFR-SAV-001: Performa
- [ ] Goals list loading ≤500ms untuk 20 goals
- [ ] Contribution add/update ≤200ms
- [ ] Progress calculation real-time

### NFR-SAV-002: Akurasi
- [ ] Perhitungan progress 100% akurat
- [ ] Tidak ada rounding error
- [ ] Running balance konsisten

### NFR-SAV-003: User Experience
- [ ] Create goal dalam ≤20 detik
- [ ] Add contribution dalam ≤10 detik
- [ ] Visual feedback untuk semua aksi

### NFR-SAV-004: Data Integrity
- [ ] Contribution amount tidak dapat melebihi current goal amount untuk withdraw
- [ ] Goal status konsisten dengan current vs target
- [ ] Contribution history tidak dapat dihapus (audit trail)

---

## Verifikasi Checklist

**Total Requirements**: 6 (REQ-SAV-001 hingga REQ-SAV-006)
**Total NFR**: 4 (NFR-SAV-001 hingga NFR-SAV-004)

### Status Implementasi

| ID | Deskripsi | Status | Metode Verifikasi | Terakhir Diverifikasi |
|----|-----------|--------|-------------------|---------------------|
| REQ-SAV-001 | Entitas Savings Goal | ⏳ | Code review | - |
| REQ-SAV-002 | CRUD Savings Goal | ⏳ | Test + Manual | - |
| REQ-SAV-003 | Goal Contributions | ⏳ | Test execution | - |
| REQ-SAV-004 | Progress Tracking | ⏳ | Manual testing | - |
| REQ-SAV-005 | Goal Completion | ⏳ | Manual testing | - |
| REQ-SAV-006 | Goal Insights | ⏳ | Manual testing | - |
| NFR-SAV-001 | Performa | ⏳ | Performance test | - |
| NFR-SAV-002 | Akurasi | ⏳ | Test execution | - |
| NFR-SAV-003 | User Experience | ⏳ | Usability test | - |
| NFR-SAV-004 | Data Integrity | ⏳ | Test execution | - |

### Ringkasan Implementasi

- **Total Requirements**: 6
- **Fully Implemented (✅)**: 0 (0%)
- **Partially Implemented (⚠️)**: 0 (0%)
- **Not Implemented (⏳)**: 6 (100%)

### File Implementasi yang Direncanakan

- **Entity**: `lib/domain/entities/savings_goal/savings_goal_entity.dart`
- **Entity**: `lib/domain/entities/savings_goal/goal_contribution_entity.dart`
- **Repository Interface**: `lib/domain/repositories/savings_goal/savings_goal_repository.dart`
- **Repository Impl**: `lib/data/repositories/savings_goal/savings_goal_repository_impl.dart`
- **Use Cases**: `lib/domain/usecases/savings_goal/`
- **Provider**: `lib/presentation/providers/savings_goal/savings_goal_provider.dart`
- **Screen**: `lib/presentation/screens/savings_goals_screen.dart`
- **Widgets**: `lib/presentation/widgets/savings_goal/`

### Database Schema

```sql
CREATE TABLE savings_goals (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  target_amount REAL NOT NULL,
  current_amount REAL NOT NULL DEFAULT 0,
  target_date TEXT,
  icon TEXT DEFAULT '🎯',
  color TEXT DEFAULT '#4CAF50',
  status TEXT NOT NULL DEFAULT 'active',
  completion_date TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

CREATE TABLE goal_contributions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  goal_id INTEGER NOT NULL,
  amount REAL NOT NULL,
  type TEXT NOT NULL, -- 'contribution' or 'withdrawal'
  note TEXT,
  date TEXT NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (goal_id) REFERENCES savings_goals(id) ON DELETE CASCADE
);

CREATE INDEX idx_goal_contributions_goal ON goal_contributions(goal_id);
CREATE INDEX idx_goal_contributions_date ON goal_contributions(date);
```

### Dependencies

| Package | Versi | Tujuan |
|---------|-------|--------|
| confetti | ^0.7.0 | Celebration animation |

---

**Status**: 📝 Draft - Ready for Implementation
**Created**: 8 April 2026
