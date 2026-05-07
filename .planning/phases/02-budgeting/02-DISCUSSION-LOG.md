# Phase 2: Budgeting - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-07
**Phase:** 2-Budgeting
**Areas discussed:** Alert delivery mechanism, Month navigation & creation, Home screen budget card, Budget vs Actual detail

---

## Alert Delivery Mechanism

| Option | Description | Selected |
|--------|-------------|----------|
| SnackBar | Familiar pattern already used in the app. Appears briefly at bottom, doesn't block workflow. | ✓ |
| Dialog | Modal popup that requires dismissal. More prominent but interrupts the user. | |
| Persistent banner | Stays visible until dismissed. Good for ongoing warnings but adds UI complexity. | |

**User's choice:** SnackBar

| Option | Description | Selected |
|--------|-------------|----------|
| DB field on budget | Add alert_status fields to budgets table. Persists across sessions. | ✓ |
| SharedPreferences flags | Store flags in SharedPreferences. Simpler but less robust. | |
| In-memory only | Track during session only. Resets on restart. | |

**User's choice:** DB field on budget

| Option | Description | Selected |
|--------|-------------|----------|
| After transaction save | Check thresholds immediately after recording a transaction. Most responsive. | ✓ |
| On budget screen load | Check when user opens Anggaran tab. Simpler but delayed. | |
| Both | Check after save AND on screen load. Most thorough but adds complexity. | |

**User's choice:** After transaction save

---

## Month Navigation & Creation

| Option | Description | Selected |
|--------|-------------|----------|
| Swipe + arrows | Current month default, swipe/arrows to navigate. Standard mobile pattern. | ✓ |
| Month picker dialog | Tap month label to open picker. Explicit but slower for adjacent months. | |
| Both | Swipe/arrows AND tap-to-pick. Most flexible but more UI. | |

**User's choice:** Swipe + arrows

| Option | Description | Selected |
|--------|-------------|----------|
| Auto-show current, add any | Current month shows, user taps + to add budget for any month. | ✓ |
| Show only budgeted months | Only months with budgets are visible. | |
| Always show current month | Always show current month even if no budgets. | |

**User's choice:** Auto-show current, add any

| Option | Description | Selected |
|--------|-------------|----------|
| Any month | Past, current, future months. Useful for planning. | ✓ |
| Current & future only | Prevents historical clutter. | |
| Current month only | Simplest but most restrictive. | |

**User's choice:** Any month

| Option | Description | Selected |
|--------|-------------|----------|
| Manual per month | User creates new budgets each month. Full control. | ✓ |
| Copy from previous month | Option to copy last month's budgets. Reduces setup. | |
| Auto-recurring | Automatically create same budgets each month. | |

**User's choice:** Manual per month

---

## Home Screen Budget Card

| Option | Description | Selected |
|--------|-------------|----------|
| Summary card | Total budget, total spent, remaining, overspending count. Compact. | ✓ |
| Multi-row with mini bars | Top 3-4 categories with mini progress bars. More detail. | |
| Circular progress ring | Overall percentage ring. Visual but harder to read. | |

**User's choice:** Summary card

| Option | Description | Selected |
|--------|-------------|----------|
| Navigate to Anggaran tab | Tap card to go to Anggaran tab. Simple. | ✓ |
| Expand inline (bottom sheet) | Bottom sheet with per-category breakdown. | |
| Dedicated detail screen | Separate route for budget detail. | |

**User's choice:** Navigate to Anggaran tab

| Option | Description | Selected |
|--------|-------------|----------|
| Only when budgets exist | No card if no budgets. Avoids empty state on home. | ✓ |
| Always show with empty state | Always show, prompts user to create budgets. | |

**User's choice:** Only when budgets exist

---

## Budget vs Actual Detail

| Option | Description | Selected |
|--------|-------------|----------|
| Cards with progress | Glass cards with progress bars per category. Consistent with design system. | ✓ |
| Table layout | Columns for category, budget, spent, remaining, %. Compact. | |
| Bar chart comparison | Horizontal bar chart per category. Visual but harder to read. | |

**User's choice:** Cards with progress

| Option | Description | Selected |
|--------|-------------|----------|
| Expand card inline | Tap to expand, showing transactions inline. Contextual. | ✓ |
| Bottom sheet | Bottom sheet with transaction list. Familiar pattern. | |
| Separate screen | Navigate to category transaction screen. Most space. | |

**User's choice:** Expand card inline

| Option | Description | Selected |
|--------|-------------|----------|
| By % spent descending | Highest ratios first. Natural priority view. | ✓ |
| Alphabetical | Predictable, easy to scan. | |
| Alerts first, then alphabetical | Surfaces problems first. | |

**User's choice:** By % spent descending

---

## Agent's Discretion

- SnackBar styling and duration for alerts
- Alert status field design (separate columns vs single status enum)
- Progress bar visual details (rounded, animated, etc.)
- Empty state illustration and copy for Anggaran tab
- Card expand/collapse animation for transaction list
- Month navigation transition animation

## Deferred Ideas

None — discussion stayed within phase scope
