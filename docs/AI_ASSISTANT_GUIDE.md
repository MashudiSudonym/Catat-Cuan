# AI Assistant Guide for Catat Cuan

**Last Updated**: 2026-04-02
**Project**: Catat Cuan (Flutter Expense Tracking App)
**Status**: Production-ready with 100% SRP compliance

---

## Quick Context

Catat Cuan is a **Clean Architecture** Flutter application following **SOLID principles** with complete **Single Responsibility Principle (SRP)** compliance. The app uses **Riverpod 3.3.1** with `@riverpod` annotation patterns, **Freezed 3.x** for immutable data classes, and **GoRouter 17.1.0** for type-safe navigation.

### Key Technologies
- **Flutter**: 3.5.0+
- **State Management**: Riverpod 3.3.1 with @riverpod annotation
- **Database**: SQLite with SchemaManager (version 2)
- **Navigation**: GoRouter 17.1.0
- **Immutable Data**: Freezed 3.2.5 with abstract keyword requirement
- **Code Generation**: build_runner 2.4.13

### Architecture Overview
```
lib/
├── domain/              # Business logic (no Flutter dependencies)
│   ├── entities/        # Core business entities
│   ├── usecases/        # Business logic operations
│   ├── repositories/    # Repository interfaces (contracts)
│   └── services/        # Domain services
├── data/                # Data layer (implementation details)
│   ├── datasources/     # DatabaseHelper with SchemaManager
│   ├── models/          # Data transfer objects
│   ├── repositories/    # Repository implementations
│   └── services/        # Platform services (OCR, image picker, etc.)
└── presentation/        # UI and state management
    ├── providers/       # Riverpod providers (organized by feature)
    ├── screens/         # Full-screen widgets
    ├── widgets/         # Reusable UI components
    ├── controllers/     # Business logic controllers
    ├── states/          # State classes (Freezed)
    └── utils/           # Theme, colors, helpers
```

---

## Critical Rules ⚠️

### 1. Freezed 3.x - ABSTRACT KEYWORD REQUIRED

**⚠️ CRITICAL**: Always add `abstract` keyword before class definition in Freezed 3.x

```dart
// ❌ WRONG - Missing 'abstract' keyword
@freezed
class TransactionFormState with _$TransactionFormState {
  const factory TransactionFormState.initial() = TransactionFormInitial;
}

// ✅ CORRECT - Includes 'abstract' keyword
@freezed
abstract class TransactionFormState with _$TransactionFormState {
  const factory TransactionFormState.initial() = TransactionFormInitial;
  const factory TransactionFormState.loading() = TransactionFormLoading;
  const factory TransactionFormState.data(TransactionEntity transaction) = TransactionFormData;
  const factory TransactionFormState.error(String message) = TransactionFormError;
}
```

**Why**: Freezed 3.x requires the `abstract` keyword to properly generate immutable union types.

**Dependencies**:
```yaml
dependencies:
  freezed_annotation: ^3.1.0

dev_dependencies:
  freezed: ^3.2.5
  build_runner: ^2.4.13
```

---

### 2. Riverpod 3.x - Initialize in build(), NOT Constructor

**⚠️ CRITICAL**: Never initialize state or read providers in the constructor

```dart
// ❌ WRONG - Initialization in constructor
@riverpod
class TransactionListNotifier extends _$TransactionListNotifier {
  TransactionListNotifier() {
    // This runs BEFORE providers are available!
    _loadTransactions();
  }

  @override
  Future<List<TransactionEntity>> build() => Future.value([]);
}
```

```dart
// ✅ CORRECT - Initialization in build()
@riverpod
class TransactionListNotifier extends _$TransactionListNotifier {
  @override
  Future<List<TransactionEntity>> build() async {
    // Providers are available here
    final getTransactionsUseCase = ref.read(getTransactionsUseCaseProvider);
    return await getTransactionsUseCase.execute();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
```

**Why**: Riverpod 3.x with code generation ensures providers are available during the `build()` method, not in the constructor.

**Code Generation Command**:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### 3. Repository Segregation Pattern

**⚠️ CRITICAL**: Repositories are segregated by operation type, NOT by entity

