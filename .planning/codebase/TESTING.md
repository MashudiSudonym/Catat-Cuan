# Testing Patterns

**Analysis Date:** 2026-05-06

## Test Framework

**Runner:**
- Flutter test framework (`flutter_test` SDK)
- Config: No custom `test_config.yaml` — uses Flutter defaults
- 954 tests passing (as of 2026-04-09)

**Assertion Library:**
- `package:flutter_test` — `expect`, `equals`, `isTrue`, `isFalse`, `isA<T>()`
- `package:mockito` ^5.4.4 — `when()`, `verify()`, `verifyNever()`, `captureAny`
- Custom matchers in `test/test_config.dart` — `CustomMatchers.isValidCategory()`

**Run Commands:**
```bash
flutter test                                      # Run all tests (954)
flutter test test/domain/usecases/my_test.dart    # Specific test
flutter test --coverage                            # With coverage
flutter analyze                                    # Required before commit
flutter pub run build_runner build --delete-conflicting-outputs  # Regenerate mocks
```

## Test File Organization

**Location:**
- Tests mirror source structure under `test/`
- Domain tests: `test/domain/` (entities, usecases)
- Data tests: `test/data/` (models, repositories, services)
- Presentation tests: `test/presentation/` (controllers, providers, widgets)
- Unit tests (duplicated structure): `test/unit/`
- Integration tests: `test/integration/`

**Naming:**
- Source file: `add_transaction.dart` → Test: `add_transaction_usecase_test.dart`
- Mock files: `*_mocks.dart` with generated `*.mocks.dart`

**Structure:**
```
test/
├── test_config.dart                           # Global config, matchers, helpers
├── widget_test.dart                           # Basic widget smoke test
├── helpers/
│   └── test_fixtures.dart                     # Shared test data factory
├── data/
│   ├── data_mocks.dart                        # MockLocalDataSource definition
│   ├── data_mocks.mocks.dart                  # Generated mock
│   ├── models/                                # Model unit tests
│   ├── repositories/                          # Repository impl tests
│   └── services/                              # Service tests
├── domain/
│   ├── entities/                              # Entity tests
│   └── usecases/                              # Use case tests (largest group)
│       └── category/                          # Category-specific use cases
├── presentation/
│   ├── presentation_mocks.dart                # Use case mock definitions
│   ├── presentation_mocks.mocks.dart          # Generated mocks
│   ├── controllers/                           # Controller tests
│   ├── providers/                             # Provider tests
│   └── widgets/                               # Widget tests
├── integration/
│   └── integration_test.dart                  # Integration tests
└── unit/
    ├── data/services/                         # Pure unit tests (data)
    ├── domain/services/                       # Domain service tests
    ├── models/                                # Model conversion tests
    ├── parsers/                               # Parser tests
    ├── presentation/managers/                 # Manager tests
    └── validators/                            # Validator tests
```

**64 test files** (excluding generated `.mocks.dart` and `.g.dart` files)

## Test Structure

**Suite Organization:**
```dart
// From test/domain/usecases/add_transaction_usecase_test.dart
@GenerateNiceMocks([
  MockSpec<TransactionWriteRepository>(),
])
import 'add_transaction_usecase_test.mocks.dart';

void main() {
  late AddTransactionUseCase useCase;
  late MockTransactionWriteRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionWriteRepository();
    useCase = AddTransactionUseCase(mockRepository);
  });

  group('AddTransactionUseCase', () {
    test('should add transaction successfully with valid data', () async {
      // Arrange
      final transaction = TestFixtures.transactionLunch();
      when(mockRepository.addTransaction(any))
          .thenAnswer((_) async => Result.success(transaction.copyWith(id: 1)));

      // Act
      final result = await useCase(transaction);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.id, equals(1));
      verify(mockRepository.addTransaction(any)).called(1);
    });
  });
}
```

