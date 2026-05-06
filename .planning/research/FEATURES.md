# Feature Landscape

**Domain:** Personal finance expense tracker (v2 upgrade)
**Researched:** 2026-05-06
**Base:** Existing v1 app with transaction CRUD, categories, OCR, monthly insights, CSV import/export, search/filter, home widgets, onboarding

---

## Table Stakes

Features users expect from a v2 personal finance app. Missing = app feels incomplete or behind competitors.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| **Per-category monthly budgets** | Every finance app beyond basic trackers offers budgeting. Users who've used v1 for visibility naturally want control. | Med | Core budget CRUD + spending tracking against limits. SPEC: REQ-BUD-001 to REQ-BUD-003 |
| **Budget progress indicators** | Setting a budget without visual feedback is useless. Green→yellow→red progress bars are the universal pattern. | Low | Progress bars per category, budget overview card on home. SPEC: AC-BUD-003.2, AC-BUD-003.3 |
| **Budget overspending alerts** | The entire point of budgeting is getting warned before overspending. Without alerts, budgets are decorative. | Med | In-app alerts at 75% (warning) and 100% (critical) thresholds. SPEC: REQ-BUD-004 |
| **Savings goals with progress** | Goal-based saving is the standard next step after expense tracking in personal finance. Users need motivation. | Med | CRUD goals + contribution/withdrawal + circular progress. SPEC: REQ-SAV-001 to REQ-SAV-004 |
| **Dark mode with system follow** | In 2026, dark mode is expected by default. Apps without it feel dated, especially for evening use. | Med | Foundation already exists in codebase (`AppTheme.darkTheme`, `AppColors.backgroundDark`). Need: ThemeProvider, persistence, settings UI, glassmorphism adaptation. SPEC: REQ-THM-001 to REQ-THM-003 |
| **Cloud backup/restore** | Users lose phones. Any data app without backup risks losing user trust after a single device loss event. | High | Google Drive API with `drive.appdata` scope. OAuth flow + backup/restore + conflict handling. SPEC: REQ-BKP-001 to REQ-BKP-004 |
| **Week-over-week and month-over-month comparison** | Users need trend context, not just raw numbers. "Am I spending more or less?" is the fundamental question. | Med | Bar charts comparing current vs previous period. SPEC: AC-RPT-002.1 |
| **Category breakdown (pie/bar chart)** | Standard in every finance app. Users need to see where money goes at a glance. | Low | fl_chart PieChart already available. SPEC: REQ-RPT-003 |
| **Enhanced time-frame reports** | v1 only has monthly. Users need daily/weekly/monthly/yearly views to spot patterns at different granularities. | Med | Tab navigation with 4 time frames. SPEC: REQ-RPT-001, REQ-RPT-007 |

---

## Differentiators

Features that set Catat Cuan apart from generic expense trackers. Not expected by default, but create competitive advantage.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| **Goal completion celebration (confetti)** | Delight moment. Makes the app memorable and creates emotional attachment. Rare in simple trackers. | Low | `confetti` package integration. Auto-trigger when `current >= target`. SPEC: AC-SAV-005.2 |
| **Spending velocity / burn rate indicator** | Shows projected end-of-month spending based on current pace. Proactive, not reactive. Most simple trackers don't project. | Med | Daily average × remaining days = projected total. Warning if projected > income. SPEC: AC-RPT-002.3 |
| **Spending pattern insights** | "You tend to spend more on Fridays" or "Week 3 is always your highest." Makes reports actionable, not just descriptive. | Med | Requires analyzing day-of-week and week-of-month patterns from historical data. SPEC: AC-RPT-004.1 |
| **Budget vs Actual report integration** | Combining budgets with reports (showing budget adherence alongside spending trends) is a step above apps that treat them as separate features. | Med | Budget data feeds into enhanced reports. SPEC: AC-RPT-001.3 |
| **Motivational messages for savings milestones** | Encouraging messages at 25%/50%/75% progress prevents goal abandonment. Behavioral psychology applied to finance. | Low | Static message bank triggered by progress threshold. SPEC: AC-SAV-006.2, AC-SAV-006.3 |
| **Quick budget set from transaction list** | Setting budget in ≤10 seconds without leaving context. Most apps require navigating to a separate budget screen. | Low | Contextual action on transaction item. SPEC: AC-BUD-006.1 |
| **Quick contribution from home screen** | One-tap add to savings goal without navigating to goal detail. Reduces friction for repeated contributions. | Low | Inline action on goals overview card. SPEC: AC-SAV-004.3 |
| **Backup preview before restore** | Showing what's in the backup (transaction count, date range) before committing. Prevents data loss anxiety. | Med | Read backup metadata without full restore. SPEC: AC-BKP-003.2 |
| **Report chart export to image** | Shareable spending reports. Useful for couples discussing finances or personal accountability. | Low | `screenshot` + `share_plus` packages. SPEC: AC-RPT-006.1 |
| **Projected savings completion date** | Based on contribution velocity, estimate when goal will be reached. Helps users stay motivated or adjust pace. | Low | Simple linear projection: remaining ÷ avg monthly contribution. SPEC: AC-SAV-004.2 |

