---
status: diagnosed
trigger: "After the user signs in with Google and then fully closes and reopens the app, the Google account connection is lost and the app asks the user to sign in again — instead of silently restoring/refreshing the session."
created: 2026-07-07T00:00:00Z
updated: 2026-07-07T00:00:00Z
goal: find_root_cause_only
---

## Current Focus

hypothesis: CONFIRMED — Cold-start session restore is missing. `AuthController.build()` → `_checkExistingUser()` only calls `getSignedInUser()`, which synchronously reads `_googleSignIn.currentUser` (always null on cold start). The codebase's `refreshToken()` method (which calls `signInSilently()`) has ZERO callers — it is dead code. No silent restore is ever attempted, so the UI renders signed-out after restart.
test: Trace cold-start auth path; grep all callers of `refreshToken`/`signInSilently`/`getConnectedAccountEmail`.
expecting: If hypothesis holds: (a) build() path uses only `currentUser` (no silent sign-in), (b) `refreshToken()` declared but uncalled, (c) persisted email never read back.
next_action: Report ROOT CAUSE FOUND to planner. No fix applied (diagnose-only).

## Symptoms

expected: After signing in, fully closing the app, and reopening it, the app silently refreshes/restores the signed-in Google account (via signInSilently or restored currentUser) and proceeds — NO prompt to sign in again.
actual: After the application is closed and reopened, the connection to the Google account is lost, and it asks to sign in again.
errors: None reported (no exception); the app simply shows the signed-out/unconnected state on cold start instead of restoring the session.
reproduction: UAT Test 12 — sign in, fully close the app, reopen, observe auth state. (100% reproducible.)
started: Discovered during Phase 04 UAT (on-device), 2026-07-07.

## Evidence

- timestamp: 2026-07-07
  checked: `lib/presentation/controllers/auth_controller.dart` lines 26-40
  found: `build()` (line 27-30) calls `_checkExistingUser()` then returns `AsyncValue.loading()`. `_checkExistingUser()` (lines 33-40) calls ONLY `authRepositoryProvider.getSignedInUser()`. No call to `refreshToken()`, no call to `signInSilently()`, no read of persisted SharedPreferences email.
  implication: The cold-start restore path relies entirely on whatever `getSignedInUser()` returns. There is no silent-refresh attempt.

- timestamp: 2026-07-07
  checked: `lib/data/services/auth_service_impl.dart` lines 63-77 (`getSignedInUser`) and lines 79-103 (`refreshToken`)
  found: `getSignedInUser()` reads `_googleSignIn.currentUser` SYNCHRONOUSLY (line 66) and returns `Result.success(null)` if it is null (lines 67-69). `google_sign_in` does NOT hydrate `currentUser` across cold starts without an explicit `signInSilently()` call, so on cold start this always returns null. `refreshToken()` (lines 79-103) IS implemented correctly and calls `_googleSignIn.signInSilently()` (line 83) — but is never invoked.
  implication: `_checkExistingUser()` is guaranteed to yield null on cold start, so `state = AsyncValue.data(null)` (auth_controller.dart:38), and the UI shows the signed-out state.

- timestamp: 2026-07-07
  checked: `grep -rn "refreshToken|signInSilently" lib/` — full callgraph of both symbols
  found: Only 7 matches total. `signInSilently()` appears ONLY inside `refreshToken()` (auth_service_impl.dart:83). `refreshToken()` is declared in the interface (auth_service.dart:46) and implemented (auth_service_impl.dart:80) — and has NO other callers anywhere in `lib/`. It is dead code.
  implication: No code path in the running app ever triggers a silent sign-in. This is the missing restore.

- timestamp: 2026-07-07
  checked: `grep -rn "getConnectedAccountEmail|setConnectedAccountEmail" lib/` — persisted-email usage
  found: `setConnectedAccountEmail()` is called in `auth_controller.dart:49` on successful `signIn()`. `getConnectedAccountEmail()` is defined in `shared_preferences_service.dart:70` but is NEVER CALLED anywhere in `lib/`. The persisted email is write-only.
  implication: Even the cosmetic "remembered email" fallback is absent. The persisted email exists in SharedPreferences but is never consulted to (a) decide whether to attempt silent refresh, or (b) display a "restoring…" placeholder. (However, even if it were read, it would not by itself restore the live `GoogleSignInAccount`/auth headers — backups would still fail without a real `signInSilently()`.)

- timestamp: 2026-07-07
  checked: `lib/presentation/screens/backup_screen.dart` lines 44-84; `grep` for `signInSilently|getSignedInUser|_checkExistingUser|refreshToken` across `lib/` (13 matches, none in main.dart or any bootstrap)
  found: BackupScreen line 46-47: `final authState = ref.watch(authControllerProvider); final connectedEmail = authState.value?.email;`. Line 78: `if (connectedEmail == null && ...)` shows the "Hubungkan Akun Google" connect-prompt button. No app-level bootstrap (main.dart, app.dart, ProviderScope) calls signInSilently or refreshToken.
  implication: UI is driven entirely by the live AuthUser from AuthController, which is null on cold start per the chain above. Symptom fully explained end-to-end.

- timestamp: 2026-07-07
  checked: `.planning/phases/04-cloud-backup/04-UAT.md` Test 12 (lines 72-76) and Gaps section (lines 126-134)
  found: Test 12 status = issue, severity = major. Reported: "After the application is closed and reopened, the connection to the Google account is lost, and it asks to sign in again." `root_cause` field is empty — this debug session fills it.
  implication: Confirms the symptom and that this root cause was previously unidentified.

## Eliminated

(none — primary hypothesis confirmed on first trace; no competing hypotheses required)

## Resolution

root_cause: MISSING silent-restore on cold start. The cold-start auth path `AuthController.build()` → `_checkExistingUser()` (auth_controller.dart:27-40) calls only `AuthServiceImpl.getSignedInUser()` (auth_service_impl.dart:63-77), which synchronously reads `_googleSignIn.currentUser`. `google_sign_in` does not hydrate `currentUser` across cold starts without an explicit `signInSilently()`, so this always returns `Result.success(null)` → state becomes `AsyncValue.data(null)` → BackupScreen renders the signed-out UI. The correct silent-restore method `AuthServiceImpl.refreshToken()` (auth_service_impl.dart:79-103, calls `_googleSignIn.signInSilently()` at line 83) EXISTS but has ZERO callers — it is dead code. Additionally, the persisted SharedPreferences connected-email (`setConnectedAccountEmail`, written in auth_controller.dart:49) is never read back (`getConnectedAccountEmail` has no callers), so there is no fallback signal to trigger a restore attempt.

fix: (planner to author) On startup, attempt silent session restoration. Concretely: in `AuthController._checkExistingUser()` (or `build()`), consult the persisted connected-email from SharedPreferences — if non-empty, call `refreshToken()` (which performs `signInSilently()`); on success seed state with the returned AuthUser, on failure fall through to signed-out (and optionally clear the stale persisted email). Per AGENTS.md, keep the initialization inside `build()`/a method it kicks off — do NOT move to a constructor. Do NOT apply this fix in diagnose-only mode.

verification: (pending — planner plans it; suggest a unit/integration test that constructs AuthController with a stubbed AuthService whose `refreshToken()` returns a fixed AuthUser, and asserts state transitions loading → AsyncData(authUser) on first build; plus a UAT-12 re-run on a real device: sign in, force-stop, reopen, expect connected state with no re-prompt.)

files_changed: []
