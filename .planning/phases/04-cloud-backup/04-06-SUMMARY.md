---
phase: 04-cloud-backup
plan: 06
subsystem: database
tags: [sqflite, transactions, riverpod, google-sign-in, restore, gap-closure]

# Dependency graph
requires:
  - phase: 04-05
    provides: "AuthServiceImpl.signIn() that completes OAuth (unblocks the auth path the three UAT gaps run through)"
provides:
  - "Restore writes run inside the real sqflite transaction (no lock contention, no 10s warning, batched inserts)"
  - "Backup list loading state is guaranteed to clear after delete (try/finally + awaited refresh)"
  - "Cold-start silent session restore via signInSilently() — refreshToken() wired through AuthRepository, persisted email read back"
affects: [restore-flow, backup-list-ui, auth-controller]

# Tech tracking
tech-stack:
  added: []  # no new packages — all three fixes reuse existing abstractions
  patterns:
    - "Txn-scoped LocalDataSource adapter (_TxnDataSource) — a sqflite Transaction (IS-A DatabaseExecutor) wrapped in the LocalDataSource vocabulary so callers write the same code whether or not they are inside a txn"
    - "try/finally loading-state guarantee on async StatefulWidgets (clears _isLoading on every exit path)"
    - "Two-stage cold-start session restore: fast in-memory check, then persisted-hint-driven silent refresh with stale-hint eviction on failure"

key-files:
  created: []
  modified:
    - lib/data/datasources/local/local_data_source.dart
    - lib/data/datasources/local/sqlite_data_source.dart
    - lib/data/services/backup_restore_service.dart
    - test/data/services/backup_restore_service_test.dart
    - lib/presentation/screens/backup_list_screen.dart
    - lib/domain/repositories/backup/auth_repository.dart
    - lib/data/repositories/backup/auth_repository_impl.dart
    - lib/presentation/controllers/auth_controller.dart

key-decisions:
  - "Txn adapter over a narrower executor type: BackupRestoreService already speaks the LocalDataSource vocabulary, so wrapping the sqflite Transaction in a _TxnDataSource lets the caller's method calls stay unchanged — only the target instance changes (minimal-diff, lowest-risk)"
  - "One sqflite batch round-trip per table during restore instead of N per-row inserts (all inside the txn) — eliminates both the lock contention and the O(N) insert overhead"
  - "On failed silent restore, evict the stale persisted email via clearBackupMetadata() so subsequent cold starts skip the refreshToken attempt — no dead-session retry loop"
  - "Failure branch of cold-start restore sets AsyncData(null), never AsyncError — an expected cold-start outcome, not a user action; no error surfaced to the UI"

patterns-established:
  - "LocalDataSource.transaction(callback) now receives a txn-scoped source — the canonical way to run multi-table atomic writes against sqflite"
  - "try/finally around async loading state in StatefulWidget screens (pairs with the ErrorMessageMapper convention for caught throws)"

requirements-completed: [BKP-03, BKP-04, BKP-06, BKP-07]

