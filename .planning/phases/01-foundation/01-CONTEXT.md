# Phase 1: Foundation - Context

**Gathered:** 2026-05-07
**Status:** Ready for planning

<domain>
## Phase Boundary

App has theme switching, database schema v3 with 3 new tables, and restructured navigation ready for v2 features. Specifically:
- Schema v2→v3 migration adding `budgets`, `savings_goals`, `goal_contributions` tables
- Full dark mode audit and glassmorphism redesign for dark theme
- Navigation restructure from 2 tabs to 2 functional tabs (Transaksi, Laporan) with infrastructure for 4-tab growth

This phase does NOT implement budgeting, savings goals, or enhanced reports — it prepares the foundation.

</domain>

<decisions>
## Implementation Decisions

### Navigation Restructure
- **D-01:** Summary (Ringkasan) tab merges into Reports (Laporan) tab. Current MonthlySummaryScreen content moves to Laporan tab as-is. Phase 5 will enhance it.
- **D-02:** Tab layout in Phase 1: **2 tabs** — Transaksi + Laporan. Budget and Goals tabs are HIDDEN until Phase 2 and Phase 3 implement them respectively. Do NOT show placeholder/empty state tabs.
- **D-03:** Tab order for final 4-tab layout: Transaksi → Anggaran → Tabungan → Laporan
- **D-04:** Tab icons: Transaksi (`receipt_long`), Anggaran (`account_balance_wallet`), Tabungan (`savings`), Laporan (`bar_chart`)
- **D-05:** Settings access moves to Laporan tab header (gear icon). Category management stays in Transaksi tab.
- **D-06:** FAB is context-aware — changes action per active tab: Add Transaction on Transaksi, hidden on Laporan. Phase 2 adds Add Budget on Anggaran, Phase 3 adds Add Goal on Tabungan.
- **D-07:** Navigation shell must support dynamic tab count — build with configurable branches so adding tabs in Phase 2/3 is a configuration change, not a refactor.

### Dark Mode Audit
- **D-08:** Full audit — check every screen and widget for hardcoded colors. Fix all issues. No shortcuts.
- **D-09:** Glassmorphism needs redesign for dark mode — not just alpha adjustments. Revisit blur radius, border treatment, shadow strategy for dark theme. Current dark alpha values are a starting point, not final.
- **D-10:** WCAG contrast verification is manual — use contrast checker tool on key color pairs during audit. No automated contrast tests.
- **D-11:** Dark theme colors must follow Material Design dark theme guidelines: #121212 background, elevated surfaces #1E1E1E/#2C2C2C, maintained accent colors (per THM-05).

### Schema v3 — Table Design
- **D-12:** Budgets table uses separate `year` (INTEGER) and `month` (INTEGER) columns. Unique constraint on `(category_id, year, month)` to enforce BUD-07 (one budget per category per month).
- **D-13:** Savings goals have a `current_amount` (REAL) column that is stored and kept in sync atomically with contributions. NOT computed from SUM on read.
- **D-14:** Contributions use amount sign for type — positive = contribution, negative = withdrawal. No separate type column needed.
- **D-15:** Goals use a `status` TEXT column with values: 'active', 'completed', 'cancelled'. Matches SAV-04 (soft delete) and SAV-08 (auto-completion).
- **D-16:** Running balance is a stored `running_balance` REAL column in goal_contributions. Updated atomically with each insert.
- **D-17:** Budgets have a DB-level constraint ensuring category_id references an expense-type category only. Not just UI validation.
- **D-18:** Migration is simple incremental — add 3 new tables + indexes in `onUpgrade()`. No existing data is modified. Same pattern as v1→v2.

### Agent's Discretion
- Exact column names for the 3 new tables (follow existing `TransactionFields`/`CategoryFields` pattern)
- Index selection beyond what REQUIREMENTS.md implies
- Glassmorphism redesign specifics (blur values, border colors, shadow approach)
- Which hardcoded colors to fix first during audit (prioritize by user impact)
- Tab transition animations

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Requirements & Roadmap
- `.planning/REQUIREMENTS.md` — All v2 requirements (THM-01 to THM-06, BUD-*, SAV-*)
- `.planning/ROADMAP.md` §Phase 1 — Phase goal, success criteria, plan list
- `.planning/PROJECT.md` — Tech stack constraints, key decisions, architecture context

