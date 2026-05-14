# Phase 4: Cloud Backup - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-14
**Phase:** 4-Cloud Backup
**Areas discussed:** Backup data format & versioning, OAuth flow & token management, Restore UX & conflict handling, Backup management & auto-cleanup

---

## Backup Data Format & Versioning

| Option | Description | Selected |
|--------|-------------|----------|
| Single JSON file | One file with all tables under named keys. Atomic, one upload/download. | ✓ |
| Multiple files per table | One JSON file per table in a folder. Granular but multiple API calls. | |

| Option | Description | Selected |
|--------|-------------|----------|
| Schema version header | Include schema_version in backup. Compare on restore. Run migration if older, reject if newer. | ✓ |
| Simple version counter | Increment manually. Less robust. | |

| Option | Description | Selected |
|--------|-------------|----------|
| Include all settings | Backup theme, onboarding state. Restore complete app state. | ✓ |
| Data only | Only financial data. Settings stay on device. | |

| Option | Description | Selected |
|--------|-------------|----------|
| Entity toJson serialization | Query DB → map to Freezed entities → toJson(). Reuses existing code. | ✓ |
| Raw DB row serialization | Query DB → raw Map → JSON. 1:1 DB mapping but separate serialization logic. | |

| Option | Description | Selected |
|--------|-------------|----------|
| Timestamp-based naming | catatcuan_backup_20260514_143052.json. Unique, sortable. | ✓ |
| Fixed name with version suffix | catatcuan_backup_v1.json. Cleaner but needs version tracking. | |

| Option | Description | Selected |
|--------|-------------|----------|
| No compression | JSON as-is. Under 5MB within Drive limits. Debuggable. | ✓ |
| Gzip compression | ~80% size reduction. Adds complexity. | |

| Option | Description | Selected |
|--------|-------------|----------|
| Full metadata | app_version, schema_version, device_model, created_at, data_counts. Useful for preview. | ✓ |
| Minimal metadata | Just version + created_at. Lighter. | |

**Notes:** User consistently chose the recommended option for all format decisions.

---

## OAuth Flow & Token Management

| Option | Description | Selected |
|--------|-------------|----------|
| google_sign_in | Official Google package. Handles sign-in, scope, tokens. | ✓ |
| Custom OAuth via flutter_appauth | Generic OAuth2/OIDC. More control but overkill. | |

| Option | Description | Selected |
|--------|-------------|----------|
| flutter_secure_storage | Platform Keychain/EncryptedSharedPreferences. Encrypted at rest. | ✓ |
| shared_preferences | Already used but plain text. NOT suitable for auth tokens. | |

| Option | Description | Selected |
|--------|-------------|----------|
| Sign-in on demand | Trigger Google Sign-In when user taps Backup/Restore. No upfront wall. | ✓ |
| Sign-in on Settings screen | Must connect account in Settings first. More traditional. | |

| Option | Description | Selected |
|--------|-------------|----------|
| Show account in Settings | Connected account email + disconnect in Settings. Backup screens stay clean. | ✓ |
| Show on backup screen | Account management on backup screen. More visible but cluttered. | |

**Notes:** Security-conscious choices — flutter_secure_storage for tokens, minimal auth surface.

---

## Restore UX & Conflict Handling

| Option | Description | Selected |
|--------|-------------|----------|
| Full preview | Show date, size, device, data counts per table. Compare with current data. | ✓ |
| Minimal preview | Just date and size. Less info but simpler. | |

| Option | Description | Selected |
|--------|-------------|----------|
| Warning dialog + confirm | Show warning with data counts. User must type "GANTI" or hold 3 seconds. | ✓ |
| Simple confirm dialog | Standard "Are you sure?" with Ya/Tidak. Risk of accidental restore. | |

| Option | Description | Selected |
|--------|-------------|----------|
| Linear progress bar | Stages: "Membuat backup..." → "Mengupload..." → "Selesai!" | ✓ |
| Spinner with status text | Circular spinner with changing messages. Less informative. | |

**Notes:** User wants strong guardrails against accidental restore (destructive confirm pattern).

---

## Backup Management & Auto-cleanup

| Option | Description | Selected |
|--------|-------------|----------|
| Auto-cleanup after backup | After upload, if > 5 backups, delete oldest. Automatic. | ✓ |
| Manual cleanup only | User deletes old backups. More control but accumulation risk. | |

| Option | Description | Selected |
|--------|-------------|----------|
| Glass cards list | Each backup as glass card with metadata. Consistent with app design. | ✓ |
| Simple list tiles | Standard Material ListTile. Less visual. | |

| Option | Description | Selected |
|--------|-------------|----------|
| Settings screen entry | Backup & Restore section in Settings. Shows last backup, account. | ✓ |
| New tab or bottom sheet | Dedicated tab. More visible but overkill for infrequent action. | |

**Notes:** Backup/restore is an infrequent action — Settings is the right home for it.

---

## Agent's Discretion

- Exact Google Sign-In scope request configuration
- Token refresh retry logic and backoff strategy
- Error-specific Indonesian messages mapping
- Progress bar percentage calculation approach
- Confirm dialog exact visual design
- Delete backup confirmation flow
- First backup empty state messaging

## Deferred Ideas

None — discussion stayed within phase scope
