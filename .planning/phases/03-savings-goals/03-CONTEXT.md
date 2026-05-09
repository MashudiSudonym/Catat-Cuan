# Phase 3: Savings Goals - Context

**Gathered:** 2026-05-09
**Status:** Ready for planning

<domain>
## Phase Boundary

Users can create savings goals, track progress with contributions (earmarks), and celebrate completions with confetti. Specifically:
- CRUD savings goals with name, target amount, optional deadline, icon, color (SAV-01, SAV-02, SAV-03)
- Soft-delete goals (status = cancelled) with preserved contribution history (SAV-04)
- Add contributions and withdrawals (earmarks) with atomic balance updates and running balance history (SAV-05, SAV-06)
- Color gradient progress with circular indicators: red 0-25%, orange 25-50%, yellow 50-75%, green 75-100% (SAV-07)
- Auto-completion with brief confetti celebration when current_amount reaches target (SAV-08)
- Goals overview card on home screen with quick-add bottom sheet (SAV-09)
- Contribution history per goal with date, type, amount, running balance, note (SAV-10)

This phase does NOT implement enhanced reports, cloud backup, goal templates, recurring contributions, or export — those are separate phases.

</domain>

<decisions>
## Implementation Decisions

### Contribution Semantics
- **D-01:** Contributions are earmarks — visual tracking only. A Rp 500K contribution to "New Phone" goal does NOT create a transaction or reduce available balance. The user's actual money is not affected; they just track "I've set aside Rp 500K for this goal."
- **D-02:** Withdrawals (SAV-06) are reverse earmarks — they reduce the goal's tracked current_amount. No transaction created. Withdrawal amount is capped at current_amount (floor at zero — current_amount can never go below 0).
- **D-03:** Each contribution/withdrawal is recorded as a row in goal_contributions. Positive amount = contribution, negative amount = withdrawal (per D-14 from Phase 1). running_balance is stored and updated atomically.

### Goal Creation & Editing
- **D-04:** Goal creation uses full-screen form (like Add Transaction screen). Fields: name, target amount, optional deadline, icon, color. Consistent with existing app pattern.
- **D-05:** Icon and color picker reused from existing Category management picker. Same Material Icons grid and color palette. Consistent UX, less code.
- **D-06:** Target date is optional — date field with "Tenggat Waktu (Opsional)" label. Empty by default. When set, shows days remaining on goal card.
- **D-07:** Goal editing uses same full-screen form pattern. Users can update name, target amount, deadline, icon, color — but NOT current_amount directly (per SAV-03). Current amount only changes via contributions/withdrawals.

### Home Screen Goals Card
- **D-08:** Goals card is stacked below the existing budget card on home screen. Both cards visible. Compact layout.
- **D-09:** Goals card shows compact summary: total saved / total target (overall %) with mini circular progress indicator. Tap card → navigate to Tabungan tab. Consistent with budget card pattern.
- **D-10:** Quick-add button on goals card opens inline bottom sheet with amount field + goal selector. Fast contribution without leaving home screen.

### Completion Celebration
- **D-11:** Brief confetti burst (2-3 seconds) on the goal detail screen when auto-completion is detected. Followed by "Selamat! Goal tercapai!" success message (SnackBar or dialog).
- **D-12:** Confetti triggers once on completion — subsequent views of completed goal show a checkmark/completion badge, no more confetti.
- **D-13:** Completed goals are view-only. Users can view goal details and contribution history, but cannot add more contributions. Status = 'completed' prevents further writes.

### Agent's Discretion
- Confetti library selection (pick appropriate Flutter confetti package)
- Exact confetti animation parameters (particle count, colors, direction)
- Circular progress indicator implementation details (size, stroke width)
- Contribution history list styling (timeline vs simple list)
- Empty state illustrations and copy for Tabungan tab
- Goal detail screen layout specifics
- Quick-add bottom sheet field arrangement

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Requirements & Roadmap
- `.planning/REQUIREMENTS.md` §Savings Goals — All savings requirements (SAV-01 to SAV-10) and deferred enhancements (SAV-F01 to SAV-F04)
- `.planning/ROADMAP.md` §Phase 3 — Phase goal, success criteria, plan list (03-01, 03-02, 03-03)
- `.planning/PROJECT.md` — Tech stack constraints, key decisions, architecture context

### Architecture & Patterns
- `.planning/codebase/ARCHITECTURE.md` — System overview, data flow, repository segregation pattern
- `.planning/codebase/CONVENTIONS.md` — Naming, Freezed/Riverpod patterns, error handling, design system usage
- `.planning/codebase/STACK.md` — Dependencies, versions, platform requirements

