---
status: diagnosed
phase: 04-cloud-backup
source: 04-01-SUMMARY.md, 04-02-SUMMARY.md, 04-03-SUMMARY.md
started: 2026-06-03T00:00:00Z
updated: 2026-06-30T00:00:00Z
reverify_after_fix: 04-04
---

## Current Test

[testing paused — blocker on test 2, root cause diagnosed, fix ready to plan]

## Tests

### 1. Settings shows Backup & Restore section
expected: Open Settings screen. Scroll down — there should be a "Backup & Restore" section between Data and App Info sections, with a navigation item to open the backup screen.
result: pass

### 2. Backup screen shows Google Sign-In prompt
expected: Navigate to Backup screen from Settings. When not connected, you should see a prompt/button to sign in with your Google account (e.g., "Hubungkan Akun Google" or similar).
result: issue
reverify: true
prior_result: issue
prior_reported: "I can't find the 'connect Google account' button, but there is a 'create backup' button. When I click the 'create backup' button, it connects to my Google account, but it fails. There's no error log that explains why the Google account connection failed."
reported: "Dedicated 'Hubungkan Akun Google' button now shows (fix 04-04 worked), but tapping it fails: UnimplementedError: canAccessScopes() has not been implemented. Stack: AuthServiceImpl.signIn (auth_service_impl.dart:41) -> GoogleSignIn.canAccessScopes. Log: '⛔ Google sign-in failed'."
severity: blocker

### 3. Google Sign-In authenticates successfully
expected: Tap the sign-in button. Google Sign-In flow should appear. After authenticating, the backup screen should show the connected account email. The app should only request drive.appdata scope (no full Drive access prompt).
result: blocked
blocked_by: prior-phase
reason: "Couldn't log in to Google account, blocked by auth failure from Test 2"

### 4. Create backup with progress indicator
expected: With a connected account, tap "Buat Backup" button. You should see a progress indicator showing stages (serializing → uploading → completed). After completion, the screen should show the backup was created successfully and display the last backup date.
result: blocked
blocked_by: prior-phase
reason: "Blocked by auth failure from Test 2"

### 5. View backup list
expected: From Backup screen, navigate to backup list. You should see all backups listed as glass cards with date, size, device info, and data summary. List should be sorted newest first. Pull-to-refresh should work.
result: blocked
blocked_by: prior-phase
reason: "Blocked by auth failure from Test 2"

### 6. Preview backup before restore
expected: Tap on a backup in the list. A preview screen should open showing a data comparison table — "Backup" column vs "Saat Ini" (current) column with counts for transactions, categories, budgets, goals, and contributions.
result: blocked
blocked_by: prior-phase
reason: "Blocked by auth failure from Test 2"

### 7. Destructive restore confirm with GANTI keyword
expected: From the preview screen, tap the restore button. A destructive confirmation dialog should appear requiring you to type "GANTI" to proceed. The confirm button should only become active when "GANTI" is typed exactly.
result: blocked
blocked_by: prior-phase
reason: "Blocked by auth failure from Test 2"

### 8. Restore completes with progress
expected: After confirming with GANTI, restore should show progress states (downloading → restoring → completed). After completion, all data in the app should match the backup preview (transactions, categories, budgets, goals restored).
result: blocked
blocked_by: prior-phase
reason: "Blocked by auth failure from Test 2"

### 9. Swipe to delete backup
expected: In the backup list, swipe a backup card to reveal a delete action. Confirm deletion. The backup should be removed from the list.
result: blocked
blocked_by: prior-phase
reason: "Blocked by auth failure from Test 2"

### 10. Error messages display in Indonesian
expected: If an error occurs (e.g., no internet, token expired, quota exceeded), the error message shown to the user should be in Indonesian (not English, not technical error details). Examples: "Gagal menghubungkan", "Kuota penyimpanan penuh", etc.
result: blocked
blocked_by: prior-phase
reason: "Blocked by auth failure from Test 2"

### 11. Auto-cleanup keeps only 5 newest backups
expected: After creating more than 5 backups, navigate to the backup list. Only the 5 most recent backups should be visible. Older ones are automatically cleaned up on Drive.
result: blocked
blocked_by: prior-phase
reason: "Blocked by auth failure from Test 2"

### 12. Auth token refresh works automatically
expected: After signing in, close the app, wait a bit (or simulate token expiry), then reopen and try to create a backup. The app should automatically refresh the expired token and proceed without asking to sign in again.
result: blocked
blocked_by: prior-phase
reason: "Blocked by auth failure from Test 2"

## Summary

total: 12
passed: 1
issues: 1
pending: 0
skipped: 0
blocked: 10

## Gaps

- truth: "Tapping 'Hubungkan Akun Google' completes Google Sign-In and connects the account"
  status: failed
  reason: "User reported: Dedicated button now shows (fix 04-04 worked), but tapping it fails with UnimplementedError: canAccessScopes() has not been implemented. Stack: AuthServiceImpl.signIn (auth_service_impl.dart:41) -> GoogleSignIn.canAccessScopes. Log shows '⛔ Google sign-in failed'."
  severity: blocker
  test: 2
  root_cause: "AuthServiceImpl.signIn() calls _googleSignIn.canAccessScopes([driveAppDataScope]) at auth_service_impl.dart:41. canAccessScopes() throws UnimplementedError on the google_sign_in platform interface (requires serverClientId, which is not set). This call is REDUNDANT: the drive.appdata scope is already declared in the GoogleSignIn constructor (service_providers.dart:99-101), and signIn() requests constructor scopes automatically during the OAuth flow. The canAccessScopes/requestScopes two-step was never reachable and is the sole cause of the sign-in failure."
  artifacts:
    - path: "lib/data/services/auth_service_impl.dart"
      issue: "Lines 40-53: redundant canAccessScopes()+requestScopes() block; canAccessScopes throws UnimplementedError. Scope is already in the GoogleSignIn constructor."
    - path: "lib/presentation/providers/services/service_providers.dart"
      issue: "Lines 98-102: GoogleSignIn already constructed with scopes: [drive.appdata] — this is the correct, working path."
  missing:
    - "Delete the canAccessScopes/requestScopes block (auth_service_impl.dart:40-53) — signIn() will request the constructor-declared drive.appdata scope automatically."
  debug_session: ""
