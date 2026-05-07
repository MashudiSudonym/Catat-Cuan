# Domain Pitfalls: Catat Cuan v2

**Domain:** Personal finance app — adding budgeting, savings goals, Google Drive backup, dark mode, and enhanced reports to production-ready Flutter v1
**Researched:** 2026-05-06
**Overall Confidence:** HIGH (codebase-verified + official docs + domain experience)

---

## Critical Pitfalls

Mistakes that cause data loss, rewrite, or broken production v1.

### Pitfall 1: Schema Migration Breaks Existing v1 Data

**What goes wrong:** The `onUpgrade` migration from schema v2→v3 fails silently or partially. Users with existing transactions open the app, migration crashes midway, and the database is left in an inconsistent state — half-migrated with corrupted foreign key relationships. Since `onUpgrade` runs in a transaction in sqflite, a crash rolls back, but the app may be left unable to open if the version number got written.

**Why it happens:** The existing `SchemaManager.onUpgrade` (schema_manager.dart:35) uses `if (oldVersion < 2)` style checks. Adding `if (oldVersion < 3)` for three new tables (`budgets`, `savings_goals`, `goal_contributions`) seems straightforward, but:
- Forgetting to add the new tables to `onCreate` means fresh installs get different schemas than upgrades
- Not creating indexes for the new tables during migration
- Missing foreign key references from `goal_contributions` to `savings_goals`
- The `onCreate` path (line 21-28) doesn't create new tables — only categories and transactions

**Consequences:** Users lose all transaction data. The app cannot open. Crash loop on launch. The worst kind of failure — silent data corruption on existing production users.

**Prevention:**
1. **Test both paths:** Every migration must be tested for both `onCreate` (fresh install with version=3) AND `onUpgrade` (v2→v3). Write integration tests that: (a) create a v2 database, seed it with transactions, then open with v3 code and verify data intact + new tables exist; (b) fresh install with v3 and verify all tables exist.
2. **Use batch operations** in migration (sqflite docs confirm `onUpgrade` runs in a transaction — use `db.batch()` for atomicity).
3. **Never modify existing table columns** in the v2→v3 migration — only ADD new tables. Column modifications to `transactions` or `categories` tables are catastrophic risk.
4. **Keep `onCreate` in sync** — `onCreate` must create ALL tables (v1 + v2 + v3), not just new ones.

**Detection:** Warning signs — tests only cover fresh install, not upgrade path; `onCreate` doesn't include new tables; migration tested manually but not automated.

**Phase:** Phase 1 (Foundation — database schema migration is Week 1)

---

### Pitfall 2: Google Drive OAuth Token Becomes Invalid Between Sessions

**What goes wrong:** User authenticates with Google, backs up successfully. Next week, they try to restore — the access token has expired (Google access tokens last ~1 hour). The app shows a cryptic "401 Unauthorized" or crashes trying to use a stale `DriveApi` client. The user thinks their backup is gone.

**Why it happens:** `google_sign_in` returns an access token that expires quickly. The PRD specifies `flutter_secure_storage` for token storage, but storing just the access token is useless once it expires. The common mistake is:
- Storing the access token and assuming it persists
- Not using `google_sign_in`'s `signInSilently()` to refresh tokens
- Not wrapping every Drive API call in a "try → 401 → re-auth → retry" pattern
- The `googleapis` Dart package doesn't auto-refresh tokens — you must provide fresh auth headers

**Consequences:** Backup appears to work but restore fails days later. User trust destroyed. "Lost my data" is the worst possible outcome for a finance app.

**Prevention:**
1. **Never store raw access tokens** — store refresh capability via `google_sign_in`'s persistent session. Call `signInSilently()` at the start of every backup/restore operation to get a fresh access token.
2. **Wrap every Drive API call** in a re-auth retry: `try { call } catch (401) { signInSilently(); retry; }`.
3. **Use `extension_google_sign_in_as_googleapis_auth`** (listed in PRD deps) to bridge `google_sign_in` auth headers to `googleapis` `DriveApi` client — but re-obtain headers before each API call.
4. **Test token expiry explicitly** — mock a 401 response and verify the retry path works.

**Detection:** Warning signs — code stores access token in secure storage; no retry logic around Drive API calls; `signInSilently()` not called before operations; no test for expired token scenario.

**Phase:** Phase 4 (Cloud Backup — Week 7-8)

---

