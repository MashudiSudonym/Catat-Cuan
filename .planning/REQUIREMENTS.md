# Requirements: Catat Cuan v2

**Defined:** 2026-05-06
**Core Value:** Users can control their finances — not just see them. Budgets prevent overspending, savings goals create motivation, and backup ensures data safety.

## v1 Requirements (Validated)

Requirements already shipped in v1. These constrain v2 implementation.

- ✓ **TRANS-01**: User can create, read, update, delete transactions with amount, category, date, note
- ✓ **TRANS-02**: User can search and filter transactions by text, category, date range, amount range
- ✓ **TRANS-03**: User can scan receipts via OCR (ML Kit) to auto-extract amount and merchant
- ✓ **CAT-01**: User can manage categories with custom icons and colors
- ✓ **CAT-02**: User can seed default categories during onboarding
- ✓ **IMP-01**: User can import transactions from CSV files
- ✓ **EXP-01**: User can export transactions to CSV and share
- ✓ **INS-01**: User can view monthly summary with basic financial insights
- ✓ **WID-01**: User can view transaction summary on Android home screen widget
- ✓ **ONB-01**: User completes onboarding flow on first launch
- ✓ **DB-01**: SQLite database with schema v2, managed by SchemaManager

## v2 Requirements

Requirements for v2 release. Each maps to roadmap phases.

### Cloud Backup

- [ ] **BKP-01**: User can authenticate with Google Account via OAuth 2.0 using `drive.appdata` scope (app-specific folder only)
- [ ] **BKP-02**: User can backup all data (transactions, categories, settings) to Google Drive in JSON format with progress indicator
- [ ] **BKP-03**: User can view list of available backups (date, size, device origin) and preview before restoring
- [ ] **BKP-04**: User can restore data from Google Drive backup with conflict handling (replace all or cancel)
- [ ] **BKP-05**: User can view backup info (last backup date, size, account) and manage old backups (auto-cleanup keeping 5 latest)
- [ ] **BKP-06**: System handles OAuth token expiry with automatic refresh and re-authentication prompt when needed
- [ ] **BKP-07**: System handles backup/restore errors gracefully (network, quota, auth, corrupted file) with user-friendly Indonesian messages

### Budgeting

- [ ] **BUD-01**: User can create, read, update, delete monthly budgets per expense category with amount validation
- [ ] **BUD-02**: System tracks spent amount per budget in real-time as transactions are recorded, with progress percentage calculation
- [ ] **BUD-03**: User sees visual progress indicators per budget (green 0-75%, yellow 75-100%, red >100%)
- [ ] **BUD-04**: User receives in-app alerts when budget reaches 75% (warning), 100% (limit), and >100% (overspending)
- [ ] **BUD-05**: User sees budget overview card on Home Screen showing total budget, total spent, remaining, and overspending count
- [ ] **BUD-06**: User can view budget vs actual comparison per category with list of transactions for that category
- [ ] **BUD-07**: System enforces one budget per category per month and prevents orphan budgets when categories are deleted

### Savings Goals

- [ ] **SAV-01**: User can create savings goals with name, target amount, optional target date, icon, and color
- [ ] **SAV-02**: User can read goal list with circular progress indicators, current/target amounts, percentage, days remaining
- [ ] **SAV-03**: User can update goal name, target amount, target date, icon, color (not current amount directly)
- [ ] **SAV-04**: User can soft-delete goals (status = cancelled) with confirmation; contribution history preserved
- [ ] **SAV-05**: User can add contributions to goals with amount, date, and optional note; current amount updates atomically
- [ ] **SAV-06**: User can withdraw from goals with amount and optional reason; recorded as negative contribution
- [ ] **SAV-07**: User sees goal progress with color gradient (red 0-25%, orange 25-50%, yellow 50-75%, green 75-100%)
- [ ] **SAV-08**: System auto-detects goal completion (current >= target), sets status to completed, triggers confetti celebration
- [ ] **SAV-09**: User sees goals overview card on Home Screen with total saved, total target, overall progress, quick-add button
- [ ] **SAV-10**: User can view contribution history per goal with date, type, amount, running balance, and note/reason

### Dark Mode

