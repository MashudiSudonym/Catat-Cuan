---
status: diagnosed
phase: 04-cloud-backup
source: 04-01-SUMMARY.md, 04-02-SUMMARY.md, 04-03-SUMMARY.md, 04-04-SUMMARY.md, 04-05-SUMMARY.md
started: 2026-06-03T00:00:00Z
updated: 2026-07-07T00:00:00Z
reverify_after_fix: 04-05
---

## Current Test

[testing complete]

## Tests

### 1. Settings shows Backup & Restore section
expected: Open Settings screen. Scroll down — there should be a "Backup & Restore" section between Data and App Info sections, with a navigation item to open the backup screen.
result: pass

### 2. Backup screen shows Google Sign-In prompt
expected: Navigate to Backup screen from Settings. When not connected, you should see a prompt/button to sign in with your Google account (e.g., "Hubungkan Akun Google" or similar).
result: pass
reverify: true
prior_result: issue
prior_reported: "I can't find the 'connect Google account' button, but there is a 'create backup' button. When I click the 'create backup' button, it connects to my Google account, but it fails. There's no error log that explains why the Google account connection failed."
prior_reported_2: "Dedicated 'Hubungkan Akun Google' button now shows (fix 04-04 worked), but tapping it fails: UnimplementedError: canAccessScopes() has not been implemented. Stack: AuthServiceImpl.signIn (auth_service_impl.dart:41) -> GoogleSignIn.canAccessScopes. Log: '⛔ Google sign-in failed'."
resolved_by: "04-05 (deleted redundant canAccessScopes/requestScopes block)"
note: "User confirmed sign-in flow now completes without UnimplementedError on re-verification (2026-07-07)."

### 3. Google Sign-In authenticates successfully
expected: Tap the sign-in button. Google Sign-In flow should appear. After authenticating, the backup screen should show the connected account email. The app should only request drive.appdata scope (no full Drive access prompt).
result: pass

### 4. Create backup with progress indicator
expected: With a connected account, tap "Buat Backup" button. You should see a progress indicator showing stages (serializing → uploading → completed). After completion, the screen should show the backup was created successfully and display the last backup date.
result: pass

### 5. View backup list
expected: From Backup screen, navigate to backup list. You should see all backups listed as glass cards with date, size, device info, and data summary. List should be sorted newest first. Pull-to-refresh should work.
result: pass

### 6. Preview backup before restore
expected: Tap on a backup in the list. A preview screen should open showing a data comparison table — "Backup" column vs "Saat Ini" (current) column with counts for transactions, categories, budgets, goals, and contributions.
result: pass

### 7. Destructive restore confirm with GANTI keyword
expected: From the preview screen, tap the restore button. A destructive confirmation dialog should appear requiring you to type "GANTI" to proceed. The confirm button should only become active when "GANTI" is typed exactly.
result: pass

### 8. Restore completes with progress
expected: After confirming with GANTI, restore should show progress states (downloading → restoring → completed). After completion, all data in the app should match the backup preview (transactions, categories, budgets, goals restored).
result: issue
reported: "The restore process is taking too long, and the log also displays a message like this: \"Warning: The database has been locked for 0:00:10.000000. Make sure you always use the transaction object for database operations during a transaction.\""
severity: major

### 9. Swipe to delete backup
expected: In the backup list, swipe a backup card to reveal a delete action. Confirm deletion. The backup should be removed from the list.
result: issue
reported: "swipe to delete works, but after that loading doesn't stop and gets stuck in loading state."
severity: major

### 10. Error messages display in Indonesian
expected: If an error occurs (e.g., no internet, token expired, quota exceeded), the error message shown to the user should be in Indonesian (not English, not technical error details). Examples: "Gagal menghubungkan", "Kuota penyimpanan penuh", etc.
result: skipped
reason: "User skipped — error condition hard to trigger during this session"

### 11. Auto-cleanup keeps only 5 newest backups
expected: After creating more than 5 backups, navigate to the backup list. Only the 5 most recent backups should be visible. Older ones are automatically cleaned up on Drive.
result: skipped
reason: "User skipped — would require creating >5 backups to verify"

### 12. Auth token refresh works automatically
expected: After signing in, close the app, wait a bit (or simulate token expiry), then reopen and try to create a backup. The app should automatically refresh the expired token and proceed without asking to sign in again.
result: issue
reported: "After the application is closed and reopened, the connection to the Google account is lost, and it asks to sign in again."
severity: major

