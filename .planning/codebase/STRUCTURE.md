# Codebase Structure

**Analysis Date:** 2026-05-06

## Directory Layout

```
catat_cuan/
├── lib/                              # Application source code
│   ├── main.dart                     # App entry point
│   ├── domain/                       # Business logic (pure Dart, no dependencies)
│   │   ├── core/                     # Base types (Result<T>, UseCase<T,P>)
│   │   ├── entities/                 # Freezed immutable entities
│   │   │   └── widget/               # Widget-specific entities
│   │   ├── failures/                 # Typed failure hierarchy
│   │   ├── parsers/                  # Receipt parsing utilities
│   │   ├── repositories/             # Abstract repository interfaces
│   │   │   ├── category/             # 4 segregated interfaces + barrel export
│   │   │   ├── transaction/          # 6+ segregated interfaces + barrel export
│   │   │   └── widget/               # Widget repository interface
│   │   ├── services/                 # Abstract service interfaces + domain services
│   │   │   ├── analyzers/            # Financial health & category analyzers
│   │   │   └── insight/              # Insight engine, rules, formatting
│   │   ├── usecases/                 # Business operation classes
│   │   │   └── category/             # Category-specific use cases + params/results
│   │   └── validators/               # Shared validation logic
│   ├── data/                         # Data layer (implements domain interfaces)
│   │   ├── datasources/              # Data source abstractions + implementations
│   │   │   ├── local/                # SQLite (DatabaseHelper, SchemaManager, LocalDataSource)
│   │   │   └── widget/               # Home widget data source
│   │   ├── models/                   # Freezed data models (DB mapping layer)
│   │   ├── repositories/             # Repository implementations
│   │   │   ├── category/             # 4 impl classes matching 4 interfaces
│   │   │   ├── transaction/          # 6 impl classes matching 6 interfaces
│   │   │   └── widget/               # Widget repository impl
│   │   └── services/                 # External service implementations
│   └── presentation/                 # UI layer
│       ├── app/                      # Root widget, init screen, error screen
│       ├── controllers/              # Business logic controllers (extracted from screens)
│       ├── managers/                 # Pure UI data transformers
│       ├── models/                   # Presentation-only data models
│       ├── navigation/               # GoRouter configuration
│       │   ├── routes/               # App routes constants + router definition
│       │   └── providers/            # Router Riverpod provider
│       ├── providers/                # Riverpod state management
│       │   ├── category/             # Category list, form, management providers
│       │   ├── controllers/          # Controller DI wiring
│       │   ├── currency/             # Currency provider
│       │   ├── export/               # Export provider
│       │   ├── import/               # Import provider
│       │   ├── navigation/           # Navigation provider
│       │   ├── onboarding/           # Onboarding + category seeding providers
│       │   ├── repositories/         # Repository DI wiring (composition root)
│       │   ├── scan/                 # Receipt scan provider
│       │   ├── services/             # Service DI wiring
│       │   ├── summary/              # Monthly summary provider
│       │   ├── theme/                # Theme mode provider
│       │   ├── transaction/          # Transaction list, form, filter, search, selection, pagination
│       │   ├── usecases/             # Use case DI wiring
│       │   ├── widget/               # Home widget provider
│       │   ├── app_providers.dart    # Central barrel export for all providers
│       │   └── cache_provider.dart   # Cache invalidation provider
│       ├── screens/                  # Full-screen widgets
│       │   └── transaction_list/     # Subdirectory for dialog/sheet components
│       ├── services/                 # Presentation-layer services
│       ├── states/                   # Freezed state classes
│       │   └── validators/           # Form validators
│       ├── utils/                    # Design system & utilities
│       │   ├── error/                # Error handler + message mapper
│       │   ├── formatters/           # Date & transaction formatters
│       │   ├── formatting/           # Formatting utilities
│       │   ├── glassmorphism/        # Glass UI effects
│       │   ├── logger/               # AppLogger wrapper
│       │   ├── mixins/               # Screen & utility mixins
│       │   ├── responsive/           # Spacing, radius, dimensions, responsive builder
│       │   ├── theme/                # Theme utilities
│       │   ├── app_colors.dart       # Color constants
│       │   ├── app_theme.dart        # Light/dark theme definitions
│       │   ├── category_constants.dart # Category default data
│       │   ├── color_helper.dart     # Color manipulation helpers
│       │   ├── currency_formatter.dart # Rupiah formatting
│       │   └── utils.dart            # Design system barrel export
│       └── widgets/                  # Reusable UI components
│           ├── base/                 # Design system primitives (glass containers, states, FAB)
│           │   ├── effects/          # Shimmer & animation effects
│           │   ├── layout/           # Container & FAB layout widgets
│           │   └── states/           # Loading, empty, error, initial state widgets
│           └── transaction/          # Transaction-specific sub-widgets
├── test/                             # Test files
│   ├── data/                         # Data layer tests
│   ├── domain/                       # Domain layer tests
│   ├── helpers/                      # Test helpers & mocks
│   ├── integration/                  # Integration tests
│   ├── presentation/                 # Presentation layer tests
│   ├── unit/                         # Unit tests
│   └── test_config.dart              # Test configuration
├── integration_test/                 # Flutter integration tests
├── android/                          # Android platform code
├── ios/                              # iOS platform code
├── linux/                            # Linux platform code
├── macos/                            # macOS platform code
├── web/                              # Web platform code
├── windows/                          # Windows platform code
├── assets/                           # Static assets (icons)
├── docs/                             # Project documentation (23 guides)
│   ├── guides/                       # Technical guides (architecture, Riverpod, Freezed, etc.)
│   ├── v1/                           # Product specs & design system docs
│   │   ├── database/                 # Database schema docs
│   │   ├── design/                   # Design system guide
│   │   └── product/                  # Product specs & implementation status
│   └── project/                      # Project status & refactoring history
├── scripts/                          # Build & version scripts
├── .github/                          # GitHub Actions CI/CD
├── .claude/                          # Claude Code configuration & skills
├── pubspec.yaml                      # Dart package manifest
├── analysis_options.yaml             # Dart analyzer configuration
├── build.yaml                        # Build runner configuration
└── AGENTS.md                         # AI agent instructions
```