---

## Anti-Features

Features to explicitly NOT build. These increase complexity without proportional value for a personal expense tracker.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| **Real-time cross-device sync** | Requires backend infrastructure, conflict resolution for concurrent edits, WebSocket/monitoring layer. This is a v3+ problem. V2 scope is manual backup/restore. | Google Drive manual backup/restore with conflict resolution UI. |
| **Automatic bank/e-wallet integration** | Requires partnerships, API access, security compliance (PCI-DSS), and ongoing maintenance for each provider. Massive scope creep for a personal project. | OCR receipt scanning (already in v1) + manual entry. Consider e-wallet CSV import as future bridge. |
| **Push notification budget alerts** | Requires Firebase Cloud Messaging setup, notification channels, background processing, and user permission management. Overkill for v2. | In-app alerts (snackbar/badge) shown when user adds a transaction that crosses threshold. |
| **Multi-currency advanced features** | Currency conversion requires live exchange rate APIs, handling rate fluctuations, and dual-currency reporting. v1 basic IDR/USD is sufficient. | Support IDR primary with USD as secondary. No live conversion. |
| **Investment tracking** | Fundamentally different data model (holdings, NAV, dividends, capital gains). Scope creep that dilutes the "expense tracker" identity. | Stay focused on expense/income tracking. Suggest separate app for investments. |
| **Family/shared accounts** | Multi-user brings permission models, shared data ownership, privacy concerns. Completely different architecture. | Single-user personal app. Period. |
| **AI-powered spending recommendations** | Requires ML model, significant training data, and risk of wrong advice. High complexity, uncertain value. | Rule-based insights from spending patterns (SPEC: AC-RPT-004.3). Simple, deterministic, no AI needed. |
| **PDF report generation** | Heavy dependency (`pdf` package), complex layout, and low usage for a personal app. Image export is 80% of the value at 20% of the cost. | Export chart as PNG image for sharing. Defer PDF to v3 if users request it. |
| **Budget rollover between months** | Adds complexity to budget period logic, creates edge cases (partial rollovers, negative rollovers), and confuses users who expect clean monthly resets. | Fresh budget each month. Historical budget data is viewable but doesn't carry forward. |
| **Recurring transaction auto-creation** | Requires background scheduling, handling failures, and creates phantom transactions the user didn't confirm. Risky for financial data. | Manual entry with "duplicate last transaction" quick action. Fast enough without automation risk. |

---

## Feature Dependencies

