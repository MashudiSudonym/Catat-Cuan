---
phase: 04-cloud-backup
plan: 04
subsystem: auth
tags: [google-sign-in, oauth, riverpod, gradle, error-mapping, gap-closure]
dependency_graph:
  requires: [04-01]
  provides: [auth-controller, dedicated-sign-in-ui, google-services-gradle-wiring, auth-error-surfacing]
  affects: [backup-screen, backup-providers, auth-controller]
tech_stack:
  added: [com.google.gms.google-services 4.4.2]
  patterns: [riverpod-auth-controller, dedicated-sign-in-action, human-verify-checkpoint]
key_files:
  created:
    - lib/presentation/controllers/auth_controller.dart
    - android/app/google-services.json.placeholder
  modified:
    - android/settings.gradle.kts
    - android/app/build.gradle.kts
    - lib/presentation/screens/backup_screen.dart
  tested: []
decisions:
  - AuthController is a separate @riverpod controller from BackupController, holding AsyncValue<AuthUser?> so sign-in state is observable independently of backup progress
  - Google Services plugin declared with `apply false` in settings.gradle.kts (v4.4.2) and applied only in app/build.gradle.kts — standard Android Gradle pattern
  - google-services.json is NOT committed (contains per-project OAuth credentials); a .placeholder file documents the 5-step Firebase setup so the build compiles and the contract is self-describing
  - BackupScreen drives all account state from ref.watch(authControllerProvider); "Buat Backup" while unauthenticated prompts the user to connect first
key_decisions:
  - "Separate AuthController from BackupController so auth state is observable without coupling to backup progress"
  - "Ship google-services.json.placeholder (not the real file) — keeps OAuth creds out of git while documenting the setup"
patterns-established:
  - "Pattern: dedicated @riverpod controller per concern (auth vs backup) returning AsyncValue for reactive UI"
  - "Pattern: .placeholder file for required-but-secret platform config (google-services.json)"
requirements-completed: [BKP-01, BKP-07]
coverage:
  - id: D1
    description: "Google Services Gradle plugin declared (apply false, v4.4.2) in settings.gradle.kts and applied in app/build.gradle.kts"
    requirement: BKP-01
    verification:
      - kind: other
        ref: "grep 'com.google.gms.google-services' android/settings.gradle.kts android/app/build.gradle.kts"
        status: pass
    human_judgment: false
  - id: D2
    description: "google-services.json.placeholder with 5-step Firebase setup instructions exists at android/app/"
    requirement: BKP-01
    verification:
      - kind: other
        ref: "test -f android/app/google-services.json.placeholder"
        status: pass
    human_judgment: false
  - id: D3
    description: "AuthController (@riverpod) with signIn/signOut/getSignedInUser, persists connected email via SharedPreferencesService"
    requirement: BKP-01
    verification:
      - kind: unit
        ref: "flutter analyze lib/presentation/controllers/auth_controller.dart (0 issues)"
        status: pass
    human_judgment: false
  - id: D4
    description: "BackupScreen shows dedicated 'Hubungkan Akun Google' button when not connected, connected email when signed in, and surfaces auth errors as visible red Indonesian text via ErrorMessageMapper"
    requirement: BKP-07
    verification: []
    human_judgment: true
    rationale: "Sign-in button visibility, account-card state transitions, and Indonesian error surfacing require a real device with live Google OAuth (google-services.json + SHA-1) — verified manually in the blocking checkpoint (Task 3, approved)."
duration: 11min
completed: 2026-06-26
status: complete
---

# Plan 04-04: Google Sign-In Auth Flow Fix Summary

**Dedicated Google Sign-In button + AuthController + Google Services Gradle wiring, surfacing auth errors visibly instead of swallowing them silently.**

## Performance

- **Duration:** ~11 min (Tasks 1–2 automated; Task 3 blocking human-verify checkpoint approved by user after Firebase setup + device test)
- **Started:** 2026-06-26T16:21:31+07:00
- **Completed:** 2026-06-26 (checkpoint approved same session)
- **Tasks:** 3 (2 auto + 1 human-verify)
- **Files modified:** 5 (2 created, 3 modified; generated `.g.dart` is gitignored by repo convention)

