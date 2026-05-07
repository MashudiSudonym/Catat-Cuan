# Phase 2: Budgeting - Context

**Gathered:** 2026-05-07
**Status:** Ready for planning

<domain>
## Phase Boundary

Users can set monthly budgets per expense category and track spending against limits with real-time updates, color-coded progress indicators, in-app alerts, a home screen summary card, and a drill-down budget vs actual comparison view with transaction lists.

Specifically:
- CRUD monthly budgets per expense category with amount validation and one-budget-per-category-per-month enforcement (BUD-01, BUD-07)
- Real-time spent amount calculation as transactions are recorded, with progress percentage (BUD-02)
- Color-coded progress indicators per budget: green 0-75%, yellow 75-100%, red >100% (BUD-03)
- In-app SnackBar alerts exactly once when budget reaches 75%, 100%, >100% (BUD-04)
- Budget overview card on home screen showing total budget, total spent, remaining, overspending count (BUD-05)
- Budget vs actual comparison per category with expandable transaction list (BUD-06)

This phase does NOT implement savings goals, enhanced reports, cloud backup, or budget rollover — those are separate phases.

</domain>

<decisions>
## Implementation Decisions

### Alert Delivery Mechanism
- **D-01:** Budget alerts use SnackBar — consistent with existing app UX. Appears briefly at bottom, does not block workflow.
- **D-02:** Already-shown tracking uses DB fields on the budget record (e.g., `warning_shown_at`, `limit_shown_at`, `overshown_at` or a single `alert_status` field). Persists across sessions, survives app restart.
- **D-03:** Alert check triggers after each transaction save — most responsive timing. User sees alert right when overspending happens.

### Month Navigation & Creation
- **D-04:** Month navigation uses swipe + arrow buttons. Standard mobile pattern consistent with Laporan tab.
- **D-05:** Anggaran tab auto-shows current month. User can add budgets for any month from there. No budgets = show empty state with "Tambah Anggaran" prompt.
- **D-06:** Users can create budgets for any month — past, current, or future. Past budgets show historical spending vs limits.
- **D-07:** New month budgets are manual — no auto-carryover. User creates budgets per month. (Copy-from-previous-month is deferred to BUD-F01.)

### Home Screen Budget Card
- **D-08:** Budget card on home screen shows summary: total budget, total spent, remaining amount, overspending category count. Compact single card.
- **D-09:** Tapping the budget card navigates to Anggaran tab (not a detail screen or bottom sheet).
- **D-10:** Budget card only appears when budgets exist for the current month. No card if no budgets — avoids empty state on home screen.

### Budget vs Actual Detail View
- **D-11:** Budget vs actual comparison uses glass cards with progress bars per category — consistent with app design system. Each card shows category name/icon, budget amount, spent amount, remaining, and color-coded progress.
- **D-12:** Tapping a budget card expands it inline to show the transaction list for that category within the budget month. No navigation to separate screen.
- **D-13:** Budget categories ordered by % spent descending — highest spending ratios first. Overshadowed categories naturally rise to top.

### Agent's Discretion
- Exact SnackBar styling and duration for alerts
- Alert status field design (separate columns vs single status enum)
- Progress bar visual details (rounded, animated, etc.)
- Empty state illustration and copy for Anggaran tab
- Card animation on expand/collapse for transaction list
- Month navigation transition animation

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Requirements & Roadmap
- `.planning/REQUIREMENTS.md` §Budgeting — All budget requirements (BUD-01 to BUD-07) and deferred enhancements (BUD-F01 to BUD-F04)
- `.planning/ROADMAP.md` §Phase 2 — Phase goal, success criteria, plan list (02-01, 02-02, 02-03)
- `.planning/PROJECT.md` — Tech stack constraints, key decisions, architecture context

### Architecture & Patterns
- `.planning/codebase/ARCHITECTURE.md` — System overview, data flow, repository segregation pattern
- `.planning/codebase/CONVENTIONS.md` — Naming, Freezed/Riverpod patterns, error handling, design system usage
- `.planning/codebase/STACK.md` — Dependencies, versions, platform requirements

