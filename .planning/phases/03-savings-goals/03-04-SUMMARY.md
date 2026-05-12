---
phase: 03-savings-goals
plan: 04
type: gap-closure
status: complete
gap_closure: true
started: "2026-05-13T06:40:00.000Z"
completed: "2026-05-13T06:43:00.000Z"
requirements: [SAV-01]
---

# Plan 03-04: Fix Savings Goal Creation Flow Bugs

## Objective

Fix three bugs in the savings goal creation flow that prevent users from completing UAT Test 5.

## What Was Done

### Task 1: Fix icon/color picker double-pop and stale goal list after save

**Fix 1 — Icon picker double-pop** in `lib/presentation/widgets/category_icon_picker.dart`:
- Removed redundant `Navigator.of(context).pop()` from `CategoryIconPickerDialog.build()` (line 147)
- The `onIconSelected(icon)` callback already triggers `show()` method's `Navigator.of(context).pop(icon)` which correctly closes the dialog. The second pop was erroneously closing the form screen.

**Fix 2 — Color picker double-pop** in `lib/presentation/widgets/category_color_picker.dart`:
- Removed redundant `Navigator.of(context).pop()` from `CategoryColorPickerDialog.build()` (line 81)
- Same pattern as icon picker — `onColorSelected(color)` already triggers the dialog close via `show()`'s callback.

**Fix 3 — Stale goal list** in `lib/presentation/screens/savings/savings_goal_form_screen.dart`:
- Added `ref.invalidate(savingsGoalsWithProgressProvider)` before `context.pop(true)` in `_submit()` success handler
- This forces a fresh fetch of goals after save, since the list screen uses `FutureProvider.autoDispose` in a permanently mounted `StatefulShellBranch.indexedStamp`.

## Key Files

### Modified
- `lib/presentation/widgets/category_icon_picker.dart` — Removed double-pop (1 line removed)
- `lib/presentation/widgets/category_color_picker.dart` — Removed double-pop (1 line removed)
- `lib/presentation/screens/savings/savings_goal_form_screen.dart` — Added provider invalidation (1 line added)

## Verification

- `flutter analyze` — 0 errors
- `flutter test` — 1103/1103 tests passed
- No regressions introduced

## Deviations

None. All fixes were surgical single-line changes as planned.

## Self-Check: PASSED

- [x] Icon picker: single pop (dialog only), form screen preserved
- [x] Color picker: single pop (dialog only), form screen preserved
- [x] Goal list: provider invalidated after save, goals appear without manual refresh
- [x] Zero regressions: `flutter analyze` clean, all 1103 tests pass