```
┌─────────────────────────────────────────────────────────────────┐
│                    Phase 1: Foundation                          │
│                                                                 │
│  Dark Mode ─────────────────────────────────────────────────── │
│  (All subsequent features benefit from theme-aware components)  │
│  DB Schema Migration (v2→v3) ──────────────────────────────── │
│  (Required before budget/savings features)                      │
└───────────────────────────┬─────────────────────────────────────┘
                            │
              ┌─────────────┴─────────────┐
              ▼                           ▼
┌──────────────────────┐    ┌───────────────────────┐
│  Phase 2: Budgeting  │    │  Phase 3: Savings     │
│                      │    │  Goals                 │
│  Budget Entity       │    │                       │
│  Budget CRUD         │    │  Goal Entity           │
│  Budget Tracking     │    │  Goal CRUD             │
│  Budget Alerts ──────┼───▶│  Contributions         │
│                      │    │  Progress Tracking     │
└──────────┬───────────┘    │  Celebration           │
           │                └───────────┬───────────┘
           │                            │
           ▼                            │
┌──────────────────────┐               │
│  Phase 5: Enhanced   │◀──────────────┘
│  Reports             │
│                      │
│  Budget data feeds───┘  into reports
│  Time-frame views    │
│  Trend analysis      │
│  Category breakdown  │
│  Chart interactions  │
└──────────────────────┘

┌──────────────────────┐
│  Phase 4: Cloud      │  (Independent, can run in parallel)
│  Backup              │
│                      │
│  OAuth flow          │
│  Backup to Drive     │
│  Restore + conflict  │
│  Backup management   │
└──────────────────────┘
```

### Dependency Details

| From | To | Why |
|------|----|-----|
| DB Schema Migration | Budgeting, Savings Goals | New `budgets`, `savings_goals`, `goal_contributions` tables required before any domain logic |
| Dark Mode | All UI features | Theme-aware components must exist before building new screens, otherwise hardcode light-only |
| Budgeting (entity + CRUD) | Budget Alerts | Can't alert without budget data and spending comparison |
| Budgeting (tracking data) | Enhanced Reports | Budget vs Actual report requires budget entities and spent calculations |
| Savings Goals (entity) | Contributions | Contributions reference goal IDs via foreign key |
| fl_chart (existing) | Enhanced Reports | Chart widgets build on top of existing fl_chart dependency |
| Google Sign-In OAuth | Backup/Restore | Can't access Drive without authenticated session |

---

## Complexity Assessment

### By Feature Area

| Feature | Data Layer | Domain Layer | Presentation Layer | Integration Risk | Overall |
|---------|-----------|--------------|-------------------|-----------------|---------|
| Dark Mode | Low (settings table) | Low (theme enum) | Med (refactor all components) | Low | **Med** |
| Budgeting | Med (1 new table) | Med (6 use cases) | Med (new screens + home card) | Low | **Med** |
| Savings Goals | Med (2 new tables) | Med (8+ use cases) | Med (screens + celebration) | Low | **Med** |
| Cloud Backup | Low (no new tables) | Med (backup/restore logic) | Low (settings screen) | **High** (OAuth, Drive API, network) | **High** |
| Enhanced Reports | Low (read-only queries) | Med (analyzers, calculators) | **High** (6+ chart types, interactive) | Low | **Med-High** |

### Risk-Adjusted Effort

| Feature | Effort (weeks) | Risk | Notes |
|---------|---------------|------|-------|
| Dark Mode + Schema Migration | 1.5-2 | Low | Theme foundation exists. Main work: ThemeProvider + component refactor + glassmorphism adaptation |
| Budgeting | 2 | Low | Standard CRUD + tracking pattern. Well-defined in SPEC |
| Savings Goals | 1.5-2 | Low | Similar pattern to budgeting. Confetti is low-risk delight |
| Cloud Backup | 2-3 | **High** | OAuth edge cases, Drive API quota limits, network failures, conflict resolution, testing on real devices |
| Enhanced Reports | 2-2.5 | Med | fl_chart is well-understood but 6+ chart types with interactivity is significant UI work |
| Polish + Testing | 1-1.5 | Low | Integration testing, performance optimization |

---

## MVP Recommendation (Phase Priority)

