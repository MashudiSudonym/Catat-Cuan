---
status: diagnosed
trigger: "Investigate restore-db-lock: during cloud backup restore, the process takes too long and sqflite emits \"The database has been locked for 0:00:10.000000. Make sure you always use the transaction object for database operations during a transaction.\""
created: 2026-07-07T00:00:00Z
updated: 2026-07-07T00:00:00Z
---

## Current Focus
<!-- OVERWRITE on each update - reflects NOW -->

hypothesis: CONFIRMED. `LocalDataSource.transaction()` has a no-arg callback and `SqliteDataSource.transaction()` discards the sqflite `Transaction` object (sqlite_data_source.dart:123). `insert()`/`delete()` always use the outer `db`. So all 10 ops inside `BackupRestoreService.restoreFromData()` transaction callback re-enter the outer DB while the txn holds its lock → 10s lock warning + slow restore.
test: Read sqlite_data_source.dart + backup_restore_service.dart + local_data_source.dart + grep for transaction callers.
expecting: Find the txn object discarded and inner ops using outer db. CONFIRMED — see Evidence.
next_action: Diagnose-only mode — return ROOT CAUSE FOUND. No fix applied.

## Symptoms
<!-- Written during gathering, then IMMUTABLE -->

expected: After confirming restore with the GANTI keyword, restore shows progress states (downloading → restoring → completed) in reasonable time, and all data in the app matches the backup preview.
actual: The restore process is taking too long, and the log displays: "Warning: The database has been locked for 0:00:10.000000. Make sure you always use the transaction object for database operations during a transaction."
errors: "Warning: The database has been locked for 0:00:10.000000. Make sure you always use the transaction object for database operations during a transaction." (sqflite warning)
reproduction: UAT Test 8 — perform a restore from a backup preview with the GANTI confirmation.
started: Discovered during Phase 04 UAT (on-device).

## Eliminated
<!-- APPEND only - prevents re-investigating -->

## Evidence
<!-- APPEND only - facts discovered -->

- timestamp: 2026-07-07T00:00:00Z
  checked: 04-03-SUMMARY.md lines 82-86 (deviation note)
  found: Plan originally specified `transaction(Future<void> Function(LocalDataSource) action)` (callback receives txn-bound data source). Implementation "fixed a signature mismatch" by making the callback NO-ARG and "access LocalDataSource methods directly via this" — i.e. dropped the txn object.
  implication: The txn object was lost during implementation. Every write inside the callback would route through the outer db.

- timestamp: 2026-07-07T00:00:00Z
  checked: lib/data/datasources/local/sqlite_data_source.dart lines 121-124
  found: `transaction(Future<void> Function() action)` => `db.transaction((_) async => await action())`. The sqflite `Transaction` object is the `_` parameter — explicitly discarded. The action callback receives no txn reference.
  implication: This is the literal sqflite anti-pattern the warning names: "Make sure you always use the transaction object for database operations during a transaction." The txn object is unavailable to the callback by design.

- timestamp: 2026-07-07T00:00:00Z
  checked: lib/data/datasources/local/sqlite_data_source.dart lines 67-70 (insert) and 111-118 (delete)
  found: Both methods do `final db = await _database; return db.insert(...)` / `db.delete(...)`. They always use the outer Database, never any txn. There is no code path that lets them target a Transaction.
  implication: Any insert/delete called inside a transaction callback will re-enter the outer db while the txn holds its lock → sqflite serializes, waits, emits the 10s lock warning.

- timestamp: 2026-07-07T00:00:00Z
  checked: lib/data/services/backup_restore_service.dart lines 34-81
  found: The ENTIRE restoreFromData() body. Opens `_localDataSource.transaction(() async { ... })`. Inside the callback: 5 `_localDataSource.delete(...)` calls + 5 per-row insert loops (`for (...) await _localDataSource.insert(...)`) across categories, transactions, budgets, savings_goals, goal_contributions. Total = 5 deletes + N inserts (one per restored row), ALL routed through the outer db.
  implication: Every one of these ops triggers lock contention against the open transaction. With many rows this means many seconds of contention — matches "takes too long" + "locked for 0:00:10" exactly.