# Coverage metadata (#1602) — mirrors the plan's <coverage> block.
# G1-G8 are auto-verifiable and PASS after this plan's gates. G9-G11 are
# human_judgment (on-device UAT) — pending real-device re-verification.
coverage:
  - id: G1
    description: "LocalDataSource.transaction() passes a txn-scoped LocalDataSource into the callback"
    requirement: BKP-04
    verification:
      - kind: other
        ref: "grep -E 'transaction\\(Future<void> Function\\(LocalDataSource txn\\)' lib/data/datasources/local/local_data_source.dart (line 93)"
        status: pass
      - kind: other
        ref: "flutter analyze lib/data/datasources/local/local_data_source.dart — 0 issues"
        status: pass
    human_judgment: false
  - id: G2
    description: "Every restore write routes through the sqflite Transaction (no outer-db re-entry, no lock warning)"
    requirement: BKP-04
    verification:
      - kind: other
        ref: "grep -E '_TxnDataSource\\(sqfTxn\\)' lib/data/datasources/local/sqlite_data_source.dart (line 125)"
        status: pass
      - kind: other
        ref: "negative grep: ! grep -E 'db\\.transaction\\(\\(_\\)' lib/data/datasources/local/sqlite_data_source.dart — absent"
        status: pass
      - kind: unit
        ref: "test/data/services/backup_restore_service_test.dart — batch-insert contract asserted (batchInsert called once per table, insert() verifyNever)"
        status: pass
    human_judgment: false
  - id: G3
    description: "restoreFromData() failure message no longer interpolates raw exception text (AGENTS.md Rule 4)"
    requirement: BKP-07
    verification:
      - kind: other
        ref: "negative fixed-string grep: ! grep -F 'Gagal memulihkan data: $e' lib/data/services/backup_restore_service.dart — absent; exception logged via AppLogger.e only"
        status: pass
    human_judgment: false
  - id: G4
    description: "_loadBackups() guarantees _isLoading=false via try/finally on every exit path"
    requirement: BKP-03
    verification:
      - kind: other
        ref: "grep -E 'finally \\{' lib/presentation/screens/backup_list_screen.dart (line 48)"
        status: pass
      - kind: other
        ref: "flutter analyze lib/presentation/screens/backup_list_screen.dart — 0 issues"
        status: pass
    human_judgment: false
  - id: G5
    description: "_confirmDelete() awaits the post-delete refresh and surfaces an Indonesian message on unexpected throw"
    requirement: BKP-03
    verification:
      - kind: other
        ref: "grep -E 'await _loadBackups\\(\\)' lib/presentation/screens/backup_list_screen.dart (line 163)"
        status: pass
      - kind: other
        ref: "grep -E 'ErrorMessageMapper.getUserMessage\\(e\\)' lib/presentation/screens/backup_list_screen.dart (line 167)"
        status: pass
    human_judgment: false
  - id: G6
    description: "AuthRepository exposes refreshToken(); AuthController calls it on cold start when a connected email is persisted"
    requirement: BKP-06
    verification:
      - kind: other
        ref: "grep -E 'Future<Result<AuthUser>> refreshToken\\(\\);' lib/domain/repositories/backup/auth_repository.dart (line 31)"
        status: pass
      - kind: other
        ref: "grep -E 'refreshToken\\(\\) => _authService.refreshToken\\(\\);' lib/data/repositories/backup/auth_repository_impl.dart (line 32)"
        status: pass
      - kind: other
        ref: "grep -E 'repo.refreshToken\\(\\)' lib/presentation/controllers/auth_controller.dart (line 59)"
        status: pass
      - kind: other
        ref: "grep -E 'getConnectedAccountEmail' lib/presentation/controllers/auth_controller.dart (line 53)"
        status: pass
    human_judgment: false
  - id: G7
    description: "Initialization stays inside build()/_checkExistingUser() — no constructor init (AGENTS.md Riverpod 3.x)"
    requirement: BKP-06
    verification:
      - kind: other
        ref: "code inspection: _checkExistingUser() invoked from build() (auth_controller.dart:28); AuthController has no named constructor body with side effects"
        status: pass
    human_judgment: false
  - id: G8
    description: "Full test suite green; no regressions from the two interface signature changes"
    verification:
      - kind: unit
        ref: "flutter test — 1156/1156 passing, 0 failures"
        status: pass
    human_judgment: false
  - id: G9
    description: "UAT Test 8 — restore completes in reasonable time with no sqflite lock warning, data matches preview"
    requirement: BKP-04
    verification: []
    human_judgment: true
    rationale: "Requires a real device with a populated database + a Google Drive backup to restore from. The lock-warning symptom only manifests against the real sqflite engine under contention; the in-process unit test cannot reproduce the platform-level lock. This is UAT's job, not this plan's — the plan's automated gates end at flutter test."
  - id: G10
    description: "UAT Test 9 — swipe-to-delete leaves the list in a non-loading state with the deleted backup removed"
    requirement: BKP-03
    verification: []
    human_judgment: true
    rationale: "Requires a real device with >=1 Drive backup to delete; the post-delete refresh's network path (Drive eventual consistency) is the exact fragile trigger the diagnosis names. The try/finally guarantee is unit-greppable, but the end-to-end 'spinner clears' verdict is on-device UAT."
  - id: G11
    description: "UAT Test 12 — after force-stop and reopen, the Google account is silently restored (no re-prompt)"
    requirement: BKP-06
    verification: []
    human_judgment: true
    rationale: "signInSilently() exercises live Google OAuth + the google_sign_in platform plugin; cannot be exercised in CI. Requires a real device with a valid google-services.json + a previously-signed-in account. This is UAT's job — the plan's automated gates end at flutter test."

# Metrics
duration: 12min
completed: 2026-07-07
status: complete
---

# Phase 4 Plan 06: UAT Gap Closure (Restore Lock, Delete Loading, Cold-Start Auth) Summary

**Three surgical root-cause fixes closing the last Phase 04 UAT gaps: a txn-scoped LocalDataSource adapter so restore writes hit the sqflite Transaction, a try/finally loading-state guarantee + awaited post-delete refresh, and cold-start silent session restore wired through AuthRepository.refreshToken().**

## Performance

- **Duration:** 12 min
- **Started:** 2026-07-07T17:29:14Z
- **Completed:** 2026-07-07T17:41:03Z
- **Tasks:** 3
- **Files modified:** 8 (7 source + 1 test)

