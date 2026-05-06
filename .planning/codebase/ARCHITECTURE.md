<!-- refreshed: 2026-05-06 -->
# Architecture

**Analysis Date:** 2026-05-06

## System Overview

```text
┌──────────────────────────────────────────────────────────────────────────────┐
│                         Presentation Layer                                   │
│  `lib/presentation/`                                                         │
├──────────────┬──────────────┬───────────────┬──────────────┬─────────────────┤
│   Screens    │  Providers   │  Controllers  │   Widgets    │    States       │
│  `screens/`  │ `providers/` │`controllers/` │ `widgets/`   │   `states/`     │
└──────┬───────┴──────┬───────┴───────┬───────┴──────┬───────┴────────┬────────┘
       │              │               │              │                │
       │    ┌─────────┘               │              │                │
       │    │  Riverpod DI            │              │                │
       ▼    ▼                         ▼              ▼                ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                          Domain Layer                                        │
│  `lib/domain/`                                                               │
├──────────────┬──────────────┬───────────────┬──────────────┬─────────────────┤
│  Use Cases   │  Entities    │  Repository   │   Services   │   Failures      │
│ `usecases/`  │ `entities/`  │  Interfaces   │ `services/`  │  `failures/`    │
│              │              │ `repositories/`│              │                 │
└──────────────┴──────────────┴───────┬───────┴──────────────┴─────────────────┘
                                      │ (interfaces only)
                                      │
                                      ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                           Data Layer                                         │
│  `lib/data/`                                                                 │
├──────────────┬──────────────┬───────────────┬──────────────┬─────────────────┤
│  Repository  │   Models     │  Data Sources │   Services   │                 │
│  Impls       │  `models/`   │ `datasources/`│ `services/`  │                 │
│`repositories/`│             │               │              │                 │
└──────────────┴──────────────┴───────┬───────┴──────────────┴─────────────────┘
                                      │
                                      ▼
                              ┌───────────────────┐
                              │  SQLite (sqflite)  │
                              │  `catat_cuan.db`   │
                              │  Schema v2         │
                              └───────────────────┘
```

## Component Responsibilities

| Component | Responsibility | Key File(s) |
|-----------|----------------|-------------|
| **App Entry** | Bootstrap, logger init, locale setup | `lib/main.dart` |
| **AppWidget** | Root widget, watches init/seeding/theme/router | `lib/presentation/app/app_widget.dart` |
| **Router** | GoRouter config with StatefulShellRoute for tabs | `lib/presentation/navigation/routes/app_router.dart` |
| **Route Constants** | Centralized route path strings | `lib/presentation/navigation/routes/app_routes.dart` |
| **Router Provider** | Riverpod provider bridging router + seeding state | `lib/presentation/navigation/providers/router_provider.dart` |
| **Repository Providers** | DI wiring for all repository + data source providers | `lib/presentation/providers/repositories/repository_providers.dart` |
| **Service Providers** | DI wiring for OCR, image picker, permissions, etc. | `lib/presentation/providers/services/service_providers.dart` |
| **Controller Providers** | DI wiring for form submission, delete, scanning controllers | `lib/presentation/providers/controllers/controller_providers.dart` |
| **Use Case Providers** | DI wiring for transaction and category use cases | `lib/presentation/providers/usecases/transaction_usecase_providers.dart`, `lib/presentation/providers/usecases/category_usecase_providers.dart` |
| **Result** | Functional error handling (`Result<T>` = success or failure) | `lib/domain/core/result.dart` |
| **UseCase** | Base abstract class for all use cases | `lib/domain/core/usecase.dart` |
| **SchemaManager** | Table creation, index creation, migration logic | `lib/data/datasources/local/schema_manager.dart` |
| **DatabaseHelper** | SQLite connection singleton, table name constants | `lib/data/datasources/local/database_helper.dart` |
| **LocalDataSource** | Abstract interface for DB operations (query, insert, update, delete, transaction) | `lib/data/datasources/local/local_data_source.dart` |
| **SqliteDataSource** | Concrete implementation of LocalDataSource | `lib/data/datasources/local/sqlite_data_source.dart` |
| **ErrorMessageMapper** | Maps technical exceptions to Indonesian user-friendly messages | `lib/presentation/utils/error/error_message_mapper.dart` |

