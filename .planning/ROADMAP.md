# Roadmap: Catat Cuan v2

## Milestones

- ✅ **v2.0 Foundation** — Phase 1 (shipped 2026-05-07)
- 🚧 **v2.1 Budgeting & Goals** — Phases 2-3 (planned)
- 📋 **v2.2 Cloud & Reports** — Phases 4-5 (planned)
- 📋 **v2.3 Polish** — Phase 6 (planned)

## Phases

<details>
<summary>✅ v2.0 Foundation (Phase 1) — SHIPPED 2026-05-07</summary>

- [x] Phase 1: Foundation (3/3 plans) — completed 2026-05-07

</details>

### 🚧 v2.1 Budgeting & Goals (Planned)

- [ ] **Phase 2: Budgeting** — Per-category monthly budgets with alerts and progress tracking
- [ ] **Phase 3: Savings Goals** — Goals with contributions, progress, and confetti celebration

### 📋 v2.2 Cloud & Reports (Planned)

- [ ] **Phase 4: Cloud Backup** — Google Drive backup/restore with OAuth
- [ ] **Phase 5: Enhanced Reports** — Multi-timeframe charts with trend analysis

### 📋 v2.3 Polish (Planned)

- [ ] **Phase 6: Polish & Integration** — Unified home screen and cross-feature validation

## Phase Details

### Phase 2: Budgeting
**Goal**: Users can set monthly budgets per category and track spending against limits with alerts
**Depends on**: Phase 1
**Requirements**: BUD-01, BUD-02, BUD-03, BUD-04, BUD-05, BUD-06, BUD-07
**Success Criteria** (what must be TRUE):
  1. User can create, edit, and delete monthly budgets per expense category with amount validation and one-budget-per-category-per-month enforcement
  2. Budget spent amount updates in real-time as transactions are recorded, with progress percentage calculation
  3. User sees color-coded progress indicators per budget (green 0-75%, yellow 75-100%, red >100%)
  4. User receives in-app alerts exactly once when budget reaches 75% (warning), 100% (limit), and >100% (overspending)
  5. User sees budget overview card on home screen and can drill into budget vs actual comparison per category with transaction list

Plans:
- [ ] 02-01: Budget data layer — entity, repository interfaces, SQLite implementation
- [ ] 02-02: Budget tracking — real-time spent calculation, cross-aggregate query (transactions JOIN budgets)
- [ ] 02-03: Budget UI — CRUD screens, progress bars, alerts, home screen card, detail comparison view
**UI hint**: yes

### Phase 3: Savings Goals
**Goal**: Users can create savings goals, track progress with contributions, and celebrate completions
**Depends on**: Phase 1
**Requirements**: SAV-01, SAV-02, SAV-03, SAV-04, SAV-05, SAV-06, SAV-07, SAV-08, SAV-09, SAV-10
**Success Criteria** (what must be TRUE):
  1. User can create, update, and soft-delete savings goals with name, target amount, optional deadline, icon, and color
  2. User can add contributions and withdrawals to goals with atomic balance updates and running balance history
  3. Goal progress displays with color gradient (red 0-25%, orange 25-50%, yellow 50-75%, green 75-100%) and circular indicators
  4. Goal auto-completes when current amount reaches target, triggering confetti celebration
  5. User sees goals overview card on home screen with quick-add button and can view full contribution history per goal

Plans:
- [ ] 03-01: Savings goals data layer — entities, repository interfaces, SQLite implementation
- [ ] 03-02: Contribution system — atomic writes, contribution/withdrawal recording, running balance
- [ ] 03-03: Goals UI — goal list, CRUD screens, progress indicators, confetti celebration, home screen card
**UI hint**: yes

