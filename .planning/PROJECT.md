# Catat Cuan v2

## What This Is

Catat Cuan is a personal expense tracking Flutter app with OCR receipt scanning, built with clean architecture. v1 provides transaction recording, category management, monthly insights, CSV import/export, and home screen widgets — all offline with SQLite. v2 evolves the app from "visibility" to "control" by adding budgeting, savings goals, cloud backup, dark mode, and enhanced reports.

## Core Value

Users can control their finances — not just see them. Budgets prevent overspending, savings goals create motivation, and backup ensures data safety.

## Requirements

### Validated

- ✓ Transaction CRUD with amount, category, date, note — v1
- ✓ Category management with icons and colors — v1
- ✓ OCR receipt scanning via ML Kit — v1
- ✓ Monthly summary with basic insights — v1
- ✓ CSV import/export — v1
- ✓ Search and filter transactions — v1
- ✓ Home screen widgets (Android) — v1
- ✓ Onboarding flow — v1
- ✓ Clean architecture with repository segregation — v1
- ✓ 954 tests, 100% SRP compliance — v1
- ✓ Theme switching (Light/Dark/System) with instant switch — v2.0
- ✓ Theme persistence across sessions — v2.0
- ✓ Dark mode glassmorphism with adjusted blur and alpha — v2.0
- ✓ System Default theme follows device in real-time — v2.0
- ✓ Material Design dark colors with maintained accents — v2.0
- ✓ WCAG contrast ratios in both themes — v2.0

### Active

- [ ] Google Drive backup/restore with OAuth (BKP-01 to BKP-007)
- [ ] Full budgeting with per-category monthly budgets and alerts (BUD-01 to BUD-07)
- [ ] Savings goals with contributions, progress tracking, and celebration (SAV-01 to SAV-10)
- [ ] Enhanced reports with daily/weekly/monthly/yearly views and interactive charts (RPT-01 to RPT-07)

### Out of Scope

- Real-time sync between devices — v2 is manual backup/restore only, sync deferred to v3
- Multi-user / family accounts — single-user personal app
- Business finance features — personal finance only
- Automatic bank/e-wallet integration — manual entry + OCR
- Multi-currency advanced — v1 basic IDR/USD sufficient
- Tax reporting — not applicable for personal use
- Investment tracking — out of scope for expense tracker
- Push notifications — in-app alerts sufficient for v2; push requires Firebase infrastructure
- PDF report export — image export covers 80% of sharing use case at 20% cost

## Context

**Existing codebase:** Production-ready Flutter app with clean architecture (domain/data/presentation layers), Riverpod 3.3.1 state management, Freezed 3.x immutable entities, GoRouter navigation, SQLite via sqflite (schema v3). Repository segregation pattern with ISP compliance. 969 tests passing.

**v2.0 shipped:** Database schema v3 with budgets, savings_goals, goal_contributions tables. Dark mode glassmorphism across all screens. 2-tab navigation with dynamic NavigationTabConfig. Zero hardcoded Colors.grey/black.

**Design system:** Glassmorphism-based UI with custom design tokens (AppSpacing, AppRadius, AppGlassContainer, AppEmptyState, AppDateFormatter). Indonesian locale (id_ID). Google Fonts for typography. Theme-aware colors via AppColors methods.

**Platform:** Android-primary (APK via GitHub Actions), iOS runner present but no custom native code. Fully offline, no server/cloud backend.

**Known blockers:**
- Phase 4 (Cloud Backup) requires Google Cloud Console OAuth Client ID setup (manual step)
- Phase 3 (Savings Goals) needs contribution semantics decision (earmarks vs real transactions)

## Constraints

- **Tech Stack:** Flutter/Dart with Riverpod, Freezed, GoRouter, sqflite — must maintain consistency
- **Architecture:** Clean Architecture with repository segregation — all new features follow this pattern
- **Database:** SQLite (sqflite) — schema v3, budgets/savings tables ready
- **Offline-first:** All features must work offline; Google Drive backup is manual, not real-time sync
- **Language:** UI in Bahasa Indonesia, code/docs bilingual (EN/ID)
- **Testing:** Maintain high test coverage; new features require unit tests following existing patterns
- **Code Generation:** Freezed 3.x requires `abstract` keyword; Riverpod 3.x initializes in `build()`
- **No secrets in UI:** Technical errors never shown to users — use ErrorMessageMapper

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Clean Architecture maintained | Proven pattern, 969 tests, SRP compliance | ✓ Good |
| Repository segregation for new features | Consistency with existing codebase | — Pending (Phase 2+) |
| SQLite for new tables (not Hive/Isar) | Consistency with existing data layer | ✓ Good |
| Manual backup only (no auto-sync) | Simplicity for v2, deferred complexity to v3 | — Pending (Phase 4) |
| fl_chart for enhanced reports | Already in use for v1 charts | — Pending (Phase 5) |
| Google Drive API with `drive.appdata` scope | Privacy-preserving, no access to user files | — Pending (Phase 4) |
| SQLite CHECK via repository layer | SQLite doesn't support subqueries in CHECK constraints | ✓ Good |
| sqflite_common_ffi for DB tests | Real database integration tests, not just mocks | ✓ Good |
| NavigationTabConfig pattern | Phase 2/3 tab additions as config changes only | ✓ Good |
| On-primary Colors.white kept as-is | Correct Material Design contrast | ✓ Good |
| 2-tab layout in Phase 1 | Start simple, grow to 4 tabs in Phase 2/3 | ✓ Good |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-05-07 after v2.0 Foundation milestone*
