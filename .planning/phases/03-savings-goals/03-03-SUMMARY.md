---
phase: 03-savings-goals
plan: 03
subsystem: presentation
tags: [ui, savings-goals, navigation, confetti, circular-progress, home-card, bottom-sheet]
dependency_graph:
  requires: [03-01, 03-02]
  provides: [SavingsGoalListScreen, SavingsGoalFormScreen, SavingsGoalDetailScreen, QuickAddContributionSheet, GoalHomeCard, CircularGoalProgress, SavingsGoalCard, ContributionListItem, CompletionBadge, ConfettiCelebration]
  affects: [app_router, app_routes, app_colors, transaction_list_screen]
tech-stack:
  added:
    - "confetti v0.8.0 for goal completion celebration"
    - "CustomPaint with CircularProgressPainter for goal progress"
  patterns:
    - "4-tab navigation with Tabungan as 4th tab"
    - "Context-aware FAB (Add Goal on Tabungan tab)"
    - "ConfettiWidget overlay on Stack for celebration"
    - "FutureProvider.autoDispose for reactive goal data"
    - "Bottom sheet for quick-add contribution"
    - "Glass card pattern for goal cards matching budget card design"
key-files:
  created:
    - lib/presentation/screens/savings/savings_goal_list_screen.dart
    - lib/presentation/screens/savings/savings_goal_form_screen.dart
    - lib/presentation/screens/savings/savings_goal_detail_screen.dart
    - lib/presentation/screens/savings/sheets/quick_add_contribution_sheet.dart
    - lib/presentation/widgets/savings/circular_goal_progress.dart
    - lib/presentation/widgets/savings/savings_goal_card.dart
    - lib/presentation/widgets/savings/contribution_list_item.dart
    - lib/presentation/widgets/savings/completion_badge.dart
    - lib/presentation/widgets/savings/confetti_celebration.dart
    - lib/presentation/widgets/savings/goal_home_card.dart
    - test/presentation/widgets/savings/circular_goal_progress_test.dart
  modified:
    - lib/presentation/navigation/routes/app_router.dart
    - lib/presentation/navigation/routes/app_routes.dart
    - lib/presentation/utils/app_colors.dart
    - lib/presentation/screens/transaction_list_screen.dart
    - pubspec.yaml
decisions:
  - "ConfettiWidget placed directly in Stack on detail screen (not wrapped in separate StatefulWidget) for simpler lifecycle management"
  - "Confetti triggers once per session via _confettiPlayed flag; _wasLoadedAsCompleted prevents re-trigger when navigating back"
  - "Category icon/color picker reused from category_form_screen.dart per D-05, using CategoryType.expense as picker type"
  - "overallProgressProvider returns double (percentage), so GoalHomeCard reads savingsGoalsWithProgressProvider separately for totalSaved/totalTarget display"
  - "QuickAddContributionSheet uses DropdownButtonFormField with initialValue (not deprecated value parameter)"
metrics:
  duration: 16min
  completed: "2026-05-10"
  tasks_completed: 2
  files_created: 11
  files_modified: 5
  tests_added: 7
  total_tests: 1103
---

# Phase 3 Plan 03: Savings Goals UI Layer Summary

Complete savings goals UI with 4-tab navigation, goal list with circular progress indicators, create/edit form with icon/color picker reuse, detail screen with contribution history and confetti celebration, home screen goals card with quick-add bottom sheet.

## What Was Built

### Navigation Changes
- **4-tab bottom navigation** with Tabungan as 4th tab (savings icon, between Anggaran and Laporan)
- **Savings routes** added to app_routes.dart and StatefulShellBranch in app_router.dart
- **Context-aware FAB** shows "Buat Goal Tabungan" on Tabungan tab, navigating to `/savings/add`

### Screens

**SavingsGoalListScreen** (Tabungan tab)
- Watches `savingsGoalsWithProgressProvider` for reactive goal list
- Empty state: "Belum ada tabungan" with "Buat Goal" CTA
- Error state with retry button and user-friendly error messages
- Pull-to-refresh via `RefreshIndicator`
- Goal cards navigate to `/savings/detail/{id}`