### Pitfall 3: Backup/Restore Data Format Incompatibility Between App Versions

**What goes wrong:** v2.0 backs up data including budgets and savings goals. User restores this backup on a device still running v1 (or v2.1 changes the schema). The restore either fails with "unknown table" errors or silently drops the new data. Worse: the restore partially succeeds, corrupting the database state.

**Why it happens:** The PRD says backup includes "transaksi, kategori, settings" but v2 adds budgets, savings_goals, and goal_contributions. Without a version stamp in the backup file:
- v2 backup restored on v1 app → new tables don't exist → data loss or crash
- v2.1 backup with schema changes restored on v2.0 → schema mismatch
- JSON export/import doesn't enforce schema version

**Consequences:** Data corruption across versions. Users who upgrade and downgrade (sideloading APK) lose data. Restore appears to succeed but budgets/goals are silently missing.

**Prevention:**
1. **Embed a schema version in every backup file** — `{ "version": 3, "data": { ... } }`.
2. **Validate version on restore** — if backup version > app version, warn user to update app first. If backup version < app version, run migration on restored data.
3. **Use JSON format** (not raw SQLite file) for backup — it's version-resilient, human-readable, and works across architectures (arm64→x86).
4. **Write restore as idempotent** — restoring the same backup twice should not duplicate transactions. Use ID mapping or upsert logic.

**Detection:** Warning signs — backup is a raw SQLite file copy; no version field in backup; restore doesn't validate backup integrity before writing; no test for version mismatch scenarios.

**Phase:** Phase 4 (Cloud Backup — Week 7-8)

---

### Pitfall 4: Glassmorphism Colors Hardcoded for Light Mode in Existing Widgets

**What goes wrong:** After implementing dark mode, existing v1 screens look broken — glass containers use hardcoded `AppColors.surfaceLight` (white) instead of theme-aware colors. Some widgets render as white-on-dark rectangles, destroying the glassmorphism aesthetic. The existing `AppColors` class already has `isDark` parameters, but individual widgets may bypass them.

**Why it happens:** The current `AppColors` (app_colors.dart) already has dark-aware methods (`getGlassSurface`, `getGlassCard`, etc. with `isDark` parameter), but existing v1 widgets likely call these without `isDark` or use direct color constants like `AppColors.surfaceLight` instead of `AppColors.getSurfaceColor(isDark)`. Adding dark mode means auditing EVERY existing widget for:
- Hardcoded `Color(0xFF...)` values
- Direct use of `AppColors.surfaceLight` instead of theme-aware methods
- `BackdropFilter` blur values that look wrong on dark backgrounds (dark mode needs slightly more blur — already handled in `GlassBlur.getAdjustedBlur` but only if called)

**Consequences:** Dark mode ships looking broken on half the screens. Users see white boxes, invisible text, or glass effects that look like smudges. Negative reviews and "dark mode is broken" feedback.

**Prevention:**
1. **Audit ALL existing widgets** before Phase 1 starts — grep for `AppColors.surfaceLight`, `AppColors.backgroundLight`, `Colors.white`, `Colors.black` hardcoded references. Replace with `AppColors.getSurfaceColor(isDark)` or `Theme.of(context)` calls.
2. **Use `Theme.of(context).brightness`** consistently — don't pass `isDark` as a parameter through 5 layers. The `AppColors` methods should accept `BuildContext` and read brightness internally.
3. **Create a dark mode visual test suite** — screenshots of every screen in light + dark mode, compared for regressions.
4. **The existing `AppColors` dark-aware methods are GOOD** — the pattern is already established. The risk is that existing code doesn't use them.

**Detection:** Warning signs — `grep -r "surfaceLight"` shows direct usage in widgets; `grep -r "Colors.white"` in widget files; widgets don't read `Theme.of(context).brightness`; no visual regression test for dark mode.

**Phase:** Phase 1 (Foundation — dark mode must be validated against ALL existing screens before new features are built)

---

## Moderate Pitfalls

### Pitfall 5: Budget Alerts Fire on Every Transaction (Notification Spam)

**What goes wrong:** Budget at 75% triggers a warning on every subsequent transaction. User adds 5 small transactions in a row → 5 notifications in 2 minutes. User disables notifications entirely, defeating the purpose of budgeting.

**Why it happens:** PRD specifies 75%/100%/overspending alert levels. Naive implementation checks budget threshold after EVERY transaction insert and fires a notification if crossed. No deduplication, no cooldown, no "already notified this threshold" tracking.

