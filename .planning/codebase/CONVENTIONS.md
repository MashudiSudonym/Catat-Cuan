# Coding Conventions

**Analysis Date:** 2026-05-06

## Naming Patterns

**Files:**
- Snake_case with descriptive suffixes: `transaction_entity.dart`, `category_read_repository.dart`
- Generated files: `*.freezed.dart`, `*.g.dart`, `*.mocks.dart`
- Test files mirror source path: `test/domain/usecases/add_transaction_usecase_test.dart`
- Mock definitions in dedicated files: `test/data/data_mocks.dart`, `test/presentation/presentation_mocks.dart`
- Barrel exports: `failures.dart`, `utils.dart`, `category_repositories.dart`

**Classes:**
- Entities: PascalCase with suffix — `TransactionEntity`, `CategoryEntity` (`lib/domain/entities/`)
- Models: PascalCase with suffix — `CategoryModel`, `TransactionModel` (`lib/data/models/`)
- Use cases: PascalCase with suffix — `AddTransactionUseCase`, `DeleteTransactionUseCase` (`lib/domain/usecases/`)
- Repositories: PascalCase with suffix — `CategoryReadRepository`, `TransactionWriteRepository` (`lib/domain/repositories/`)
- Implementations: PascalCase with `Impl` suffix — `CategoryReadRepositoryImpl` (`lib/data/repositories/`)
- Controllers: PascalCase with suffix — `TransactionFormSubmissionController` (`lib/presentation/controllers/`)
- States: PascalCase with suffix — `TransactionFormState`, `ReceiptScanState` (`lib/presentation/states/`)
- Failures: PascalCase with suffix — `DatabaseFailure`, `ValidationFailure` (`lib/domain/failures/`)
- Validators: PascalCase with suffix — `TransactionValidator` (`lib/domain/validators/`)
- Private constructors for utility classes: `AppLogger._()`, `AppSpacing._()`

**Functions/Methods:**
- camelCase: `getCategories()`, `addTransaction()`, `getUserMessage()`
- Factory constructors: `Result.success()`, `Result.failure()`
- Private members prefixed with underscore: `_repository`, `_dataSource`

**Variables:**
- camelCase: `mockRepository`, `testMaps`, `filterState`
- Private fields with underscore prefix: `_logger`, `_dataSource`
- Constants: camelCase with `static const` — `AppSpacing.lg`, `AppRadius.md`

**Types:**
- Enums: PascalCase — `TransactionType`, `CategoryType`
- Enum values: camelCase — `TransactionType.income`, `CategoryType.expense`
- Generic type parameters: single uppercase letter — `Result<T>`, `UseCase<T, Params>`

## Code Style

**Formatting:**
- Dart formatter (default via `flutter format`)
- `analysis_options.yaml` includes `package:flutter_lints/flutter.yaml`
- No custom lint rules beyond defaults

**Linting:**
- `flutter_lints` ^6.0.0 (included in `analysis_options.yaml`)
- Riverpod lint temporarily disabled due to analyzer_plugin compatibility
- Run `flutter analyze` before every commit (enforced by AGENTS.md)

**Code Generation:**
- Freezed 3.x for immutable data classes and union types
- Riverpod generator (`@riverpod`) for providers
- Mockito (`@GenerateNiceMocks`) for test mocks
- GoRouter builder for type-safe routing
- Run command: `flutter pub run build_runner build --delete-conflicting-outputs`
- Config in `build.yaml` at project root

## Import Organization

**Order:**
1. Dart/Flutter SDK imports — `package:flutter/material.dart`
2. Package imports — `package:riverpod_annotation/riverpod_annotation.dart`
3. Absolute project imports — `package:catat_cuan/domain/...`
4. Relative imports — `../../helpers/test_fixtures.dart`
5. Generated file imports — `part 'transaction_entity.freezed.dart'`

**Generated file imports (in .dart files with `@GenerateNiceMocks`):**
```dart
// At bottom of file, with ignore comment:
import 'data_mocks.mocks.dart'; // ignore: unused_import
```

**Path Aliases:**
- No path aliases configured in `pubspec.yaml`
- All imports use full `package:catat_cuan/...` paths in lib/
- Test files use relative imports: `'../../helpers/test_fixtures.dart'`

## Error Handling

**Domain Layer — Result Pattern:**
- Use `Result<T>` from `lib/domain/core/result.dart` for all repository/use case operations
- Success: `Result.success(data)`
- Failure: `Result.failure(DatabaseFailure('message'))`
- Check: `result.isSuccess` / `result.isFailure`
- Helper: `ResultFailures.database<T>('message')` for quick failure creation

**Failure Types** (in `lib/domain/failures/`):
- `ValidationFailure` — input validation errors (Indonesian messages)
- `DatabaseFailure` — SQLite operation errors
- `NotFoundFailure` — entity not found
- `PermissionFailure` — OS permission denied
- `OcrFailure` — ML Kit text recognition errors
- `NetworkFailure` — connectivity errors
- `ExportFailure` / `ImportFailure` — data transfer errors
- `UserCancelledFailure` — user-initiated cancellation
- `UnknownFailure` — unexpected errors

**CRITICAL — Never Expose Technical Errors to UI:**
```dart
// ❌ WRONG — leaks technical details
} catch (e) {
  showSnackBar(SnackBar(content: Text('Gagal: $e')));
}

// ✅ CORRECT — log technical details, show user-friendly message
} catch (e, stackTrace) {
  AppLogger.e('Operation failed', e, stackTrace);
  showSnackBar(SnackBar(content: Text(ErrorMessageMapper.getUserMessage(e))));
}
```
- Use `ErrorMessageMapper.getUserMessage(e)` from `lib/presentation/utils/error/error_message_mapper.dart`
- Use `ErrorHandler.handleError(e, stackTrace)` from `lib/presentation/utils/error/error_handler.dart`
- All user-facing error messages in Indonesian