### Prior Phase Context
- `.planning/phases/01-foundation/01-CONTEXT.md` — Schema decisions (D-13: current_amount stored, D-14: amount sign, D-15: status values, D-16: running_balance stored), navigation decisions (D-04: tab order, D-06: FAB behavior, D-07: NavigationTabConfig)
- `.planning/phases/02-budgeting/02-CONTEXT.md` — Budget card pattern on home screen (D-08 to D-13), repository segregation pattern, alert mechanism, progress indicator approach

### Database (existing code)
- `lib/data/datasources/local/schema_manager.dart` — Schema v4 with savings_goals and goal_contributions tables already created. SavingsGoalFields and GoalContributionFields classes defined.
- `lib/data/datasources/local/database_helper.dart` — Table name constants (tableSavingsGoals, tableGoalContributions)

### Navigation (existing code)
- `lib/presentation/navigation/routes/app_router.dart` — NavigationTabConfig with Phase 3 comment. Add Tabungan branch. activeTabs currently has 3 tabs (Transaksi, Anggaran, Laporan) — needs 4th.
- `lib/presentation/navigation/routes/app_routes.dart` — Route path constants

### Design System
- `lib/presentation/utils/glassmorphism/` — Glass container components for goal cards
- `lib/presentation/utils/responsive/` — AppSpacing, AppRadius tokens
- `lib/presentation/widgets/base/base.dart` — Base widget exports
- `lib/presentation/utils/app_colors.dart` — Color system with theme-aware methods
- `lib/presentation/utils/error/error_message_mapper.dart` — For user-friendly Indonesian error messages
- `lib/presentation/utils/formatters/app_date_formatter.dart` — Date formatting for deadline display
- `lib/presentation/utils/currency_formatter.dart` — Rupiah formatting for amounts
- `docs/v1/design/DESIGN_SYSTEM_GUIDE.md` — Glassmorphism design system guide

### Existing Icon/Color Picker (reuse target)
- `lib/presentation/screens/category_form_screen.dart` — Category icon and color picker UI pattern

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `AppGlassContainer`: Glass card component for goal list items — consistent with budget cards and design system
- `AppEmptyState`: Reusable empty state widget — use for "no goals" state on Tabungan tab
- `AppColors` with theme-aware methods: Pattern for color-coded progress (red/orange/yellow/green gradient per SAV-07)
- `CurrencyFormatter`: Already formats Indonesian Rupiah — reuse for goal amounts
- `AppDateFormatter`: Date formatting — may need new method for deadline countdown display ("X hari lagi")
- `NavigationTabConfig`: Phase 1 infrastructure for adding tabs as config changes — add Tabungan as 4th tab
- `Category icon/color picker` from `category_form_screen.dart`: Reuse for goal icon/color selection per D-05
- Budget home card pattern: `BudgetHomeCard` widget structure — follow similar compact card pattern for Goals card
- Budget repository segregation: BudgetReadRepository, BudgetWriteRepository, etc. — follow same ISP pattern for SavingsGoal repositories

### Established Patterns
- Repository Segregation (ISP): Savings goals need separate interfaces — SavingsGoalReadRepository, SavingsGoalWriteRepository, SavingsGoalContributionRepository, SavingsGoalQueryRepository
- `SavingsGoalFields` / `GoalContributionFields`: Already defined in schema_manager.dart — use for all column references
- Freezed 3.x with `abstract` keyword: All savings goal entities use `@freezed abstract class`
- Riverpod `@riverpod` with `build()` initialization: All savings goal providers follow this pattern
- `Result<T>` monad: All repository/use case operations return `Result<T>`
- Schema migration pattern: If schema changes needed, increment currentVersion in SchemaManager and add migration block

### Integration Points
- `lib/presentation/navigation/routes/app_router.dart`: Add StatefulShellBranch for Tabungan tab (4th tab, currently commented/referenced but not active)
- `lib/data/datasources/local/schema_manager.dart`: Tables already exist. May need schema v5 if any column changes needed (unlikely based on D-13/D-14/D-15/D-16 decisions).
- `lib/data/datasources/local/database_helper.dart`: Table name constants already defined
- Home screen: Add goals summary card below budget card
- `lib/presentation/providers/repositories/repository_providers.dart`: Add savings goal repository providers
- `lib/presentation/providers/usecases/`: Add savings goal use case providers
- Contribution trigger: After transaction save does NOT trigger goal updates (earmarks are independent of transactions)

</code_context>

<specifics>
## Specific Ideas

No specific external references or examples — decisions are based on codebase analysis, REQUIREMENTS.md, and standard mobile savings goal UX patterns.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 3-Savings Goals*
*Context gathered: 2026-05-09*