**SavingsGoalFormScreen** (Create/Edit)
- Full-screen form per D-04 with name, target amount, optional deadline, icon, color
- Icon picker reused from category management per D-05
- Color picker reused from category management per D-05
- Date picker for optional deadline per D-06
- Edit mode pre-populates fields from existing goal
- Error handling via ErrorMessageMapper — never shows raw errors

**SavingsGoalDetailScreen** (Detail with Contribution History)
- Large circular progress (120×120, stroke 8) as hero element
- Target, current, remaining amounts with CurrencyFormatter
- Days remaining or "Selamat! Goal tercapai!" for completed goals
- Contribution/withdrawal dialogs per UI-SPEC
- Confetti celebration via ConfettiController (3-second burst) on completion
- Completed goals are view-only per D-13 — action buttons hidden, CompletionBadge shown
- Soft-delete with "Batalkan Goal" confirmation dialog
- Contribution history via `goalContributionsProvider`

**QuickAddContributionSheet** (Bottom Sheet per D-10)
- Glass background with compact layout (~250dp)
- Goal selector dropdown with mini progress indicators
- Amount field with CurrencyFormatter
- Auto-dismiss on success

### Widgets

**CircularGoalProgress** — CustomPaint with TweenAnimationBuilder
- 4-tier color gradient per SAV-07: red 0-25%, orange 25-50%, yellow 50-75%, green 75-100%
- Three size presets: card (48×48, stroke 4), detail (120×120, stroke 8), home (36×36, stroke 3)
- 500ms ease-out animation on progress change

**SavingsGoalCard** — Glass card with goal info
- CircularGoalProgress, goal name, amounts, deadline, trailing chevron
- CompletionBadge overlay for completed goals

**ContributionListItem** — Contribution/withdrawal row
- Type icon (trending_up green / trending_down red), amount, running balance, note
- Color-coded amounts per UI-SPEC

**CompletionBadge** — Green badge with emoji_events icon and "Tercapai" label

**ConfettiCelebration** — Wrapper around confetti v0.8.0
- Blast direction upward (pi/2), gravity 0.3, 30 particles
- Brand colors: primary, success, warning, info

**GoalHomeCard** — Compact home screen card per D-08/D-09
- Mini circular progress (36dp), total saved/target text, quick-add button
- Taps navigate to Tabungan tab; quick-add opens QuickAddContributionSheet
- Hidden when no active goals

### Home Screen Integration
- GoalHomeCard added below BudgetOverviewCard in TransactionListScreen
- Watches `overallProgressProvider` for reactive data

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Fixed DropdownButtonFormField deprecated value parameter**
- **Found during:** Task 2 — QuickAddContributionSheet
- **Issue:** `value` parameter deprecated in Flutter 3.33+, replaced by `initialValue`
- **Fix:** Changed `value:` to `initialValue:` in DropdownButtonFormField
- **Files modified:** `quick_add_contribution_sheet.dart`

**2. [Rule 1 - Bug] Enhanced SavingsGoalListScreen error state**
- **Found during:** Self-check — list screen was minimal (66 lines) with no proper error handling
- **Issue:** Plan required min 80 lines; screen lacked proper error state with retry
- **Fix:** Added dedicated error state widget with retry button matching budget list pattern
- **Files modified:** `savings_goal_list_screen.dart`

None - plan executed closely as written.

## Test Results

- **CircularGoalProgress tests:** 7 passed (0%, 25%, 50%, 75%, 100%, dark mode, hide center text)
- **Full suite:** 1103 passed, 0 failed
- **flutter analyze:** 0 issues

## Key Implementation Details

- Confetti uses ConfettiController directly in detail screen State (not wrapped in separate widget)
- `_wasLoadedAsCompleted` flag prevents confetti from re-firing when returning to already-completed goal detail
- overallProgressProvider returns `double` (percentage only); GoalHomeCard reads savingsGoalsWithProgressProvider for total amounts
- All error handling uses ErrorMessageMapper.getUserMessage(e) — no raw error strings visible to users
- All user-facing text in Indonesian per UI-SPEC copywriting contract

## Self-Check: PASSED

- All 16 source/test files verified present
- Commits verified: b0faaf6 (Task 1), 0b62167 (Task 2), 9d1579f (refactor)
- 1103 tests passing, flutter analyze clean
- All must_have min_lines met
