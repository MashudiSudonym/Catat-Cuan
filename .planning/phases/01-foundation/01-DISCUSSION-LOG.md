# Phase 1: Foundation - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-07
**Phase:** 1-Foundation
**Areas discussed:** Navigation restructure, Dark mode audit scope, New table schemas, Budget category scope, Migration safety

---

## Navigation Restructure

### Summary tab disposition

| Option | Description | Selected |
|--------|-------------|----------|
| Merge into Reports | Summary content becomes part of Reports tab. Phase 5 extends it later. | ✓ |
| Keep as separate tab | 5 tabs total: Transactions, Summary, Budget, Goals, Reports | |
| Replace with Reports | Summary tab becomes Reports tab immediately. | |

**Notes:** Clean 4-tab layout from the start. Phase 5 will enhance the Reports tab.

### Settings access

| Option | Description | Selected |
|--------|-------------|----------|
| Keep in AppBar | Settings icon on TransactionListScreen appBar, same as now | |
| Move to profile/tab more | "Lainnya" section for 4-5 tab apps | ✓ |
| App-level drawer | Hamburger menu accessible from any screen | |

**Notes:** Settings goes to Laporan tab header. Category management stays in Transaksi tab.

### FAB behavior

| Option | Description | Selected |
|--------|-------------|----------|
| Context-aware FAB | Changes action per tab | ✓ |
| Always add transaction | FAB always adds transaction regardless of tab | |
| Hide on non-transaction | FAB only shows on Transactions tab | |

**Notes:** Add Transaction on Transaksi, Add Budget on Anggaran (Phase 2), Add Goal on Tabungan (Phase 3), hidden on Laporan.

### Tab order

| Option | Description | Selected |
|--------|-------------|----------|
| Transaksi, Anggaran, Tabungan, Laporan | Transaction-centric — most-used first | ✓ |
| Transaksi, Laporan, Anggaran, Tabungan | View-first — see data then manage | |

### Tab icons

| Option | Description | Selected |
|--------|-------------|----------|
| account_balance_wallet + savings | Clear financial meaning | ✓ |
| pie_chart + flag | More abstract but distinctive | |

### Empty tab strategy

| Option | Description | Selected |
|--------|-------------|----------|
| Empty state with info | "Fitur segera hadir" placeholder | |
| Hidden until ready | Start with 2 tabs, add more per phase | ✓ |

**Notes:** Phase 1 starts with 2 tabs (Transaksi, Laporan). Budget tab added in Phase 2, Goals in Phase 3.

### Laporan tab content (Phase 1)

| Option | Description | Selected |
|--------|-------------|----------|
| Current Summary content | Move MonthlySummaryScreen as-is | ✓ |
| Simplified overview | Just current month summary | |

---

## Dark Mode Audit Scope

### Audit depth

| Option | Description | Selected |
|--------|-------------|----------|
| Full audit + fix | Every screen and widget, fix all issues | ✓ |
| Main flows only | Primary user flows only | |

### Glassmorphism approach

| Option | Description | Selected |
|--------|-------------|----------|
| Keep current dark values | Just audit for widgets not using helpers | |
| Redesign dark glass | Different blur radius, border, shadow for dark theme | ✓ |

**Notes:** Current dark alpha values are starting point, not final. Full redesign needed.

### WCAG testing

| Option | Description | Selected |
|--------|-------------|----------|
| Manual verification | Contrast checker tool on key color pairs | ✓ |
| Automated contrast tests | Tests that compute contrast ratios | |

---

## New Table Schemas

### Schema design approach

| Option | Description | Selected |
|--------|-------------|----------|
| Design now | Define exact columns, types, constraints, indexes | ✓ |
| Let researcher derive | REQUIREMENTS.md has enough detail | |

### Budget month representation

| Option | Description | Selected |
|--------|-------------|----------|
| Separate year + month cols | INTEGER year, INTEGER month. Easier range queries | ✓ |
| Single date TEXT column | 'YYYY-MM' string | |

### Savings current_amount

| Option | Description | Selected |
|--------|-------------|----------|
| Stored + kept in sync | Fast reads, careful transaction handling | ✓ |
| Computed from contributions | Simpler writes, slower reads | |
| Both (denormalized) | Redundancy for safety | |

### Contribution type tracking

| Option | Description | Selected |
|--------|-------------|----------|
| Amount sign only | Positive = contribution, negative = withdrawal | ✓ |
| Type enum + positive amount | Separate type column, amount always positive | |

### Goal soft delete

| Option | Description | Selected |
|--------|-------------|----------|
| Status enum | 'active', 'completed', 'cancelled' | ✓ |
| deleted_at timestamp | NULL = active, non-null = deleted | |

### Running balance

| Option | Description | Selected |
|--------|-------------|----------|
| Stored per row | Updated atomically with each insert | ✓ |
| Computed on read | Window function SUM() OVER | |

---

## Budget Category Scope

| Option | Description | Selected |
|--------|-------------|----------|
| DB constraint | CHECK/trigger for expense-only categories | ✓ |
| UI validation only | Category picker shows only expense categories | |

---

## Migration Safety

| Option | Description | Selected |
|--------|-------------|----------|
| Simple incremental migration | Add tables in onUpgrade(), no existing data touched | ✓ |
| Add transaction backup | Export data as safety net before migration | |

---

## Agent's Discretion

- Exact column names for 3 new tables
- Index selection beyond what REQUIREMENTS.md implies
- Glassmorphism redesign specifics (blur values, border colors, shadow)
- Which hardcoded colors to fix first (prioritize by user impact)
- Tab transition animations

## Deferred Ideas

None — discussion stayed within phase scope.
