---
status: diagnosed
phase: 02-budgeting
source: 02-04-SUMMARY.md, 02-05-SUMMARY.md, 02-06-SUMMARY.md
type: re-verification
started: 2026-05-08T16:30:00Z
updated: 2026-05-08T17:00:00Z
---

## Current Test

[testing complete]

## Tests

### 1. FAB No Longer Overlaps Budget Tab
expected: Bottom navigation has 3 tabs (Transaksi, Anggaran, Laporan). FAB is positioned at bottom-right (not center). FAB is visible on Transaksi tab but hidden on Anggaran tab. All tabs are fully visible and tappable with no overlap.
result: pass

### 2. Swipe Gesture Month Navigation
expected: On the Anggaran (budget) list screen, swiping left navigates to the next month and swiping right navigates to the previous month. Arrow buttons still work. Accidental swipes during vertical scrolling do not trigger month changes.
result: skipped
reason: User says swipe only works once, arrow keys sufficient — feature not needed

### 3. Budget Appears Immediately After Creation
expected: After creating a new budget via the form, returning to the budget list shows the new budget immediately without needing to pull-to-refresh or manually reload.
result: pass

### 4. Duplicate Budget Error Message in Indonesian
expected: When trying to create a budget for a category that already has one for the same month, an Indonesian error message appears (e.g., "Budget untuk kategori ini sudah ada bulan ini"), not a generic English/technical error.
result: blocked
blocked_by: prior-phase
reason: "Can't create a new budget because the 'Add Budget' button doesn't appear when budgets exist — blocked by Test 12 issue"

### 5. Edit Budget from Detail Screen
expected: On the budget detail screen, each budget category card has an edit (pencil) icon button. Tapping it navigates to the budget form pre-filled with the existing budget data. Saving updates the budget.
result: pass

### 6. Delete Budget from Detail Screen
expected: On the budget detail screen, each budget category card has a delete (trash) icon button. Tapping it shows an Indonesian confirmation dialog. Confirming deletes the budget and shows a success SnackBar.
result: pass

### 7. Budget Page Auto-Refreshes on Tab Switch
expected: After making changes (e.g., creating a transaction), switching to the Anggaran tab shows updated data immediately without needing to pull-to-refresh. Progress bars and amounts reflect current spending.
result: issue
reported: "no"
severity: major

### 8. Spent Amount Auto-Updates After Transactions
expected: After adding or deleting a transaction, navigating to the budget detail screen shows the updated spent amount and progress bar without needing to manually refresh.
result: issue
reported: "no"
severity: major

### 9. Budget Alert at 75% Threshold
expected: When adding an expense transaction that brings spending to 75% or more of a category's budget limit, a warning SnackBar alert appears in Indonesian. Alert fires only once per threshold crossing.
result: pass

### 10. Budget Alert at 100% Threshold
expected: When adding an expense transaction that brings spending to exactly 100% of a category's budget limit, a limit SnackBar alert appears in Indonesian. Alert fires only once.
result: pass

### 11. Budget Alert Above 100% (Overspending)
expected: When adding an expense transaction that pushes spending above 100% of a category's budget limit, an overspending SnackBar alert appears in Indonesian. Alert fires only once.
result: pass

### 12. "Tambah Anggaran" Button Missing When Budgets Exist
expected: The "Tambah Anggaran" (Add Budget) button should always be visible on the Anggaran tab, even when one or more budgets already exist for the current month, so users can add budgets for additional categories.
result: issue
reported: "the 'Add Budget' button wasn't available when there was already a saved budget in the list. Therefore, you couldn't add a new budget beyond the one already on the list."
severity: major

## Summary

total: 12
passed: 7
issues: 3
pending: 0
skipped: 1
blocked: 1

## Gaps

- truth: "Tambah Anggaran button always visible on Anggaran tab even when budgets exist for current month"
  status: failed
  reason: "User reported: the 'Add Budget' button wasn't available when there was already a saved budget in the list. Therefore, you couldn't add a new budget beyond the one already on the list."
  severity: major
  test: 12
  root_cause: "BudgetListScreen._buildContent() only shows 'Tambah Anggaran' in empty state (_buildEmptyState). When budgets exist, _buildContent() returns a ListView with no add button. FAB is hidden (showFab: false) for Anggaran tab in app_router.dart."
  artifacts:
    - path: "lib/presentation/screens/budget/budget_list_screen.dart"
      issue: "Lines 127-167: _buildContent() has no add button when budgets exist; add button only in _buildEmptyState (lines 220-233)"
    - path: "lib/presentation/navigation/routes/app_router.dart"
      issue: "Line 62: showFab: false for Anggaran tab hides the FAB entirely"
  missing:
    - "Add a persistent '+' or 'Tambah Anggaran' button to BudgetListScreen AppBar actions when budgets exist, OR change showFab to true for Anggaran tab and remove the FAB hide logic"

- truth: "Budget page auto-refreshes when switching to Anggaran tab after making changes"
  status: failed
  reason: "User reported: no"
  severity: major
  test: 7
  root_cause: "StatefulShellRoute.indexedStack preserves widget state. BudgetListScreen loads data only in initState (line 38). No RouteAware mixin or visibility listener to detect tab re-activation. Switching tabs does not re-trigger initState or _loadBudgets()."
  artifacts:
    - path: "lib/presentation/screens/budget/budget_list_screen.dart"
      issue: "initState (line 38) is the only trigger for _loadBudgets(). No RouteAware or WidgetsBindingObserver lifecycle hook."
    - path: "lib/presentation/navigation/routes/app_router.dart"
      issue: "Line 119: StatefulShellRoute.indexedStack preserves tab state"
  missing:
    - "Add RouteAware mixin to BudgetListScreen to call _loadBudgets() on didChangeDependencies or didPushNext"

- truth: "Spent amount auto-updates on budget detail screen after adding/deleting transactions"
  status: failed
  reason: "User reported: no"
  severity: major
  test: 8
  root_cause: "Same root cause as Test 7: BudgetListScreen is cached by StatefulShellRoute. The list shows stale progress bars after transactions are added on another tab. BudgetDetailScreen loads fresh on each navigation, but the LIST screen (first thing user sees on Anggaran tab) shows stale data."
  artifacts:
    - path: "lib/presentation/screens/budget/budget_list_screen.dart"
      issue: "Same as Test 7"
  missing:
    - "Same fix as Test 7 — RouteAware refresh fixes both list and detail (detail already loads fresh on navigation)"
