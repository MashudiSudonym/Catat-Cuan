# Project Research Summary

**Project:** Catat Cuan v2
**Domain:** Personal finance expense tracker (Flutter) — v2 upgrade adding budgeting, savings goals, cloud backup, dark mode, and enhanced reports
**Researched:** 2026-05-06
**Confidence:** HIGH

## Executive Summary

Catat Cuan v2 extends a production-ready Flutter expense tracker (954 tests, 100% SRP compliance) with five major feature areas. The existing Clean Architecture with repository segregation is proven and well-suited — **no architectural changes are needed**, only extension. All v2 features map cleanly onto the domain/data/presentation layers that already exist.

The recommended approach is a 6-phase build starting with schema migration and dark mode foundation, then budgeting and savings goals in parallel, followed by cloud backup (which must serialize all tables), and finally enhanced reports. Only **5 new packages** are needed (`google_sign_in`, `googleapis`, `extension_google_sign_in_as_googleapis_auth`, `flutter_secure_storage`, `confetti`) — everything else uses existing dependencies. Dark mode requires zero new packages (existing `shared_preferences` + Flutter `ThemeData`).

The key risks are: (1) schema migration v2→v3 breaking existing production data, (2) Google OAuth token expiry causing silent backup failures, and (3) dark mode glassmorphism looking broken on existing screens due to hardcoded light-mode colors. All three are preventable with explicit testing strategies outlined below.

## Key Findings

### Recommended Stack

Only 5 new packages needed. Dark mode, enhanced reports, and budgeting require zero new dependencies.

**New packages (all HIGH confidence):**
- `google_sign_in ^7.2.0` — OAuth for Google Drive backup. v7 uses `GoogleSignIn.instance` singleton with scope-based authorization.
- `googleapis ^16.0.0` — Typed Dart client for Drive API v3. Use `drive.appdata` scope (hidden, no consent screen review).
- `extension_google_sign_in_as_googleapis_auth ^3.0.0` — The **only** supported bridge from `google_sign_in` to `googleapis` in Flutter. `googleapis_auth` explicitly warns against direct Flutter use.
- `flutter_secure_storage ^10.0.0` — Hardware-backed encryption for auth tokens (Keychain/KeyStore). Never store tokens in `shared_preferences`.
- `confetti ^0.8.0` — Goal completion celebration. Cap particles at 15–20 for performance.

**No new packages needed for:** Dark mode (use existing `shared_preferences` + Flutter `ThemeData`), Enhanced reports (use existing `fl_chart ^1.2.0`).

**Rejected alternatives:** `flex_color_scheme` (fights existing glassmorphism), `syncfusion_flutter_charts` (commercial, 5MB), `googleapis_auth` (docs say "Do NOT use with Flutter"), Firebase Cloud Storage (requires backend + billing).

### Expected Features

**Must have (table stakes):**
- Per-category monthly budgets with progress indicators — the #1 "control" feature users expect after visibility
- Budget overspending alerts (75%/100% thresholds) — budgets without alerts are decorative
- Savings goals with progress tracking — standard next step after expense tracking
- Dark mode with system follow — expected by default in 2026
- Cloud backup/restore — users lose phones; no backup = no trust
- Enhanced time-frame reports (daily/weekly/monthly/yearly) — trend context, not just raw numbers

**Should have (differentiators):**
- Goal completion confetti celebration — emotional attachment, memorable delight
- Spending velocity / burn rate indicator — proactive projection, not just reactive reporting
- Motivational messages at savings milestones (25%/50%/75%) — prevents goal abandonment
- Quick budget set from transaction list — ≤10 second contextual action
- Backup preview before restore — shows metadata before committing, reduces data-loss anxiety
- Projected savings completion date — linear projection from contribution velocity

**Explicitly defer:**
- Real-time cross-device sync — requires backend infrastructure, this is v3+
- Push notification budget alerts — Firebase Cloud Messaging is overkill; in-app alerts sufficient
- Budget rollover between months — adds complexity, confuses users expecting clean resets
- PDF report generation — image export covers 80% of value at 20% of cost
- Investment tracking — fundamentally different data model, dilutes expense tracker identity

### Architecture Approach

**Extend existing Clean Architecture. Do not refactor or introduce new patterns.** The domain/data/presentation structure with ISP-compliant repository segregation (4+ interfaces per entity) accommodates all v2 features. Dark mode infrastructure already exists (`AppTheme.darkTheme`, `AppColors.isDark`, `ThemeNotifier`) — the work is auditing existing widgets, not building from scratch.