Each entity type has multiple repository interfaces, each with a single responsibility:

#### Category Repositories (4 interfaces)
```dart
// lib/domain/repositories/category/

// Read operations only
abstract class CategoryReadRepository {
  Future<List<CategoryEntity>> getActiveCategories(TransactionType type);
}

// Write operations only
abstract class CategoryWriteRepository {
  Future<CategoryEntity> addCategory(CategoryEntity category);
}

// Management operations only (deactivate, reorder)
abstract class CategoryManagementRepository {
  Future<void> deactivateCategory(int id);
}

// Seeding operations only
abstract class CategorySeedingRepository {
  Future<void> seedDefaultCategories();
}
```

#### Transaction Repositories (6+ interfaces)
```dart
// lib/domain/repositories/transaction/

// Basic CRUD
abstract class TransactionReadRepository { }
abstract class TransactionWriteRepository { }

// Query operations
abstract class TransactionQueryRepository { }

// Search operations
abstract class TransactionSearchRepository { }

// Analytics operations
abstract class TransactionAnalyticsRepository { }

// Export operations
abstract class TransactionExportRepository { }
```

**Why**: This follows the **Interface Segregation Principle (ISP)** - clients only depend on methods they actually use.

**Usage Example**:
```dart
// In a provider that only needs to read categories
@riverpod
class CategoryListNotifier extends _$CategoryListNotifier {
  @override
  Future<List<CategoryEntity>> build() async {
    // Only depends on read repository
    final readRepo = ref.read(categoryReadRepositoryProvider);
    return await readRepo.getActiveCategories(TransactionType.expense);
  }
}
```

---

### 4. Controller Pattern

**⚠️ CRITICAL**: Business logic that doesn't belong in state management goes in controllers

Controllers are located in `lib/presentation/controllers/` and handle complex business logic:

```dart
// lib/presentation/controllers/transaction_form_submission_controller.dart

/// Controller for transaction form submission with strategy pattern
/// Following SRP: Only handles submission logic, not form state
class TransactionFormSubmissionController {
  final SubmissionStrategy addStrategy;
  final SubmissionStrategy updateStrategy;

  TransactionFormSubmissionController({
    required this.addStrategy,
    required this.updateStrategy,
  });

  Future<Either<Failure, TransactionEntity>> submit({
    required TransactionFormState formState,
    required TransactionEntity? existingTransaction,
  }) {
    final strategy = existingTransaction == null ? addStrategy : updateStrategy;
    return strategy.execute(formState, existingTransaction);
  }
}
```

**Available Controllers**:
- `transaction_delete_controller.dart` - Deletion logic
- `receipt_scanning_controller.dart` - OCR coordination
- `category_management_controller.dart` - Category management
- `transaction_form_submission_controller.dart` - Form submission with strategy pattern
- `transaction_scan_result_controller.dart` - Scan result processing

---

### 5. Code Generation Workflow

**⚠️ CRITICAL**: Run code generation after creating providers or Freezed classes

```bash
# Watch mode (recommended during development)
flutter pub run build_runner watch

# One-time build
flutter pub run build_runner build --delete-conflicting-outputs

# Clean build (if issues occur)
flutter pub run build_runner build --delete-conflicting-outputs --delete-conflicting-outputs
```

**Files requiring code generation**:
- All providers with `@riverpod` annotation
- All Freezed classes with `@freezed` annotation
- GoRouter routes with `@ TypedRoute` annotation

---

### 6. Post-Change Workflow - Commit & Update Documentation ⚠️

**⚠️ CRITICAL**: After making any code changes, AI MUST:
1. Commit the changes with proper git commit message
2. Update `docs/v1/project/PROJECT_STATUS.md` if applicable

**Why**: Ensures changes are tracked in git history and project documentation stays synchronized with implementation.

**Workflow**:
```bash
# After completing changes and running tests
git add .
git commit -m "type: description of changes

Co-Authored-By: Claude (glm-4.7) <noreply@anthropic.com>"
```