- timestamp: 2026-07-07T00:00:00Z
  checked: grep `\.transaction\(` across lib/
  found: Exactly 2 matches: the definition (sqlite_data_source.dart:123) and the single caller (backup_restore_service.dart:36). No other transaction sites exist in the codebase.
  implication: Blast radius is narrow and contained — fixing the transaction API + this one caller fixes the bug with no collateral damage.

- timestamp: 2026-07-07T00:00:00Z
  checked: lib/data/datasources/local/local_data_source.dart line 92
  found: Abstract `transaction(Future<void> Function() action)` — interface itself has no way to pass a txn-bound executor to the callback. The abstraction enforces the bug: any implementer must discard the txn (or break the interface).
  implication: Fix requires changing the interface signature so the callback receives a txn-scoped LocalDataSource (or equivalent).

- timestamp: 2026-07-07T00:00:00Z
  checked: secondary slowness factor — per-row insert loops in backup_restore_service.dart lines 55-77
  found: Each table is inserted via `for (final row in rows) { await _localDataSource.insert(table, row); }`. There is already a `batchInsert(table, values)` method on LocalDataSource (lines 48-54) that uses sqflite batch — but it is unused here, and it ALSO currently routes through `db.batch()` (sqlite_data_source.dart:72-82) so it would need the same txn-aware treatment to help inside a transaction.
  implication: Lock warning is caused purely by the txn-object mismatch. Slowness has two compounding causes: (a) the lock contention, (b) per-row inserts instead of batched inserts. Fix (a) is required to clear the warning; fix (b) is recommended for speed.

## Resolution
<!-- OVERWRITE as understanding evolves -->

root_cause: |
  `LocalDataSource.transaction()` exposes a NO-ARG callback, and `SqliteDataSource.transaction()` (lib/data/datasources/local/sqlite_data_source.dart:121-124) opens a real sqflite transaction but DISCARDS the sqflite `Transaction` object:
    `db.transaction((_) async => await action())`
  The `_` is the Transaction; it is never passed to the action.

  `SqliteDataSource.insert()` (lines 67-70) and `delete()` (lines 111-118) always resolve `final db = await _database` and call `db.insert(...)` / `db.delete(...)` — i.e. they always target the OUTER Database, never the Transaction. There is no API path that targets a txn.

  `BackupRestoreService.restoreFromData()` (lib/data/services/backup_restore_service.dart:34-81) wraps all restore writes in `_localDataSource.transaction(() async { ... })`. Inside the callback it performs 5 deletes + 5 per-row insert loops (categories, transactions, budgets, savings_goals, goal_contributions) — ALL via `_localDataSource.insert/delete`, which re-enter the outer Database while the transaction holds its lock.

  sqflite serializes access to the single DB connection; re-entrant calls from inside the txn callback wait on the lock the txn itself holds, hit the 10-second lock threshold, emit the warning, then force through one at a time. Result: warning + slow restore. This is precisely the anti-pattern named in the sqflite message.

  Architectural origin: 04-03-SUMMARY.md (lines 82-86) documents that the plan originally specified `transaction(Future<void> Function(LocalDataSource) action)` — i.e. a txn-bound data source passed into the callback — but during implementation the team hit a signature mismatch and "fixed" it by dropping the argument, silently losing the txn object. The interface (local_data_source.dart:92) now codifies this lossy shape.

fix: (diagnose-only — not applied) Pass a txn-scoped executor into the transaction callback so inner writes go through the sqflite `Transaction` object, not the outer `Database`. Switch per-row insert loops to txn-bound batch inserts for speed.
verification:
files_changed: []