### Must Ship (Phase 1-2)
1. **Dark mode + schema migration** — Foundation for all v2 UI work. Theme-aware components prevent rework.
2. **Budgeting core** (CRUD + tracking + alerts) — The #1 requested "control" feature. Delivers the core v2 value proposition.

### Should Ship (Phase 3-4)
3. **Savings goals** (CRUD + contributions + celebration) — Completes the "visibility → control → goals" journey.
4. **Cloud backup/restore** — Data safety. Users will lose phones; this prevents catastrophic data loss.

### Nice to Have (Phase 5)
5. **Enhanced reports** — Deepens engagement for power users. Can be iterative (start with monthly + comparison, add time frames later).
6. **Chart export** — Low effort, high perceived value for sharing.

### Defer Explicitly
- **PDF export**: Defer to v3. Image export covers 80% of use cases.
- **Push notifications**: In-app alerts sufficient for v2.
- **Budget rollover**: Clean monthly reset is simpler and less confusing.

---

## Competitive Positioning

### How Catat Cuan v2 compares

| Dimension | Catat Cuan v2 | Typical Competitors | Premium Competitors |
|-----------|--------------|-------------------|-------------------|
| Budget | Per-category monthly | Per-category monthly | Per-category + rollover + custom periods |
| Savings | Goals + celebration | Goals (basic) | Goals + auto-save rules |
| Backup | Manual Google Drive | Manual export | Real-time cloud sync |
| Dark Mode | Light/Dark/System | Usually supported | Always supported |
| Reports | 4 time frames + trends | Monthly only | Custom date ranges + AI insights |
| OCR | ML Kit receipt scan | Manual entry | Bank sync + OCR |

**Catat Cuan v2's sweet spot**: Above basic trackers (which lack budgeting/goals/backup), below premium apps (which require subscriptions/servers). The confetti celebration and spending velocity are delightful touches that create emotional attachment without infrastructure cost.

---

## Implementation Status Tracking

All v2 features are currently at ⏳ (Not Implemented) status per the SPEC documents. See individual specs for detailed verification checklists:

| Spec | Requirements | NFRs | Status |
|------|-------------|------|--------|
| [01-Google-Drive-Backup](../../docs/v2/product/01-SPEC-v2-001-Google-Drive-Backup.md) | 4 (REQ-BKP) | 5 (NFR-BKP) | ⏳ |
| [02-Full-Budgeting](../../docs/v2/product/02-SPEC-v2-002-Full-Budgeting.md) | 6 (REQ-BUD) | 4 (NFR-BUD) | ⏳ |
| [03-Savings-Goals](../../docs/v2/product/03-SPEC-v2-003-Savings-Goals.md) | 6 (REQ-SAV) | 4 (NFR-SAV) | ⏳ |
| [04-Dark-Mode](../../docs/v2/product/04-SPEC-v2-004-Dark-Mode.md) | 6 (REQ-THM) | 4 (NFR-THM) | ⏳ |
| [05-Enhanced-Reports](../../docs/v2/product/05-SPEC-v2-005-Enhanced-Reports.md) | 7 (REQ-RPT) | 4 (NFR-RPT) | ⏳ |

---

## Sources

- **PRD**: `docs/v2/product/00-PRD.md` — Product requirements and user stories
- **Feature Specs**: `docs/v2/product/01-05` — Detailed technical requirements with acceptance criteria
- **Existing Codebase**: `lib/presentation/utils/app_theme.dart` — Dark theme already defined (ThemeProvider missing)
- **Existing Codebase**: `lib/presentation/utils/app_colors.dart` — Dark color tokens + glassmorphism dark variants exist
- **Database Schema**: `docs/v1/database/DATABASE_SCHEMA.md` — Current v2 schema, migration path to v3
- **Context7**: Flutter ThemeData dark mode patterns verified — `brightness: Brightness.dark` approach confirmed
- **Context7**: fl_chart interactive chart capabilities verified — BarTouchData, LineTouchData, tooltips all supported
- **Confidence**: HIGH — All findings verified against project's own SPEC documents and existing codebase