## Accomplishments

- **Restore runs in a real transaction now.** `LocalDataSource.transaction()` passes a txn-scoped source into the callback; `SqliteDataSource` wraps the sqflite `Transaction` in a `_TxnDataSource` adapter so every restore write (delete + batchInsert) hits the txn, not the outer `Database`. Eliminates the re-entrant locking that produced the 10s sqflite lock warning. Per-row insert loops replaced with one batched `batchInsert` per table.
- **Backup list spinner can't get stuck.** `_loadBackups()` is wrapped in try/finally — `_isLoading` clears on every exit path. `_confirmDelete()` now awaits the refresh (was fire-and-forget); any unexpected throw surfaces an Indonesian message via `ErrorMessageMapper`, never raw exception text.
- **Cold-start session restore works.** `refreshToken()` (which calls `signInSilently()`) was dead code with zero callers — now exposed on `AuthRepository` and called from `AuthController._checkExistingUser()` when a connected email is persisted. On failure the stale hint is cleared so a dead session isn't retried every cold start.
- **Closed a pre-existing error-text leak.** `BackupFailure.unknown('Gagal memulihkan data: $e')` is now `'Gagal memulihkan data'` with the exception logged via `AppLogger` (AGENTS.md Rule 4).

## Task Commits

Each task was committed atomically:

1. **Task 1: Thread txn-scoped LocalDataSource through transaction() and batch restore writes (UAT Test 8)** — `060bb58` (fix)
2. **Task 2: Guarantee backup-list loading state clears after delete (UAT Test 9)** — `ba77019` (fix)
3. **Task 3: Cold-start silent session restore via refreshToken() (UAT Test 12)** — `ffd9cbb` (fix)

## Files Created/Modified

- `lib/data/datasources/local/local_data_source.dart` — `transaction()` callback signature now receives a txn-scoped `LocalDataSource`.
- `lib/data/datasources/local/sqlite_data_source.dart` — `transaction()` wraps the sqflite `Transaction` in `_TxnDataSource`; new private adapter class delegates insert/delete/update/query/batchInsert/batchUpdate/rawQuery to the executor.
- `lib/data/services/backup_restore_service.dart` — `restoreFromData()` routes all writes through the txn-scoped source + `batchInsert`; `$e` leak closed, exception logged via `AppLogger`.
- `test/data/services/backup_restore_service_test.dart` — 2 happy/empty stubs updated to the new callback signature; failing-path stub left unchanged (throw-before-capture). Assertions lock in the batch-insert contract. `AppLogger.initialize()` added to setUp.
- `lib/presentation/screens/backup_list_screen.dart` — `_loadBackups()` try/finally; `_confirmDelete()` awaits the refresh with try/catch.
- `lib/domain/repositories/backup/auth_repository.dart` — `refreshToken()` added to the contract.
- `lib/data/repositories/backup/auth_repository_impl.dart` — `refreshToken()` delegated to `AuthService`.
- `lib/presentation/controllers/auth_controller.dart` — `_checkExistingUser()` rewritten as two-stage restore (in-memory fast path + persisted-hint silent refresh).

## Decisions Made

- **Adapter over a narrower executor type.** `BackupRestoreService` already speaks the `LocalDataSource` vocabulary, so wrapping the sqflite `Transaction` in a `_TxnDataSource` keeps the caller's method calls unchanged — only the target instance changes. Minimal-diff, lowest-risk.
- **Batched inserts per table.** One sqflite batch round-trip per table (inside the txn) instead of N per-row inserts — fixes both the lock contention and the O(N) overhead in one move.
- **Evict the stale hint on failed silent restore.** `clearBackupMetadata()` after a failed `refreshToken()` prevents a dead-session retry loop on every cold start.
- **Failure branch sets `AsyncData(null)`, never `AsyncError`.** A failed cold-start silent restore is an expected outcome, not a user action — surfacing it as an error would confuse the user.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Regenerated stale Mockito mocks after the `LocalDataSource.transaction()` signature change**
- **Found during:** Task 1 (verify gate)
- **Issue:** Changing the interface signature made the generated `MockLocalDataSource.transaction(...)` in `backup_restore_service_test.mocks.dart` stale — test compilation failed with a parameter-type mismatch.
- **Fix:** Ran `flutter pub run build_runner build --delete-conflicting-outputs` to regenerate the mock from the `@GenerateNiceMocks` annotation. (`.mocks.dart` files are gitignored, so no tracked file changed.)
- **Files modified:** none tracked (generated file regenerated)
- **Verification:** `flutter test test/data/services/backup_restore_service_test.dart` — 3/3 passing
- **Committed in:** n/a (generated artifact, gitignored)

