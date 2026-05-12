---
status: diagnosed
phase: 03-savings-goals
source: 03-01-SUMMARY.md, 03-02-SUMMARY.md, 03-03-SUMMARY.md
started: 2026-05-12T23:08:18Z
updated: 2026-05-12T23:16:00Z
---

## Current Test

[testing paused — 9 items blocked by Test 5 issue]

## Tests

### 1. Cold Start Smoke Test
expected: Kill the app completely. Restart from scratch. App boots without errors, bottom navigation shows 4 tabs (Beranda, Anggaran, Tabungan, Laporan), and home screen loads normally.
result: pass

### 2. Tabungan Tab Navigation
expected: Bottom navigation shows 4 tabs. Tap "Tabungan" tab (savings icon, between Anggaran and Laporan) — navigates to savings goal list screen.
result: pass

### 3. Empty State
expected: With no savings goals created, Tabungan tab shows "Belum ada tabungan" message with a "Buat Goal" call-to-action button.
result: pass

### 4. Context-Aware FAB
expected: On Tabungan tab, FAB (floating action button) shows "Buat Goal Tabungan" text. Tapping it navigates to the savings goal creation form.
result: pass

### 5. Create Savings Goal
expected: Fill out the form — enter a name (e.g. "Dana Darurat"), set target amount (e.g. 1000000), optionally pick a deadline, icon, and color. Tap save. Goal appears in the Tabungan list with correct name, target amount, and circular progress indicator at 0%.
result: issue
reported: "1. When selecting an icon, it suddenly returns to the main savings tab. 2. When selecting a color, it suddenly returns to the main savings tab. 3. The data saving process may be successful, as there's a success notification in the snackbar, and the console log also displays a success log. However, the data doesn't appear on the savings list page."
severity: major

### 6. Circular Progress Colors
expected: A goal at 0% shows red progress ring. After adding a contribution that brings it to ~30%, the ring turns orange. At ~60%, yellow. At ~90%+, green.
result: blocked
blocked_by: prior-phase
reason: "Blocked by Test 5 issue — goals not showing in list"

### 7. Goal Detail Screen
expected: Tap a goal card. Detail screen shows large circular progress (120px), target amount, current amount, remaining amount (all formatted as currency), and days remaining or deadline info.
result: blocked
blocked_by: prior-phase
reason: "Blocked by Test 5 issue — goals not showing in list"

### 8. Add Contribution
expected: On goal detail screen, add a contribution (e.g. 250000). Contribution is recorded, current amount increases, progress percentage updates, and the contribution appears in the history list with green trending_up icon and running balance.
result: blocked
blocked_by: prior-phase
reason: "Blocked by Test 5 issue — goals not showing in list"

### 9. Withdraw from Goal
expected: On goal detail screen, withdraw an amount less than the current balance. Current amount decreases, a withdrawal entry appears in history with red trending_down icon.
result: blocked
blocked_by: prior-phase
reason: "Blocked by Test 5 issue — goals not showing in list"

### 10. Confetti Celebration
expected: Add a contribution that completes the goal (currentAmount >= targetAmount). A confetti burst animation appears for ~3 seconds. Goal shows "Selamat! Goal tercapai!" message and a "Tercapai" completion badge.
result: blocked
blocked_by: prior-phase
reason: "Blocked by Test 5 issue — goals not showing in list"

### 11. Completed Goal Is View-Only
expected: A completed goal shows the CompletionBadge ("Tercapai") and hides the add contribution / withdraw action buttons. The goal is view-only.
result: blocked
blocked_by: prior-phase
reason: "Blocked by Test 5 issue — goals not showing in list"

### 12. Goal Home Card
expected: On the home screen (Beranda tab), a compact "Tabungan" card appears below the budget overview card showing mini circular progress, total saved / total target. Tap the card navigates to Tabungan tab.
result: blocked
blocked_by: prior-phase
reason: "Blocked by Test 5 issue — goals not showing in list"

### 13. Quick Add Contribution Sheet
expected: From the home screen goal card, tap the quick-add button. A bottom sheet opens with a goal selector dropdown and amount field. Fill in and submit — contribution is added, sheet auto-dismisses.
result: blocked
blocked_by: prior-phase
reason: "Blocked by Test 5 issue — goals not showing in list"

### 14. Edit Savings Goal
expected: On goal detail screen, tap edit. Form opens pre-populated with current goal data. Change the name or target amount and save. Changes are reflected in the goal list and detail.
result: blocked
blocked_by: prior-phase
reason: "Blocked by Test 5 issue — goals not showing in list"

### 15. Cancel/Delete Goal
expected: On goal detail screen, tap "Batalkan Goal". A confirmation dialog appears. Confirm — goal is soft-deleted and removed from the active goal list.
result: blocked
blocked_by: prior-phase
reason: "Blocked by Test 5 issue — goals not showing in list"

### 16. Pull to Refresh
expected: On the Tabungan list screen, pull down. Refresh indicator appears, goal list reloads with latest data.
result: blocked
blocked_by: prior-phase
reason: "Blocked by Test 5 issue — goals not showing in list"

## Summary

total: 16
passed: 4
issues: 1
pending: 0
skipped: 0
blocked: 11

## Gaps

- truth: "Create goal form: icon picker, color picker, and save all work without navigation issues; saved goal appears in list"
  status: failed
  reason: "User reported: 1. When selecting an icon, it suddenly returns to the main savings tab. 2. When selecting a color, it suddenly returns to the main savings tab. 3. Data saving succeeds (snackbar + console log) but data doesn't appear on savings list page."
  severity: major
  test: 5
  root_cause: "Three bugs: (1-2) Double Navigator.pop in CategoryIconPickerDialog and CategoryColorPickerDialog — show() callback already pops the dialog, then build() pops again removing the form screen from the root navigator. (3) savingsGoalsWithProgressProvider (FutureProvider.autoDispose) is never invalidated after goal creation; the StatefulShellBranch keeps the list screen permanently mounted so autoDispose never triggers."
  artifacts:
    - path: "lib/presentation/widgets/category_icon_picker.dart"
      issue: "Double pop — onIconSelected callback pops dialog, then Navigator.of(context).pop() pops the form screen"
    - path: "lib/presentation/widgets/category_color_picker.dart"
      issue: "Same double pop pattern for onColorSelected"
    - path: "lib/presentation/screens/savings/savings_goal_form_screen.dart"
      issue: "_submit() never invalidates savingsGoalsWithProgressProvider after successful save"
  missing:
    - "Remove redundant Navigator.of(context).pop() from CategoryIconPickerDialog onIconSelected handler"
    - "Remove redundant Navigator.of(context).pop() from CategoryColorPickerDialog onColorSelected handler"
    - "Add ref.invalidate(savingsGoalsWithProgressProvider) in _submit() before context.pop(true)"
