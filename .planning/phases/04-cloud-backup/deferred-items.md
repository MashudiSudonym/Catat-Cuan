# Deferred Items — Phase 04-cloud-backup

Out-of-scope discoveries logged during execution. Not fixed per the executor scope-boundary rule.

## 2026-06-30 (discovered during 04-05 Task 2 verification)

**`info`-level lint, unrelated to plan 04-05, pre-existing at HEAD.**

- **File:** `lib/presentation/screens/category_management_screen.dart:213`
- **Rule:** `deprecated_member_use`
- **Message:** `'onReorder' is deprecated and shouldn't be used. Use the onReorderItem callback instead. ... deprecated after v3.41.0-0.0.pre.`
- **Severity:** info (not error, not warning)
- **Provenance:** Present at `HEAD` before the 04-05 deletion; `category_management_screen.dart` was NOT modified by plan 04-05 (which touched only `lib/data/services/auth_service_impl.dart`).
- **Why deferred:** The 04-05 plan is a deletion-only fix for `auth_service_impl.dart`. Touching an unrelated screen to fix a Flutter-SDK deprecation would be scope creep. The plan author's "0 issues project-wide" gate was written without awareness of this pre-existing lint; the plan's per-file gate (`flutter analyze lib/data/services/auth_service_impl.dart` → 0 issues) passes.
- **Suggested fix (for a future chore phase):** Replace `onReorder: (oldIndex, newIndex) => ...` with `onReorderItem: ...` and adjust the newIndex parameter per the Flutter 3.41+ migration note.
