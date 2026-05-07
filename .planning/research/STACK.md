# Technology Stack — v2 Additions

**Project:** Catat Cuan v2 (Budgeting, Savings Goals, Google Drive Backup, Dark Mode, Enhanced Reports)
**Researched:** 2026-05-06
**Mode:** Ecosystem (additions to existing stack only)

---

## v1 Stack (Existing — No Changes)

These remain unchanged. Do NOT re-add or re-research.

| Package | Version | Role |
|---------|---------|------|
| flutter_riverpod | ^3.3.1 | State management |
| riverpod_annotation | ^4.0.2 | Provider annotations |
| riverpod_generator | ^4.0.3 | Provider codegen |
| freezed | ^3.2.5 | Immutable entities (remember `abstract` keyword) |
| freezed_annotation | ^3.1.0 | Freezed annotations |
| go_router | ^17.1.0 | Navigation |
| go_router_builder | ^4.2.0 | Type-safe routes |
| sqflite | ^2.4.1 | SQLite database |
| fl_chart | ^1.2.0 | Charts & visualization |
| shared_preferences | ^2.3.4 | Key-value store (theme, onboarding) |
| path_provider | ^2.1.5 | Filesystem paths |
| google_mlkit_text_recognition | ^0.15.1 | OCR |
| image_picker | ^1.1.2 | Camera/gallery |
| permission_handler | ^12.0.1 | Runtime permissions |
| json_serializable | ^6.7.1 | JSON codegen |
| build_runner | ^2.4.13 | Code generation runner |
| mockito | ^5.4.4 | Test mocking |

---

## v2 New Dependencies

### Google Drive Backup/Restore

| Package | Version | Purpose | Confidence |
|---------|---------|---------|------------|
| `google_sign_in` | ^7.2.0 | OAuth authentication for Google accounts | **HIGH** — official flutter.dev package, verified pub.dev |
| `googleapis` | ^16.0.0 | Auto-generated Dart client libraries (includes Drive API v3) | **HIGH** — official google.dev package, verified pub.dev |
| `extension_google_sign_in_as_googleapis_auth` | ^3.0.0 | Bridge: creates `AuthClient` from `GoogleSignIn` credentials | **HIGH** — official flutter.dev package, explicitly recommended by googleapis_auth docs |
| `flutter_secure_storage` | ^10.0.0 | Encrypts Google auth tokens at rest (Keychain/KeyStore) | **HIGH** — verified pub.dev, Context7 docs |

**Why this combination:**

1. **`google_sign_in` ^7.2.0** handles the entire OAuth flow (sign-in, scope authorization, token refresh). v7 introduced `GoogleSignIn.instance` singleton with stream-based auth events and `authorizationClient` for scope-based authorization. The `scopeHint` parameter on `authenticate()` enables combined auth+authorization flows where supported. This is the officially maintained Flutter plugin from the flutter.dev team.

2. **`extension_google_sign_in_as_googleapis_auth` ^3.0.0** is critical — it's the **only** supported way to bridge `google_sign_in` credentials to `googleapis` API clients in Flutter. The `googleapis_auth` package explicitly warns: *"Do NOT use this package with a Flutter application. Use extension_google_sign_in_as_googleapis_auth instead."* It provides `authenticatedClient()` as an extension method on `GoogleSignInClientAuthorization`, yielding an `AuthClient` usable with any `googleapis` API.

3. **`googleapis` ^16.0.0** includes `DriveApi` (drive/v3) for file upload/download. We'll use `drive.appdata` scope — a hidden, app-specific folder invisible to users. This gives privacy (no access to user's personal files) and avoids sensitive scope rejection during OAuth review. The Drive API v3 supports media upload/download via `Media` and `DownloadOptions`.

4. **`flutter_secure_storage` ^10.0.0** stores the Google auth tokens (access token, refresh token metadata) encrypted at rest using platform-native security — Keychain on iOS, EncryptedSharedPreferences with Tink on Android. v10 defaults to RSA OAEP + AES-GCM on Android (API 23+). This prevents credential theft even on rooted devices.