**2. [Rule 3 - Blocking] Regenerated stale Mockito mocks after adding `refreshToken()` to `AuthRepository`**
- **Found during:** Task 3 (verify gate)
- **Issue:** Adding `refreshToken()` to the `AuthRepository` contract made the generated `MockAuthRepository` in `create_backup_usecase_test.mocks.dart` and `restore_backup_usecase_test.mocks.dart` stale.
- **Fix:** Ran `flutter pub run build_runner build --delete-conflicting-outputs` again. (Nice mocks return defaults for unstubbed methods, so the new method needs no test-side stubbing.)
- **Files modified:** none tracked (generated files regenerated)
- **Verification:** `flutter test` — 1156/1156 passing
- **Committed in:** n/a (generated artifacts, gitignored)

**3. [Rule 1 - Bug] Added `AppLogger.initialize()` to the restore-service test setUp**
- **Found during:** Task 1 (verify gate)
- **Issue:** The new `AppLogger.e('Restore failed', ...)` call in the catch block of `restoreFromData()` threw `StateError: AppLogger not initialized` when the failing-path test exercised the catch block. (Previously the catch block did not touch AppLogger.)
- **Fix:** Added `AppLogger.initialize();` to the test's `setUp` and imported `app_logger.dart` — the established codebase convention (17 other tests do exactly this).
- **Files modified:** test/data/services/backup_restore_service_test.dart
- **Verification:** failing-path test now passes; `flutter analyze` clean
- **Committed in:** `060bb58` (part of Task 1 commit)

---

**Total deviations:** 3 auto-fixed (2 blocking, 1 bug) — all necessary for compilation/test correctness.
**Impact on plan:** Zero scope creep. All three fixes are directly caused by this plan's changes and follow existing codebase conventions. The two build_runner regenerations are the stale-`.g.dart` escape hatch the plan's verification note explicitly anticipates ("If flutter analyze ever reports a stale .g.dart, run build_runner").

## Issues Encountered

None beyond the auto-fixes above. The plan's line-level `<action>` blocks were accurate; all three tasks executed on the first attempt after the mock/test-harness fixes.

## Threat Surface

No new threat surface. All three fixes operate inside existing trust boundaries (App -> SQLite; App -> Google Sign-In / Drive). The plan's `<threat_model>` register (T-04-19 through T-04-23) covers every change here; nothing additional surfaced.

## Known Stubs

None. All three fixes are end-to-end wired: the txn adapter delegates to the real sqflite executor, the loading-state guarantee runs on the real list-refresh path, and `refreshToken()` delegates to the real `signInSilently()`.

## Deferred Items

| Category | Item | Status | Deferred At |
|----------|------|--------|-------------|
| hardening | Migrate `_BackupListScreenState` to `AsyncNotifier`/`AsyncValue` (durable loading-state handling vs. the current manual `_isLoading`/`_error` fields) | Open | 2026-07-07 (04-06 PRESERVE note) |

The try/finally + await fix is the correct, lowest-risk gap closure. The `AsyncNotifier` migration is a durable refactor that belongs in a hardening pass, not a gap-closure plan.

## Next Phase Readiness

- All automated gates green: `flutter analyze` 0 issues on all 8 files; `flutter test` 1156/1156 passing.
- The three UAT gaps (Tests 8, 9, 12) are code-ready for on-device re-verification (human_judgment items G9-G11). They require a real device with a valid `google-services.json` and a previously-signed-in Google account — this is UAT's job, not this plan's.
- Phase 5 (Enhanced Reports) remains the next phase, pending the on-device UAT re-verification of Tests 2, 8, 9, 12.

---
*Phase: 04-cloud-backup*
*Completed: 2026-07-07*

## Self-Check: PASSED

**Files exist:**
- FOUND: lib/data/datasources/local/local_data_source.dart
- FOUND: lib/data/datasources/local/sqlite_data_source.dart
- FOUND: lib/data/services/backup_restore_service.dart
- FOUND: test/data/services/backup_restore_service_test.dart
- FOUND: lib/presentation/screens/backup_list_screen.dart
- FOUND: lib/domain/repositories/backup/auth_repository.dart
- FOUND: lib/data/repositories/backup/auth_repository_impl.dart
- FOUND: lib/presentation/controllers/auth_controller.dart

**Commits exist:**
- FOUND: 060bb58 — fix(backup): thread txn-scoped LocalDataSource through restore writes (04-06 task 1)
- FOUND: ba77019 — fix(backup): guarantee list loading state clears after delete (04-06 task 2)
- FOUND: ffd9cbb — fix(backup): cold-start silent session restore via refreshToken (04-06 task 3)