**When to update PROJECT_STATUS.md**:
- New features implemented → Add to "Fitur yang Diimplementasikan"
- Bug fixes → Update status if applicable
- Refactoring → Update "Pekerjaan Saat Ini" section
- Database changes → Add to "Database Migration History"
- Documentation changes → Update "Last Updated" date

**Example Commit Message Types**:
- `feat:` New feature
- `fix:` Bug fix
- `refactor:` Code refactoring
- `docs:` Documentation changes
- `test:` Test additions/changes
- `chore:` Maintenance tasks

---

### 7. Context7 Documentation Reference ⚠️

**⚠️ CRITICAL**: Before providing any implementation guidance for third-party packages, AI MUST:
1. Query Context7 for the latest package documentation
2. Use the most up-to-date information available
3. Reference the specific library ID used

**Why**: Flutter/Dart ecosystem evolves rapidly. Using outdated patterns can lead to deprecated APIs, breaking changes, or missed improvements. Context7 provides current documentation and examples.

**Workflow**:
```dart
// ❌ WRONG - Providing guidance without checking current docs
"You should use Provider with ChangeNotifier"

// ✅ CORRECT - First query Context7, then provide guidance
// Step 1: Query Context7 for the package
// Step 2: Use the latest information to provide guidance
"Based on the latest Riverpod 3.3.1 documentation from Context7,
you should use @riverpod annotation with build() method..."
```

**When to use Context7**:
- Providing examples for flutter_riverpod, go_router, freezed, etc.
- Explaining package-specific patterns or APIs
- Suggesting implementation approaches for third-party packages
- Answering questions about package features or best practices
- ANY time you're about to write code using external packages

**Example Context7 Query Pattern**:
```
1. Use mcp__context7__resolve-library-id to find the library
2. Use mcp__context7__query-docs with the resolved library ID
3. Provide guidance based on the retrieved documentation
4. Reference the library ID in your response
```

**Key Packages to Always Check**:
- `riverpod` - /refiic/riverpod
- `go_router` - /flutter/packages
- `freezed` - /rrousselGit/freezed
- `sqflite` - /tekartik/sqflite

---

## Reference Locations

### Domain Layer (Business Logic)
```
lib/domain/
├── entities/                      # Core business entities
│   ├── transaction_entity.dart
│   ├── category_entity.dart
│   └── paginated_result_entity.dart
├── usecases/                      # Business operations (one per operation)
│   ├── transaction/
│   │   ├── add_transaction_usecase.dart
│   │   ├── get_transactions_usecase.dart
│   │   └── ...
│   └── category/
│       ├── add_category_usecase.dart
│       └── ...
├── repositories/                  # Repository interfaces (contracts)
│   ├── category/
│   │   ├── category_read_repository.dart
│   │   ├── category_write_repository.dart
│   │   ├── category_management_repository.dart
│   │   ├── category_seeding_repository.dart
│   │   └── category_repositories.dart (barrel export)
│   └── transaction/
│       ├── transaction_read_repository.dart
│       ├── transaction_write_repository.dart
│       ├── transaction_query_repository.dart
│       ├── transaction_search_repository.dart
│       ├── transaction_analytics_repository.dart
│       ├── transaction_export_repository.dart
│       └── transaction_repositories.dart (barrel export)
└── services/                      # Domain services
    ├── export_service.dart
    ├── import_service.dart
    └── insight_service.dart
```

### Data Layer (Implementation)
```
lib/data/
├── datasources/
│   └── local/
│       ├── database_helper.dart           # Database connection
│       └── schema_manager.dart            # Schema management (version 2)
├── models/                                # Data transfer objects
│   ├── transaction_model.dart
│   └── category_model.dart
├── repositories/                          # Repository implementations
│   ├── category/
│   │   ├── category_read_repository_impl.dart
│   │   ├── category_write_repository_impl.dart
│   │   ├── category_management_repository_impl.dart
│   │   └── category_seeding_repository_impl.dart
│   └── transaction/
│       ├── transaction_read_repository_impl.dart
│       ├── transaction_write_repository_impl.dart
│       └── ...
└── services/                              # Platform services
    ├── receipt_ocr_service_impl.dart
    ├── image_picker_service_impl.dart
    ├── csv_export_service_impl.dart
    ├── csv_import_service_impl.dart
    └── shared_preferences_service.dart
```