**Prevention:**
1. **Track last notified threshold** per budget per month in the database (`budget_alerts` table or `settings` field).
2. **Only fire once per threshold crossing** — 75% alert fires exactly once, then 100% fires once when reached.
3. **Implement a daily summary option** (mentioned in PRD mitigation) — "You've used 78% of your Food budget today" instead of per-transaction alerts.
4. **Respect notification cooldown** — minimum 4 hours between budget notifications for the same category.

**Detection:** Warning signs — no `last_notified` field in budget schema; notification logic runs synchronously in transaction save path; no test for "consecutive transactions at same threshold."

**Phase:** Phase 2 (Budgeting — Week 3-4)

---

### Pitfall 6: Budget Month Rollover Calculations Are Wrong

**What goes wrong:** "Current month budget" calculation includes transactions from wrong months. Budget for January shows December transactions or misses late-January transactions. Timezone issues cause transactions on the 31st at 11:59 PM to appear in the next month.

**Why it happens:** The existing transactions table stores `date_time` as TEXT (schema_manager.dart:79). Date comparison in SQLite is string-based. If the app uses `DateTime.now()` for "current month" boundaries but stores dates in different formats or timezones, month boundaries don't match. Specifically:
- `strftime('%Y-%m', date_time)` (already used for indexes) must match the comparison logic
- User changes phone timezone → transactions shift months
- No explicit "budget period" entity — budget period is implicit (current month)

**Prevention:**
1. **Use a consistent date format** — all dates stored as ISO 8601 UTC (`YYYY-MM-DDTHH:MM:SSZ`).
2. **Calculate month boundaries in Dart** (not SQL) — `DateTime(now.year, now.month, 1)` to `DateTime(now.year, now.month + 1, 1)` for clear boundaries.
3. **Store budget period explicitly** — `budgets` table should have `year_month TEXT` column (e.g., "2026-05") for unambiguous period matching.
4. **Test timezone edge cases** — transactions at month boundary, timezone changes, leap years.

**Detection:** Warning signs — month calculation uses `BETWEEN` with date strings; no explicit budget period field; tests only use dates in the middle of months.

**Phase:** Phase 2 (Budgeting — Week 3-4)

---

### Pitfall 7: Savings Goal Contributions Don't Affect Transaction Balance

**What goes wrong:** User "contributes" 500K IDR to a savings goal, but this doesn't create a corresponding transaction. The money appears "spent" in the goal but still shows as available in their regular balance. Or worse: contribution creates a transaction, but withdrawing from goal creates a duplicate income entry.

**Why it happens:** The PRD separates "contributions" from "transactions" — `goal_contributions` table is independent. But from a financial perspective, moving money to a savings goal is like earmarking it. The question is: does a contribution reduce available balance? Two valid designs exist, and choosing wrong creates confusion.

**Prevention:**
1. **Decide explicitly before implementation**: Is a contribution a real transaction (reduces available balance) or just an earmark (visual tracking only)? Document this in the entity design.
2. **Recommended approach for v2**: Contributions are earmarks, not transactions. The savings goal tracks a subset of existing funds. This is simpler and doesn't affect the existing transaction balance.
3. **If contributions ARE transactions**: The contribution must create a transfer-type transaction (new transaction type: 'transfer'). Withdrawal reverses it. This is more complex but more accurate.
4. **Whichever approach is chosen, write it down in the architecture docs** before coding.

**Detection:** Warning signs — no design decision documented; `goal_contributions` table has no `transaction_id` foreign key (if earmark approach) or has one (if transaction approach); ambiguity in PRD about "is this real money moving."

**Phase:** Phase 3 (Savings Goals — Week 5-6)

---

### Pitfall 8: fl_chart Performance Degrades with Large Transaction History

**What goes wrong:** Enhanced reports load a year of daily data (365+ data points) into `BarChart` or `LineChart`. The chart stutters, takes 2+ seconds to render, and consumes excessive memory. Monthly comparison charts with 12 months × multiple categories create hundreds of `BarChartRodData` objects that trigger layout thrashing.

**Why it happens:** fl_chart is a custom-painter library — it redraws on every frame during animations and gestures. With 365 data points:
- Each `FlSpot` triggers a layout calculation
- Touch handling scans all data points for hit testing
- `BarChartGroupData` creates many render objects
- The existing v1 charts likely have <30 data points (monthly summary), so this hasn't been a problem yet