- [x] **THM-01**: User can select theme mode (Light, Dark, System Default) from Settings with instant switch and no app restart — ✅ Validated v2.0
- [x] **THM-02**: System persists theme preference across sessions using shared_preferences — ✅ Validated v2.0
- [x] **THM-03**: System adapts all UI components for dark mode including glassmorphism containers with adjusted blur and alpha — ✅ Validated v2.0
- [x] **THM-04**: System follows device theme when set to System Default, updating in real-time on platform brightness change — ✅ Validated v2.0
- [x] **THM-05**: Dark theme uses Material Design dark colors (#121212 background, elevated surfaces #1E1E1E/#2C2C2C) with maintained accent colors — ✅ Validated v2.0
- [x] **THM-06**: All text and icons meet accessibility contrast ratios (≥4.5:1 normal text, ≥3:1 large text and icons) — ✅ Validated v2.0

### Enhanced Reports

- [ ] **RPT-01**: User can view reports across four time frames (Daily, Weekly, Monthly, Yearly) via tab navigation with swipe gestures
- [ ] **RPT-02**: User sees time-appropriate breakdowns (daily summary, weekly 7-bar chart, monthly weekly bars, yearly 12-bar chart)
- [ ] **RPT-03**: User can view category breakdown via pie chart (all categories) and horizontal bar chart (top categories) with tap-to-detail
- [ ] **RPT-04**: User sees month-over-month comparison with percentage change indicators (up/down/stable) and color coding
- [ ] **RPT-05**: User sees trend line chart for 6-month spending history with spending velocity (burn rate) projection
- [ ] **RPT-06**: User can navigate periods with arrow buttons and see current period clearly labeled with quick-jump to current
- [ ] **RPT-07**: System pre-aggregates report data in SQLite queries to maintain ≤2 second load time for 1 year of data

## v2+ Requirements

Deferred to future release. Tracked but not in current roadmap.

### Cloud Backup Enhancements
- **BKP-F01**: Auto-backup on schedule (daily/weekly)
- **BKP-F02**: Real-time sync between devices
- **BKP-F03**: Merge conflict resolution (append cloud data to local)
- **BKP-F04**: Data encryption before upload

### Budgeting Enhancements
- **BUD-F01**: Budget rollover (unused amount carries to next month)
- **BUD-F02**: Push notifications for budget alerts (not just in-app)
- **BUD-F03**: Custom alert thresholds per category
- **BUD-F04**: Historical budget adherence trends (3+ months)

### Savings Goals Enhancements
- **SAV-F01**: Goal templates from completed goals
- **SAV-F02**: Goal archiving (hide from active list)
- **SAV-F03**: Export contribution history
- **SAV-F04**: Recurring auto-contributions

### Reports Enhancements
- **RPT-F01**: Export report as PDF
- **RPT-F02**: Anomaly detection (unusual spending outliers)
- **RPT-F03**: Actionable spending reduction recommendations
- **RPT-F04**: Interactive chart pinch-to-zoom for time series
- **RPT-F05**: Report home screen card with mini chart preview

## Out of Scope

| Feature | Reason |
|---------|--------|
| Real-time multi-device sync | High complexity, manual backup sufficient for v2 |
| Multi-user / family accounts | Single-user personal finance app |
| Business finance features | Personal finance only, different domain |
| Automatic bank/e-wallet integration | Manual entry + OCR is the product model |
| Multi-currency advanced | v1 basic IDR/USD sufficient for target user |
| Tax reporting | Not applicable for personal use case |
| Investment tracking | Different product category |
| Push notifications | In-app alerts sufficient for v2; push requires Firebase infrastructure |
| PDF report export | Image export covers 80% of sharing use case at 20% cost |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| BKP-01 | Phase 4 | Pending |
| BKP-02 | Phase 4 | Pending |
| BKP-03 | Phase 4 | Pending |
| BKP-04 | Phase 4 | Pending |
| BKP-05 | Phase 4 | Pending |
| BKP-06 | Phase 4 | Pending |
| BKP-07 | Phase 4 | Pending |
| BUD-01 | Phase 2 | Pending |
| BUD-02 | Phase 2 | Pending |
| BUD-03 | Phase 2 | Pending |
| BUD-04 | Phase 2 | Pending |
| BUD-05 | Phase 2 | Pending |
| BUD-06 | Phase 2 | Pending |
| BUD-07 | Phase 2 | Pending |
| SAV-01 | Phase 3 | Pending |
| SAV-02 | Phase 3 | Pending |
| SAV-03 | Phase 3 | Pending |
| SAV-04 | Phase 3 | Pending |
| SAV-05 | Phase 3 | Pending |
| SAV-06 | Phase 3 | Pending |
| SAV-07 | Phase 3 | Pending |
| SAV-08 | Phase 3 | Pending |
| SAV-09 | Phase 3 | Pending |
| SAV-10 | Phase 3 | Pending |
| THM-01 | Phase 1 | ✅ Complete |
| THM-02 | Phase 1 | ✅ Complete |
| THM-03 | Phase 1 | ✅ Complete |
| THM-04 | Phase 1 | ✅ Complete |
| THM-05 | Phase 1 | ✅ Complete |
| THM-06 | Phase 1 | ✅ Complete |
| RPT-01 | Phase 5 | Pending |
| RPT-02 | Phase 5 | Pending |
| RPT-03 | Phase 5 | Pending |
| RPT-04 | Phase 5 | Pending |
| RPT-05 | Phase 5 | Pending |
| RPT-06 | Phase 5 | Pending |
| RPT-07 | Phase 5 | Pending |

**Coverage:**
- v2 requirements: 37 total
- Mapped to phases: 37
- Unmapped: 0 ✓

---
*Requirements defined: 2026-05-06*
*Last updated: 2026-05-07 after v2.0 Foundation milestone (6/37 complete)*
