# Phase 3: Savings Goals - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-09
**Phase:** 3-Savings Goals
**Areas discussed:** Contribution semantics, Goal creation & editing, Home screen goals card, Completion celebration

---

## Contribution Semantics

### Contribution model

| Option | Description | Selected |
|--------|-------------|----------|
| Earmarks (visual tracking) | Contributions don't create transactions or reduce available balance. Just visual tracking. | ✓ |
| Real transactions | Each contribution creates a transaction, reduces available balance. More complex. | |

**User's choice:** Earmarks (Recommended)
**Notes:** STATE.md previously flagged this decision — research recommended earmarks. User agreed.

### Withdrawal semantics

| Option | Description | Selected |
|--------|-------------|----------|
| Reverse earmark | Reduces tracked amount. Floor at zero. No transaction. | ✓ |
| Close goal entirely | Abandons the goal, sets cancelled. All progress lost. | |

**User's choice:** Reverse earmark (Recommended)
**Notes:** Withdrawal is just reducing the earmark, not a dramatic action.

### Minimum balance

| Option | Description | Selected |
|--------|-------------|----------|
| Floor at zero | current_amount can never go below 0. Withdrawal capped. | ✓ |
| Allow negative | current_amount can go below 0. More flexible but confusing. | |

**User's choice:** Floor at zero (Recommended)
**Notes:** Simpler, no need to explain negative savings to users.

---

## Goal Creation & Editing

### Creation flow

| Option | Description | Selected |
|--------|-------------|----------|
| Full screen form | Like Add Transaction. Consistent pattern, good for 5+ fields. | ✓ |
| Bottom sheet | Compact but tight for 5 fields. Less consistent. | |

**User's choice:** Full screen form (Recommended)
**Notes:** Follows existing transaction creation pattern.

### Icon/Color picker

| Option | Description | Selected |
|--------|-------------|----------|
| Reuse category picker | Same Material Icons grid + color palette from Category management. | ✓ |
| Simplified emoji picker | Emoji-based icons. More personal but needs new component. | |

**User's choice:** Reuse category picker (Recommended)
**Notes:** Consistent UX, less code.

### Deadline input

| Option | Description | Selected |
|--------|-------------|----------|
| Optional date picker | "Tenggat Waktu (Opsional)" label. Empty by default. | ✓ |
| Quick presets + custom | 3/6/12 month buttons + custom. More complex. | |

**User's choice:** Optional date picker (Recommended)
**Notes:** Simple and clear. Days remaining shown when set.

---

## Home Screen Goals Card

### Card coexistence

| Option | Description | Selected |
|--------|-------------|----------|
| Both cards stacked | Budget card on top, goals below. Compact. Phase 6 can optimize. | ✓ |
| Tabbed card with toggle | Single area with tabs. More compact but complex. | |

**User's choice:** Both cards stacked (Recommended)
**Notes:** Simple layout that works now. Phase 6 will redesign home screen.

### Quick-add behavior

| Option | Description | Selected |
|--------|-------------|----------|
| Inline bottom sheet | Amount field + goal selector. Fast contribution without leaving home. | ✓ |
| Navigate to goal detail | Navigate to Tabungan tab. More steps but full context. | |

**User's choice:** Inline bottom sheet (Recommended)
**Notes:** Fast contribution without navigation.

### Card content

| Option | Description | Selected |
|--------|-------------|----------|
| Compact summary | Single line: total/total (%). Mini circular progress. Tap → Tabungan tab. | ✓ |
| Detailed multi-goal | Top 2-3 goals individually + overall summary. More info but taller. | |

**User's choice:** Compact summary (Recommended)
**Notes:** Consistent with budget card compact pattern.

---

## Completion Celebration

### Celebration style

| Option | Description | Selected |
|--------|-------------|----------|
| Brief celebration | 2-3s confetti burst + success message. One-time trigger. | ✓ |
| Elaborate celebration | Full-screen overlay + animation + share option. Risk of over-engineering. | |

**User's choice:** Brief celebration (Recommended)
**Notes:** Quick and delightful without over-engineering a finance app.

### Post-completion behavior

| Option | Description | Selected |
|--------|-------------|----------|
| View only | Completed goals visible in completed section. Can view history. No more contributions. | ✓ |
| Allow over-contributions | Users can keep adding beyond target. Contradicts completion semantics. | |

**User's choice:** View only (Recommended)
**Notes:** Clean end state. Completed = done.

---

## Agent's Discretion

- Confetti library selection and animation parameters
- Circular progress indicator implementation details
- Contribution history list styling
- Empty state illustrations and copy
- Goal detail screen layout specifics
- Quick-add bottom sheet field arrangement

## Deferred Ideas

None — all discussion stayed within Phase 3 scope.
