---
status: diagnosed
phase: 02-budgeting
source: 02-01-SUMMARY.md, 02-02-SUMMARY.md, 02-03-SUMMARY.md
started: 2026-05-08T12:00:00Z
updated: 2026-05-08T12:14:00Z
---

## Current Test

[testing complete]

## Tests

### 14. Budget Alert Over 100% (Overspending)
expected: When spending exceeds budget limit (>100%), an Indonesian SnackBar alert appears warning about overspending. Alert fires only once.
result: issue
reported: "does not work as per scenario"
severity: major

## Summary

total: 14
passed: 3
issues: 11
pending: 0
skipped: 0

## Gaps

- truth: "Bottom navigation tabs are fully visible and tappable with no overlap from FAB button"
  status: failed
  reason: "User reported: yes it works fine, but there is a UI issue, the FAB button covers the 'budget' button in the bottom nav"
  severity: major
  test: 2
  root_cause: "centerDocked FAB (64px) overlaps center Anggaran tab because BottomNavigationBar has no notch cutout"
  artifacts:
    - path: "lib/presentation/navigation/routes/app_router.dart"
      issue: "FAB at centerDocked + BottomNavigationBar without notch at lines 305, 337-361"
  missing:
    - "Either hide FAB on Anggaran tab (showFab: false) with in-screen add button, or move FAB to endFloat"

- truth: "Month navigation responds to swipe gesture on budget list"
  status: failed
  reason: "User reported: I can navigate the month selection with the arrows, but I can't use swipe"
  severity: minor
  test: 3
  root_cause: "No swipe gesture detection implemented; budget_list_screen uses plain ListView.builder without PageView or GestureDetector"
  artifacts:
    - path: "lib/presentation/screens/budget/budget_list_screen.dart"
      issue: "Lines 123-153 use ListView.builder, no swipe/PageView at all"
  missing:
    - "Wrap budget list in PageView or add GestureDetector with onHorizontalDragEnd for month navigation"

- truth: "Budget appears immediately in the list after creation without needing to refresh"
  status: failed
  reason: "User reported: Yes, as expected but with the issue of having to refresh the page first for it to appear in the list"
  severity: major
  test: 4
  root_cause: "FutureBuilder fires once; context.push() not awaited so pop(true) result is lost; no setState triggered"
  artifacts:
    - path: "lib/presentation/screens/budget/budget_list_screen.dart"
      issue: "Lines 59-83 FutureBuilder one-shot, lines 212-217 push not awaited"
    - path: "lib/presentation/navigation/routes/app_router.dart"
      issue: "Line 330 FAB push not awaited"
  missing:
    - "Change push to await context.push<bool>(...) and call setState(() {}) when result is true"

- truth: "Error message clearly informs user about duplicate budget for same category/month"
  status: failed
  reason: "User reported: Yes, according to expectations, but the error message issue does not inform about duplicate budgets"
  severity: major
  test: 5
  root_cause: "ErrorMessageMapper checks for DatabaseException but repo returns DatabaseFailure; good Indonesian message from repo is lost and generic fallback shown"
  artifacts:
    - path: "lib/presentation/utils/error/error_message_mapper.dart"
      issue: "Line 34 checks DatabaseException not DatabaseFailure, line 112 generic fallback"
    - path: "lib/data/repositories/budget/budget_write_repository_impl.dart"
      issue: "Lines 84-95 returns DatabaseFailure with clear Indonesian message"
  missing:
    - "Add Failure type check in ErrorMessageMapper.getUserMessage() to return error.message for Failure types"

- truth: "User can edit an existing budget from the detail or list screen"
  status: failed
  reason: "User reported: can't edit existing budget, no edit button, or anything like that"
  severity: major
  test: 6
  root_cause: "BudgetFormScreen supports edit mode (budgetId param, _isEditing) but no UI element navigates to it with a budgetId"
  artifacts:
    - path: "lib/presentation/screens/budget/budget_detail_screen.dart"
      issue: "No edit button in AppBar or anywhere in the 190-line file"
    - path: "lib/presentation/screens/budget/budget_form_screen.dart"
      issue: "Lines 24-26, 37-87 edit mode exists but never triggered from UI"
  missing:
    - "Add edit icon button to BudgetDetailScreen AppBar that navigates to form with budgetId"