## Directory Purposes

**`lib/domain/`:**
- Purpose: Pure business logic with zero external package dependencies
- Contains: Entities, use cases, repository interfaces, service interfaces, failures, validators, parsers
- Key constraint: Never imports from `lib/data/` or `lib/presentation/`

**`lib/data/`:**
- Purpose: Implements domain abstractions, manages persistence and external services
- Contains: Repository implementations, data models (DB mapping), data sources, service implementations
- Key constraint: Only imports from `lib/domain/` (never from `lib/presentation/`)

**`lib/presentation/`:**
- Purpose: UI rendering, user interaction, state management, and dependency injection wiring
- Contains: Screens, widgets, Riverpod providers, controllers, states, design system
- Key constraint: Imports from `lib/domain/` only (never from `lib/data/` directly — goes through providers)

**`lib/presentation/providers/repositories/`:**
- Purpose: **Composition root** — wires domain interfaces to data implementations via Riverpod
- Contains: All repository providers, data source providers
- This is the only place where `lib/data/` implementations are imported

**`lib/presentation/providers/services/`:**
- Purpose: Service composition root — wires domain service interfaces to data implementations
- Contains: OCR, image picker, permissions, file save, merchant pattern service providers

## Key File Locations

### Entry Points

- `lib/main.dart`: Application bootstrap (logger, locale, ProviderScope)
- `lib/presentation/app/app_widget.dart`: Root widget (MaterialApp.router)
- `lib/presentation/navigation/routes/app_router.dart`: GoRouter configuration

### Configuration

- `pubspec.yaml`: Package manifest, dependencies, version (1.5.1)
- `analysis_options.yaml`: Dart static analysis rules
- `build.yaml`: Code generation configuration

### Database

- `lib/data/datasources/local/schema_manager.dart`: Table definitions, indexes, migration logic
- `lib/data/datasources/local/database_helper.dart`: SQLite connection singleton, table name constants
- `lib/data/datasources/local/local_data_source.dart`: Abstract CRUD interface
- `lib/data/datasources/local/sqlite_data_source.dart`: SQLite implementation of LocalDataSource

### Domain Core