### Prior Phase Context
- `.planning/phases/01-foundation/01-CONTEXT.md` — Schema v3 decisions (D-12: year+month columns, D-17: expense-type constraint), navigation decisions (tab order, icons, FAB behavior)

### Database (existing code)
- `lib/data/datasources/local/schema_manager.dart` — Schema v3 with budgets table already created. Column definitions and indexes.
- `lib/data/datasources/local/database_helper.dart` — Table name constants, connection singleton

### Navigation (existing code)
- `lib/presentation/navigation/routes/app_router.dart` — Current StatefulShellRoute config. Add Anggaran branch here.
- `lib/presentation/navigation/routes/app_routes.dart` — Route path constants

### Design System
- `lib/presentation/utils/glassmorphism/` — Glass container components for budget cards
- `lib/presentation/utils/responsive/` — AppSpacing, AppRadius tokens
- `lib/presentation/widgets/base/base.dart` — Base widget exports
- `lib/presentation/utils/app_colors.dart` — Color system with theme-aware methods
- `lib/presentation/utils/error/error_message_mapper.dart` — For user-friendly Indonesian error messages
- `lib/presentation/utils/formatters/app_date_formatter.dart` — Date formatting for month labels
- `lib/presentation/utils/currency_formatter.dart` — Rupiah formatting for amounts
- `docs/v1/design/DESIGN_SYSTEM_GUIDE.md` — Glassmorphism design system guide

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `AppGlassContainer`: Glass card component for budget list items — consistent with existing design system
- `AppEmptyState`: Reusable empty state widget — use for "no budgets" state on Anggaran tab
- `AppColors` with theme-aware methods (`getGlassSurface`, `getGlassCard`, etc.): Pattern for color-coded progress (green/yellow/red) needs new methods or direct Material color usage
- `CurrencyFormatter`: Already formats Indonesian Rupiah — reuse for budget amounts
- `AppDateFormatter`: Month/year formatting — may need new method for "Mei 2026" format
- `TransactionAnalyticsRepository`: Already has monthly summary queries — budget spent calculation extends this
- `NavigationTabConfig`: Phase 1 infrastructure for adding tabs as config changes — use to add Anggaran tab

### Established Patterns
- Repository Segregation (ISP): Budget needs separate interfaces — BudgetReadRepository, BudgetWriteRepository, BudgetQueryRepository (spent calculation), BudgetAlertRepository (alert tracking)
- `TransactionFields` / `CategoryFields` pattern: Create `BudgetFields` class for column name constants
- Freezed 3.x with `abstract` keyword: All budget entities use `@freezed abstract class`
- Riverpod `@riverpod` with `build()` initialization: All budget providers follow this pattern
- `Result<T>` monad: All budget repository/use case operations return `Result<T>`
- Strategy Pattern: May use for alert threshold checking (75% vs 100% vs >100% strategies)

### Integration Points
- `lib/data/datasources/local/schema_manager.dart`: Budgets table already exists in schema v3. May need alert_status columns added.
- `lib/presentation/navigation/routes/app_router.dart`: Add StatefulShellBranch for Anggaran tab (currently hidden in Phase 1)
- `lib/presentation/navigation/providers/router_provider.dart`: Watch budget providers if needed for routing
- `lib/presentation/providers/transaction/`: After transaction save — trigger budget alert check (use case or controller integration)
- `lib/presentation/screens/transaction_list_screen.dart` or home screen: Add budget summary card widget
- `lib/presentation/utils/app_colors.dart`: Add budget-specific color methods (progress green/yellow/red)

</code_context>

<specifics>
## Specific Ideas

No specific external references or examples — decisions are based on codebase analysis, REQUIREMENTS.md, and standard mobile budgeting UX patterns.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 2-Budgeting*
*Context gathered: 2026-05-07*