## Pattern Overview

**Overall:** Clean Architecture with Repository Segregation

**Key Characteristics:**
- **Dependency Inversion Principle (DIP):** All dependencies flow through abstractions. Presentation depends on domain interfaces, data implements domain interfaces.
- **Interface Segregation Principle (ISP):** Repositories are split into focused interfaces (read, write, query, search, analytics, export for transactions; read, write, management, seeding for categories).
- **Single Responsibility Principle (SRP):** Each class has one job — one use case per operation, one controller per feature concern, one provider per state slice.
- **Strategy Pattern:** Used for transaction form submission (add vs update) in `TransactionFormSubmissionController`.
- **Result Monads:** `Result<T>` used throughout instead of throwing exceptions — callers must handle both success and failure.
- **Code Generation:** Freezed for entities/models/states, Riverpod generator for providers.

## Layers

### Domain Layer (`lib/domain/`)

- **Purpose:** Pure business logic with zero external dependencies
- **Location:** `lib/domain/`
- **Contains:** Entities, use cases, repository interfaces, service interfaces, failures, validators, parsers
- **Depends on:** Nothing external (only Dart core + Freezed annotations)
- **Used by:** Data layer (implements interfaces), Presentation layer (invokes use cases)

**Subdirectories:**
- `core/` — `Result<T>`, `UseCase<T, Params>` base types
- `entities/` — Freezed immutable data classes (`TransactionEntity`, `CategoryEntity`, etc.)
- `repositories/` — Segregated abstract interfaces, organized by aggregate (`transaction/`, `category/`, `widget/`)
- `usecases/` — One class per operation, extends `UseCase<T, Params>`
- `services/` — Abstract service interfaces (`OcrService`, `PermissionService`, etc.) + domain service implementations (`InsightService`, analyzers)
- `failures/` — Typed failure hierarchy (`DatabaseFailure`, `OcrFailure`, `ValidationFailure`, etc.)
- `validators/` — Shared validation logic (`TransactionValidator`)
- `parsers/` — Receipt parsing utilities (amount, date, time, merchant)

### Data Layer (`lib/data/`)

- **Purpose:** Implements domain interfaces, manages data persistence and external services
- **Location:** `lib/data/`
- **Contains:** Repository implementations, data models, data sources, service implementations
- **Depends on:** Domain layer (implements interfaces), sqflite, external packages
- **Used by:** Presentation layer via Riverpod providers (never directly)

**Subdirectories:**
- `datasources/local/` — `DatabaseHelper` (singleton connection), `SchemaManager` (DDL/migrations), `LocalDataSource` (abstract), `SqliteDataSource` (concrete)
- `datasources/widget/` — `WidgetLocalDataSource` for home screen widget data
- `models/` — Freezed data models with `fromMap()`/`toMap()`/`toEntity()`/`fromEntity()` conversion methods
- `repositories/transaction/` — 6 implementations matching 6 segregated interfaces
- `repositories/category/` — 4 implementations matching 4 segregated interfaces
- `repositories/widget/` — Widget data repository implementation
- `services/` — Concrete service implementations (`ReceiptOcrServiceImpl`, `ImagePickerServiceImpl`, etc.)

### Presentation Layer (`lib/presentation/`)

- **Purpose:** UI, state management, and user interaction logic
- **Location:** `lib/presentation/`
- **Contains:** Screens, widgets, providers, controllers, states, utils, navigation, models
- **Depends on:** Domain layer (use cases, entities, interfaces)
- **Used by:** Flutter framework (rendered to screen)