- `lib/domain/core/result.dart`: `Result<T>` monad for error handling
- `lib/domain/core/usecase.dart`: `UseCase<T, Params>` base class
- `lib/domain/failures/failure.dart`: Base `Failure` abstract class
- `lib/domain/validators/transaction_validator.dart`: Shared transaction validation

### DI / Composition Root

- `lib/presentation/providers/app_providers.dart`: Central barrel export for all providers
- `lib/presentation/providers/repositories/repository_providers.dart`: All repository + data source providers
- `lib/presentation/providers/services/service_providers.dart`: All service providers
- `lib/presentation/providers/controllers/controller_providers.dart`: Controller providers
- `lib/presentation/providers/usecases/transaction_usecase_providers.dart`: Transaction use case providers
- `lib/presentation/providers/usecases/category_usecase_providers.dart`: Category use case providers

### Design System

- `lib/presentation/utils/utils.dart`: Barrel export for design system
- `lib/presentation/utils/app_theme.dart`: Light/dark theme definitions
- `lib/presentation/utils/app_colors.dart`: Color constants
- `lib/presentation/widgets/base/base.dart`: Base widget barrel export
- `lib/presentation/widgets/base/layout/layout_base.dart`: Container & FAB layout widgets
- `lib/presentation/widgets/base/states/state_base.dart`: Loading, empty, error state widgets
- `lib/presentation/widgets/base/effects/effect_base.dart`: Shimmer & animation effects

### Error Handling

- `lib/presentation/utils/error/error_message_mapper.dart`: Maps exceptions → Indonesian user messages
- `lib/presentation/utils/error/error_handler.dart`: Error handling utilities
- `lib/presentation/utils/logger/app_logger.dart`: Logging wrapper

### Testing

- `test/test_config.dart`: Test setup configuration
- `test/helpers/`: Test helpers and mocks
- `test/domain/`: Domain layer unit tests
- `test/data/`: Data layer unit tests
- `test/presentation/`: Presentation layer tests
- `test/integration/`: Integration tests

## Naming Conventions

### Files

- **Entities:** `snake_case_entity.dart` — e.g., `transaction_entity.dart`, `category_entity.dart`
- **Models:** `snake_case_model.dart` — e.g., `transaction_model.dart`, `category_model.dart`
- **Repositories (interfaces):** `snake_case_repository.dart` — e.g., `transaction_read_repository.dart`
- **Repositories (implementations):** `snake_case_repository_impl.dart` — e.g., `transaction_read_repository_impl.dart`
- **Use cases:** `snake_case_usecase.dart` or `verb_noun.dart` — e.g., `add_transaction.dart`, `delete_transaction.dart`, `search_transactions_usecase.dart`
- **Providers:** `snake_case_provider.dart` — e.g., `transaction_list_provider.dart`
- **Controllers:** `snake_case_controller.dart` — e.g., `transaction_form_submission_controller.dart`
- **States:** `snake_case_state.dart` — e.g., `transaction_form_state.dart`, `receipt_scan_state.dart`
- **Screens:** `snake_case_screen.dart` — e.g., `transaction_list_screen.dart`, `home_screen.dart`
- **Widgets:** `snake_case.dart` — e.g., `transaction_card.dart`, `category_grid.dart`
- **Barrel exports:** `plural_noun.dart` or `domain_name.dart` — e.g., `base.dart`, `utils.dart`, `failures.dart`
- **Generated files:** `.g.dart` (Riverpod) or `.freezed.dart` (Freezed) — auto-generated, committed

### Directories

- **Feature modules:** `snake_case/` — e.g., `transaction/`, `category/`, `onboarding/`
- **Layer subdirectories:** Plural noun — e.g., `entities/`, `repositories/`, `providers/`
- **Nested components:** Organized by screen — e.g., `screens/transaction_list/dialogs/`

### Classes

- **Entities:** `PascalCaseEntity` — e.g., `TransactionEntity`, `CategoryEntity`
- **Models:** `PascalCaseModel` — e.g., `TransactionModel`, `CategoryModel`
- **Repositories (interface):** `PascalCaseRepository` — e.g., `TransactionReadRepository`
- **Repositories (impl):** `PascalCaseRepositoryImpl` — e.g., `TransactionReadRepositoryImpl`
- **Use cases:** `VerbNounUseCase` or `VerbNoun` — e.g., `AddTransactionUseCase`
- **Providers (annotated):** `PascalCaseNotifier` extends `_$PascalCaseNotifier`
- **Failures:** `PascalCaseFailure` — e.g., `DatabaseFailure`, `OcrFailure`
- **Enums:** `PascalCase` with `camelCase` values — e.g., `TransactionType { income, expense }`
- **Field constants:** `PascalCaseFields` class with `camelCase` static fields — e.g., `TransactionFields.id`