- truth: "User can delete an existing budget from the detail or list screen"
  status: failed
  reason: "User reported: can't delete existing budget, no delete button, or anything like that"
  severity: major
  test: 7
  root_cause: "BudgetFormController.submitDelete() method exists but no UI element ever calls it; no delete button or confirmation dialog"
  artifacts:
    - path: "lib/presentation/screens/budget/budget_detail_screen.dart"
      issue: "No delete button anywhere"
    - path: "lib/presentation/controllers/budget/budget_form_controller.dart"
      issue: "Lines 59-62 submitDelete exists but unused"
  missing:
    - "Add delete button to BudgetDetailScreen with confirmation dialog, follow TransactionDeleteController pattern"

- truth: "Budget page updates automatically when navigating to it, showing current progress bar state"
  status: failed
  reason: "User reported: Yes, this works as expected, but there's one issue: the 'budget' page doesn't update automatically when you enter it. You have to refresh the budget page before you can see the changes in the progress bar"
  severity: major
  test: 8
  root_cause: "FutureBuilder one-shot + StatefulShellRoute.indexedStack preserves state; no lifecycle hook triggers refresh on tab switch or navigation back"
  artifacts:
    - path: "lib/presentation/screens/budget/budget_list_screen.dart"
      issue: "Lines 59-83 FutureBuilder, no RouteAware or visibility listener"
  missing:
    - "Add RouteAware mixin or convert to Riverpod AsyncNotifier with ref.invalidate for reactivity"

- truth: "Spent amount updates automatically on budget page after adding transactions"
  status: failed
  reason: "User reported: Yes, this works as expected, but there's one issue: the 'budget' page doesn't update automatically when you enter it. You have to refresh the budget page before you can see the changes in the progress bar"
  severity: major
  test: 9
  root_cause: "Same as test 8: FutureBuilder one-shot in both BudgetListScreen and BudgetDetailScreen"
  artifacts:
    - path: "lib/presentation/screens/budget/budget_detail_screen.dart"
      issue: "Lines 46-89 same FutureBuilder pattern"
  missing:
    - "Same fix as test 8"

- truth: "SnackBar alert appears when spending reaches 75% of budget limit"
  status: failed
  reason: "User reported: does not work as per scenario"
  severity: major
  test: 12
  root_cause: "Alert check only wired in DELETE flow (transaction_list_screen line 732), NOT in SAVE/ADD flow (transaction_form_screen lines 408-429)"
  artifacts:
    - path: "lib/presentation/screens/transaction_form_screen.dart"
      issue: "Lines 408-429 save flow has no budget alert check"
    - path: "lib/presentation/screens/transaction_list_screen.dart"
      issue: "Line 732 alert check only in _showDeleteDialog"
  missing:
    - "Add budget alert check in transaction_form_screen after successful save, same pattern as TransactionListScreen._checkBudgetAlertAfterTransaction"

- truth: "SnackBar alert appears when spending reaches 100% of budget limit"
  status: failed
  reason: "User reported: does not work as per scenario"
  severity: major
  test: 13
  root_cause: "Same as test 12: alert check missing from save/add flow"
  artifacts:
    - path: "lib/presentation/screens/transaction_form_screen.dart"
      issue: "Same as test 12"
  missing:
    - "Same fix as test 12"

- truth: "SnackBar alert appears when spending exceeds 100% of budget limit"
  status: failed
  reason: "User reported: does not work as per scenario"
  severity: major
  test: 14
  root_cause: "Same as test 12: alert check missing from save/add flow"
  artifacts:
    - path: "lib/presentation/screens/transaction_form_screen.dart"
      issue: "Same as test 12"
  missing:
    - "Same fix as test 12"