### Phase 4: Cloud Backup
**Goal**: Users can backup all data to Google Drive and restore it, with proper OAuth handling and error recovery
**Depends on**: Phase 2, Phase 3
**Requirements**: BKP-01, BKP-02, BKP-03, BKP-04, BKP-05, BKP-06, BKP-07
**Success Criteria** (what must be TRUE):
  1. User can authenticate with Google Account via OAuth 2.0 using drive.appdata scope (app-specific folder only)
  2. User can backup all data (transactions, categories, budgets, goals, contributions, settings) to Google Drive with progress indicator
  3. User can view list of available backups with metadata (date, size, device) and preview before restoring
  4. User can restore from backup with conflict handling (replace all or cancel)
  5. System handles OAuth token expiry with automatic refresh and all errors (network, quota, auth, corrupted file) with user-friendly Indonesian messages

Plans:
- [ ] 04-01: Auth layer — Google Sign-In OAuth, secure token storage, token refresh + retry pattern
- [ ] 04-02: Backup engine — serialize all tables to versioned JSON, upload to Drive with progress
- [ ] 04-03: Restore + management — backup list, preview, restore with conflict handling, auto-cleanup
**UI hint**: yes

### Phase 5: Enhanced Reports
**Goal**: Users can analyze spending across daily, weekly, monthly, and yearly views with interactive charts and trend projections
**Depends on**: Phase 2
**Requirements**: RPT-01, RPT-02, RPT-03, RPT-04, RPT-05, RPT-06, RPT-07
**Success Criteria** (what must be TRUE):
  1. User can switch between Daily, Weekly, Monthly, and Yearly report views via tab navigation with swipe gestures
  2. User sees time-appropriate visualizations for each period (daily summary, weekly 7-bar chart, monthly weekly bars, yearly 12-bar chart)
  3. User sees category breakdown with interactive pie chart and horizontal bar chart with tap-to-detail
  4. User sees month-over-month comparison with percentage change indicators and 6-month spending trend with burn rate projection
  5. Reports load within 2 seconds for 1 year of data using pre-aggregated SQL queries

Plans:
- [ ] 05-01: Report data layer — extend analytics repository with pre-aggregated SQL queries for all time frames
- [ ] 05-02: Chart components — bar charts, line charts, pie charts, trend indicators with fl_chart
- [ ] 05-03: Report UI — tabbed screen, period navigation, category breakdown, export to image
**UI hint**: yes

### Phase 6: Polish & Integration
**Goal**: All v2 features work cohesively with a unified home screen, cross-feature validation, and production readiness
**Depends on**: Phase 2, Phase 3, Phase 4, Phase 5
**Requirements**: *(no new requirements — integration phase)*
**Success Criteria** (what must be TRUE):
  1. Home screen displays unified layout with budget card, goals card, and quick actions coexisting without overcrowding (max 2-3 cards)
  2. All v2 features work correctly in end-to-end flows (budget + goal + backup + reports integration)
  3. App meets performance targets across all screens and feature interactions

Plans:
- [ ] 06-01: Unified home screen layout — design and implement holistic card arrangement
- [ ] 06-02: Cross-feature integration testing — end-to-end flows, edge cases, performance profiling
- [ ] 06-03: Documentation and release prep — update PROJECT_STATUS.md, final verify, version bump
**UI hint**: yes

## Progress

**Execution Order:**
Phases execute in numeric order: 2 → 3 (may parallelize) → 4 → 5 → 6
Note: Phases 2 and 3 are independent and may be parallelized.

| Phase | Milestone | Plans Complete | Status | Completed |
|-------|-----------|----------------|--------|-----------|
| 1. Foundation | v2.0 | 3/3 | Complete ✓ | 2026-05-07 |
| 2. Budgeting | v2.1 | 0/3 | Not started | - |
| 3. Savings Goals | v2.1 | 0/3 | Not started | - |
| 4. Cloud Backup | v2.2 | 0/3 | Not started | - |
| 5. Enhanced Reports | v2.2 | 0/3 | Not started | - |
| 6. Polish & Integration | v2.3 | 0/3 | Not started | - |

---
*Roadmap created: 2026-05-06*
*Last updated: 2026-05-07 after v2.0 Foundation milestone*
*Granularity: standard (6 phases)*
*Coverage: 37/37 requirements mapped ✓*