### Presentation Layer (UI & State)
```
lib/presentation/
├── providers/                            # Riverpod providers
│   ├── app_providers.dart                # Central export file
│   ├── usecases/                         # UseCase providers
│   ├── transaction/                      # Transaction feature providers
│   ├── category/                         # Category feature providers
│   └── ...
├── screens/                              # Full-screen widgets
├── widgets/                              # Reusable UI components
├── controllers/                          # Business logic controllers
├── states/                               # State classes (Freezed)
├── utils/                                # Utilities
│   ├── utils.dart                        # Central export (design system)
│   └── ...
└── navigation/
    └── routes/
        └── app_router.dart               # GoRouter configuration
```

---

## Common Tasks

### 1. Adding a New Feature

**Step 1: Create Entity**
```dart
// lib/domain/entities/my_entity.dart
class MyEntity {
  final int id;
  final String name;

  MyEntity({required this.id, required this.name});
}
```

**Step 2: Create Repository Interface**
```dart
// lib/domain/repositories/my/my_read_repository.dart
abstract class MyReadRepository {
  Future<List<MyEntity>> getAll();
}
```

**Step 3: Implement Repository**
```dart
// lib/data/repositories/my/my_read_repository_impl.dart
class MyReadRepositoryImpl implements MyReadRepository {
  final DatabaseHelper _databaseHelper;

  MyReadRepositoryImpl(this._databaseHelper);

  @override
  Future<List<MyEntity>> getAll() async {
    // Implementation
  }
}
```

**Step 4: Create Use Case**
```dart
// lib/domain/usecases/my/get_all_usecase.dart
class GetAllMyUseCase {
  final MyReadRepository _repository;

  GetAllMyUseCase(this._repository);

  Future<List<MyEntity>> execute() {
    return _repository.getAll();
  }
}
```

**Step 5: Create Provider**
```dart
// lib/presentation/providers/my/my_list_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_list_provider.g.dart';

@riverpod
class MyListNotifier extends _$MyListNotifier {
  @override
  Future<List<MyEntity>> build() async {
    final useCase = ref.read(getAllMyUseCaseProvider);
    return await useCase.execute();
  }
}
```

**Step 6: Run Code Generation**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Step 7: Build UI**
```dart
// lib/presentation/screens/my_list_screen.dart
class MyListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(myListNotifierProvider);

    return itemsAsync.when(
      loading: () => const AppLoadingState(),
      error: (error, stack) => AppErrorState(error: error.toString()),
      data: (items) => ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => Text(items[index].name),
      ),
    );
  }
}
```

---

### 2. Creating a New Provider

**Pattern: AsyncNotifier for async data**
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_provider.g.dart';

@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  Future<DataType> build() async {
    // Initialize here, NOT in constructor
    final useCase = ref.read(myUseCaseProvider);
    return await useCase.execute();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  Future<void> performAction() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Perform action
    });
  }
}
```

**Pattern: Notifier for synchronous data**
```dart
@riverpod
class MySyncNotifier extends _$MySyncNotifier {
  @override
  DataType build() {
    return DataType.initial();
  }

  void updateValue(DataType newValue) {
    state = newValue;
  }
}
```

---

### 3. Adding Database Migration

**Step 1: Increment version in SchemaManager**
```dart
// lib/data/datasources/local/schema_manager.dart
class DatabaseSchemaManager {
  static const int currentVersion = 3;  // Increment from 2
}
```

**Step 2: Add migration logic**
```dart
static Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
  // Existing migration
  if (oldVersion < 2) {
    await _createMonthlyAggregationIndex(db);
  }

  // New migration
  if (oldVersion < 3) {
    await _addNewColumn(db);
  }
}
```

---

### 4. Testing Patterns

**Unit Test Example**:
```dart
// test/domain/usecases/add_transaction_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockTransactionWriteRepository extends Mock implements TransactionWriteRepository {}

