# PRD v2 – Catat Cuan

## 0. The WHY – Alasan v2

v1 Catat Cuan sudah berhasil memberikan visibility atas pengeluaran pribadi dengan pencatatan transaksi dan insight dasar. Namun, ada beberapa pain point yang muncul setelah penggunaan:

1. **Kehilangan data** - Jika HP hilang/rusak, semua data transaksi hilang tanpa backup.
2. **Tidak ada kontrol** - Visibility baik, tapi tidak ada mekanisme untuk membatasi pengeluaran.
3. **Tidak ada tujuan** - Tidak ada cara untuk menetapkan target tabungan.
4. **Eye strain** - Penggunaan di malam hari kurang nyaman tanpa dark mode.
5. **Insight terbatas** - Laporan bulanan terlalu sederhana untuk analisis mendalam.

Dengan v2, dalam 2-3 bulan penggunaan aku ingin:
- Memiliki backup data yang aman di cloud.
- Bisa mengatur budget per kategori dan mendapat alert ketika mendekati limit.
- Menetapkan target tabungan dan melacak progress.
- Menggunakan app dengan nyaman di malam hari.
- Mendapat laporan keuangan yang lebih detail dan actionable.

---

## 1. Target Pengguna (The WHO)

### 1.1 Persona Utama (Sama dengan v1)

**Persona: "Developer dengan income campuran"**

- Sudah menggunakan v1 dan merasakan manfaat visibility pengeluaran.
- Ingin naik level dari sekadar "tahu" ke "mengontrol" keuangan.
- Memiliki multiple device dan khawatir kehilangan data.
- Sering menggunakan app di malam hari (eye strain dengan tema terang).

### 1.2 Use Case Baru v2

- **Backup & Restore**: Backup data ke Google Drive secara manual, restore ke device manapun.
- **Budget Management**: Set budget bulanan per kategori, terima alert ketika mendekati/melewati limit.
- **Savings Goals**: Buat target tabungan (misal: liburan, gadget), lacak progress.
- **Dark Mode**: Gunakan app dengan tema gelap untuk kenyamanan mata.
- **Enhanced Reports**: Lihat laporan detail dengan charts dan breakdowns yang lebih kaya.

---

## 2. Tujuan & Keberhasilan (The WHY → terukur)

### 2.1 Tujuan v2 (2-3 bulan pertama)

- Aku bisa:
  - Backup data ke Google Drive dan restore ke device lain dengan lancar.
  - Mengatur budget per kategori dan mendapat notifikasi ketika overspending.
  - Membuat target tabungan dan melihat progress secara visual.
  - Menggunakan app dengan dark mode tanpa eye strain.
  - Mendapat insight lebih detail dari laporan bulanan yang enhanced.

### 2.2 Metrics (untuk evaluasi)

- **Cloud Backup**:
  - Backup data minimal 1x per minggu.
  - Restore berhasil ke device baru dalam ≤5 menit.

- **Budgeting**:
  - Set budget untuk minimal 3 kategori.
  - Budget adherence rate ≥70% (tidak exceed budget).

- **Savings Goals**:
  - Minimal 1 savings goal aktif.
  - Progress tracking diupdate minimal 2x per bulan.

- **Dark Mode**:
  - Penggunaan dark mode ≥50% dari total waktu penggunaan app.

- **Enhanced Reports**:
  - Engagement dengan reports naik ≥30% vs v1.

---

## 3. Lingkup Produk v2 (The WHAT – non-teknis)

### 3.1 In Scope v2

#### 1. Google Drive Backup/Restore

**User Stories:**
- Sebagai pengguna, aku ingin backup data transaksiku ke Google Drive, agar data aman jika HP hilang/rusak.
- Sebagai pengguna, aku ingin restore data dari Google Drive ke device baru, agar aku tidak kehilangan histori keuangan.

**Functional Requirements:**
- Tombol "Backup ke Google Drive" di Settings.
- OAuth login ke Google Account (one-time).
- Backup manual (tidak auto-sync) untuk simplicity v2.
- Progress indicator saat backup/restore.
- Conflict handling: pilih data lokal vs cloud saat restore.
- Backup mencakup: transaksi, kategori, settings.

**Technical Considerations:**
- Google Drive API v3.
- Data format: JSON atau SQLite file.
- OAuth 2.0 scope: `drive.appdata` (app-specific folder, tidak akses file user).

**Success Criteria:**
- Backup 1000 transaksi dalam ≤30 detik.
- Restore berhasil dengan 0 data loss.
- User dapat backup/restore tanpa error di 95% kasus.

---

#### 2. Full Budgeting

**User Stories:**
- Sebagai pengguna, aku ingin mengatur budget bulanan per kategori, agar aku bisa mengontrol pengeluaran.
- Sebagai pengguna, aku ingin mendapat alert ketika pengeluaran mendekati atau melewati budget, agar aku aware sebelum terlambat.
- Sebagai pengguna, aku ingin melihat summary budget vs actual di akhir bulan, agar aku tahu performa keuanganku.

