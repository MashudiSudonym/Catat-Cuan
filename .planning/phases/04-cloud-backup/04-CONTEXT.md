# Phase 4: Cloud Backup - Context

**Gathered:** 2026-05-14
**Status:** Ready for planning

<domain>
## Phase Boundary

Users can backup all data to Google Drive and restore it, with proper OAuth handling and error recovery. Specifically:
- Authenticate with Google Account via OAuth 2.0 using drive.appdata scope (BKP-01)
- Backup all data (transactions, categories, budgets, goals, contributions, settings) to Google Drive with progress indicator (BKP-02)
- View list of available backups with metadata (date, size, device) and preview before restoring (BKP-03)
- Restore from backup with conflict handling — replace all or cancel (BKP-04)
- Backup info display (last backup date, size, account) and auto-cleanup keeping 5 latest backups (BKP-05)
- OAuth token expiry handled with automatic refresh and re-authentication prompt (BKP-06)
- Graceful error handling (network, quota, auth, corrupted file) with user-friendly Indonesian messages (BKP-07)

This phase does NOT implement auto-backup scheduling, real-time sync, merge conflict resolution, or data encryption — those are deferred to v3 (BKP-F01 to BKP-F04).

</domain>

<decisions>
## Implementation Decisions

### Backup Data Format & Versioning
- **D-01:** Single JSON file per backup containing all tables under named keys. Structure: `{"version": 1, "schema_version": 4, "device": "Pixel 8", "created_at": "...", "data_counts": {...}, "data": {"transactions": [...], "categories": [...], ...}}`. Atomic upload/download — one file, one API call.
- **D-02:** Schema version header for forward/backward compatibility. On restore, compare backup schema_version vs current app schema_version. If backup is older, run migration logic. If backup is newer, reject with Indonesian message asking user to update app.
- **D-03:** Include app settings (theme preference, onboarding state) in backup. On restore, apply settings so user gets their exact app state back.
- **D-04:** Serialize via existing Freezed entity toJson methods. Query DB → map to entities → toJson(). Reuses existing serialization code.
- **D-05:** Timestamp-based file naming: `catatcuan_backup_20260514_143052.json`. Unique per backup, easy to sort chronologically.
- **D-06:** No compression. JSON as-is. Typical backup size (500KB-5MB) is well within Drive API limits. Debuggable by reading the file directly.
- **D-07:** Full metadata in backup header: app_version, schema_version, device_model, created_at timestamp, data_counts per table. Used for preview display and debugging.

### OAuth Flow & Token Management
- **D-08:** Use `google_sign_in` package for authentication. Combined with `googleapis` package for Drive API calls. Official Google packages, well-maintained.
- **D-09:** Store OAuth tokens securely using `flutter_secure_storage`. Uses platform Keychain (iOS) / EncryptedSharedPreferences (Android). Encrypted at rest.
- **D-10:** Sign-in on demand — user taps "Backup" or "Restore", if not signed in, trigger Google Sign-In with drive.appdata scope inline. No upfront auth wall.
- **D-11:** Connected Google account shown in Settings screen with email and disconnect option. Backup/restore screens only show the feature actions, not account management.

### Restore UX & Conflict Handling
- **D-12:** Full preview before restore — show backup date, size, device name, data counts per table. User knows exactly what they're restoring and can compare with current data.
- **D-13:** Destructive confirm dialog with warning: "Semua data saat ini akan diganti dengan data backup." Show current data counts vs backup data counts. User must type "GANTI" or hold button 3 seconds to confirm. Prevents accidental restore.
- **D-14:** Linear progress bar with stages: "Membuat backup..." → "Mengupload..." → "Selesai!" for backup; "Mengunduh..." → "Memulihkan data..." → "Selesai!" for restore. Indeterminate for serialization, determinate for upload/download.

### Backup Management & Navigation
- **D-15:** Auto-cleanup after each new backup — check backup count, if > 5 delete oldest. Always keep at most 5 backups. Automatic, no user action needed.
- **D-16:** Backup list displayed as glass cards — each backup is a glass card showing date, size, device name, data summary. Tap to preview/restore. Swipe to delete. Consistent with app design system.
- **D-17:** Backup & Restore entry point in Settings screen. Shows last backup date, connected account info. Tap to open backup management screen with backup/restore/list actions. Infrequent action, doesn't warrant a dedicated tab.

