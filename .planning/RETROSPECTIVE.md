# Retrospective

## Cross-Milestone Trends

| Metric | v2.0 Foundation |
|--------|----------------|
| Phases | 1 |
| Plans | 3 |
| Duration | 24 min |
| Files changed | 83 |
| Tests | 969 |
| Requirements validated | 6/37 |
| Avg plan duration | 8 min |
| Deviations | 1 auto-fixed |

---

## Milestone: v2.0 — Foundation

**Shipped:** 2026-05-07
**Phases:** 1 | **Plans:** 3

### What Was Built
- Schema v3 with budgets, savings_goals, goal_contributions tables and v2→v3 migration
- Dark mode glassmorphism across all screens with theme-aware AppColors
- 2-tab navigation (Transaksi + Laporan) with dynamic NavigationTabConfig
- 15 new schema tests using sqflite_common_ffi

### What Worked
- **Research-first approach:** Deep research (STACK, FEATURES, ARCHITECTURE, PITFALLS) before any code meant plans were accurate and required zero rework
- **Schema-first ordering:** Migrating the database first ensured Phase 2/3 data layers have tables ready
- **NavigationTabConfig pattern:** Abstraction that lets Phase 2/3 add tabs without touching router code
- **sqflite_common_ffi auto-fix:** Discovered missing test dependency during execution, fixed immediately without blocking

### What Was Inefficient
- **All commits on main:** No feature branching — made PR creation require manual branch setup post-hoc
- **Planning docs overhead:** 31 of 33 commits included docs (plans, summaries, state updates) alongside code. Consider separating planning commits from feature commits for cleaner history.

### Patterns Established
- **Field constant classes** — BudgetFields, SavingsGoalFields, GoalContributionFields for each table
- **Theme-aware colors** — Use AppColors.textTertiary/textSecondary instead of Colors.grey
- **Dynamic tab config** — NavigationTabConfig + activeTabs for scalable navigation
- **Context-aware FAB** — activeTabs[currentIndex].showFab drives FAB visibility

### Key Lessons
1. **Branch from the start** — Even for solo projects, feature branches make PR creation trivial
2. **Schema migration tests need real DB** — Mocks can't test SQL constraints; sqflite_common_ffi is essential
3. **UI-SPEC before implementation** — Having specific alpha values (surface 0.90, border 0.12, shadow 0.18) meant zero design iteration during execution