**Functional Requirements:**
- Screen Budget dengan list kategori dan input budget per kategori.
- Budget period: bulanan (reset setiap awal bulan).
- Alert types:
  - 75% tercapai: warning notification.
  - 100% tercapai: critical notification.
  - Melebihi budget: overspending notification.
- Budget overview card di Home Screen.
- Budget vs Actual chart di Monthly Summary.
- Rollover budget (opsional): sisa budget bulan lalu masuk ke bulan ini.

**UI/UX Considerations:**
- Progress bar per kategori (hijau → kuning → merah).
- Quick edit budget dari Home Screen.
- Notification dengan deep link ke detail kategori.

**Success Criteria:**
- User dapat set budget dalam ≤10 detik per kategori.
- Alert diterima real-time saat transaksi dicatat.
- Budget adherence ≥70% untuk active users.

---

#### 3. Savings Goals

**User Stories:**
- Sebagai pengguna, aku ingin membuat target tabungan dengan nama dan nominal, agar aku punya tujuan keuangan yang jelas.
- Sebagai pengguna, aku ingin melacak progress tabungan secara visual, agar aku termotivasi untuk menabung.
- Sebagai pengguna, aku ingin mencatat kontribusi ke goal, agar aku tahu histori tabungan.

**Functional Requirements:**
- Screen Goals dengan list savings goals.
- Create goal: nama, target nominal, target date (opsional), icon.
- Progress tracking: current amount / target amount.
- Add contribution: input nominal, pilih goal.
- Withdraw from goal: input nominal, pilih goal (dengan alasan).
- Goal completion celebration (confetti animation).
- Goals overview card di Home Screen.

**UI/UX Considerations:**
- Circular progress indicator per goal.
- Visual celebration saat goal tercapai.
- Quick add contribution dari Home Screen.

**Success Criteria:**
- User dapat membuat goal dalam ≤20 detik.
- Progress update real-time setelah contribution.
- Goal completion rate ≥30% untuk users yang set goals.

---

#### 4. Dark Mode

**User Stories:**
- Sebagai pengguna, aku ingin menggunakan app dengan tema gelap, agar nyaman digunakan di malam hari.
- Sebagai pengguna, aku ingin tema mengikuti setting system, agar konsisten dengan device.

**Functional Requirements:**
- Theme options: Light, Dark, System Default.
- Toggle di Settings screen.
- Semua komponen UI mendukung dark mode.
- Glassmorphism design diadaptasi untuk dark mode.
- Persistent theme preference.