**Major new components:**
1. **Budget aggregate** — 3 repository interfaces (`BudgetRead`, `BudgetWrite`, `BudgetTracking`), cross-aggregate query via SQL JOIN on transactions+budgets
2. **Savings Goals aggregate** — 4 repository interfaces (`GoalRead`, `GoalWrite`, `ContributionRead`, `ContributionWrite`), atomic contribution+goal update via `LocalDataSource.transaction()`
3. **Cloud Backup** — Domain service interfaces (`BackupService`, `AuthService`) with data-layer implementations using `google_sign_in` + `googleapis`
4. **Enhanced Reports** — Extend existing `TransactionAnalyticsRepository` with new query methods (not a new repository)
5. **Database migration v2→v3** — 3 new tables (`budgets`, `savings_goals`, `goal_contributions`) with indexes
6. **Navigation** — Expand from 2 tabs to 4 tabs (Transactions, Budget, Goals, Reports)

### Critical Pitfalls

1. **Schema migration breaks production data** — Test BOTH fresh install (onCreate) AND upgrade path (v2→v3). Never modify existing table columns. Keep `onCreate` in sync.
2. **Google OAuth token expires, backup silently fails** — Call `signInSilently()` before every Drive API call. Wrap calls in 401→re-auth→retry pattern. Never store raw access tokens.
3. **Hardcoded light-mode colors break dark mode** — Audit ALL existing widgets for `AppColors.surfaceLight`, `Colors.white`, hardcoded `Color(0xFF...)`. Replace with theme-aware `AppColors.getXxx(isDark:)` or `Theme.of(context)`.
4. **Budget alerts spam on every transaction** — Track last-notified threshold per budget per month. Fire once per threshold crossing, not per transaction.
5. **Backup format has no version stamp** — Embed schema version in JSON backup. Validate on restore. Handle v1→v3 and v2→v3 migration during restore.
6. **Contribution ≠ Transaction ambiguity** — Decide explicitly before coding: contributions are earmarks (visual tracking only) or real transactions (reduce available balance). Recommended: earmarks for v2 simplicity.

## Implications for Roadmap

### Phase 1: Foundation
**Rationale:** Schema migration unblocks all data features. Dark mode must be validated against ALL existing screens before new features add more surfaces. Navigation restructure sets the tab layout for all new features.
**Delivers:** Schema v3 (3 new tables + indexes), dark mode audit + glassmorphism fixes, 4-tab navigation
**Addresses:** Dark mode (table stakes), database foundation for budgeting/savings
**Avoids:** Pitfall #1 (migration breaks data), Pitfall #3 (hardcoded light colors), Pitfall #4 (broken glassmorphism on dark)

### Phase 2: Budgeting
**Rationale:** The #1 requested feature after expense visibility. Depends on Phase 1 schema only. Budget tracking is the cross-aggregate query pattern (transactions JOIN budgets) that feeds into Phase 5 reports.
**Delivers:** Budget CRUD, per-category monthly budgets, progress bars, overspending alerts
**Uses:** New `budgets` table, `BudgetTrackingRepository` with SQL aggregation, existing `fl_chart`
**Implements:** Budget aggregate with 3 repository interfaces, `BudgetWithProgressEntity` composite
**Avoids:** Pitfall #4 (alert spam — track notified threshold), Pitfall #5 (month rollover — explicit period field)

### Phase 3: Savings Goals
**Rationale:** Completes the "visibility → control → goals" user journey. Independent of budgeting — can run in parallel or swap order. Confetti celebration is low-risk delight.
**Delivers:** Goal CRUD, contributions/withdrawals, circular progress, confetti on completion, motivational milestones
**Uses:** New `savings_goals` + `goal_contributions` tables, `confetti ^0.8.0`, atomic `LocalDataSource.transaction()`
**Implements:** Savings Goal aggregate with 4 repository interfaces, `ConfettiCelebration` widget
**Avoids:** Pitfall #6 (contribution ambiguity — document earmark decision), Pitfall #7 (confetti jank — cap particles)

### Phase 4: Cloud Backup
**Rationale:** Must be built AFTER budgeting and savings goals are stable — backup serializes ALL tables including new v2 tables. Building earlier means rework when new tables are added. Google OAuth + Drive API is the highest-risk feature.
**Delivers:** Google Sign-In OAuth, backup to Drive appdata, restore with version validation, backup management
**Uses:** `google_sign_in`, `googleapis`, `extension_google_sign_in_as_googleapis_auth`, `flutter_secure_storage`
**Implements:** `BackupService` + `AuthService` domain interfaces, `GoogleDriveBackupServiceImpl`, backup state machine
**Avoids:** Pitfall #2 (token expiry — signInSilently + 401 retry), Pitfall #8 (no version stamp — embed schema version in JSON)

### Phase 5: Enhanced Reports
**Rationale:** Can overlap with Phase 4 since reports only READ transaction data (v1-stable). Budget vs Actual reports can be added as extension after Phase 2.
**Delivers:** Daily/weekly/monthly/yearly chart views, week-over-week comparison, spending velocity, category breakdown, chart export to image
**Uses:** Existing `fl_chart ^1.2.0`, extended `TransactionAnalyticsRepository`
**Implements:** New chart entities, report use cases, `EnhancedReportScreen` with tab navigation
**Avoids:** Pitfall #9 (fl_chart performance — pre-aggregate in SQL, limit data points, skip animation for heavy charts)