**Repository Implementation Pattern:**
```dart
// From lib/data/repositories/category/category_read_repository_impl.dart
try {
  final maps = await _dataSource.query(...);
  return Result.success(categories);
} catch (e, stackTrace) {
  AppLogger.e('Failed to get categories', e, stackTrace);
  return Result.failure(DatabaseFailure('Gagal mengambil kategori', exception: e));
}
```

## Logging

**Framework:** `logger` package via `AppLogger` wrapper

**Location:** `lib/presentation/utils/logger/app_logger.dart`

**Usage:**
```dart
AppLogger.d('Debug message');           // Debug level
AppLogger.i('Info message');             // Info level
AppLogger.w('Warning message');          // Warning level
AppLogger.e('Error message', e, st);     // Error level (with exception + stackTrace)
AppLogger.f('Fatal message', e, st);     // Fatal level
```

**Configuration:**
- Dev mode: All levels (trace and above)
- Release mode: Warning and above only
- Initialize in `main.dart`: `AppLogger.initialize()`
- Initialize in tests: `setUpAll(() { AppLogger.initialize(); })`

## Comments

**When to Comment:**
- All public classes and methods use `///` doc comments
- File-level `library;` directive with description for key files
- Explain WHY, not WHAT
- Reference SOLID principles in architecture files

**Doc Comments:**
```dart
/// Entity representing a transaction (income/expense)
@freezed
abstract class TransactionEntity with _$TransactionEntity { ... }

/// Repository interface untuk membaca kategori
///
/// Following Interface Segregation Principle (ISP) - hanya berisi operasi baca
abstract class CategoryReadRepository { ... }
```

**Language:**
- Domain/Architecture comments: English
- UI/Product-facing comments: Mixed English and Indonesian
- Error messages for users: Indonesian only
- Validation messages: Indonesian (e.g., `'Nominal harus lebih dari 0'`)

## Function Design

**Size:** Single responsibility — one function, one purpose. Keep methods focused.

**Parameters:**
- Use named parameters with `required` for mandatory fields
- Optional parameters without defaults are nullable
- Use `@Default(value)` for Freezed defaults
- Parameter classes for complex use cases: `TransactionFilterParams`, `PaginationParamsEntity`

**Return Values:**
- Repositories/Use cases: `Future<Result<T>>`
- UI state: Freezed state objects (`TransactionFormState`)
- Void operations: `Future<Result<void>>`
- Validators: `ValidationResult` with `isValid` and `error` fields

## Module Design

**Exports:**
- Barrel files for grouped exports: `lib/domain/failures/failures.dart`, `lib/presentation/utils/utils.dart`
- Each domain aggregate has a barrel: `category_repositories.dart`, `transaction_repositories.dart`
- Design system exported via single import: `import 'package:catat_cuan/presentation/utils/utils.dart'`

**Barrel Files:**
- `lib/domain/failures/failures.dart` — exports all failure types
- `lib/domain/repositories/category/category_repositories.dart` — exports all category repos
- `lib/domain/repositories/transaction/transaction_repositories.dart` — exports all transaction repos
- `lib/presentation/utils/utils.dart` — exports responsive, formatting, theme, mixins

## Architecture Patterns

**Repository Segregation (ISP):**
- Category: 4 interfaces — `CategoryReadRepository`, `CategoryWriteRepository`, `CategoryManagementRepository`, `CategorySeedingRepository` (`lib/domain/repositories/category/`)
- Transaction: 7 interfaces — `TransactionReadRepository`, `TransactionWriteRepository`, `TransactionQueryRepository`, `TransactionSearchRepository`, `TransactionAnalyticsRepository`, `TransactionExportRepository`, `TransactionSummaryRepository` (`lib/domain/repositories/transaction/`)
- Each has matching impl in `lib/data/repositories/`

**Strategy Pattern:**
- Used in controllers: `TransactionSubmissionStrategy` with `AddTransactionStrategy` / `UpdateTransactionStrategy` (`lib/presentation/controllers/transaction_form_submission_controller.dart`)

**Provider Pattern (Riverpod 3.x):**
- Provider hierarchy: `repository_providers.dart` → `*_usecase_providers.dart` → feature providers
- Initialize in `build()`, NOT constructor
- Use `@riverpod` annotation for code generation
- Use `ref.read()` for one-time access, `ref.watch()` for reactive

**Freezed Pattern (3.x):**
- Always use `abstract` keyword: `abstract class MyState with _$MyState`
- Private constructor for methods: `const MyState._();`
- Immutable state with `copyWith()` auto-generated

**Design System:**
- Spacing: `AppSpacing.lg` (16px, 4px grid) — `lib/presentation/utils/responsive/app_spacing.dart`
- Radius: `AppRadius.md` (12px) — `lib/presentation/utils/responsive/app_radius.dart`
- Colors: `AppColors` — `lib/presentation/utils/app_colors.dart`
- Theme: `AppTheme` — `lib/presentation/utils/app_theme.dart`
- Glassmorphism: `AppGlassContainer` — `lib/presentation/utils/glassmorphism/`
- Import all via: `import 'package:catat_cuan/presentation/utils/utils.dart'`

---

*Convention analysis: 2026-05-06*