**Important: Google Cloud Console setup required** — OAuth 2.0 Client ID for Android (SHA-1 fingerprint), Drive API enabled, `drive.appdata` scope whitelisted.

**Scope:** `https://www.googleapis.com/auth/drive.appdata` (appdata only — no user file access).

### Savings Goals Celebration

| Package | Version | Purpose | Confidence |
|---------|---------|---------|------------|
| `confetti` | ^0.8.0 | Celebration animation when savings goal completed | **HIGH** — verified pub.dev, Context7 docs |

**Why `confetti`:** It's the standard Flutter confetti package (1.6k likes, 282k downloads). Provides `ConfettiWidget` with `ConfettiController`, customizable particle shapes (star, circle, custom Path), blast direction, gravity, emission frequency. Lightweight — only depends on `flutter` and `vector_math`. Triggered programmatically via `_controller.play()` on goal completion, auto-stops after duration. Performance note: keep `numberOfParticles` ≤ 20 to avoid jank on low-end devices.

### Dark Mode / Theming

| Package | Version | Purpose | Confidence |
|---------|---------|---------|------------|
| *(no new package)* | — | Use existing `shared_preferences` + Flutter's `ThemeData` | **HIGH** — standard Flutter approach |

**Why no new package:** Dark mode in Flutter requires only `ThemeData.brightness` switching — no external package needed. The existing `shared_preferences ^2.3.4` already stores theme preference. The implementation is:

1. Define `AppTheme` class with `lightTheme()` and `darkTheme()` `ThemeData` instances
2. Store theme mode (`light`/`dark`/`system`) in `shared_preferences`
3. Provide `ThemeMode` via Riverpod `@riverpod` notifier
4. Pass `theme:` and `darkTheme:` to `MaterialApp.router`

This is the canonical Flutter approach — every major Flutter app implements dark mode this way. Adding a theming package (like `flex_color_scheme`) would be over-engineering for a personal finance app with an existing glassmorphism design system.

### Enhanced Reports

| Package | Version | Purpose | Confidence |
|---------|---------|---------|------------|
| *(no new package)* | — | Use existing `fl_chart ^1.2.0` | **HIGH** — already in stack |

**Why no new package:** `fl_chart ^1.2.0` already supports all chart types needed for enhanced reports:

- **Bar charts** (`BarChart`) — daily/weekly spending comparison, category breakdowns
- **Line charts** (`LineChart`) — monthly trend lines, spending over time
- **Pie charts** (`PieChart`) — category distribution, budget allocation
- **Range annotations** — highlight budget limits on bar charts
- **Touch interactions** (`BarTouchData`, `LineTouchData`, `PieTouchData`) — tap-to-inspect data points
- **Animations** — built-in `swapAnimationDuration` and `swapAnimationCurve`

The v2 enhanced reports (daily/weekly/monthly/yearly views) are a **data aggregation and UI design challenge**, not a charting library gap. What's needed:

1. New use cases for time-range aggregation (daily/weekly/monthly/yearly)
2. New repository query methods for grouped summaries
3. New screen layouts with tab/segmented control for time ranges
4. Interactive chart configurations using fl_chart's existing API

No additional charting package needed. `fl_chart` is sufficient.

---

## Installation

```bash
# Add v2 dependencies
flutter pub add google_sign_in:^7.2.0
flutter pub add googleapis:^16.0.0
flutter pub add extension_google_sign_in_as_googleapis_auth:^3.0.0
flutter pub add flutter_secure_storage:^10.0.0
flutter pub add confetti:^0.8.0

# Run code generation (existing build_runner setup handles new Freezed/Riverpod classes)
flutter pub run build_runner build --delete-conflicting-outputs
```

### Android Configuration (Required for Google Sign-In)