### Architecture & Patterns
- `.planning/codebase/ARCHITECTURE.md` — System overview, data flow, key abstractions
- `.planning/codebase/CONVENTIONS.md` — Naming, coding style, Freezed/Riverpod patterns
- `.planning/codebase/STACK.md` — Dependencies, versions, platform requirements

### Theme & Navigation (existing code)
- `lib/presentation/utils/app_theme.dart` — Light and dark theme definitions
- `lib/presentation/utils/app_colors.dart` — Color system with dark mode helpers
- `lib/presentation/providers/theme/theme_provider.dart` — ThemeNotifier with persistence
- `lib/presentation/app/app_widget.dart` — Root widget, applies themeMode
- `lib/presentation/navigation/routes/app_router.dart` — Current 2-tab GoRouter config
- `lib/presentation/navigation/routes/app_routes.dart` — Route path constants

### Database (existing code)
- `lib/data/datasources/local/schema_manager.dart` — Schema v2, onCreate, onUpgrade pattern
- `lib/data/datasources/local/database_helper.dart` — Table name constants, connection singleton

### Design System
- `lib/presentation/utils/glassmorphism/` — Glass container components
- `lib/presentation/utils/responsive/` — AppSpacing, AppRadius
- `lib/presentation/widgets/base/base.dart` — Base widget exports
- `docs/v1/design/DESIGN_SYSTEM_GUIDE.md` — Glassmorphism design system guide

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `AppTheme.lightTheme` / `AppTheme.darkTheme`: Fully defined — no need to create from scratch. Dark theme already has surface, text, and component overrides.
- `AppColors` with `isDark` parameter methods (`getGlassSurface`, `getGlassCard`, `getGlassNavigation`, etc.): Pattern for theme-aware color selection already established.
- `ThemeNotifier` + `themeModeProvider`: Full Riverpod 3.x theme persistence via SharedPreferences. System/Light/Dark switching works.
- `StatefulShellRoute.indexedStack`: Current tab navigation pattern. Extensible to more branches.
- `DatabaseSchemaManager.onUpgrade()`: Incremental migration pattern (`if (oldVersion < N)`) — just add `if (oldVersion < 3)` block.
- `AppGlassNavigation`: Bottom nav wrapper with glassmorphism — already used for current 2-tab layout.
- `AppEmptyState`: Reusable empty state widget for placeholder screens.

### Established Patterns
- Repository Segregation (ISP): New features follow the same pattern — split interfaces per operation type.
- `TransactionFields` / `CategoryFields` pattern: Column name constants in dedicated classes. New tables should have `BudgetFields`, `SavingsGoalFields`, `GoalContributionFields`.
- Freezed 3.x with `abstract` keyword: All new entities use `@freezed abstract class`.
- Riverpod `@riverpod` with `build()` initialization: All new providers follow this pattern.
- `Result<T>` monad: All repository/use case operations return `Result<T>`.

### Integration Points
- `lib/presentation/navigation/routes/app_router.dart`: Add new StatefulShellBranch entries for Budget/Goals tabs (hidden until ready).
- `lib/data/datasources/local/schema_manager.dart`: Add `onCreate` table creation + `onUpgrade` migration for v3.
- `lib/data/datasources/local/database_helper.dart`: Add table name constants for new tables.
- `lib/presentation/utils/app_colors.dart`: Dark glassmorphism colors need redesign.
- `lib/presentation/app/app_widget.dart`: No changes needed — already applies `themeMode`.
- `lib/presentation/screens/settings_screen.dart`: Theme selector already exists.

</code_context>

<specifics>
## Specific Ideas

- No specific references or examples — decisions are based on codebase analysis and REQUIREMENTS.md

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 1-Foundation*
*Context gathered: 2026-05-07*