## Accomplishments
- Added `com.google.gms.google-services` Gradle plugin (v4.4.2, `apply false` in settings, applied in app) so Google Sign-In is wired into the Android platform project
- Created `AuthController` (`@riverpod`) holding `AsyncValue<AuthUser?>` — sign-in state is now observable independently from backup progress, with email persisted to SharedPreferences on success
- BackupScreen now shows a dedicated "Hubungkan Akun Google" button when not connected, the connected email + "Putuskan Koneksi" when authenticated, and red Indonesian error text (via `ErrorMessageMapper`) on failure — replacing the old silent inline-triggered sign-in
- `google-services.json.placeholder` documents the 5-step Firebase setup so the build compiles without leaking OAuth credentials
- Unblocks 10 dependent UAT cases that previously failed on silent auth

## Task Commits

1. **Task 1: Add Google Services Gradle plugin + placeholder** — `151b41b` (feat)
2. **Task 2: AuthController + dedicated sign-in UI** — `d866a67` (feat)
3. **Task 3: Human-verify checkpoint (Firebase setup + device test)** — no commit (gate-only); **approved** by user

## Files Created/Modified
- `android/settings.gradle.kts` — declared `com.google.gms.google-services` v4.4.2 `apply false`
- `android/app/build.gradle.kts` — applied `com.google.gms.google-services` plugin
- `android/app/google-services.json.placeholder` (NEW) — 5-step Firebase setup instructions
- `lib/presentation/controllers/auth_controller.dart` (NEW) — `@riverpod` AuthController: signIn / signOut / getSignedInUser, AsyncValue<AuthUser?> state, email persistence
- `lib/presentation/screens/backup_screen.dart` — reactive auth state via `ref.watch(authControllerProvider)`; dedicated sign-in / sign-out buttons; visible Indonesian error surfacing

## Decisions Made
- **Separate AuthController from BackupController:** auth state must be observable without coupling to backup progress — a dedicated `@riverpod` controller returning `AsyncValue<AuthUser?>` is the idiomatic Riverpod 3.x shape.
- **Ship a `.placeholder`, not the real `google-services.json`:** the real file holds per-project OAuth credentials and must not be committed. The placeholder keeps the build green and self-documents setup.
- **Drive BackupScreen entirely from `authControllerProvider`:** removed the static `_connectedEmail` field so the UI is a pure function of auth state.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 — Blocking] Stale `<interfaces>` block in the plan**
- **Found during:** Task 2 (AuthController implementation)
- **Issue:** The plan's `<interfaces>` snippet listed `AuthRepository.getCurrentUser()`, but the real interface (from 04-01) exposes `getSignedInUser()`.
- **Fix:** Used `getSignedInUser()` to match the actual `AuthRepository` contract.
- **Files modified:** lib/presentation/controllers/auth_controller.dart
- **Verification:** `flutter analyze` clean on the file.
- **Committed in:** d866a67 (Task 2 commit)

**2. [Rule 3 — Convention alignment] Generated `.g.dart` not committed**
- **Found during:** Task 2 (code generation)
- **Issue:** Plan said to commit `auth_controller.g.dart`, but the repo `.gitignore` excludes `*.g.dart` (no generated file is tracked, including `backup_controller.g.dart`).
- **Fix:** Followed repo convention — did not force-add. The file regenerates via `flutter pub run build_runner build --delete-conflicting-outputs`.
- **Verification:** `git check-ignore lib/presentation/controllers/auth_controller.g.dart` → ignored (confirmed).
- **Committed in:** (N/A — file intentionally untracked)

---

**Total deviations:** 2 auto-fixed (1 blocking interface mismatch, 1 convention alignment)
**Impact on plan:** Both necessary for correctness/repo hygiene. No scope creep.

## Issues Encountered
None beyond the deviations above. `flutter analyze` clean on changed files; `flutter test` 1156/1156 passing (no regressions).

## User Setup Required

**Yes — external, one-time, per developer.** Google Sign-In requires a real `google-services.json` from Firebase Console (cannot be committed). See `android/app/google-services.json.placeholder` for the 5 steps:
1. Get debug keystore SHA-1: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
2. Firebase Console → add Android app `com.tigasatudesember.catat_cuan` → add SHA-1 fingerprint
3. Enable Google Sign-In in Authentication → Sign-in method
4. Download `google-services.json` → place at `android/app/google-services.json` (replaces placeholder, keep local)
5. `flutter run` and verify the sign-in flow

## Next Phase Readiness
- Phase 4 (Cloud Backup) is now fully complete: auth layer (04-01), backup engine (04-02), restore + management UI (04-03), and the auth-flow fix (04-04) all shipped.
- No code blockers for Phase 5 (Enhanced Reports). The only outstanding item is the per-developer Firebase setup above, which does not block reports work.

---
*Phase: 04-cloud-backup*
*Plan: 04 (gap closure)*
*Completed: 2026-06-26*
