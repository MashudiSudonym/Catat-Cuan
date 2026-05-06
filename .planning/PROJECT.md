# Catat Cuan v2

## What This Is

Catat Cuan is a personal expense tracking Flutter app with OCR receipt scanning, built with clean architecture. v1 provides transaction recording, category management, monthly insights, CSV import/export, and home screen widgets — all offline with SQLite. v2 evolves the app from "visibility" to "control" by adding cloud backup, budgeting, savings goals, dark mode, and enhanced reports.

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

### Active

- [ ] Google Drive backup/restore with OAuth (REQ-BKP-001 to REQ-BKP-004)
- [ ] Full budgeting with per-category monthly budgets and alerts (REQ-BUD-001 to REQ-BUD-006)
- [ ] Savings goals with contributions, progress tracking, and celebration (REQ-SAV-001 to REQ-SAV-006)
- [ ] Dark mode with light/dark/system theme options (REQ-THM-001 to REQ-THM-006)
- [ ] Enhanced reports with daily/weekly/monthly/yearly views and interactive charts (REQ-RPT-001 to REQ-RPT-007)

### Out of Scope

- Real-time sync between devices — v2 is manual backup/restore only, sync deferred to v3
- Multi-user / family accounts — single-user personal app
- Business finance features — personal finance only
- Automatic bank/e-wallet integration — manual entry + OCR
- Multi-currency advanced — v1 basic IDR/USD sufficient
- Tax reporting — not applicable for personal use
- Investment tracking — out of scope for expense tracker

## Context

**Existing codebase:** Production-ready Flutter app with clean architecture (domain/data/presentation layers), Riverpod 3.3.1 state management, Freezed 3.x immutable entities, GoRouter navigation, SQLite via sqflite (schema v2). Repository segregation pattern with ISP compliance. 954 tests passing.

**Design system:** Glassmorphism-based UI with custom design tokens (AppSpacing, AppRadius, AppGlassContainer, AppEmptyState, AppDateFormatter). Indonesian locale (id_ID). Google Fonts for typography.

**Platform:** Android-primary (APK via GitHub Actions), iOS runner present but no custom native code. Fully offline, no server/cloud backend.

**v2 adds:** 3 new database tables (`budgets`, `savings_goals`, `goal_contributions`), new dependencies (google_sign_in, googleapis, flutter_secure_storage, confetti), and schema migration from v2 to v3. The PRD targets 2-3 months of development across 6 phases.

## Constraints

- **Tech Stack:** Flutter/Dart with Riverpod, Freezed, GoRouter, sqflite — must maintain consistency
- **Architecture:** Clean Architecture with repository segregation — all new features follow this pattern
- **Database:** SQLite (sqflite) — schema migration v2→v3, new tables for budgets/savings
- **Offline-first:** All features must work offline; Google Drive backup is manual, not real-time sync
- **Language:** UI in Bahasa Indonesia, code/docs bilingual (EN/ID)
- **Testing:** Maintain high test coverage; new features require unit tests following existing patterns
- **Code Generation:** Freezed 3.x requires `abstract` keyword; Riverpod 3.x initializes in `build()`
- **No secrets in UI:** Technical errors never shown to users — use ErrorMessageMapper

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Clean Architecture maintained | Proven pattern, 954 tests, SRP compliance | — Pending |
| Repository segregation for new features | Consistency with existing codebase | — Pending |
| SQLite for new tables (not Hive/Isar) | Consistency with existing data layer | — Pending |
| Manual backup only (no auto-sync) | Simplicity for v2, deferred complexity to v3 | — Pending |
| fl_chart for enhanced reports | Already in use for v1 charts | — Pending |
| Google Drive API with `drive.appdata` scope | Privacy-preserving, no access to user files | — Pending |

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
*Last updated: 2026-05-06 after initialization*