```kotlin
// android/app/build.gradle.kts — add if not present
android {
    defaultConfig {
        // minSdk must be 21+ (already satisfied)
    }
}
```

```xml
<!-- android/app/src/main/AndroidManifest.xml — disable Drive backup to avoid key exceptions -->
<application
    android:allowBackup="false"
    android:fullBackupContent="false"
    tools:replace="android:allowBackup,android:fullBackupContent">
</application>
```

### Google Cloud Console Setup

1. Create OAuth 2.0 Client ID (Android type) with app's SHA-1 signing fingerprint
2. Enable Google Drive API in the project
3. No consent screen approval needed — `drive.appdata` scope is non-sensitive

---

## Alternatives Considered (and Rejected)

| Category | Recommended | Alternative | Why Not |
|----------|-------------|-------------|---------|
| Auth | `google_sign_in ^7.2.0` | Manual OAuth via `googleapis_auth` | `googleapis_auth` docs explicitly say "Do NOT use with Flutter" — use the bridge package instead |
| Auth bridge | `extension_google_sign_in_as_googleapis_auth ^3.0.0` | Custom `AuthClient` wrapper | Official bridge handles token refresh, lifecycle, and edge cases — reinventing is brittle |
| Drive API | `googleapis ^16.0.0` (Drive v3) | REST API via raw `http` package | `googleapis` gives typed Dart classes for all Drive operations — no manual JSON parsing, proper error types, versioned API |
| Drive scope | `drive.appdata` (app folder) | `drive.file` (user-visible) | `drive.appdata` is hidden from users, requires no consent screen review, and is the standard for app backup data |
| Secure storage | `flutter_secure_storage ^10.0.0` | `shared_preferences` for tokens | `shared_preferences` stores plaintext — auth tokens would be readable on rooted devices. `flutter_secure_storage` uses hardware-backed encryption |
| Charts | *(existing)* `fl_chart ^1.2.0` | `syncfusion_flutter_charts` | Syncfusion is commercial (license needed), heavy (~5MB), and overkill for personal finance. `fl_chart` already in stack |
| Charts | *(existing)* `fl_chart ^1.2.0` | `charts_flutter` (Google) | Deprecated and unmaintained since 2021 |
| Confetti | `confetti ^0.8.0` | Custom `AnimationController` + canvas | Confetti physics (gravity, drag, blast force, rotation) are non-trivial. `confetti` handles all of this in ~100 LOC dependency |
| Theming | Flutter `ThemeData` + existing `shared_preferences` | `flex_color_scheme` | Adds complexity for marginal benefit. Our existing glassmorphism design system has custom tokens — `flex_color_scheme` would fight it |
| Theming | Flutter `ThemeData` | `adaptive_theme` | Over-engineering for 3 mode options (light/dark/system). A simple Riverpod notifier + `shared_preferences` achieves the same in <50 LOC |
| Backup | Google Drive `appdata` | Firebase Cloud Storage | Requires Firebase project setup, billing plan, and user authentication via Firebase Auth. Google Drive `appdata` is simpler — uses Google account user already has, no backend needed |
| Backup | Google Drive `appdata` | Dropbox API | Requires separate SDK, developer app registration, and users need Dropbox accounts. Google is more universal on Android |

---

## Dependency Impact on Architecture

Each new dependency maps to specific architecture layers:

| Package | Domain Layer | Data Layer | Presentation Layer |
|---------|-------------|------------|-------------------|
| `google_sign_in` | — | Data source (auth) | Sign-in UI |
| `googleapis` | — | Data source (Drive API) | — |
| `extension_google_sign_in_as_googleapis_auth` | — | Data source bridge | — |
| `flutter_secure_storage` | — | Data source (token storage) | — |
| `confetti` | — | — | Widget (savings goal screen) |
| *(theming)* | — | — | Theme provider + MaterialApp |
| *(fl_chart enhancements)* | New use cases | New repository queries | New report screens |

