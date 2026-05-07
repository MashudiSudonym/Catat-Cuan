# Codebase Concerns

**Analysis Date:** 2026-05-06

## Tech Debt

**Mock User Data in Production Profile Screen:**
- Issue: Profile screen contains a `MockUserData` class and hardcoded mock user data (`Budi Santoso`, `@budisantoso`, etc.) directly in the production screen. There is no real user model, no user authentication, and no persistence layer for profile data. The edit profile bottom sheet also has a mock save button.
- Files: `lib/presentation/screens/profile_screen.dart` (lines 10-40, 663-817)
- Impact: Profile feature is entirely non-functional. Any changes to user info are lost on restart. Blocks real user personalization.
- Fix approach: Create a `UserProfileEntity` in domain, add a `UserProfileRepository` with local persistence (shared_preferences or SQLite), and replace all `MockUserData` references with real data flows.

**Deprecated `HomeScreen` Still Exists:**
- Issue: `HomeScreen` is marked `@Deprecated` and replaced by `HomeNavigationShell` in `app_router.dart`, but the file still exists and is imported elsewhere.
- Files: `lib/presentation/screens/home_screen.dart` (85 lines)
- Impact: Dead code increases maintenance burden and could confuse new developers into using the wrong entry point.
- Fix approach: Remove `home_screen.dart` entirely after verifying no active imports reference it. Search for and remove any route definitions pointing to it.

**Deprecated `ExportService.exportTransactionsToCsv` Method:**
- Issue: The `ExportService` interface still carries a deprecated `exportTransactionsToCsv` method with a `@Deprecated` annotation. The implementation in `CsvExportServiceImpl` delegates to `shareTransactionsToCsv` for backward compatibility.
- Files: `lib/domain/services/export_service.dart` (line 28-32), `lib/data/services/csv_export_service_impl.dart` (line 122-129)
- Impact: API surface pollution. Consumers may still use the deprecated path unknowingly.
- Fix approach: Remove the deprecated method from both the interface and implementation. Update any remaining callers to use `saveTransactionsToCsv` or `shareTransactionsToCsv`.

**Deprecated `share_plus` API Usage:**
- Issue: `Share.shareXFiles` is called with an `// ignore: deprecated_member_use` suppression in the CSV export service.
- Files: `lib/data/services/csv_export_service_impl.dart` (line 108-109)
- Impact: Will break when `share_plus` removes the deprecated API in a future major version.
- Fix approach: Migrate to the current `share_plus` API (e.g., `Share.shareXFiles` replacement or the newer `ShareResult`-returning API).

**Legacy `TransactionSummaryRepository` Export:**
- Issue: `transaction_repositories.dart` exports a "Legacy (deprecated)" `TransactionSummaryRepository` barrel.
- Files: `lib/domain/repositories/transaction/transaction_repositories.dart` (line 28-29)
- Impact: Encourages usage of deprecated repository interface.
- Fix approach: Migrate any consumers to `TransactionAnalyticsRepository`, then remove the legacy export.

**Widget Provider Category Lookup Stub:**
- Issue: `_getCategoryName` in `WidgetNotifier` always returns `'Umum'` regardless of the actual `categoryId`. The TODO comment acknowledges this is a stub.
- Files: `lib/presentation/providers/widget/widget_provider.dart` (lines 132-138)
- Impact: Home screen widget shows incorrect category names for all transactions.
- Fix approach: Inject a `CategoryReadRepository` or maintain a cached category map in the notifier. Map `categoryId` to actual category name before creating `TransactionPreviewEntity`.

**Receipt Item Extraction Not Implemented:**
- Issue: `ScanReceiptUseCase` creates `ReceiptDataEntity` with `items: []` and a TODO comment for future item extraction.
- Files: `lib/domain/usecases/scan_receipt.dart` (line 73)
- Impact: Receipt line items are never extracted. Users only get total amount, not itemized data.
- Fix approach: Create a `ReceiptItemParser` in `lib/domain/parsers/` to extract line items from OCR text. Add to `ScanReceiptUseCase` pipeline.

## Known Bugs