**Subdirectories:**
- `app/` — Root `AppWidget`, `InitializationScreen`, `ErrorScreen`
- `controllers/` — Business logic controllers extracted from screens (form submission, scanning, delete)
- `managers/` — Pure UI data transformers (`TransactionGrouper`)
- `models/` — Presentation-only models (`OnboardingPageData`)
- `navigation/` — GoRouter configuration, route constants, router provider
- `providers/` — Riverpod providers organized by feature (transaction/, category/, summary/, scan/, export/, import/, onboarding/, theme/, currency/, widget/)
- `screens/` — Full-screen widgets (one file per screen, subdirectories for dialogs/sheets)
- `services/` — Presentation-layer services
- `states/` — Freezed state classes for forms and filters
- `utils/` — Design system, formatters, theme, colors, logger, error handling
- `widgets/` — Reusable UI components with base/ subdirectory for design system primitives

## Data Flow

### Primary Request Path (View Transactions)

1. User opens app → `main()` initializes logger + locale (`lib/main.dart:20-37`)
2. `ProviderScope` wraps `AppWidget` (`lib/main.dart:33`)
3. `AppWidget.build()` watches `appInitializationProvider`, `categorySeedingProvider`, `themeModeProvider`, `routerProvider` (`lib/presentation/app/app_widget.dart:26-41`)
4. Router redirects to `/onboarding` if no categories seeded, else `/transactions` (`lib/presentation/navigation/routes/app_router.dart:31-55`)
5. `TransactionListScreen` reads `transactionListPaginatedProvider` (`lib/presentation/providers/transaction/transaction_list_paginated_provider.dart`)
6. Provider invokes `GetTransactionsPaginatedUseCase` → `TransactionQueryRepository` → `SqliteDataSource` → SQLite
7. Data flows back: `Map<String, dynamic>` → `TransactionModel.fromMap()` → `TransactionModel.toEntity()` → `TransactionEntity`
8. UI renders via `TransactionCard` widget

### Transaction Creation Path

1. User taps FAB → navigates to `/transactions/add` via GoRouter
2. `TransactionFormScreen` displayed, watches `transactionFormProvider`
3. User fills form → state managed by `TransactionFormState` (Freezed)
4. On submit → `TransactionFormSubmissionController.submit()` with `AddTransactionStrategy` (`lib/presentation/controllers/transaction_form_submission_controller.dart:70-118`)
5. Strategy calls `AddTransactionUseCase.call()` → validates via `TransactionValidator` → calls `TransactionWriteRepository.addTransaction()` → SQLite INSERT
6. On success → `ref.invalidateSelf()` refreshes list, navigation pops back

### OCR Receipt Scan Path

1. User taps scan → navigates to `/transactions/scan`
2. `ScanReceiptScreen` uses `ReceiptScanningController` → `ScanReceiptUseCase`
3. Camera/gallery → `ImagePickerServiceImpl` → `OcrService.extractText()` (Google ML Kit)
4. Raw text → `ReceiptAmountParser`, `ReceiptDateParser`, `ReceiptTimeParser`, `ReceiptMerchantParser`
5. Parsed data → `ReceiptDataEntity` → pre-fills `TransactionFormScreen`
6. User confirms/edits → follows normal transaction creation path

**State Management:**
- Riverpod 3.x with `@riverpod` annotation (code generation)
- `AsyncNotifier` pattern for async data loading
- Providers watch other providers for reactive updates (e.g., `transactionFilterProvider` watched by `transactionListNotifier`)
- `ref.invalidateSelf()` for manual refresh
- `ref.watch()` for reactive rebuilds, `ref.read()` for one-time access

## Key Abstractions

**Repository Segregation (ISP):**
- Purpose: Split monolithic repository interfaces into focused, single-responsibility contracts
- Category aggregate: 4 interfaces in `lib/domain/repositories/category/`
  - `CategoryReadRepository` — queries, getById, getByName, getWithCount
  - `CategoryWriteRepository` — create, update, delete
  - `CategoryManagementRepository` — reorder, activate/deactivate
  - `CategorySeedingRepository` — seed defaults