**Design Considerations:**
- Dark background: #121212 (Material Design dark theme).
- Elevated surfaces: lighter shades (#1E1E1E, #2C2C2C).
- Accent colors tetap sama dengan light mode.
- Text contrast ratio ≥4.5:1 untuk accessibility.

**Success Criteria:**
- 100% UI components mendukung dark mode.
- Theme switch instant (no flicker).
- User satisfaction dengan dark mode ≥4/5 rating.

---

#### 5. Enhanced Reports

**User Stories:**
- Sebagai pengguna, aku ingin melihat breakdown pengeluaran per minggu, agar aku tahu pola pengeluaran lebih detail.
- Sebagai pengguna, aku ingin membandingkan pengeluaran bulan ini vs bulan lalu, agar aku tahu trend keuanganku.
- Sebagai pengguna, aku ingin melihat insight yang lebih actionable, agar aku bisa mengambil keputusan keuangan yang lebih baik.

**Functional Requirements:**
- Weekly breakdown chart (4 minggu per bulan).
- Month-over-month comparison (bar chart).
- Trend indicators (naik/turun %).
- Top spending days identification.
- Average daily spending calculation.
- Spending velocity indicator (burn rate).
- Export enhanced reports ke image/PDF (opsional).

**UI/UX Considerations:**
- Tab navigation: Daily → Weekly → Monthly → Yearly.
- Interactive charts (tap untuk detail).
- Share button untuk report images.

**Success Criteria:**
- User engagement dengan reports naik ≥30% vs v1.
- Report load time ≤2 detik untuk 1 tahun data.
- User dapat understand report dalam ≤30 detik.

---

### 3.2 Out of Scope v2 (ditunda ke v3)

- Real-time sync antar device (v2 hanya manual backup/restore).
- Multi-user / family accounts.
- Business finance features.
- Automatic bank/e-wallet integration.
- Multi-currency advanced (v1 sudah support IDR/USD basic).
- Tax reporting.
- Investment tracking.

---

## 4. User Story Tingkat Produk

1. Sebagai pengguna, aku ingin backup data ke Google Drive, agar data keuangan aman dari kehilangan.
2. Sebagai pengguna, aku ingin restore data dari Google Drive, agar bisa melanjutkan pencatatan di device baru.
3. Sebagai pengguna, aku ingin mengatur budget per kategori, agar bisa mengontrol pengeluaran.
4. Sebagai pengguna, aku ingin mendapat alert budget, agar aware sebelum overspending.
5. Sebagai pengguna, aku ingin membuat target tabungan, agar punya tujuan keuangan yang jelas.
6. Sebagai pengguna, aku ingin melacak progress tabungan, agar termotivasi menabung.
7. Sebagai pengguna, aku ingin menggunakan dark mode, agar nyaman di malam hari.
8. Sebagai pengguna, aku ingin melihat laporan yang lebih detail, agar bisa analisis keuangan lebih baik.

---

## 5. Pengalaman Pengguna yang Diinginkan (UX)

- **Backup/Restore**: One-tap backup, progress indicator jelas, restore dengan conflict handling yang intuitif.
- **Budgeting**: Set budget cepat (≤10 detik), alert yang helpful (bukan annoying), visual yang jelas (progress bars).
- **Savings Goals**: Setup goal simple (≤20 detik), progress tracking visual, celebration yang memuaskan.
- **Dark Mode**: Instant switch, consistent design, accessible contrast.
- **Enhanced Reports**: Interactive charts, load time cepat, shareable.

**UX Principles:**
- **Simplicity**: Fitur baru tidak membuat app terasa complicated.
- **Progressive Disclosure**: Advanced features tersembunyi sampai dibutuhkan.
- **Delight**: Micro-interactions dan celebrations untuk moments penting.

---

## 6. Risiko & Asumsi

### Asumsi

- Pengguna sudah familiar dengan v1 dan fitur dasar.
- Google Account sudah dimiliki oleh mayoritas pengguna Indonesia.
- Budgeting manual (tanpa auto-sync bank) masih acceptable untuk v2.
- Dark mode adalah fitur yang highly requested.

### Risiko

- **Google Drive API complexity** - OAuth flow dan quota limits bisa jadi challenging.
- **Budget fatigue** - Alert terlalu sering bisa membuat user ignore notifications.
- **Goal abandonment** - Goals yang tidak tercapai bisa demotivasi user.
- **Feature bloat** - Terlalu banyak fitur baru bisa overwhelming.

### Mitigasi

- Simple backup/restore dulu, real-time sync di v3.
- Alert frequency settings (daily summary vs per transaction).
- Encouraging messages untuk goals yang slow progress.
- Progressive disclosure dan good information architecture.

---

## 7. Catatan Teknis High-Level

### Dependencies Baru

| Package | Versi | Tujuan |
|---------|-------|--------|
| google_sign_in | ^6.x | OAuth untuk Google Drive |
| googleapis | ^13.x | Google Drive API v3 |
| flutter_riverpod | ^3.3.1 | State management (existing) |
| extension_google_sign_in_as_googleapis_auth | ^0.x | Auth adapter |

### Database Schema Changes

**Tabel baru:**
- `budgets` - Budget per kategori per bulan
- `savings_goals` - Target tabungan
- `goal_contributions` - Histori kontribusi goal

**Tabel dimodifikasi:**
- `settings` - Theme preference, backup metadata

### Architecture

- **Clean Architecture** dipertahankan dengan:
  - New entities: `BudgetEntity`, `SavingsGoalEntity`, `GoalContributionEntity`
  - New repositories: `BudgetRepository`, `SavingsGoalRepository`, `BackupRepository`
  - New use cases: per feature operations
  - New providers: feature-specific state management

### Security

- Google Drive data dienkripsi sebelum upload (optional untuk v2).
- OAuth tokens disimpan securely di device (flutter_secure_storage).
- No sensitive data di logs.

---

## 8. Timeline & Prioritas

### Phase 1: Foundation (Week 1-2)
- [ ] Database schema migration
- [ ] Dark mode design system
- [ ] Dark mode implementation

### Phase 2: Budgeting (Week 3-4)
- [ ] Budget entities & repositories
- [ ] Budget UI & providers
- [ ] Budget alerts

### Phase 3: Savings Goals (Week 5-6)
- [ ] Goals entities & repositories
- [ ] Goals UI & providers
- [ ] Contribution flow

### Phase 4: Cloud Backup (Week 7-8)
- [ ] Google Drive OAuth
- [ ] Backup/Restore implementation
- [ ] Error handling & edge cases

### Phase 5: Enhanced Reports (Week 9-10)
- [ ] New chart components
- [ ] Weekly/Monthly comparison
- [ ] Trend analysis

### Phase 6: Polish & Testing (Week 11-12)
- [ ] Integration testing
- [ ] Bug fixes
- [ ] Performance optimization
- [ ] Documentation update

---

## 9. Success Criteria Summary

| Feature | Metric | Target |
|---------|--------|--------|
| Google Drive Backup | Backup success rate | ≥95% |
| Google Drive Backup | Restore success rate | ≥95% |
| Full Budgeting | Budget adherence | ≥70% |
| Full Budgeting | Alert engagement | ≥50% open rate |
| Savings Goals | Goal completion rate | ≥30% |
| Savings Goals | Active goals per user | ≥1 |
| Dark Mode | Usage rate | ≥50% of sessions |
| Dark Mode | User satisfaction | ≥4/5 |
| Enhanced Reports | Engagement increase | ≥30% vs v1 |
| Enhanced Reports | Load time | ≤2 seconds |

---

**Last Updated**: 8 April 2026
**Status**: 📝 Draft - Ready for Review