**Error Details Leaked in Profile Screen:**
- Symptoms: `error.toString()` is passed directly to `_buildFinancialError` which displays the raw error in the UI.
- Files: `lib/presentation/screens/profile_screen.dart` (line 86)
- Trigger: Load profile screen when transaction provider is in error state.
- Workaround: None visible. The error text may contain English technical details in an otherwise Indonesian UI.

**`debugPrint` Used Instead of `AppLogger` in Delete Controller:**
- Symptoms: `debugPrint` statements in `TransactionDeleteController` bypass the structured logging system.
- Files: `lib/presentation/controllers/transaction_delete_controller.dart` (lines 81, 92)
- Trigger: Delete transaction failure.
- Workaround: Errors are silently swallowed — controller returns `false` with no user-facing feedback.

**Scattered `ref.invalidate` Calls Across Screens:**
- Symptoms: After transaction mutations (add, edit, delete), multiple screens independently call `ref.invalidate` on `transactionListProvider`, `transactionListPaginatedProvider`, and `monthlySummaryProvider`. Some invalidation happens in both providers (e.g., `TransactionFormProvider`) and screens (e.g., `TransactionFormScreen`), causing redundant refreshes.
- Files: `lib/presentation/screens/transaction_form_screen.dart` (lines 465-467), `lib/presentation/screens/transaction_list_screen.dart` (lines 173-175, 602-604), `lib/presentation/providers/transaction/transaction_form_provider.dart` (lines 179-181)
- Trigger: Any transaction create/update/delete action.
- Workaround: Works but causes unnecessary rebuilds and potential flickering.
- Fix approach: Centralize cache invalidation in providers using Riverpod's `ref.invalidate` from within notifiers. Remove duplicate invalidation from screen code.

## Security Considerations

**No Input Sanitization for CSV Import:**
- Risk: CSV import parses user-provided files with custom date/amount parsing logic. Malformed or malicious CSV data could cause unexpected behavior or crashes.
- Files: `lib/domain/usecases/import_transactions_usecase.dart` (lines 216-249)
- Current mitigation: Basic validation (year range 1900-2100, month 1-12, day 1-31). Row-level error tracking with `ImportResultEntity`.
- Recommendations: Add maximum file size validation, row count limits, and sanitize string fields (note, category) before database insertion to prevent potential injection via SQLite.

**No Rate Limiting on OCR Scans:**
- Risk: Users could trigger unlimited OCR scans, potentially consuming device resources or causing ANR (Application Not Responding) on lower-end devices.
- Files: `lib/domain/usecases/scan_receipt.dart`
- Current mitigation: None detected.
- Recommendations: Add debouncing or cooldown between scans in the scan receipt screen/provider.

**Hardcoded Category Color in Widget Provider:**
- Risk: Widget always shows orange color (`#FF6B35`) for categories regardless of actual category color.
- Files: `lib/presentation/providers/widget/widget_provider.dart` (line 127)
- Current mitigation: None.
- Recommendations: Resolve actual category color from repository and pass to widget preview entity.

## Performance Bottlenecks

**Profile Screen Watches Full Transaction List:**
- Problem: `ProfileScreen` calls `ref.watch(transactionListProvider)` which loads ALL transactions into memory just to display a financial summary and tracking level. This is wasteful for users with thousands of transactions.
- Files: `lib/presentation/screens/profile_screen.dart` (lines 65, 82)
- Cause: No dedicated "financial summary" provider that queries aggregated data from the database.
- Improvement path: Create a dedicated `FinancialSummaryProvider` that queries `TransactionAnalyticsRepository` for monthly totals instead of loading the full list.

**Indonesian Merchant Pattern Service is 791 Lines with Inline Data:**
- Problem: The merchant pattern service contains hardcoded merchant data inline (names, patterns, addresses). The `_buildPatterns()` method constructs hundreds of `MerchantPatternEntity` objects on every instantiation.
- Files: `lib/data/services/indonesian_merchant_pattern_service_impl.dart` (791 lines)
- Cause: Merchant patterns are defined in Dart code rather than loaded from a data file or database.
- Improvement path: Move merchant patterns to a JSON asset file and load lazily on first use. This also makes it easier to update patterns without code changes.