**Prevention:**
1. **Aggregate data before feeding to charts** — daily view shows last 30 days, weekly shows last 12 weeks, monthly shows last 12 months, yearly shows last 5 years. Never render 365+ raw data points.
2. **Use `SwapAnimationDuration: Duration.zero`** for data-heavy charts to skip animation.
3. **Implement lazy loading** — load monthly data first, fetch daily detail on drill-down only.
4. **Profile with Flutter DevTools** — measure actual render time with 1000+ transactions before accepting the approach.
5. **Consider pre-aggregating in SQLite** — `SELECT strftime('%Y-%m', date_time) as month, SUM(amount) FROM transactions GROUP BY month` is fast.

**Detection:** Warning signs — chart receives raw transaction list instead of aggregated data; no pagination on report queries; testing only with <50 transactions; no performance test with realistic data volume.

**Phase:** Phase 5 (Enhanced Reports — Week 9-10)

---

### Pitfall 9: Theme Switch Causes UI Flicker and State Loss

**What goes wrong:** Toggling dark mode in Settings causes: (a) visible white flash before dark theme applies, (b) scroll position resets to top on all screens, (c) any in-progress form input is lost, (d) `MaterialApp` rebuilds entirely, remounting all routes.

**Why it happens:** The naive implementation changes theme by calling `setState` on the root widget, which rebuilds `MaterialApp`. This recreates the entire widget tree. If theme preference is stored in a Riverpod provider that's watched at the root, changing it triggers a full rebuild.

**Prevention:**
1. **Use `MaterialApp.theme` property** and let Flutter handle the animation — don't rebuild `MaterialApp` itself. Theme changes should be reactive via `theme` and `darkTheme` properties with `themeMode` control.
2. **Store theme preference in a `keepAlive` Riverpod provider** that persists across app launches but doesn't force full widget rebuild.
3. **Use `AnimatedTheme` or rely on Material 3's built-in theme transitions** — don't force-invalidate providers on theme change.
4. **Test theme toggle while:** on a form with unsaved input, scrolled mid-list, with a dialog open.

**Detection:** Warning signs — theme change triggers `ref.invalidate` on root provider; `MaterialApp` key changes on theme toggle; `themeMode` not used (only `theme`); no test for scroll position preservation.

**Phase:** Phase 1 (Foundation — dark mode implementation)

---

### Pitfall 10: New Features Overload Home Screen (Feature Bloat)

**What goes wrong:** v2 adds budget overview card, savings goals card, AND enhanced report quick-access to the Home Screen. The screen becomes scrollable with 6+ cards, pushing actual transaction list below the fold. The PRD itself lists "Budget overview card di Home Screen" and "Goals overview card di Home Screen" — both fighting for limited space.

**Why it happens:** Each feature team (budgeting, goals, reports) independently adds their "overview card" to the home screen. No one governs the overall layout. The existing home screen already has a summary section.

**Prevention:**
1. **Design the home screen layout FIRST** before implementing any feature's "home card." Decide maximum cards (recommend: 2-3, with collapse/expand).
2. **Use a priority system**: Today's budget status > savings goal progress > report teaser. Show the most actionable item prominently.
3. **Implement "dismiss" or "collapse"** — let users hide cards they don't need.
4. **Consider a dashboard tab** instead of cramming everything on the transaction home screen.

**Detection:** Warning signs — each feature spec independently says "add card to home screen"; no unified home screen mockup exists; home screen mockup shows 4+ cards.

**Phase:** Phase 1 (design) → then each feature phase

---

## Minor Pitfalls

### Pitfall 11: Confetti Animation Causes Jank on Low-End Devices

**What goes wrong:** Savings goal completion triggers a confetti celebration (PRD specifies confetti dependency). On budget Android devices, the particle system drops frames, causing visible jank that ruins the celebratory moment.

**Prevention:** Use `confetti` package with particle limit capped at 50-100. Test on a mid-range device (not just emulator). Auto-dismiss after 3 seconds. Don't fire confetti during scroll or animation.

**Phase:** Phase 3 (Savings Goals)

---

### Pitfall 12: Google Drive `appDataFolder` Deleted on App Uninstall

**What goes wrong:** User uninstalls the app to free space, planning to reinstall later. Google Drive `appDataFolder` (the backup location specified in the PRD) is automatically deleted on uninstall. When they reinstall, the backup is gone.