## Where to Add New Code

### New Feature (end-to-end)

1. **Entity:** `lib/domain/entities/new_thing_entity.dart` (Freezed, abstract class)
2. **Repository interface:** `lib/domain/repositories/new_thing/new_thing_read_repository.dart` etc. (segregated)
3. **Repository impl:** `lib/data/repositories/new_thing/new_thing_read_repository_impl.dart`
4. **Data model:** `lib/data/models/new_thing_model.dart` (Freezed, with fromMap/toMap/toEntity/fromEntity)
5. **Use case(s):** `lib/domain/usecases/add_new_thing.dart` (extends UseCase<T, Params>)
6. **Repository provider:** Add to `lib/presentation/providers/repositories/repository_providers.dart`
7. **Use case provider:** Add to `lib/presentation/providers/usecases/` (new file or existing)
8. **Riverpod provider:** `lib/presentation/providers/new_thing/new_thing_list_provider.dart` (@riverpod)
9. **Controller (if needed):** `lib/presentation/controllers/new_thing_controller.dart`
10. **Screen:** `lib/presentation/screens/new_thing_screen.dart`
11. **Widgets:** `lib/presentation/widgets/new_thing_card.dart`
12. **Route:** Add to `lib/presentation/navigation/routes/app_routes.dart` (constant) + `app_router.dart` (GoRoute)
13. **Export provider:** Add to `lib/presentation/providers/app_providers.dart`
14. **Run code generation:** `flutter pub run build_runner build --delete-conflicting-outputs`
15. **Tests:** Mirror structure under `test/`

### New Transaction Use Case

1. Use case class: `lib/domain/usecases/verb_noun_usecase.dart`
2. Provider: Add to `lib/presentation/providers/usecases/transaction_usecase_providers.dart`
3. Use in provider/controller that needs it

### New Screen

1. Screen file: `lib/presentation/screens/new_screen.dart`
2. Route constant: `lib/presentation/navigation/routes/app_routes.dart`
3. Route definition: `lib/presentation/navigation/routes/app_router.dart`
4. Provider (if stateful): `lib/presentation/providers/feature_name/`
5. Export in: `lib/presentation/providers/app_providers.dart`

### New Reusable Widget

1. Widget file: `lib/presentation/widgets/my_widget.dart`
2. If it's a base/design-system widget: `lib/presentation/widgets/base/` with subcategory

### New Database Table / Migration

1. Increment version: `lib/data/datasources/local/schema_manager.dart` → `static const int currentVersion = N;`
2. Add table creation in `onCreate()`
3. Add migration step in `onUpgrade()` under `if (oldVersion < N)`
4. Add field constants class (e.g., `NewTableFields`)
5. Add table name constant in `lib/data/datasources/local/database_helper.dart`

### New External Service Integration

1. Abstract interface: `lib/domain/services/new_service.dart`
2. Concrete implementation: `lib/data/services/new_service_impl.dart`
3. Provider wiring: `lib/presentation/providers/services/service_providers.dart`

## Special Directories

**`.claude/skills/`:**
- Purpose: Claude Code skill definitions (GitNexus integration)
- Generated: No (manually maintained)
- Committed: Yes

**`.github/workflows/`:**
- Purpose: CI/CD pipeline (analyze, test, release)
- Generated: No
- Committed: Yes

**`docs/`:**
- Purpose: 23 comprehensive bilingual guides (EN/ID)
- Generated: No (manually maintained)
- Committed: Yes

**`scripts/`:**
- Purpose: Build scripts (version bumping)
- Generated: No
- Committed: Yes

**`*.freezed.dart` / `*.g.dart` files:**
- Purpose: Generated code (Freezed immutable classes, Riverpod providers)
- Generated: Yes (by `build_runner`)
- Committed: Yes (checked into git)

---

*Structure analysis: 2026-05-06*
