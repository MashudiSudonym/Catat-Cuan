---
phase: 04-cloud-backup
plan: 03
subsystem: backup-restore
tags: [restore, backup-management, ui, settings, error-mapping]
dependency_graph:
  requires: [04-01, 04-02]
  provides: [restore-pipeline, backup-list-ui, backup-preview-ui, settings-integration]
  affects: [settings-screen, app-router, error-message-mapper]
tech_stack:
  added: [flutter_riverpod, freezed, go_router]
  patterns: [atomic-restore-transaction, destructive-confirm-dialog, repository-segregation]
key_files:
  created:
    - lib/domain/entities/backup/backup_preview.dart
    - lib/domain/usecases/backup/restore_backup_usecase.dart
    - lib/domain/usecases/backup/list_backups_usecase.dart
    - lib/domain/usecases/backup/delete_backup_usecase.dart
    - lib/data/services/backup_restore_service.dart
    - lib/data/repositories/backup/backup_read_repository_impl.dart
    - lib/presentation/controllers/restore_controller.dart
    - lib/presentation/screens/backup_screen.dart
    - lib/presentation/screens/backup_list_screen.dart
    - lib/presentation/screens/backup_preview_screen.dart
  modified:
    - lib/presentation/utils/error/error_message_mapper.dart
    - lib/data/services/shared_preferences_service.dart
    - lib/presentation/providers/backup/backup_providers.dart
    - lib/presentation/screens/settings_screen.dart
    - lib/presentation/navigation/routes/app_routes.dart
    - lib/presentation/navigation/routes/app_router.dart
  tested:
    - test/domain/usecases/backup/restore_backup_usecase_test.dart
    - test/data/services/backup_restore_service_test.dart
decisions:
  - BackupRestoreService uses LocalDataSource.transaction() callback pattern for atomicity
  - RestoreController uses @riverpod with RestoreProgress Freezed union type
  - Destructive confirm dialog requires typing "GANTI" (per D-13)
  - Backup routes use rootNavigatorKey for full-screen navigation (not inside tab shell)
  - BackupPreview loads by listing all backups then filtering by fileId (no single-file API)
metrics:
  duration: 34min
  completed: "2026-05-20"
  tasks_completed: 2
  tasks_total: 2
  files_created: 10
  files_modified: 6
  tests_added: 25
  tests_total: 1156
---

# Phase 4 Plan 03: Restore & Backup Management UI Summary

Restore pipeline with atomic DB replacement, backup list/preview/restore UI screens with glassmorphism design, destructive confirm dialog, and Settings screen integration.

## What Was Built

### Task 1: Restore Pipeline, Use Cases, Error Mappings (TDD)
- **BackupPreview** Freezed entity with backup vs current data counts for comparison display
- **BackupRestoreService** — atomic restore in DB transaction: delete all existing data in FK order → insert backup data → apply settings. Transaction guarantees all-or-nothing.
- **RestoreBackupUseCase** — orchestrates download → deserialize → restore with progress callbacks
- **ListBackupsUseCase** — lists Drive files, maps to BackupPreview with current DB counts, sorted newest first
- **DeleteBackupUseCase** — deletes backup from Drive by fileId
- **BackupReadRepositoryImpl** — repository implementation using GoogleDriveService
- **ErrorMessageMapper** extended with auth/backup error mappings (network, quota, expired, cancelled, corrupted, notFound)
- **SharedPreferencesService** extended with lastBackupDate, connectedAccountEmail, clearBackupMetadata
- All providers wired in backup_providers.dart
- 25 tests (RestoreBackupUseCase + BackupRestoreService) passing

