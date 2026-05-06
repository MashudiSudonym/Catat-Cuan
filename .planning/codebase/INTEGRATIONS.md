# External Integrations

**Analysis Date:** 2026-05-06

## APIs & External Services

**On-Device ML / OCR:**
- Google ML Kit Text Recognition — Receipt OCR scanning
  - SDK/Client: `google_mlkit_text_recognition` ^0.15.1
  - Implementation: `lib/data/services/receipt_ocr_service_impl.dart`
  - Interface: `lib/domain/services/ocr_service.dart`
  - Auth: None required (on-device, no API key)
  - Script: Latin (primary), with Android native support for Chinese, Devanagari, Japanese, Korean
  - Native Android deps (in `android/app/build.gradle.kts`):
    - `com.google.mlkit:text-recognition:16.0.0`
    - `com.google.mlkit:text-recognition-chinese:16.0.0`
    - `com.google.mlkit:text-recognition-devanagari:16.0.0`
    - `com.google.mlkit:text-recognition-japanese:16.0.0`
    - `com.google.mlkit:text-recognition-korean:16.0.0`

**Platform Channels (Native Bridge):**
- File Save via Storage Access Framework
  - MethodChannel: `catat_cuan/file_save` — Save files using native file picker
  - EventChannel: `catat_cuan/file_save_events` — Async callbacks for save operations
  - Implementation: `lib/data/services/file_save_service_impl.dart`
  - Interface: `lib/domain/services/file_save_service.dart`
  - Android: `ACTION_CREATE_DOCUMENT` intent
  - iOS: `UIDocumentPickerViewController` (export mode)

**Device Permissions:**
- Camera — For receipt photo capture
- Photo Library — For gallery image selection
  - Implementation: `lib/data/services/permission_service_impl.dart`
  - Interface: `lib/domain/services/permission_service.dart`
  - Package: `permission_handler` ^12.0.1

## Data Storage

**Databases:**
- SQLite (local, on-device)
  - Package: `sqflite` ^2.4.1
  - Database file: `catat_cuan.db`
  - Connection helper: `lib/data/datasources/local/database_helper.dart`
  - Schema manager: `lib/data/datasources/local/schema_manager.dart`
  - Data source: `lib/data/datasources/local/sqlite_data_source.dart`
  - Current schema version: 2
  - Tables:
    - `transactions` — id, amount, type (income/expense), date_time, category_id, note, created_at, updated_at
    - `categories` — id, name, type (income/expense), color, icon, sort_order, is_active, created_at, updated_at
  - Indexes: date_time, category_id, type, date_type composite, monthly aggregation composite

**File Storage:**
- Local filesystem via `path_provider` — Temp and documents directories
- Used for: CSV export files, receipt images (temp)

**Key-Value Storage:**
- `shared_preferences` ^2.3.4
  - Service: `lib/data/services/shared_preferences_service.dart`
  - Keys: `show_onboarding` (boolean)

**Caching:**
- None (no external caching layer; Riverpod providers act as in-memory cache)

## Authentication & Identity

**Auth Provider:**
- None — Single-user offline application, no authentication required

## Monitoring & Observability

**Error Tracking:**
- None (no crash reporting service like Firebase Crashlytics or Sentry)

**Logs:**
- `logger` ^2.0.0 — Structured console logging via `AppLogger`
  - Implementation: `lib/presentation/utils/logger/app_logger.dart`
  - Levels: trace, debug, info, warning, error, fatal
  - Dev mode: All levels (trace+)
  - Release mode: Warning and above only
  - PrettyPrinter with emojis, colors, stack traces

**Error Handling:**
- `lib/presentation/utils/error/error_handler.dart` — Centralized error handling
- `lib/presentation/utils/error/error_message_mapper.dart` — Maps technical errors to user-friendly Indonesian messages
- `lib/domain/failures/failures.dart` — Typed failure classes (OcrFailure, PermissionFailure, ImportFailure, etc.)

## CI/CD & Deployment

**Hosting:**
- GitHub Releases — APK distribution
- No app store deployment configured

**CI Pipeline:**
- GitHub Actions: `.github/workflows/release.yml`
  - Trigger: Push to `main` (excluding bump commits), or manual workflow_dispatch
  - Jobs:
    1. **CI (Test & Analyze)** — `flutter pub get`, `build_runner`, `flutter test`, `flutter analyze`
    2. **Version Bump** — Auto-detects conventional commits, bumps version via `scripts/bump_version.sh`
       - `feat!` or `BREAKING CHANGE` → MAJOR
       - `feat:` → MINOR
       - `fix:`, `refactor:`, `perf:` → PATCH
       - `docs:`, `test:`, `ci:`, `chore:`, `style:` → No bump
    3. **Build & Release** — Builds release APK, generates SHA256 checksum, creates GitHub Release with changelog
  - Java: Temurin 17
  - Flutter: stable channel with caching

**Version Management:**
- `scripts/bump_version.sh` — Shell script for version bumping
- Version format: `MAJOR.MINOR.PATCH` (no build number in `pubspec.yaml`)
- Build number: Auto-generated from `git rev-list --count HEAD`

## Environment Configuration

**Required env vars:**
- None — Fully offline application with no external API dependencies

**Secrets location:**
- `secrets.GITHUB_TOKEN` — Used by GitHub Actions only (auto-provisioned)

## Webhooks & Callbacks

**Incoming:**
- None

**Outgoing:**
- None

## Native Platform Integrations

**Android-Specific:**
- Jetpack Glance home screen widgets
  - `android/app/src/main/kotlin/com/tigasatudesember/catat_cuan/widget/ExpenseGlanceWidget.kt`
  - `android/app/src/main/kotlin/com/tigasatudesember/catat_cuan/widget/WidgetData.kt`
  - `lib/data/datasources/widget/widget_local_datasource.dart` — Flutter-side widget data management
  - `lib/domain/entities/widget/widget_data_entity.dart` — Widget data model
  - `lib/domain/entities/widget/widget_data_serializer.dart` — Data serialization for native bridge
  - `lib/domain/repositories/widget/widget_repository.dart` — Widget repository interface
  - `lib/presentation/providers/widget/widget_provider.dart` — Riverpod provider for widget state
- Storage Access Framework — File save via platform channel
- ProGuard/R8 — Enabled for release builds (`android/app/proguard-rules.pro`)

**iOS-Specific:**
- Standard Flutter Runner — No custom native integrations detected

## Import/Export

**Export:**
- CSV export via `share_plus` and `path_provider`
  - Service: `lib/data/services/csv_export_service_impl.dart`
  - Interface: `lib/domain/services/export_service.dart`
  - Use case: `lib/domain/usecases/export_transactions_usecase.dart`

**Import:**
- CSV import via `file_picker`
  - Service: `lib/data/services/csv_import_service_impl.dart`
  - Interface: `lib/domain/services/import_service.dart`
  - Use case: `lib/domain/usecases/import_transactions_usecase.dart`
  - Expected headers: `ID, Tanggal, Waktu, Jenis, Kategori, Jumlah, Catatan`
  - UTF-8 BOM handling included

## Merchant Pattern Recognition

**On-Device Pattern Matching:**
- Indonesian merchant pattern matching for receipt parsing
  - Service: `lib/data/services/indonesian_merchant_pattern_service_impl.dart`
  - Interface: `lib/domain/services/merchant_pattern_service.dart`
  - Entity: `lib/domain/entities/merchant_pattern_entity.dart`
  - Analyzers: `lib/domain/services/analyzers/`
  - No external API — purely rule-based pattern matching

---

*Integration audit: 2026-05-06*