### Agent's Discretion
- Exact Google Sign-In scope request configuration
- Token refresh retry logic and backoff strategy
- Backup list sorting direction (newest first assumed)
- Error-specific Indonesian messages mapping (network vs quota vs auth vs corrupted)
- Google Cloud Console OAuth Client ID setup instructions for developer
- Backup serialization order within the JSON file
- Progress bar percentage calculation approach
- Confirm dialog exact visual design (glass dialog vs standard Material)
- Delete backup confirmation flow
- First backup empty state messaging

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Requirements & Roadmap
- `.planning/REQUIREMENTS.md` §Cloud Backup — All backup requirements (BKP-01 to BKP-07) and deferred enhancements (BKP-F01 to BKP-F04)
- `.planning/ROADMAP.md` §Phase 4 — Phase goal, success criteria, plan list (04-01, 04-02, 04-03)
- `.planning/PROJECT.md` — Tech stack constraints, key decisions, architecture context, known blockers

### Architecture & Patterns
- `.planning/codebase/ARCHITECTURE.md` — System overview, data flow, repository segregation pattern, Result<T> monad
- `.planning/codebase/CONVENTIONS.md` — Naming, Freezed/Riverpod patterns, error handling, design system usage
- `.planning/codebase/STACK.md` — Dependencies, versions, platform requirements
- `.planning/codebase/INTEGRATIONS.md` — Existing external integrations (ML Kit, permissions, file save), no auth currently

### Prior Phase Context
- `.planning/phases/01-foundation/01-CONTEXT.md` — Schema decisions, navigation setup, Result<T> pattern
- `.planning/phases/02-budgeting/02-CONTEXT.md` — Budget card pattern on home screen, repository segregation pattern
- `.planning/phases/03-savings-goals/03-CONTEXT.md` — Savings goals data layer, ISP pattern, contribution semantics

### Database (existing code)
- `lib/data/datasources/local/schema_manager.dart` — Schema v4 with all tables (transactions, categories, budgets, savings_goals, goal_contributions). All table field classes defined.
- `lib/data/datasources/local/database_helper.dart` — Table name constants, connection singleton

### Error Handling (existing code)
- `lib/presentation/utils/error/error_message_mapper.dart` — Maps technical errors to Indonesian user-friendly messages
- `lib/domain/failures/failures.dart` — Typed failure classes (need new BackupFailure types)
- `lib/presentation/utils/error/error_handler.dart` — Centralized error handling

### Design System
- `lib/presentation/utils/glassmorphism/` — Glass container components for backup list cards
- `lib/presentation/utils/responsive/` — AppSpacing, AppRadius tokens
- `lib/presentation/utils/app_colors.dart` — Color system with theme-aware methods
- `docs/v1/design/DESIGN_SYSTEM_GUIDE.md` — Glassmorphism design system guide

### Settings (existing code — integration point)
- `lib/data/services/shared_preferences_service.dart` — Currently stores onboarding state and theme. Will need to store backup metadata (last backup date, account email).

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `AppGlassContainer`: Glass card component for backup list items — consistent with budget/goal cards
- `AppEmptyState`: Reusable empty state widget — use for "no backups yet" state
- `CurrencyFormatter`: Already formats Indonesian Rupiah — could format file sizes (or add a new formatter)
- `AppDateFormatter`: Date formatting — need new method for backup date display
- `ErrorMessageMapper`: Pattern for mapping technical errors to Indonesian messages — extend with backup error mappings
- `Result<T>` monad: All repository/use case operations return `Result<T>` — backup operations follow same pattern
- `SharedPreferencesService`: Already used for settings storage — extend for backup metadata

### Established Patterns
- Repository Segregation (ISP): Backup needs its own interfaces — BackupRepository (write/read), BackupQueryRepository (list backups), AuthRepository (token management)
- Freezed 3.x with `abstract` keyword: All backup entities (BackupMetadata, BackupData) use `@freezed abstract class`
- Riverpod `@riverpod` with `build()` initialization: All backup providers follow this pattern
- Service pattern: Backup service interface in domain, implementation in data layer (like OcrService, ExportService)
- Failure types: Need new `BackupFailure`, `AuthFailure` types in `lib/domain/failures/`

### Integration Points
- `lib/presentation/navigation/routes/app_router.dart`: No new tab needed — backup accessed via Settings
- `lib/presentation/screens/` — Settings screen: Add "Backup & Restore" section
- `lib/data/datasources/local/schema_manager.dart`: Read all tables for backup serialization (no schema change needed)
- `lib/presentation/providers/repositories/repository_providers.dart`: Add backup/auth repository providers
- `lib/presentation/providers/services/service_providers.dart`: Add Google Sign-In and Drive API service providers
- `pubspec.yaml`: Add google_sign_in, googleapis, flutter_secure_storage dependencies

</code_context>

<specifics>
## Specific Ideas

No specific external references or examples — decisions are based on codebase analysis, REQUIREMENTS.md, and standard mobile cloud backup UX patterns.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 4-Cloud Backup*
*Context gathered: 2026-05-14*