## Summary

total: 12
passed: 7
issues: 3
pending: 0
skipped: 2
blocked: 0

## Gaps

- truth: "Tapping 'Hubungkan Akun Google' completes Google Sign-In and connects the account"
  status: resolved
  reason: "User reported: Dedicated button now shows (fix 04-04 worked), but tapping it fails with UnimplementedError: canAccessScopes() has not been implemented. Stack: AuthServiceImpl.signIn (auth_service_impl.dart:41) -> GoogleSignIn.canAccessScopes. Log shows '⛔ Google sign-in failed'."
  severity: blocker
  test: 2
  resolved_by: "04-05 (deleted redundant canAccessScopes/requestScopes block in auth_service_impl.dart:40-53)"
  resolved_on: "2026-07-07 — user confirmed sign-in flow completes without UnimplementedError on re-verification"
  root_cause: "AuthServiceImpl.signIn() calls _googleSignIn.canAccessScopes([driveAppDataScope]) at auth_service_impl.dart:41. canAccessScopes() throws UnimplementedError on the google_sign_in platform interface (requires serverClientId, which is not set). This call is REDUNDANT: the drive.appdata scope is already declared in the GoogleSignIn constructor (service_providers.dart:99-101), and signIn() requests constructor scopes automatically during the OAuth flow. The canAccessScopes/requestScopes two-step was never reachable and is the sole cause of the sign-in failure."
  artifacts:
    - path: "lib/data/services/auth_service_impl.dart"
      issue: "Lines 40-53: redundant canAccessScopes()+requestScopes() block; canAccessScopes throws UnimplementedError. Scope is already in the GoogleSignIn constructor."
    - path: "lib/presentation/providers/services/service_providers.dart"
      issue: "Lines 98-102: GoogleSignIn already constructed with scopes: [drive.appdata] — this is the correct, working path."
  missing:
    - "Delete the canAccessScopes/requestScopes block (auth_service_impl.dart:40-53) — signIn() will request the constructor-declared drive.appdata scope automatically."
  debug_session: ""

- truth: "Restore completes in reasonable time with progress states (downloading → restoring → completed) and data matches the backup preview"
  status: failed
  reason: "User reported: The restore process is taking too long, and the log also displays a message like this: \"Warning: The database has been locked for 0:00:10.000000. Make sure you always use the transaction object for database operations during a transaction.\""
  severity: major
  test: 8
  root_cause: "SqliteDataSource.transaction() (sqlite_data_source.dart:121-124) opens db.transaction((_) async => await action()) and DISCARDS the sqflite Transaction object (_). insert() (line 67-70) and delete() (line 111-118) unconditionally target the outer Database, never a Transaction. BackupRestoreService.restoreFromData() (backup_restore_service.dart:34-81) runs all restore writes (5 deletes + 5 per-row insert loops) inside transaction(() { ... }) but every op re-enters the outer db while the txn holds its lock -> re-entrant locking, 10s lock warning, slow restore. The abstraction itself (local_data_source.dart:92 transaction(Future<void> Function())) has no way to pass a txn-bound executor into the callback."
  artifacts:
    - path: "lib/data/datasources/local/sqlite_data_source.dart"
      issue: "Lines 121-124: transaction() discards the sqflite Transaction; lines 67-70 (insert) and 111-118 (delete) always use the outer db, never txn."
    - path: "lib/data/datasources/local/local_data_source.dart"
      issue: "Line 92: abstract transaction(Future<void> Function() action) gives the callback no txn-bound executor."
    - path: "lib/data/services/backup_restore_service.dart"
      issue: "Lines 34-81: sole transaction() caller; all restore writes go through _localDataSource.insert/delete (outer db) inside the txn callback."
  missing:
    - "Change transaction() signature to pass a txn-scoped data source into the callback: Future<void> transaction(Future<void> Function(LocalDataSource txn) action)."
    - "In SqliteDataSource.transaction(), wrap the sqflite Transaction in an adapter whose insert/delete/update/query/batchInsert delegate to txn.*."
    - "Update BackupRestoreService.restoreFromData() to use the txn-scoped data source for all writes."
    - "Secondary speedup: replace per-row for(...) await insert(...) loops with txn-bound batchInsert(...) per table."
  debug_session: .planning/debug/restore-db-lock.md