### Phase 6: Polish & Integration
**Rationale:** Final integration pass — home screen layout, cross-feature alerts, performance optimization, comprehensive testing.
**Delivers:** Unified home screen (budget status + goal quick actions, max 2-3 cards), budget alert post-hooks, integration tests, documentation update
**Avoids:** Pitfall #10 (home screen overload — design unified layout first, max 2-3 cards)

### Phase Ordering Rationale

- **Schema first:** All data features depend on the v3 schema. Building this first prevents rework.
- **Dark mode early:** Every new screen benefits from theme-aware components. Auditing existing widgets before adding new ones prevents double-work.
- **Budgeting and Goals are independent:** They share no tables or repositories. Can be parallelized.
- **Backup last among data features:** It serializes all tables. Building it after budgets/goals are stable avoids rework.
- **Reports are mostly independent:** They read v1 transaction data. Budget vs Actual is a Phase 5 extension.

### Research Flags

**Phases needing deeper research during planning:**
- **Phase 4 (Cloud Backup):** Google OAuth edge cases (token refresh, revoked access, multiple accounts), Drive API quota limits, conflict resolution strategy. Needs real-device testing.
- **Phase 5 (Enhanced Reports):** fl_chart interactive chart patterns for specific report types. SQL aggregation queries need performance profiling with realistic data volumes.

**Phases with standard patterns (skip deep research):**
- **Phase 1 (Foundation):** Schema migration follows existing `SchemaManager.onUpgrade()` pattern. Dark mode uses existing `AppTheme` + `ThemeNotifier`.
- **Phase 2 (Budgeting):** Standard CRUD + tracking. Repository segregation follows existing Category/Transaction patterns.
- **Phase 3 (Savings Goals):** Nearly identical pattern to budgeting. Confetti is a well-documented package.
- **Phase 6 (Polish):** Integration testing follows existing 954-test patterns.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | All packages verified via Context7 docs + pub.dev. Official Google packages for auth/Drive. |
| Features | HIGH | Sourced from project's own PRD and SPEC documents. Competitive analysis against real apps. |
| Architecture | HIGH | Analyzed existing codebase directly. 954 tests prove the architecture works. Dark mode infrastructure already exists. |
| Pitfalls | HIGH | Codebase-verified (schema_manager, app_theme, app_colors). Official docs for Google OAuth and Drive API. |

**Overall confidence:** HIGH

### Gaps to Address

- **Contribution semantics:** Must decide before Phase 3 whether contributions are earmarks or real transactions. Recommended: earmarks. Document the decision.
- **Home screen layout:** Must be designed holistically before any feature adds cards. PRD lists budget card AND goal card — need a unified mockup with max 2-3 cards.
- **Google Cloud Console setup:** OAuth Client ID creation and Drive API enablement are manual steps outside the codebase. Must be done before Phase 4 can be tested on real devices.
- **Backup conflict resolution:** PRD mentions conflict handling but doesn't specify strategy (last-write-wins? merge? user chooses?). Needs design decision before Phase 4.
- **Budget alert tracking schema:** Whether to use a `budget_alerts` table or a `settings` field for tracking "last notified threshold" needs to be decided during Phase 2 planning.

## Sources

### Primary (HIGH confidence)
- Context7: `google_sign_in` docs — v7.2.0 API, scope authorization, `signInSilently()`
- Context7: `flutter_secure_storage` docs — v10.0.0, hardware-backed encryption
- Context7: `fl_chart` docs — BarChart, LineChart, PieChart constructors
- Context7: `confetti` docs — ConfettiWidget, ConfettiController, particle customization
- Context7: `riverpod` docs — provider invalidation, keepAlive semantics
- Context7: `sqflite` docs — onUpgrade batch migration patterns
- pub.dev: `googleapis ^16.0.0`, `extension_google_sign_in_as_googleapis_auth ^3.0.0` — verified API compatibility
- Google Developers: Drive API appDataFolder documentation — behavior, constraints, uninstall deletion
- Google Identity: OAuth token lifecycle — access token expiry, refresh patterns
- Project PRD: `docs/v2/product/00-PRD.md` — feature requirements and user stories
- Project Specs: `docs/v2/product/01-*` through `05-*` — detailed acceptance criteria
- Existing codebase: `lib/domain/`, `lib/data/`, `lib/presentation/` — architecture patterns verified against source

### Secondary (MEDIUM confidence)
- fl_chart performance with large datasets — community consensus, no official perf docs
- Google Drive appDataFolder deletion on uninstall — documented behavior, no local test possible

---
*Research completed: 2026-05-06*
*Ready for roadmap: yes*