**Patterns:**
- **Arrange-Act-Assert** (AAA) — always commented with `// Arrange`, `// Act`, `// Assert`
- **setUp()** — creates fresh instances for each test
- **setUpAll()** — initializes `AppLogger.initialize()` once
- **addTearDown()** — disposes containers (Riverpod)
- **group()** — nested groups for organizing by scenario

## Mocking

**Framework:** Mockito 5.4.4 with `@GenerateNiceMocks`

**Mock Definition Pattern:**
```dart
// In a *_mocks.dart file:
@GenerateNiceMocks([
  MockSpec<LocalDataSource>(),
])
import 'data_mocks.mocks.dart'; // ignore: unused_import

// In individual test files (use-case-level mocks):
@GenerateNiceMocks([
  MockSpec<TransactionWriteRepository>(),
])
import 'add_transaction_usecase_test.mocks.dart';
```

**Mock Generation:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Mock Locations:**
- Data layer mocks: `test/data/data_mocks.dart` — `MockLocalDataSource`
- Presentation mocks: `test/presentation/presentation_mocks.dart` — `MockAddTransactionUseCase`, `MockUpdateTransactionUseCase`, etc.
- Per-test mocks: Generated alongside individual test files (e.g., `test/domain/usecases/add_category_usecase_test.mocks.dart`)

**What to Mock:**
- Repository interfaces (in use case tests)
- Use case classes (in controller/provider tests)
- Data sources (in repository implementation tests)

**What NOT to Mock:**
- Entity classes (use real instances or `TestFixtures`)
- Model classes (test real conversion logic)
- Validators (test actual validation rules)
- `Result<T>` — use real `Result.success()` / `Result.failure()`

**Stubbing Patterns:**
```dart
// Async success
when(mockRepository.addTransaction(any))
    .thenAnswer((_) async => Result.success(data));

// Async failure
when(mockRepository.getCategoryById(any))
    .thenAnswer((_) async => Result.failure(NotFoundFailure('Not found')));

// Throw exception
when(mockRepository.addTransaction(any))
    .thenThrow(Exception('Database error'));

// Verify called exactly N times
verify(mockRepository.addTransaction(any)).called(1);

// Verify never called
verifyNever(mockRepository.addTransaction(any));

// Capture argument
final captured = verify(mockRepository.addTransaction(captureAny))
    .captured.single as TransactionEntity;

// Match any argument
when(mockDataSource.query(
  DatabaseHelper.tableCategories,
  where: anyNamed('where'),
  whereArgs: anyNamed('whereArgs'),
)).thenAnswer((_) async => testMaps);
```

## Fixtures and Factories

**Test Data:**
```dart
// From test/helpers/test_fixtures.dart
class TestFixtures {
  // Named fixture methods with optional overrides
  static CategoryEntity categoryFood({
    int? id,
    String? name,
    String? icon,
    String? color,
    CategoryType? type,
    int? sortOrder,
    bool? isActive,
  }) =>
      CategoryEntity(
        id: id ?? 1,
        name: name ?? 'Makan',
        icon: icon ?? '🍽️',
        color: color ?? '#FF64748B',
        type: type ?? CategoryType.expense,
        sortOrder: sortOrder ?? 1,
        isActive: isActive ?? true,
        createdAt: march18_2026,
        updatedAt: march18_2026,
      );

  // Pre-built lists
  static List<CategoryEntity> get defaultCategories => [
    categoryFood(), categoryTransport(), categorySalary(),
  ];

  // Generator fixtures
  static List<CategoryEntity> categoriesWithType({
    required CategoryType type,
    int count = 5,
  }) => List.generate(count, (i) => CategoryEntity(...));
}
```

**Location:**
- Primary fixtures: `test/helpers/test_fixtures.dart`
- Test config helpers: `test/test_config.dart` — `TestConfig`, `CustomMatchers`, `TestGroupBuilder`

**Fixture naming convention:**
- `categoryFood()`, `categoryTransport()`, `categorySalary()` — specific named fixtures
- `transactionLunch()`, `transactionTransport()`, `transactionSalary()` — transaction variants
- `monthlySummaryHealthy()`, `monthlySummaryImbalance()` — scenario variants
- `paginatedTransactions()` — complex composite fixtures