**Prevention:** This is a Google Drive API constraint (documented in official docs: "The application data folder is deleted when a user uninstalls your app"). **Document this clearly to users** in the backup UI. Consider offering a secondary "export to user-visible Drive folder" option for paranoid users. Show a warning before uninstall (not possible on Android, but show it in backup confirmation).

**Phase:** Phase 4 (Cloud Backup)

---

### Pitfall 13: `extension_google_sign_in_as_googleapis_auth` Package Instability

**What goes wrong:** The `extension_google_sign_in_as_googleapis_auth` package (listed in PRD dependencies) is a thin adapter that may have version conflicts with `google_sign_in` or `googleapis`. It's maintained less actively than the core packages.

**Prevention:** Pin exact versions in `pubspec.yaml`. Test the auth flow on a clean install. Have a fallback plan: manually extract auth headers from `GoogleSignIn` and pass to `DriveApi` via `AuthClient` wrapper.

**Phase:** Phase 4 (Cloud Backup)

---

### Pitfall 14: Repository Segregation Pattern Creates Too Many Files

**What goes wrong:** Following v1's pattern of 4+ repository interfaces per entity, adding budgets (4 interfaces) + savings goals (4+ interfaces) + backup (2+ interfaces) creates 10+ new repository files. Code navigation becomes difficult, and simple CRUD operations require touching 5+ files.

**Prevention:** Follow the existing pattern for consistency (don't refactor during v2), but consider combining Read + Query interfaces for new entities where the interface count doesn't add clarity. Budget likely needs: `BudgetReadRepository`, `BudgetWriteRepository` (2 interfaces, not 4).

**Phase:** Phase 2 and Phase 3 (when creating new repositories)

---

## Phase-Specific Warnings

| Phase | Topic | Likely Pitfall | Mitigation |
|-------|-------|---------------|------------|
| 1 | Schema migration v2→v3 | Migration only tested on fresh install, not upgrade from v2 | Write integration test: create v2 DB → upgrade to v3 → verify data + new tables |
| 1 | Dark mode | Existing widgets use hardcoded light colors | Audit all widgets BEFORE implementing dark mode; use theme-aware methods |
| 1 | Dark mode | Theme toggle causes flash/state loss | Use `themeMode` property, don't rebuild MaterialApp |
| 2 | Budget alerts | Notification spam on threshold crossings | Track last notified threshold; fire once per level per month |
| 2 | Budget period | Month boundary calculation wrong | Explicit `year_month` field; consistent date format |
| 3 | Savings contributions | Contribution ≠ transaction ambiguity | Document design decision explicitly before coding |
| 3 | Goal completion | Confetti jank on low-end devices | Cap particles; auto-dismiss; profile on real device |
| 4 | Google Drive OAuth | Token expires, no refresh retry | `signInSilently()` before every API call; 401 retry pattern |
| 4 | Backup format | No version stamp → restore across versions breaks | Embed schema version; validate on restore |
| 4 | appDataFolder | Deleted on uninstall (user unaware) | Show clear warning in backup UI |
| 5 | Enhanced reports | fl_chart slow with 365+ data points | Pre-aggregate in SQL; limit chart data points; skip animation |
| 6 | Integration | Feature bloat on home screen | Design unified home layout first; max 2-3 cards |

---

## Sources

- **sqflite migration patterns**: Context7 `/tekartik/sqflite` — official migration docs with `onUpgrade` batch patterns (HIGH confidence)
- **Google Drive appDataFolder constraints**: Official Google Developers docs — appDataFolder deleted on uninstall, cannot be shared or trashed (HIGH confidence)
- **Google OAuth token lifecycle**: Official Google Identity Services docs — access tokens expire in ~1 hour, must use `signInSilently()` for refresh (HIGH confidence)
- **fl_chart performance**: Context7 `/websites/pub_dev_fl_chart` — API structure confirmed; performance with large datasets is a known concern in community (MEDIUM confidence — no official perf docs)
- **Riverpod provider invalidation**: Context7 `/rrousselgit/riverpod` — `ref.invalidate` vs `ref.refresh` semantics confirmed; `keepAlive` for persistent providers (HIGH confidence)
- **Existing codebase**: `schema_manager.dart`, `app_theme.dart`, `app_colors.dart`, `app_glassmorphism.dart` — directly reviewed for pattern-specific pitfalls (HIGH confidence)