- truth: "After deleting a backup via swipe, the list refreshes and exits the loading state with the deleted backup removed"
  status: failed
  reason: "User reported: swipe to delete works, but after that loading doesn't stop and gets stuck in loading state."
  severity: major
  test: 9
  root_cause: "BackupListScreen uses a plain local bool _isLoading (backup_list_screen.dart:22), NOT an AsyncValue and NOT BackupController (which has no deleteBackup method and is not watched by this screen). _loadBackups() sets _isLoading=true (line 33) and resets it ONLY on the two happy paths (line 44 success, line 49 failure) with NO try/finally guarantee. After a successful delete, _confirmDelete() calls _loadBackups() fire-and-forget at line 159 (no await, no catchError/whenComplete). When the post-delete refresh throws or stalls (ListBackupsUseCase re-downloads every remaining backup header via Drive, fragile right after a delete), _isLoading is orphaned at true and _buildBody (lines 66-67) renders the CircularProgressIndicator forever."
  artifacts:
    - path: "lib/presentation/screens/backup_list_screen.dart"
      issue: "Line 22 bool _isLoading=true; lines 31-53 _loadBackups() sets true (33), resets only at 44/49 with no try/finally; lines 66-67 render spinner when _isLoading; line 159 _loadBackups() called fire-and-forget after delete."
    - path: "lib/domain/usecases/backup/list_backups_usecase.dart"
      issue: "Lines 42-48,71: refresh re-downloads every backup header; fragile right after delete (Drive eventual consistency) — the trigger exposing the missing-reset defect."
  missing:
    - "Wrap _loadBackups() body in try { ... } finally { if (mounted) setState(() => _isLoading = false); } so loading is guaranteed to clear."
    - "In _confirmDelete(), await _loadBackups() (with try/catch surfacing an Indonesian error via ErrorMessageMapper) or attach .catchError/.whenComplete."
    - "Durable: migrate the backup list to an AsyncNotifier returning AsyncValue<List<BackupPreview>> and render via .when(data/loading/error) so transitions are correct by construction."
  debug_session: .planning/debug/delete-stuck-loading.md

- truth: "After app restart, the app silently refreshes the token / restores the signed-in Google account without asking the user to sign in again"
  status: failed
  reason: "User reported: After the application is closed and reopened, the connection to the Google account is lost, and it asks to sign in again."
  severity: major
  test: 12
  root_cause: "Missing silent-restore on cold start. AuthController.build()/_checkExistingUser() (auth_controller.dart:27-40) calls ONLY AuthRepository.getSignedInUser(), whose impl (auth_service_impl.dart:63-77) synchronously reads _googleSignIn.currentUser. google_sign_in does NOT hydrate currentUser across cold starts without an explicit signInSilently(), so this always yields Result.success(null) -> state AsyncData(null) -> BackupScreen renders signed-out. The correct silent-restore method AuthServiceImpl.refreshToken() (auth_service_impl.dart:79-103, calls signInSilently() at line 83) EXISTS but has ZERO callers — it is dead code. Secondary: the persisted SharedPreferences connected-email (written at auth_controller.dart:49 via setConnectedAccountEmail) is never read back — getConnectedAccountEmail() has no callers — so there is no fallback signal to even attempt a restore."
  artifacts:
    - path: "lib/presentation/controllers/auth_controller.dart"
      issue: "Lines 27-40: build()/_checkExistingUser() use getSignedInUser() (sync read, null on cold start) instead of refreshToken()/signInSilently(); never consult the persisted email."
    - path: "lib/data/services/auth_service_impl.dart"
      issue: "Lines 63-77 getSignedInUser() is sync-read-only (cannot restore across cold starts); lines 79-103 refreshToken() is the correct restore path but is uncalled (dead code)."
    - path: "lib/data/services/shared_preferences_service.dart"
      issue: "Line ~70 getConnectedAccountEmail() defined but never invoked — persisted restore-hint signal unused."
  missing:
    - "In AuthController._checkExistingUser()/build(), read persisted connected-email via SharedPreferencesService.getConnectedAccountEmail(); if non-empty, call authRepository.refreshToken() (signInSilently) and seed state from the result."
    - "On success -> AsyncData(authUser); on failure -> AsyncData(null) and clear the stale persisted email."
    - "Keep initialization inside build() per AGENTS.md (do NOT move to constructor)."
  debug_session: .planning/debug/auth-lost-on-restart.md