**Large Screen Widgets (500-800+ lines):**
- Problem: Several screen files exceed 500 lines, making them difficult to maintain, test, and reason about:
  - `profile_screen.dart`: 817 lines
  - `transaction_list_screen.dart`: 689 lines
  - `transaction_form_screen.dart`: 518 lines
  - `scan_receipt_screen.dart`: 499 lines
  - `category_management_screen.dart`: 408 lines
  - `settings_screen.dart`: 400 lines
- Files: `lib/presentation/screens/` directory
- Cause: Screen files contain both layout and business logic (e.g., `ref.invalidate` calls, conditional state rendering). Private helper methods accumulate over time.
- Improvement path: Extract reusable widget sections into separate widget files. Move business logic (especially invalidation and state coordination) into controllers or notifiers.

**Infinite Scroll Without Page Size Limit:**
- Problem: The paginated transaction list uses `_scrollController` to detect bottom and load more, but there's no visible cap on how many pages can be loaded into memory.
- Files: `lib/presentation/screens/transaction_list_screen.dart` (lines 32-50)
- Cause: `loadMore()` appends to an ever-growing in-memory list.
- Improvement path: Implement a maximum page limit or switch to `SliverChildBuilderDelegate` with virtualization for very large datasets.

## Fragile Areas

**Database Migration Path:**
- Files: `lib/data/datasources/local/schema_manager.dart`
- Why fragile: The migration system relies on incremental `if (oldVersion < N)` checks. Adding version 3 requires editing the single `onUpgrade` method. No rollback mechanism exists. The comment `// Add future migrations here` is the only guidance.
- Safe modification: Always test migrations by creating a test that opens a v1 database, runs migration to v2, then to v3. Never modify existing migration steps, only add new ones.
- Test coverage: No test files found for `schema_manager.dart` or `database_helper.dart`.

**`ScreenStateMixin` with 488 Lines of UI Helpers:**
- Files: `lib/presentation/utils/mixins/screen_mixin.dart` (488 lines)
- Why fragile: A single mixin contains snackbar helpers, dialog helpers, navigation helpers, and error handling. Any screen using this mixin inherits all 488 lines. Changes to one helper risk affecting all consuming screens.
- Safe modification: Extract individual helper categories into separate smaller mixins or utility classes.
- Test coverage: No test file found.

**Provider Invalidation Is Manual and Scattered:**
- Files: 28 `ref.invalidate` calls across multiple files (see list above in Known Bugs)
- Why fragile: When a new provider is added that depends on transaction data, every invalidation site must be updated manually. Missing one causes stale data bugs that are hard to trace.
- Safe modification: Create a centralized `invalidateAllTransactionDependents(ref)` helper or use Riverpod's `ref.watch` dependency graph to auto-invalidate.
- Test coverage: Invalidation behavior is not explicitly tested.

## Scaling Limits

**SQLite Single-File Database:**
- Current capacity: Suitable for personal expense tracking (thousands of transactions).
- Limit: SQLite locks the entire database on write operations. Concurrent writes (e.g., background import + user adding transaction) could cause `SQLITE_BUSY` errors.
- Scaling path: Use WAL (Write-Ahead Logging) mode in SQLite for better concurrent read/write performance. The current `DatabaseHelper` does not appear to configure WAL mode.

**All Transactions Loaded for Analytics:**
- Current capacity: Works with up to ~10,000 transactions on modern devices.
- Limit: Analytics queries load all transactions and compute in Dart rather than using SQL aggregation.
- Scaling path: Move aggregation (sum, count, group by) to SQL queries in `TransactionAnalyticsRepository`.

## Dependencies at Risk

**`riverpod_lint` Disabled:**
- Risk: Commented out in `pubspec.yaml` due to `analyzer_plugin` compatibility issue.
- Impact: Missing compile-time checks for Riverpod best practices (e.g., proper provider usage, deprecated APIs).
- Migration plan: Re-enable `riverpod_lint` once the `analyzer_plugin` compatibility is resolved. Check `riverpod_lint` changelog for fix versions.

