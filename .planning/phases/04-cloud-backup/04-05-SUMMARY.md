---
phase: 04-cloud-backup
plan: 05
subsystem: auth
tags: [google-sign-in, oauth, gap-closure, deletion-only, uat-blocker]

dependency_graph:
  requires:
    - phase: 04-04
      provides: "AuthController + dedicated sign-in UI that surfaced the UnimplementedError from signIn()"
  provides:
    - "AuthServiceImpl.signIn() that completes the OAuth flow using the constructor-declared drive.appdata scope"
    - "Unblocks UAT Tests 3–12 (all blocked-by Test 2)"
  affects: [uat-reverification, backup-flow, auth-controller]

tech_stack:
  added: []
  patterns:
    - "Constructor-declared OAuth scope is the single source of truth; no runtime scope-check two-step"

key_files:
  created: []
  modified:
    - lib/data/services/auth_service_impl.dart

key_decisions:
  - "No API substitution: GoogleSignIn.signIn() requests constructor-declared scopes automatically during OAuth — the deleted canAccessScopes/requestScopes block was dead code that threw UnimplementedError before any scope logic ran"
  - "Refused to add serverClientId to enable the dead API — that would be scope creep against the intentional architectural decision (no server-side client)"

patterns-established:
  - "Pattern: when a constructor already declares the contract (scope, config), do not re-check it at runtime — delete the redundant check, don't patch the symptom"

requirements-completed: [BKP-01]

coverage:
  - id: D1
    description: "AuthServiceImpl.signIn() flows directly from GoogleSignInAccount null-check to _buildAuthUser(googleUser) with no intervening scope-check two-step"
    requirement: BKP-01
    verification:
      - kind: other
        ref: "! grep -E 'canAccessScopes|requestScopes|_driveAppDataScope' lib/data/services/auth_service_impl.dart"
        status: pass
      - kind: other
        ref: "flutter analyze lib/data/services/auth_service_impl.dart (0 issues)"
        status: pass
    human_judgment: false
  - id: D2
    description: "No regressions across the full test suite after the deletion"
    verification:
      - kind: other
        ref: "flutter test (1156/1156 passing)"
        status: pass
    human_judgment: false
  - id: D3
    description: "Tapping 'Hubungkan Akun Google' completes the OAuth consent flow and connects the account (UAT Test 2 re-verification)"
    requirement: BKP-01
    verification: []
    human_judgment: true
    rationale: "Requires a real device with live Google OAuth (google-services.json + SHA-1) per the 04-04 user_setup — cannot be exercised in CI. This is UAT's job, not this plan's; the plan's automated gates end at flutter test."

duration: 4min
completed: 2026-06-30
status: complete
---

# Plan 04-05: Google Sign-In Scope-Check Two-Step Removal Summary

**Pure deletion of 18 dead lines from AuthServiceImpl.signIn() — removes the canAccessScopes/requestScopes block that threw UnimplementedError and blocked UAT Test 2, letting the constructor-declared drive.appdata scope drive OAuth.**

## Performance

- **Duration:** ~4 min
- **Started:** 2026-06-30T00:29:50Z
- **Completed:** 2026-06-30T00:34:06Z
- **Tasks:** 2 (1 auto edit + 1 verification-only)
- **Files modified:** 1 (`lib/data/services/auth_service_impl.dart`, −18 lines)

## Accomplishments
- Deleted the `_driveAppDataScope` constant (2 lines) — would have flagged `unused_element` once Region B was removed
- Deleted the `canAccessScopes()`/`requestScopes()` two-step block (14 lines + comment) between the null-check and `_buildAuthUser(googleUser)` — this was the exact stack frame (`auth_service_impl.dart:41`) throwing `UnimplementedError` and blocking UAT Test 2
- `signIn()` now flows: null-check → `_buildAuthUser(googleUser)` → catch chain, relying solely on the constructor-declared `drive.appdata` scope (`service_providers.dart:99-101`)
- Verified green: `flutter analyze lib/data/services/auth_service_impl.dart` 0 issues; negative grep for `canAccessScopes|requestScopes|_driveAppDataScope` clean; `flutter test` 1156/1156 passing
- Unblocks UAT Tests 3–12 (all blocked-by Test 2's auth failure)

## Task Commits

1. **Task 1: Delete redundant scope-check block and unused constant** — `66e53d0` (fix)
2. **Task 2: Confirm no regressions** — no commit (verification-only: `flutter analyze` + `flutter test`)

**Plan metadata:** (this commit) — docs: complete plan

## Files Created/Modified
- `lib/data/services/auth_service_impl.dart` — `signIn()` body simplified; 18 lines removed. try/catch chain, `// Trigger interactive sign-in` comment, `signOut()`/`getSignedInUser()`/`refreshToken()`/`_buildAuthUser()`/`_mapPlatformException()` all unchanged.

## Decisions Made
- **No API substitution.** `GoogleSignIn.signIn()` requests all constructor-declared scopes during the OAuth consent flow; the deleted block was never reachable on this platform interface and added zero behavioral value. Patching `canAccessScopes` with `serverClientId` would have been scope creep against an intentional architectural decision (no server-side client).
- **Refused to fix the pre-existing `onReorder` deprecation lint** in `category_management_screen.dart` — out of scope (different file, present at HEAD before this plan). Logged to `deferred-items.md` for a future chore phase rather than smuggled into a deletion-only fix.

## Deviations from Plan

None — plan executed exactly as written. Both target regions deleted; resulting `signIn()` matches the plan's target code byte-for-byte; try/catch and all other methods preserved; `service_providers.dart` untouched.

## Out-of-Scope Discovery (logged, not fixed)

**Pre-existing `info`-level lint — `deprecated_member_use` on `onReorder`**
- **File:** `lib/presentation/screens/category_management_screen.dart:213`
- **Provenance:** Present at HEAD before plan 04-05; file untouched by this plan.
- **Action:** Logged to `.planning/phases/04-cloud-backup/deferred-items.md`. Not fixed — fixing an unrelated Flutter-SDK deprecation during a deletion-only auth fix would be scope creep. The plan's per-file gate (`flutter analyze lib/data/services/auth_service_impl.dart` → 0 issues) passes; the project-wide gate carries this one pre-existing info that predates this work.

## Issues Encountered
None.

## User Setup Required
None additional. The per-developer Firebase setup from 04-04 (`google-services.json` + SHA-1, documented in `android/app/google-services.json.placeholder`) remains the only manual prerequisite for the on-device UAT re-verification of Test 2.

## Next Phase Readiness
- Phase 4 (Cloud Backup) auth path is now code-complete: the deletion removes the last known blocker for UAT Test 2.
- **Awaiting on-device UAT re-verification** of Test 2 (and the cascade Tests 3–12) on a real device with a valid `google-services.json`. This is the UAT's job, not this plan's — the plan's automated gates end at `flutter test`.
- No code blockers for Phase 5 (Enhanced Reports).

## Self-Check: PASSED

- `lib/data/services/auth_service_impl.dart` — FOUND (18 lines deleted, signIn() matches plan target)
- `.planning/phases/04-cloud-backup/04-05-SUMMARY.md` — FOUND
- Commit `66e53d0` — FOUND in git log
- Negative grep `canAccessScopes|requestScopes|_driveAppDataScope` — no matches (clean)
- `flutter analyze lib/data/services/auth_service_impl.dart` — 0 issues
- `flutter test` — 1156/1156 passing

---
*Phase: 04-cloud-backup*
*Plan: 05 (gap closure for UAT Test 2 blocker)*
*Completed: 2026-06-30*