void main() {
  late AddTransactionUseCase useCase;
  late MockTransactionWriteRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionWriteRepository();
    useCase = AddTransactionUseCase(mockRepository);
  });

  test('should add transaction successfully', () async {
    // Arrange
    final transaction = TransactionEntity(/* ... */);

    // Act
    await useCase.execute(transaction);

    // Assert
    verify(mockRepository.addTransaction(transaction)).called(1);
  });
}
```

---

## What NOT to Do ❌

### ❌ Business Logic in Widgets
```dart
// WRONG - Don't put business logic in widgets
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final transactions = [];
    // Don't process data here!
    final filtered = transactions.where((t) => t.amount > 100).toList();
  }
}

// CORRECT - Use a provider or controller
@riverpod
class FilteredTransactions extends _$FilteredTransactions {
  @override
  List<Transaction> build() {
    final all = ref.watch(transactionListProvider);
    return all.where((t) => t.amount > 100).toList();
  }
}
```

### ❌ Direct Dependencies on Implementations
```dart
// WRONG - Depends on concrete implementation
class MyNotifier {
  final TransactionRepositoryImpl _repo = TransactionRepositoryImpl();
}

// CORRECT - Depends on abstraction
class MyNotifier {
  final TransactionReadRepository _repo;
  MyNotifier(this._repo);
}
```

### ❌ Forgetting `abstract` Keyword in Freezed
```dart
// WRONG - Missing 'abstract'
@freezed
class MyState with _$MyState { }

// CORRECT - Includes 'abstract'
@freezed
abstract class MyState with _$MyState { }
```

### ❌ Initialization in Constructor
```dart
// WRONG - Initializing in constructor
@riverpod
class MyNotifier extends _$MyNotifier {
  MyNotifier() {
    load();
  }

  @override
  Future build() => Future.value();
}

// CORRECT - Initialize in build()
@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  Future build() async {
    return await load();
  }
}
```

### ❌ Monolithic Use Cases
```dart
// WRONG - Too many responsibilities
class TransactionManagementUseCase {
  Future<void> add() { }
  Future<void> update() { }
  Future<void> delete() { }
  Future<List> getAll() { }
}

// CORRECT - Single responsibility each
class AddTransactionUseCase { }
class UpdateTransactionUseCase { }
class DeleteTransactionUseCase { }
class GetTransactionsUseCase { }
```

---

## Quick Reference Commands

### Development
```bash
flutter pub get                           # Install dependencies
flutter run                               # Run on device
flutter run --debug                       # Debug mode
flutter run --release                     # Release mode
```

### Code Generation
```bash
flutter pub run build_runner build --delete-conflicting-outputs
flutter pub run build_runner watch        # Watch mode
```

### Testing
```bash
flutter test                              # Run all tests
flutter test test/unit/my_test.dart       # Run specific test
flutter test --coverage                   # Generate coverage
```

### Build
```bash
flutter build apk                         # Android APK
flutter build appbundle                   # Android App Bundle
flutter build ios                         # iOS
```

---

## Related Documentation

- [ARCHITECTURE.md](guides/ARCHITECTURE.md) - Complete Clean Architecture guide
- [RIVERPOD_GUIDE.md](guides/RIVERPOD_GUIDE.md) - Riverpod 3.x patterns
- [FREEZED_GUIDE.md](guides/FREEZED_GUIDE.md) - Freezed 3.x guide
- [CODING_STANDARDS.md](guides/CODING_STANDARDS.md) - File naming and conventions
- [SOLID.md](guides/SOLID.md) - SOLID principles with examples
- [DESIGN_SYSTEM_GUIDE.md](v1/design/DESIGN_SYSTEM_GUIDE.md) - UI design system
- [DATABASE_SCHEMA.md](v1/database/DATABASE_SCHEMA.md) - Database schema documentation (EN/ID)

---

## Project Status

- **Architecture**: Clean Architecture with 100% SRP compliance ✅
- **State Management**: Riverpod 3.3.1 with @riverpod annotation ✅
- **Database**: SQLite with SchemaManager version 2 ✅
- **Code Quality**: 283/283 tests passing, 0 analyzer errors ✅
- **Documentation**: Comprehensive guides available ✅

**Last Updated**: 2026-04-02