**`home_widget: ^0.9.0`:**
- Risk: Version 0.9.x is pre-1.0, meaning breaking changes can occur in minor version bumps.
- Impact: Widget functionality could break on package update.
- Migration plan: Pin to exact version in production. Monitor changelog for 1.0 stable release.

## Missing Critical Features

**No User Authentication:**
- Problem: All data is stored locally with no user identity. Profile screen uses hardcoded mock data.
- Blocks: Multi-device sync, cloud backup, user-specific settings.

**No Data Backup/Restore:**
- Problem: Users cannot back up or restore their transaction data. If the app is uninstalled or device is lost, all data is lost.
- Blocks: User confidence in long-term data storage.

**No Real Profile Management:**
- Problem: Profile editing is entirely mock. The "save" button in the edit profile sheet does nothing.
- Blocks: Personalization, user preferences tied to identity.

## Test Coverage Gaps

**Presentation Layer — Zero Screen Widget Tests:**
- What's not tested: All 12 screen files in `lib/presentation/screens/` have no dedicated test files:
  - `profile_screen.dart`
  - `transaction_list_screen.dart`
  - `transaction_form_screen.dart`
  - `scan_receipt_screen.dart`
  - `category_management_screen.dart`
  - `category_form_screen.dart`
  - `monthly_summary_screen.dart`
  - `settings_screen.dart`
  - `onboarding_screen.dart`
  - `home_screen.dart`
  - `transaction_filter_bottom_sheet.dart`
  - `delete_transaction_dialog.dart`
- Files: `lib/presentation/screens/**/*.dart`
- Risk: UI regressions from widget changes, state management bugs, or navigation issues go undetected.
- Priority: **High** — screens are the primary user-facing code.

**Presentation Layer — 25 Providers Without Tests:**
- What's not tested: All providers in `lib/presentation/providers/` lack dedicated test files:
  - `monthly_summary_provider.dart`
  - `category_list_provider.dart`
  - `category_form_provider.dart`
  - `category_management_provider.dart`
  - `transaction_search_provider.dart`
  - `transaction_list_paginated_provider.dart`
  - `transaction_filter_provider.dart`
  - `export_provider.dart`
  - `navigation_provider.dart`
  - `receipt_scan_provider.dart`
  - `currency_provider.dart`
  - `import_provider.dart`
  - `theme_provider.dart`
  - `widget_provider.dart`
  - `onboarding_provider.dart`
- Files: `lib/presentation/providers/**/*.dart`
- Risk: State management bugs, incorrect cache invalidation, and race conditions go undetected.
- Priority: **High** — providers orchestrate all app state.

**Data Layer — 23 Files Without Tests:**
- What's not tested:
  - All data source files: `local_data_source.dart`, `sqlite_data_source.dart`, `database_helper.dart`, `schema_manager.dart`, `widget_local_datasource.dart`
  - All repository implementations (6 category + 5 transaction + 1 widget)
  - All service implementations: `csv_export_service_impl.dart`, `csv_import_service_impl.dart`, `receipt_ocr_service_impl.dart`, `image_picker_service_impl.dart`, `permission_service_impl.dart`, `file_save_service_impl.dart`, `shared_preferences_service.dart`, `indonesian_merchant_pattern_service_impl.dart`
  - Models: `monthly_summary_model.dart`, `category_breakdown_model.dart`
- Files: `lib/data/**/*.dart`
- Risk: SQL query bugs, mapping errors, and data corruption go undetected.
- Priority: **Medium** — well-tested domain/usecases layer provides some coverage, but repository bugs can still leak through.

**Error Handling Consistency — Catch Blocks Without StackTrace:**
- What's not tested: 30+ catch blocks in domain use cases capture only `e` without `stackTrace`, making debugging production issues difficult.
- Files: All use cases in `lib/domain/usecases/` (especially `add_transaction.dart`, `delete_transaction.dart`, `update_transaction.dart`, and all category use cases)
- Risk: Production errors are harder to diagnose. Logging loses critical stack trace information.
- Priority: **Medium** — change all `catch (e)` to `catch (e, stackTrace)` and pass `stackTrace` to `AppLogger`.

---

*Concerns audit: 2026-05-06*