- Transaction aggregate: 6+ interfaces in `lib/domain/repositories/transaction/`
  - `TransactionReadRepository` — getById, getAll
  - `TransactionWriteRepository` — create, update, delete, deleteAll, deleteMultiple
  - `TransactionQueryRepository` — filter, paginated queries
  - `TransactionSearchRepository` — full-text search
  - `TransactionAnalyticsRepository` — monthly summaries, breakdowns
  - `TransactionExportRepository` — export data preparation
- Barrel exports: `category_repositories.dart`, `transaction_repositories.dart`

**Result<T> Monad:**
- Purpose: Functional error handling without exceptions
- File: `lib/domain/core/result.dart`
- Pattern: `Result.success(data)` or `Result.failure(Failure)` — callers check `isSuccess`/`isFailure`
- Chainable: `.map()`, `.then()` for transformation

**UseCase<T, Params> Base Class:**
- Purpose: Enforce single-responsibility per business operation
- File: `lib/domain/core/usecase.dart`
- Pattern: Each use case extends `UseCase<ReturnType, ParamsType>` and implements `call()`
- NoParams class available for parameterless use cases

**LocalDataSource Abstraction:**
- Purpose: Decouple repositories from SQLite-specific implementation
- File: `lib/data/datasources/local/local_data_source.dart`
- Pattern: Abstract CRUD interface — `query()`, `insert()`, `update()`, `delete()`, `rawQuery()`, `batchInsert()`, `batchUpdate()`, `transaction()`
- Implementation: `SqliteDataSource` wraps `DatabaseHelper`

**Strategy Pattern (Form Submission):**
- Purpose: Separate add vs update logic without conditionals
- File: `lib/presentation/controllers/transaction_form_submission_controller.dart`
- Pattern: `TransactionSubmissionStrategy` interface → `AddTransactionStrategy`, `UpdateTransactionStrategy`

**Service Interfaces (DIP):**
- Purpose: Domain defines interfaces, data layer implements
- Examples: `OcrService` (`lib/domain/services/ocr_service.dart`), `PermissionService`, `ImagePickerService`, `FileSaveService`, `MerchantPatternService`

## Entry Points

**Application Entry:**
- Location: `lib/main.dart`
- Triggers: Flutter engine launches app
- Responsibilities: Initialize logger, initialize Indonesian date locale, wrap with `ProviderScope`, call `runApp()`

**Router Entry:**
- Location: `lib/presentation/navigation/routes/app_router.dart`
- Triggers: `AppWidget` when app is ready (init + seeding complete)
- Responsibilities: Define all routes, handle redirect logic (onboarding vs main), configure `StatefulShellRoute` for tab navigation

**Widget Deep Link:**
- Location: `lib/presentation/navigation/routes/app_router.dart:172-175`
- Triggers: Home screen widget tap
- Path: `/widget/add` → redirects to `/transactions/add`

## Architectural Constraints

- **Threading:** Single-threaded (Flutter/Dart event loop). All async operations use `Future`/`async-await` on the main isolate. No isolates or compute used.
- **Global state:** `DatabaseHelper` is a singleton (`lib/data/datasources/local/database_helper.dart:14`). `rootNavigatorKey` is a global (`lib/presentation/navigation/routes/app_router.dart:20`).
- **Dependency direction:** Strict unidirectional: Presentation → Domain ← Data. Data never imports Presentation. Domain never imports Data.
- **Code generation required:** Freezed entities/models/states, Riverpod providers. Run `flutter pub run build_runner build --delete-conflicting-outputs` after changes to annotated classes.
- **Language:** UI strings in Indonesian (Bahasa Indonesia). Code comments bilingual (English + Indonesian).
- **Database versioning:** Schema version 2. Migrations managed in `SchemaManager.onUpgrade()` with incremental version checks.
- **No network layer:** App is fully offline. No REST API, no cloud sync. All data stored locally in SQLite.

