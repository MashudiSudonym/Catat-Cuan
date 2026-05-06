# Technology Stack

**Analysis Date:** 2026-05-06

## Languages

**Primary:**
- Dart ^3.5.0 — All application logic, UI, domain, and data layers

**Secondary:**
- Kotlin — Android-native code for platform channels and home screen widgets
  - `android/app/src/main/kotlin/com/tigasatudesember/catat_cuan/`
- Swift/Objective-C — iOS runner (standard Flutter shell, no custom native code detected)

## Runtime

**Environment:**
- Flutter (stable channel) — managed via `mise.toml` (`flutter = "latest"`)
- Java 17 (Temurin distribution) — Android build toolchain

**Package Manager:**
- Flutter's built-in pub — `flutter pub get`
- Lockfile: `pubspec.lock` (present)

## Frameworks

**Core:**
- Flutter — Cross-platform mobile UI framework
  - Version: 1.5.1 (app version in `pubspec.yaml`)
  - Android namespace: `com.tigasatudesember.catat_cuan`

**State Management:**
- flutter_riverpod ^3.3.1 — Reactive state management with ProviderScope
- riverpod_annotation ^4.0.2 — Code-generation annotations for providers
- riverpod_generator ^4.0.3 — Build-time provider generation (`@riverpod`)

**Navigation:**
- go_router ^17.1.0 — Declarative routing
- go_router_builder ^4.2.0 — Type-safe route generation

**Immutable Data:**
- freezed ^3.2.5 — Union types and immutable data classes (requires `abstract` keyword)
- freezed_annotation ^3.1.0 — Runtime annotations for Freezed

**Testing:**
- flutter_test (SDK) — Unit and widget tests
- integration_test (SDK) — Integration tests
- mockito ^5.4.4 — Mock generation for unit tests
- build_runner ^2.4.13 — Code generation runner

**Build/Dev:**
- build_runner ^2.4.13 — Code generation (Freezed, Riverpod, GoRouter, JSON)
- json_serializable ^6.7.1 — JSON serialization code generation
- flutter_lints ^6.0.0 — Lint rules
- flutter_launcher_icons ^0.14.4 — App icon generation

## Key Dependencies

**Database:**
- sqflite ^2.4.1 — SQLite database for local storage
  - Database file: `catat_cuan.db`
  - Schema version: 2 (managed in `lib/data/datasources/local/schema_manager.dart`)
  - Tables: `transactions`, `categories`

**OCR & Image Processing:**
- google_mlkit_text_recognition ^0.15.1 — On-device OCR for receipt scanning
  - Android native ML Kit text recognition packages (Latin, Chinese, Devanagari, Japanese, Korean scripts)
  - Configured in `android/app/build.gradle.kts`

**Image & Media:**
- image_picker ^1.1.2 — Camera and gallery image selection
- permission_handler ^12.0.1 — Runtime permission management (camera, storage)

**Storage & Files:**
- path_provider ^2.1.5 — Filesystem paths (temp, documents)
- shared_preferences ^2.3.4 — Key-value storage (onboarding state, theme)
- file_picker ^9.2.1 — CSV file import
- share_plus ^12.0.1 — CSV export sharing

**UI & Design:**
- google_fonts ^8.0.2 — Custom typography
- fl_chart ^1.2.0 — Charts and data visualization
- smooth_page_indicator ^2.0.1 — Onboarding page indicators
- cupertino_icons ^1.0.8 — iOS-style icons

**Utilities:**
- intl ^0.20.1 — Internationalization and date formatting (Indonesian locale: `id_ID`)
- timezone ^0.11.0 — Timezone support
- uuid ^4.5.1 — Unique ID generation
- logger ^2.0.0 — Structured logging (`AppLogger` wrapper)
- form_field_validator ^1.1.0 — Form input validation
- package_info_plus ^9.0.0 — App version/package metadata

**Home Screen Widgets:**
- home_widget ^0.9.0 — Android/iOS home screen widget support
  - Android: Jetpack Glance (`androidx.glance:glance-appwidget:1.0.0`, `glance-material3:1.0.0`)

## Configuration

**Environment:**
- Dart SDK constraint: `^3.5.0` (in `pubspec.yaml`)
- Flutter stable channel (managed by `mise.toml`)
- Java 17 for Android builds

**Build:**
- `build.yaml` — Code generation config for Freezed, JSON, Riverpod, GoRouter builders
- `analysis_options.yaml` — Lint rules (flutter_lints package)
- `pubspec.yaml` — Dependencies and app metadata
- `android/app/build.gradle.kts` — Android build config (ProGuard enabled in release)
- `mise.toml` — Runtime version management

**Code Generation:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
Generated files use extensions: `.freezed.dart`, `.g.dart`

## Platform Requirements

**Development:**
- Flutter SDK (stable channel)
- Dart SDK ^3.5.0
- Java 17 (for Android builds)
- Android SDK with minSdk from Flutter default
- Xcode (for iOS builds)

**Production:**
- Android: APK via GitHub Actions release workflow
  - Release build with ProGuard/R8 optimization
  - Signing with debug keys (TODO: production signing)
- iOS: Standard Flutter Runner (no custom native code)
- No server/cloud backend — fully offline, local-only application

---

*Stack analysis: 2026-05-06*
