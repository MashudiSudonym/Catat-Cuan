# Roadmap Pengembangan Catat Cuan v2

**Dibuat**: 22 Maret 2026
**Status**: Draft Planning

---

## Status v1

**Catat Cuan v1 telah 100% selesai** dengan fitur-fitur:
- Pencatatan transaksi tanpa batas dengan pagination
- Input manual cepat dengan validasi
- Input via struk (OCR dengan Google ML Kit)
- Ringkasan bulanan dengan insight & saran
- Full CRUD transaksi dengan filter dan search
- CSV Export & Share
- Category management dengan drag-drop reorder
- Multi-select delete
- Design system glassmorphism yang konsisten

---

## Roadmap v2

### Fase 1: Data Persistence & Sync (Prioritas Tinggi)

| Fitur | Deskripsi | Kompleksitas | Estimasi Effort |
|-------|-----------|--------------|-----------------|
| Cloud Sync | Multi-device data synchronization | Tinggi | 2-3 minggu |
| Local Backup | Export/import database lokal | Rendah | 3-5 hari |
| Auto Backup | Scheduled backup ke local storage | Rendah | 2-3 hari |

**Catatan**: Cloud sync memerlukan backend service. Pertimbangkan opsi:
- Firebase (Firestore + Auth)
- Supabase (PostgreSQL + Auth)
- Self-hosted (Node.js + PostgreSQL)

### Fase 2: Budgeting & Financial Goals (Prioritas Tinggi)

| Fitur | Deskripsi | Kompleksitas | Estimasi Effort |
|-------|-----------|--------------|-----------------|
| Category Budgets | Per-category budget limits | Sedang | 1-2 minggu |
| Budget Alerts | Notification saat mendekati limit | Sedang | 3-5 hari |
| Budget Progress | Visual progress indicator | Rendah | 2-3 hari |
| Savings Goals | Target tabungan dengan tracking | Sedang | 1-2 minggu |

**Database Changes Required**:
```sql
-- New table: budgets
CREATE TABLE budgets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  category_id INTEGER REFERENCES categories(id),
  amount REAL NOT NULL,
  period TEXT NOT NULL, -- 'monthly', 'weekly'
  is_active INTEGER DEFAULT 1,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

-- New table: savings_goals
CREATE TABLE savings_goals (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  target_amount REAL NOT NULL,
  current_amount REAL DEFAULT 0,
  target_date TEXT,
  icon TEXT,
  color TEXT,
  is_active INTEGER DEFAULT 1,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

### Fase 3: UX Enhancements (Prioritas Sedang)

| Fitur | Deskripsi | Kompleksitas | Estimasi Effort |
|-------|-----------|--------------|-----------------|
| Recurring Transactions | Auto-create periodic transactions | Sedang | 1-2 minggu |
| CSV Import | Import data dari app lain | Sedang | 1 minggu |
| Home Screen Widgets | Quick entry tanpa buka app | Sedang | 1-2 minggu |
| Quick Actions | Shortcuts untuk frequent operations | Rendah | 2-3 hari |
| Transaction Templates | Pre-filled templates for common entries | Rendah | 3-5 hari |

**Database Changes Required for Recurring**:
```sql
-- New table: recurring_transactions
CREATE TABLE recurring_transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  amount REAL NOT NULL,
  type TEXT NOT NULL,
  category_id INTEGER REFERENCES categories(id),
  note TEXT,
  frequency TEXT NOT NULL, -- 'daily', 'weekly', 'monthly', 'yearly'
  day_of_week INTEGER, -- 0-6 for weekly
  day_of_month INTEGER, -- 1-31 for monthly
  next_due_date TEXT NOT NULL,
  is_active INTEGER DEFAULT 1,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

### Fase 4: Security & Privacy (Prioritas Sedang)

| Fitur | Deskripsi | Kompleksitas | Estimasi Effort |
|-------|-----------|--------------|-----------------|
| Biometrics | Fingerprint/face authentication | Sedang | 3-5 hari |
| PIN Lock | Alternative ke biometrics | Rendah | 2-3 hari |
| Data Encryption | Encrypt sensitive data at rest | Sedang | 1 minggu |
| Privacy Mode | Hide amounts on screen | Rendah | 1-2 hari |

### Fase 5: Advanced Analytics (Prioritas Rendah)

| Fitur | Deskripsi | Kompleksitas | Estimasi Effort |
|-------|-----------|--------------|-----------------|
| Year-over-Year | Annual comparison charts | Sedang | 1 minggu |
| Category Trends | Spending trend per category | Sedang | 1 minggu |
| Cash Flow Forecast | Predict future balance | Tinggi | 2 minggu |
| PDF Reports | Export laporan format PDF | Sedang | 1 minggu |
| Email Reports | Scheduled email reports | Sedang | 1 minggu |

### Fase 6: Platform Expansion (Prioritas Rendah)

| Fitur | Deskripsi | Kompleksitas | Estimasi Effort |
|-------|-----------|--------------|-----------------|
| Web App | Browser-based version | Tinggi | 4-6 minggu |
| Smartwatch | Wear OS / watchOS companion | Tinggi | 3-4 minggu |
| Tablet Optimization | Adaptive layouts untuk tablet | Sedang | 1-2 minggu |

---

## Prioritas Rekomendasi

### Jika Fokus pada User Retention:
1. **Budgeting** - User lebih engaged dengan goals
2. **Recurring Transactions** - Mengurangi friction
3. **Home Screen Widgets** - Quick access

### Jika Fokus pada User Acquisition:
1. **CSV Import** - Memudahkan migrasi dari app lain
2. **Cloud Sync** - Value proposition untuk multi-device users
3. **PDF Reports** - Share capability

### Jika Fokus pada Monetization (Future):
1. **Cloud Sync** - Premium feature
2. **Advanced Analytics** - Premium feature
3. **PDF Reports** - Premium feature
4. **Unlimited Budgets** - Freemium model

---

## Technical Debt & Maintenance

Selain fitur baru, perlu diperhatikan:

| Item | Deskripsi | Prioritas |
|------|-----------|-----------|
| Unit Test Coverage | Tingkatkan coverage di domain layer | Sedang |
| Integration Tests | E2E testing untuk critical flows | Sedang |
| Performance Profiling | Optimasi untuk large datasets | Rendah |
| Accessibility | Screen reader support, contrast | Rendah |
| CI/CD Pipeline | Automated build & deploy | Sedang |

---

## Next Steps

1. **Pilih prioritas** berdasarkan goals (retention vs acquisition vs monetization)
2. **Buat PRD v2** untuk fitur-fitur yang dipilih
3. **Estimasi resource** dan timeline
4. **Setup infrastructure** jika diperlukan (cloud sync)
5. **Implement secara iteratif** dengan feedback loop

---

## Catatan

- Roadmap ini bersifat **fleksibel** dan dapat disesuaikan
- Prioritas dapat berubah berdasarkan user feedback
- Fitur out of scope v1 (multi-currency, tax reports, business features) tetap ditunda kecuali ada kebutuhan spesifik
- Cloud sync adalah **major undertaking** yang memerlukan backend infrastructure

---

*Document ini akan diupdate seiring dengan progress pengembangan.*