## Anti-Patterns

### Never Expose Technical Errors to UI

**What happens:** Showing raw exception messages (`$e`, `e.toString()`) to users via SnackBar/Dialog
**Why it's wrong:** Exception messages contain internal class names, English text, and implementation details. Users see Indonesian UI — technical errors confuse them and expose internals.
**Do this instead:** Use `ErrorMessageMapper.getUserMessage(e)` from `lib/presentation/utils/error/error_message_mapper.dart` and log technical details via `AppLogger`.

### Never Initialize in Constructor for Riverpod Notifiers

**What happens:** Calling `load()` or setting state in a Riverpod notifier constructor
**Why it's wrong:** Riverpod 3.x may re-create notifier instances; constructor side effects cause duplicate calls and race conditions.
**Do this instead:** Initialize in the `build()` method — this is the Riverpod 3.x lifecycle hook. See `lib/presentation/providers/transaction/transaction_list_provider.dart:19`.

### Never Skip `abstract` on Freezed Classes

**What happens:** `@freezed class MyState with _$MyState { }` without `abstract`
**Why it's wrong:** Freezed 3.x requires the `abstract` keyword on the class declaration.
**Do this instead:** `@freezed abstract class MyState with _$MyState { }` — see all entities in `lib/domain/entities/`.

### Never Use Concrete Repository Types in Providers

**What happens:** Depending on `TransactionWriteRepositoryImpl` directly
**Why it's wrong:** Violates DIP — makes testing impossible and tightly couples presentation to data layer.
**Do this instead:** Always depend on the abstract interface (`TransactionWriteRepository`). Providers wire the concrete type at composition root: `lib/presentation/providers/repositories/repository_providers.dart`.

## Error Handling

**Strategy:** Result monads (functional error handling) with typed failure hierarchy

**Patterns:**
- Domain operations return `Result<T>` — callers check `isSuccess`/`isFailure`
- Failure types are specific: `DatabaseFailure`, `OcrFailure`, `ValidationFailure`, `NotFoundFailure`, `PermissionFailure`, `ExportFailure`, `ImportFailure`, `NetworkFailure`, `UserCancelledFailure`, `UnknownFailure`
- All failures extend abstract `Failure` class (`lib/domain/failures/failure.dart`)
- UI receives user-friendly Indonesian messages via `ErrorMessageMapper.getUserMessage(e)`
- Technical details logged via `AppLogger` (never shown to users)

## Cross-Cutting Concerns

**Logging:** `AppLogger` wraps the `logger` package (`lib/presentation/utils/logger/app_logger.dart`). Initialized in `main()`. Levels: `i()`, `d()`, `w()`, `e()` with optional stack traces.

**Validation:** Centralized in `TransactionValidator` (`lib/domain/validators/transaction_validator.dart`). Called from use cases before repository operations. Form-level validation in `TransactionFormValidator` (`lib/presentation/states/validators/transaction_form_validator.dart`).

**Authentication:** None — single-user offline app. No login, no auth tokens.

**Theming:** `AppTheme` provides light/dark themes (`lib/presentation/utils/app_theme.dart`). Theme mode managed by `themeModeProvider`. Glassmorphism design system via `AppGlassContainer` and related utilities.

**Currency Formatting:** `CurrencyFormatter` for Indonesian Rupiah display (`lib/presentation/utils/currency_formatter.dart`).

**Date Formatting:** `AppDateFormatter` for Indonesian date formats (`lib/presentation/utils/formatters/app_date_formatter.dart`). Locale `id_ID` initialized at startup.

**Database Migrations:** Incremental version checks in `SchemaManager.onUpgrade()` (`lib/data/datasources/local/schema_manager.dart:35-43`). Each version bump adds migration logic under `if (oldVersion < N)`.

---

*Architecture analysis: 2026-05-06*