## Coverage

**Requirements:** No enforced minimum, but target is comprehensive coverage (954 tests)

**View Coverage:**
```bash
flutter test --coverage
# Coverage data in coverage/lcov.info
```

**Test Config Helpers** (in `test/test_config.dart`):
```dart
// Entity comparison with configurable field checks
TestConfig.expectCategoryEquals(actual, expected, checkId: true, checkTimestamps: false);
TestConfig.expectTransactionEquals(actual, expected);

// Unordered list comparison
TestConfig.expectCategoriesUnordered(actual, expected);

// Validation helpers
TestConfig.isValidCategoryColor('#FF64748B');  // true
TestConfig.isValidAmount(50000);               // true
```

## Test Types

**Unit Tests:**
- Scope: Single class/function — use cases, validators, parsers, models, services
- Location: `test/domain/usecases/`, `test/unit/validators/`, `test/unit/parsers/`, `test/data/models/`
- Approach: Mock all dependencies, test logic in isolation
- Total: ~45+ use case tests, 10+ entity tests, 10+ unit tests

**Data/Repository Tests:**
- Scope: Repository implementations with mocked data source
- Location: `test/data/repositories/`
- Approach: Mock `LocalDataSource`, verify SQL query construction, test Result mapping
- Example: `test/data/repositories/category/category_read_repository_impl_test.dart`

**Provider Tests:**
- Scope: Riverpod providers with mocked dependencies
- Location: `test/presentation/providers/`
- Approach: Use `ProviderContainer` with `overrides` for mocked use cases
- Pattern:
```dart
final container = ProviderContainer(
  overrides: [
    addTransactionUseCaseProvider.overrideWithValue(mockAddUseCase),
    updateTransactionUseCaseProvider.overrideWithValue(mockUpdateUseCase),
  ],
);
addTearDown(container.dispose);
final notifier = container.read(transactionFormProvider.notifier);
```

**Widget Tests:**
- Scope: UI widget rendering and interaction
- Location: `test/presentation/widgets/`
- Example: `test/presentation/widgets/transaction_form_screen_test.dart`

**Integration Tests:**
- Scope: End-to-end flows
- Location: `test/integration/`, `integration_test/`
- Config: `integration_test/sdk: flutter` in pubspec.yaml

## Common Patterns

**Async Testing:**
```dart
test('should add transaction successfully', () async {
  // Arrange
  when(mockRepository.addTransaction(any))
      .thenAnswer((_) async => Result.success(transaction));

  // Act
  final result = await useCase(transaction);

  // Assert
  expect(result.isSuccess, isTrue);
});
```

**Error/Validation Testing:**
```dart
test('should return validation failure when amount is zero', () async {
  // Arrange
  final transaction = TestFixtures.transactionLunch(amount: 0);

  // Act
  final result = await useCase(transaction);

  // Assert
  expect(result.isFailure, isTrue);
  expect(result.failure, isA<ValidationFailure>());
  verifyNever(mockRepository.addTransaction(any));
});
```

**Repository Implementation Testing:**
```dart
test('should return category when found', () async {
  // Arrange
  final testMaps = createTestCategoryMaps();
  when(mockDataSource.query(
    DatabaseHelper.tableCategories,
    where: anyNamed('where'),
    whereArgs: anyNamed('whereArgs'),
  )).thenAnswer((_) async => testMaps);

  // Act
  final result = await repository.getCategoryById(1);

  // Assert
  expect(result.isSuccess, isTrue);
  expect(result.data?.id, 1);
  verify(mockDataSource.query(
    DatabaseHelper.tableCategories,
    where: '${CategoryFields.id} = ?',
    whereArgs: [1],
  )).called(1);
});
```

**Logger Initialization in Tests:**
```dart
setUpAll(() {
  AppLogger.initialize();
});
```
This is required in any test file that triggers code path using `AppLogger`.

---

*Testing analysis: 2026-05-06*
