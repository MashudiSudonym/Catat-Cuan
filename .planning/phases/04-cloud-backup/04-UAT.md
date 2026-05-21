---
status: testing
phase: 04-cloud-backup
source: 04-01-SUMMARY.md, 04-02-SUMMARY.md, 04-03-SUMMARY.md
started: 2026-05-21T08:54:12Z
updated: 2026-05-21T09:05:00Z
---

## Current Test

number: 0
name: Build succeeds (prerequisite)
expected: |
  App builds and runs without Gradle/AAR metadata errors.
awaiting: resolved — fix applied

## Tests

### 1. Settings shows Backup & Restore section
expected: Open Settings screen. Scroll down — there should be a "Backup & Restore" section between Data and App Info sections, with a navigation item to open the backup screen.
result: [pending]

### 2. Backup screen shows Google Sign-In prompt
expected: Navigate to Backup screen from Settings. When not connected, you should see a prompt/button to sign in with your Google account (e.g., "Hubungkan Akun Google" or similar).
result: [pending]

### 3. Google Sign-In authenticates with drive.appdata scope
expected: Tap the sign-in button. Google Sign-In flow should appear. After authenticating, the backup screen should show the connected account email. The app should only request drive.appdata scope (no full Drive access).
result: [pending]

### 4. Create backup with progress indicator
expected: With a connected account, tap "Buat Backup" button. You should see a progress indicator showing stages (serializing → uploading → completed). After completion, the screen should show the backup was created successfully and display the last backup date.
result: [pending]

### 5. View backup list
expected: From Backup screen, navigate to backup list. You should see all backups listed as cards with date, size, device info, and data summary. List should be sorted newest first. Pull-to-refresh should work.
result: [pending]

### 6. Preview backup before restore
expected: Tap on a backup in the list. A preview screen should open showing a data comparison table — "Backup" column vs "Saat Ini" (current) column with counts for transactions, categories, budgets, goals, and contributions.
result: [pending]

### 7. Destructive restore confirm with GANTI keyword
expected: From the preview screen, tap the restore/button. A destructive confirmation dialog should appear requiring you to type "GANTI" to proceed. The button should only become active when "GANTI" is typed exactly.
result: [pending]

### 8. Restore completes with progress
expected: After confirming with GANTI, restore should show progress states (downloading → restoring → completed). After completion, all data in the app should match the backup preview (transactions, categories, budgets, goals restored).
result: [pending]

### 9. Swipe to delete backup
expected: In the backup list, swipe a backup card to reveal a delete action. Confirm deletion. The backup should be removed from the list.
result: [pending]

### 10. Error messages display in Indonesian
expected: If an error occurs (e.g., no internet, token expired, quota exceeded), the error message shown to the user should be in Indonesian (not English, not technical error details). Examples: "Gagal menghubungkan", "Kuota penyimpanan penuh", etc.
result: [pending]

### 11. Auto-cleanup keeps only 5 newest backups
expected: After creating more than 5 backups, navigate to the backup list. Only the 5 most recent backups should be visible. Older ones are automatically cleaned up on Drive.
result: [pending]

### 12. Auth token refresh works automatically
expected: After signing in, close the app, wait a bit (or simulate token expiry), then reopen and try to create a backup. The app should automatically refresh the expired token and proceed without asking to sign in again.
result: [pending]

## Summary

total: 12
passed: 0
issues: 0
pending: 12
skipped: 0
blocked: 0

## Gaps

[none yet]
