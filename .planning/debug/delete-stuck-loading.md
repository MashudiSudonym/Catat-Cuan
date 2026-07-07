---
status: diagnosed
trigger: "Phase 04 UAT — swipe-to-delete backup succeeds but UI stuck in loading state"
created: 2026-07-07T00:00:00Z
updated: 2026-07-07T00:00:00Z
---

## Current Focus

hypothesis: CONFIRMED — the list's loading indicator is driven by a local `_isLoading` bool in `_BackupListScreenState` (NOT an AsyncValue, NOT BackupController). `_loadBackups()` sets `_isLoading = true` (line 33) and only resets it on happy paths (lines 44/49) with NO try/finally. Called fire-and-forget from `_confirmDelete` (line 159). Any exception or non-completion during the post-delete refresh leaves `_isLoading` stuck at true → perpetual CircularProgressIndicator.
test: Trace complete code path; verified BackupController has no delete method; verified use case re-downloads every file header.
expecting: Confirmed — _isLoading has no guaranteed reset.
next_action: Return diagnosis to planner (find_root_cause_only).

## Symptoms

expected: After swiping a backup card and confirming deletion, the backup is removed from the list and the list exits loading state (returns to idle/loaded with refreshed list).
actual: Swipe-to-delete works (backup deleted), but after that the loading state doesn't stop and UI stays in perpetual loading.
errors: None — state-management defect, not a crash.
reproduction: Phase 04 UAT Test 9 — swipe-to-delete a backup in backup list, confirm deletion.
started: Discovered during Phase 04 UAT (on-device).

## Eliminated

- hypothesis: BackupController leaves AsyncValue in AsyncLoading after delete.
  evidence: BackupController (backup_controller.dart) has NO delete method — only createBackup() + reset(). It manages BackupProgress (idle/serializing/uploading/completed/failed) for backup CREATION only. backup_list_screen.dart does not watch backupControllerProvider. Eliminated.
- hypothesis: A separate isLoading on the controller/AsyncValue is stuck.
  evidence: No AsyncValue involved. _isLoading is a plain bool field on the ConsumerState (line 22). Eliminated.

## Evidence

- timestamp: 2026-07-07
  checked: lib/presentation/controllers/backup_controller.dart + .g.dart
  found: BackupController only manages backup creation (BackupProgress: Idle/Serializing/Uploading/Completed/Failed). No delete method. Not watched by BackupListScreen.
  implication: The bug is NOT in the controller. Delete flow lives entirely in the screen widget.

- timestamp: 2026-07-07
  checked: lib/presentation/screens/backup_list_screen.dart (full file)
  found: _BackupListScreenState uses local fields _backups/_isLoading/_error (lines 21-23), NOT Riverpod AsyncValue. Loading indicator at lines 66-67 is gated purely on _isLoading. _loadBackups() (lines 31-53) sets _isLoading=true at line 33, resets ONLY at line 44 (success) and line 49 (failure), both inside `if (mounted)`. NO try/catch/finally anywhere in the method.
  implication: Any exception thrown between line 33 and lines 44/49, OR any await that never completes, leaves _isLoading stuck at true → perpetual loading.

- timestamp: 2026-07-07
  checked: _confirmDelete (backup_list_screen.dart lines 124-168)
  found: On delete success, line 159 calls `_loadBackups();` WITHOUT await and with NO .catchError/.whenComplete. Fire-and-forget.
  implication: If _loadBackups() throws or hangs after a successful delete, the exception is completely unhandled (silent Zone error), and _isLoading stays true. The delete SnackBar already showed ("Backup dihapus"), so the user believes delete succeeded while the list spins forever.

- timestamp: 2026-07-07
  checked: lib/domain/usecases/backup/list_backups_usecase.dart
  found: call() (lines 27-59) is wrapped in try/catch returning Result.failure on error — so it RETURNS a Result rather than throwing in most cases. HOWEVER, for EVERY listed file it calls _buildPreview (lines 42-48) which does `await _driveService.downloadFile(fileId: file.id)` (line 71) to fetch each backup's header. After a delete, Drive's eventual consistency can still list the just-deleted file; downloading it is the most fragile point of the refresh.
  implication: The post-delete refresh is network-heavy (re-downloads every remaining backup). A stall/non-completion here during the refresh freezes _isLoading. The use case's own try/catch does NOT protect the screen, because the screen's _isLoading is never wrapped in try/finally.

- timestamp: 2026-07-07
  checked: lib/data/repositories/backup/backup_write_repository_impl.dart deleteBackup (lines 60-62)
  found: `return _driveService.deleteFile(fileId: fileId);` — NO try/catch. If deleteFile throws, the exception propagates through DeleteBackupUseCase into _confirmDelete (also no try/catch). But this would PREVENT reaching _loadBackups(), so _isLoading would stay false — does not match symptom. Confirms delete itself succeeds and _loadBackups() IS invoked.

- timestamp: 2026-07-07
  checked: .planning/phases/04-cloud-backup/04-UAT.md Test 9 (lines 56-60) and Gap (lines 116-124)
  found: UAT confirms exactly: "swipe to delete works, but after that loading doesn't stop and gets stuck in loading state." severity: major. root_cause was empty — this session fills it.

## Resolution

root_cause: In lib/presentation/screens/backup_list_screen.dart, the backup-list loading indicator is driven by a plain local bool `_isLoading` (line 22) on _BackupListScreenState — NOT by Riverpod AsyncValue and NOT by BackupController (which has no delete method and isn't watched here). `_loadBackups()` sets `_isLoading = true` at line 33 but only resets it on the two happy paths (line 44 success, line 49 failure), with NO try/finally guaranteeing the reset. After a successful delete, `_confirmDelete()` calls `_loadBackups()` fire-and-forget at line 159 (no await, no catchError/whenComplete). The post-delete refresh re-runs ListBackupsUseCase, which re-downloads every remaining backup file header (list_backups_usecase.dart lines 42-48, 71) — a network-heavy path that is most fragile right after a delete (Drive eventual consistency may still list the deleted file). When that refresh throws an uncaught exception or fails to complete, `_isLoading` is never reset to false, so `_buildBody` (line 66-67) renders the CircularProgressIndicator forever. The "Backup dihapus" SnackBar already fired, so the user sees a successful delete followed by an infinite spinner.
fix: (planner decides) Wrap _loadBackups() body in try/finally so `_isLoading = false` is guaranteed; and/or await it in _confirmDelete with proper error handling; ideally migrate the list to Riverpod AsyncValue (AsyncNotifier) so loading/data/error transitions are handled correctly, consistent with AGENTS.md Riverpod guidance.
verification:
files_changed: []
