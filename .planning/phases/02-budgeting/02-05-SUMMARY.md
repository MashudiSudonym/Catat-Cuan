---
phase: 02-budgeting
plan: 05
subsystem: presentation
tags: [gap-closure, error-messaging, budget-crud, edit-delete]
dependency_graph:
  requires: [02-04]
  provides: [budget-edit-from-detail, budget-delete-from-detail, failure-aware-error-messages]
  affects: [error_message_mapper, budget_detail_screen, budget_category_card]
tech_stack:
  added: []
  patterns: [Failure-type-check in ErrorMessageMapper, per-card action callbacks]
key_files:
  created: []
  modified:
    - lib/presentation/utils/error/error_message_mapper.dart
    - lib/presentation/screens/budget/budget_detail_screen.dart
    - lib/presentation/widgets/budget/budget_category_card.dart
decisions:
  - "Failure type check placed before string pattern matching in ErrorMessageMapper for clean early-return"
  - "Edit/delete buttons embedded in BudgetCategoryCard header (approach A) rather than separate row below card"
metrics:
  duration: 5min
  completed: "2026-05-08"
  tasks: 2
  files: 3
---

# Phase 2 Plan 5: Budget CRUD Gap Closure Summary

ErrorMessageMapper now surfaces Failure.message for domain-layer errors, and BudgetDetailScreen provides per-card edit/delete actions with confirmation dialog.

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Fix ErrorMessageMapper for Failure types | f5f0559 | error_message_mapper.dart |
| 2 | Add edit/delete buttons to BudgetDetailScreen | a544e5a | budget_detail_screen.dart, budget_category_card.dart |

## What Was Done

### Task 1: Fix ErrorMessageMapper

Added `Failure` type check in `getUserMessage()` between the `DatabaseException` check and string pattern matching. When a `DatabaseFailure('Budget untuk kategori ini sudah ada bulan ini')` is passed, it now returns that exact Indonesian message instead of falling through to the generic "Terjadi kesalahan" fallback.

### Task 2: Edit/Delete on Budget Detail

- Added `onEdit` and `onDelete` optional callbacks to `BudgetCategoryCard` widget
- `BudgetCategoryCard` header now shows edit (pencil) and delete (trash) icon buttons before the expand/collapse arrow
- Edit navigates to `BudgetFormScreen` via `context.push` with `id`, `year`, `month` query params
- Delete shows an Indonesian confirmation dialog ("Hapus Anggaran / Apakah Anda yakin?")
- On delete confirmation, calls `BudgetFormController.submitDelete()` and refreshes the list
- Error messages shown via `ErrorMessageMapper` (which now handles `Failure` types from Task 1)

## Verification

- `flutter analyze` — 0 issues on all 3 modified files and full project
- Edit button navigates to budget form with correct budgetId
- Delete button shows confirmation dialog with Indonesian text
- After successful delete, SnackBar shows "Anggaran berhasil dihapus" and list refreshes
- Duplicate budget creation will now show "Budget untuk kategori ini sudah ada bulan ini"

## Deviations from Plan

None — plan executed exactly as written.

## Threat Flags

No new threat surface beyond what was planned. T-02-05-01 (delete confirmation) is mitigated by the confirmation dialog. T-02-05-02 (error messages) accepted — Failure messages are Indonesian and user-friendly.

## Self-Check

All files verified present and all commits verified in git log.