### New Repository Interfaces (Domain Layer)

Following existing repository segregation pattern:

```
lib/domain/repositories/
├── backup_repository.dart          // BackupRead, BackupWrite
├── budget_repository.dart          // BudgetRead, BudgetWrite, BudgetQuery
├── savings_goal_repository.dart    // SavingsGoalRead, SavingsGoalWrite, SavingsGoalQuery
└── goal_contribution_repository.dart // GoalContributionRead, GoalContributionWrite
```

### New Data Sources

```
lib/data/datasources/
├── remote/
│   └── google_drive_data_source.dart   // googleapis Drive v3 wrapper
├── local/
│   └── secure_storage_data_source.dart  // flutter_secure_storage wrapper
└── auth/
    └── google_auth_data_source.dart     // google_sign_in wrapper
```

### Database Schema Changes

Schema v2 → v3 migration (3 new tables):

```sql
CREATE TABLE budgets (
  id TEXT PRIMARY KEY,
  category_id TEXT NOT NULL,
  amount REAL NOT NULL,
  period TEXT NOT NULL,  -- 'monthly'
  month INTEGER NOT NULL,
  year INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (category_id) REFERENCES categories(id)
);

CREATE TABLE savings_goals (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  target_amount REAL NOT NULL,
  current_amount REAL NOT NULL DEFAULT 0,
  deadline TEXT,
  icon_name TEXT,
  color_value INTEGER,
  is_completed INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

CREATE TABLE goal_contributions (
  id TEXT PRIMARY KEY,
  goal_id TEXT NOT NULL,
  amount REAL NOT NULL,
  note TEXT,
  contributed_at TEXT NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (goal_id) REFERENCES savings_goals(id)
);
```

---

## Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| `google_sign_in` v7 breaking changes from v6 | Medium | v7 uses new `GoogleSignIn.instance` singleton pattern. Follow migration guide. Already researched via Context7 docs |
| Google OAuth consent screen rejection | Low | Using `drive.appdata` scope only — non-sensitive, no review needed |
| `flutter_secure_storage` Android backup conflicts | Low | Must set `android:allowBackup="false"` in manifest. Documented in package README |
| `googleapis` package size (includes all APIs) | Low | Tree-shaking removes unused APIs at build time. Only `DriveApi` is imported |
| `confetti` performance on low-end devices | Low | Cap `numberOfParticles` at 15–20. Use `shouldLoop: false` |
| SQLite schema migration v2→v3 | Medium | Follow existing `SchemaManager.onUpgrade()` pattern. Test migration on existing v2 databases |

---

## Sources

| Source | What Verified | Confidence |
|--------|--------------|------------|
| Context7: `google_sign_in` docs | v7.2.0 API: `authenticate()`, `authorizationClient`, scope authorization | HIGH |
| Context7: `flutter_secure_storage` docs | v10.0.0 API: `AndroidOptions`, encryption algorithms, biometric support | HIGH |
| Context7: `fl_chart` docs | `BarChart`, `LineChart`, `PieChart` constructors and customization | HIGH |
| Context7: `confetti` docs | `ConfettiWidget`, `ConfettiController`, particle customization | HIGH |
| pub.dev: `googleapis` ^16.0.0 | Includes Drive API v3 (`drive/v3`). Auto-generated client libraries | HIGH |
| pub.dev: `extension_google_sign_in_as_googleapis_auth` ^3.0.0 | Official bridge, `authenticatedClient()` extension method | HIGH |
| pub.dev: `googleapis_auth` docs | Explicit warning: "Do NOT use with Flutter" — must use bridge package | HIGH |
| pub.dev: `http` ^1.6.0 | Authenticated client composition, `BaseClient` subclassing | HIGH |
| AGENTS.md (project) | Existing stack versions, architecture patterns, codegen requirements | HIGH |
| `.planning/codebase/STACK.md` | Exact v1 dependency versions and schema state | HIGH |