### Task 2: Backup Management UI Screens
- **BackupScreen** — main backup hub: connected account info, "Buat Backup" button with progress, last backup date, navigation to backup list
- **BackupListScreen** — backups as glass cards with date/size/device/data summary, pull-to-refresh, swipe-to-delete with confirm dialog
- **BackupPreviewScreen** — data comparison table (Backup vs Saat Ini), destructive confirm dialog requiring "GANTI" text input, restore progress states (downloading → restoring → completed/failed)
- **RestoreController** — Riverpod controller with RestoreProgress Freezed union: idle, downloading, restoring, completed, failed
- **Settings screen** — "Backup & Restore" section between Data and App Info sections
- **App router** — backup, backupList, backupPreview routes registered with rootNavigatorKey

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] LocalDataSource.transaction() signature mismatch**
- **Found during:** Task 1 (TDD GREEN phase)
- **Issue:** Plan specified `transaction(Future<void> Function(LocalDataSource) action)` but actual signature is `transaction(Future<void> Function() action)` — callback takes no arguments
- **Fix:** Updated BackupRestoreService to use no-arg callback, access LocalDataSource methods directly via `this`
- **Files modified:** lib/data/services/backup_restore_service.dart
- **Commit:** fb5d589

**2. [Rule 3 - Blocking] AppEmptyState has no .custom() factory**
- **Found during:** Task 2 (UI implementation)
- **Issue:** Plan used `AppEmptyState.custom(...)` but AppEmptyState only has a constructor, not a named factory
- **Fix:** Changed to `AppEmptyState(icon: ..., title: ..., subtitle: ...)`
- **Files modified:** lib/presentation/screens/backup_list_screen.dart
- **Commit:** add917d

**3. [Rule 3 - Blocking] AppGlassContainer import path**
- **Found during:** Task 2 (UI implementation)
- **Issue:** Direct import of `app_glass_container.dart` didn't export the class
- **Fix:** Import via `package:catat_cuan/presentation/widgets/base/base.dart`
- **Files modified:** backup_screen.dart, backup_list_screen.dart, backup_preview_screen.dart
- **Commit:** add917d

**4. [Rule 1 - Bug] Unused imports in backup_preview_screen.dart**
- **Found during:** Task 2 post-implementation cleanup
- **Issue:** flutter analyze reported 3 unused imports (result.dart, backup_metadata.dart, list_backups_usecase.dart)
- **Fix:** Removed unused imports, also removed unused dart:async import
- **Files modified:** lib/presentation/screens/backup_preview_screen.dart
- **Commit:** add917d

## Key Decisions

1. **Atomic restore via transaction** — BackupRestoreService wraps all delete+insert operations in a single DB transaction, ensuring data integrity per D-13
2. **Destructive confirm with GANTI text** — User must type "GANTI" to confirm restore, per D-13 threat model (T-04-10: prevent accidental restore)
3. **Backup routes on root navigator** — Backup screens are full-screen, not inside the tab shell, so they use rootNavigatorKey
4. **RestoreProgress as Freezed union** — Clean state machine: idle → downloading → restoring → completed/failed

## Test Results

- **Total tests:** 1156 (all passing)
- **New tests:** 25 (RestoreBackupUseCase: 15, BackupRestoreService: 10)
- **flutter analyze:** 0 errors, 2 infos (use_build_context_synchronously — acceptable with mounted checks)

## Verification Checklist

- [x] `flutter analyze` — 0 errors
- [x] `flutter test` — 1156/1156 passing
- [x] Destructive confirm uses "GANTI" keyword
- [x] ErrorMessageMapper used in all backup screens
- [x] Settings screen has `_buildBackupSection()`
- [x] All backup routes registered in app_router.dart
- [x] Atomic restore in DB transaction
- [x] All UI text in Indonesian

## Threat Model Compliance

| Threat | Mitigation | Status |
|--------|-----------|--------|
| T-04-09 (Tampering) | Atomic transaction for data integrity | ✅ Implemented |
| T-04-10 (Spoofing/Accidental) | Destructive confirm with "GANTI" text | ✅ Implemented |
| T-04-11 (Info Disclosure) | SharedPrefs only stores date/email | ✅ Implemented |
| T-04-12 (Denial/Restore failure) | Transaction rollback on failure | ✅ Implemented |

## Self-Check: PASSED

- All 12 created/modified files verified to exist on disk
- All 3 commits verified in git log: d050415 (test), fb5d589 (feat), add917d (UI)
- 1156/1156 tests passing
- `flutter analyze`: 0 errors
