# Clean Architecture Guide - Catat Cuan

**Last Updated**: 2026-03-27
**Project**: Catat Cuan (Flutter Expense Tracking App)
**Architecture**: Clean Architecture with SOLID principles (100% SRP compliance)

---

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Layer Structure](#layer-structure)
3. [Dependency Flow](#dependency-flow)
4. [Repository Segregation Pattern](#repository-segregation-pattern)
5. [Controller Pattern](#controller-pattern)
6. [Service Layer Pattern](#service-layer-pattern)
7. [Domain Layer](#domain-layer)
8. [Data Layer](#data-layer)
9. [Presentation Layer](#presentation-layer)
10. [Dependency Injection Setup](#dependency-injection-setup)

---

## Architecture Overview

Catat Cuan follows **Uncle Bob's Clean Architecture** with clear separation of concerns. The architecture is designed to achieve:

- **Independence of Frameworks**: Business rules don't depend on Flutter, SQLite, or any external library
- **Testability**: Business rules can be tested without UI, database, or web server
- **Independence of UI**: The UI can change easily without changing the rest of the system
- **Independence of Database**: Business rules are not bound to the database
- **Independence of External Agencies**: Business rules don't know anything about the outside world

### Visual Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Presentation Layer                       │
│  (Screens, Widgets, Providers, Controllers, State, Navigation)   │
│                     ↓ depends on ↓                               │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                     Domain Layer                          │   │
│  │  (Entities, Use Cases, Repository Interfaces, Services)   │   │
│  │                   ↑ implemented by ↑                       │   │
│  └──────────────────────────────────────────────────────────┘   │
│                     ↓                                            │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                      Data Layer                           │   │
│  │  (Repository Implementations, Data Sources, Models)       │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Key Principles

1. **Dependency Rule**: Dependencies point inward, never outward
2. **Single Responsibility**: Each module has one reason to change
3. **Interface Segregation**: Small, focused interfaces
4. **Dependency Inversion**: Depend on abstractions, not concretions

---

## Layer Structure

### Directory Structure

```
lib/
├── domain/                    # Business logic (no Flutter dependencies)
│   ├── entities/              # Core business entities
│   ├── usecases/              # Business logic operations
│   ├── repositories/          # Repository interfaces (contracts)
│   ├── services/              # Domain services
│   ├── parsers/               # Domain-specific parsers
│   ├── validators/            # Business validators
│   └── core/                  # Core types (Result, Failure, etc.)
│
├── data/                      # Data layer (implementation details)
│   ├── datasources/           # Data sources (SQLite, API, etc.)
│   ├── models/                # Data transfer objects
│   ├── repositories/          # Repository implementations
│   └── services/              # Platform-specific services
│
└── presentation/              # UI and state management
    ├── providers/             # Riverpod state management
    ├── screens/               # Full-screen widgets
    ├── widgets/               # Reusable UI components
    ├── controllers/           # Business logic controllers
    ├── states/                # State classes (Freezed)
    ├── utils/                 # UI utilities
    └── navigation/            # Navigation configuration
```

### File Count by Layer

- **Domain**: 40+ files (entities, use cases, repository interfaces, services)
- **Data**: 20+ files (repository implementations, data sources, models)
- **Presentation**: 90+ files (screens, widgets, providers, controllers)

---

## Dependency Flow

### Rule: Dependencies Point Inward

```
Presentation ──depends on──> Domain ──implemented by──> Data
```

### Example: Transaction Feature

```dart
// ========================================
// 1. DOMAIN LAYER (No dependencies)
// ========================================

// Entity (Business concept)
// lib/domain/entities/transaction_entity.dart
class TransactionEntity {
  final int? id;
  final double amount;
  final TransactionType type;
  final DateTime dateTime;
  final int categoryId;
  final String? note;
  final DateTime createdAt;
  final DateTime? updatedAt;
}

// Repository Interface (Contract)
// lib/domain/repositories/transaction/transaction_write_repository.dart
abstract class TransactionWriteRepository {
  Future<Either<Failure, TransactionEntity>> addTransaction(TransactionEntity transaction);
  Future<Either<Failure, TransactionEntity>> updateTransaction(TransactionEntity transaction);
}

// Use Case (Business operation)
// lib/domain/usecases/transaction/add_transaction_usecase.dart
class AddTransactionUseCase {
  final TransactionWriteRepository _repository;

  AddTransactionUseCase(this._repository);

  Future<Either<Failure, TransactionEntity>> execute(TransactionEntity transaction) {
    // Business logic here
    if (transaction.amount <= 0) {
      return Left(ValidationFailure('Amount must be greater than 0'));
    }
    return _repository.addTransaction(transaction);
  }
}

// ========================================
// 2. DATA LAYER (Implements domain interfaces)
// ========================================

// Model (Data transfer)
// lib/data/models/transaction_model.dart
class TransactionModel {
  final int? id;
  final double amount;
  final String type;
  final String dateTime;
  final int categoryId;
  final String? note;

  // Convert to domain entity
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      amount: amount,
      type: type == 'income' ? TransactionType.income : TransactionType.expense,
      dateTime: DateTime.parse(dateTime),
      categoryId: categoryId,
      note: note,
      createdAt: DateTime.now(),
    );
  }

  // Convert from domain entity
  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      amount: entity.amount,
      type: entity.type.name,
      dateTime: entity.dateTime.toIso8601String(),
      categoryId: entity.categoryId,
      note: entity.note,
    );
  }
}

// Repository Implementation (Following DIP)
// lib/data/repositories/transaction/transaction_write_repository_impl.dart
class TransactionWriteRepositoryImpl implements TransactionWriteRepository {
  final LocalDataSource _dataSource;  // ✅ Abstract dependency

  TransactionWriteRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, TransactionEntity>> addTransaction(TransactionEntity transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      final id = await _dataSource.insert('transactions', model.toMap());
      final result = transaction.copyWith(id: id);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}

// ========================================
// 3. PRESENTATION LAYER (Depends on domain)
// ========================================

// Provider (State management)
// lib/presentation/providers/transaction/transaction_form_provider.dart
@riverpod
class TransactionFormNotifier extends _$TransactionFormNotifier {
  @override
  TransactionFormState build() {
    return TransactionFormState.initial();
  }

  Future<void> submit() async {
    state = const TransactionFormState.loading();

    final useCase = ref.read(addTransactionUseCaseProvider); // Domain use case
    final entity = _mapStateToEntity(state);

    final result = await useCase.execute(entity);

    result.fold(
      (failure) => state = TransactionFormState.error(failure.message),
      (success) => state = TransactionFormState.success(success),
    );
  }
}
```

---

## Repository Segregation Pattern

**Principle**: Interface Segregation Principle (ISP) - Clients should not depend on interfaces they don't use.

### Traditional Approach (❌ Not Used)

```dart
// BAD - Fat interface with all operations
abstract class TransactionRepository {
  // CRUD
  Future<List<Transaction>> getAll();
  Future<Transaction?> getById(int id);
  Future<void> add(Transaction transaction);
  Future<void> update(Transaction transaction);
  Future<void> delete(int id);

  // Query
  Future<List<Transaction>> getByDateRange(DateTime start, DateTime end);

  // Search
  Future<List<Transaction>> search(String query);

  // Analytics
  Future<double> getTotalByType(TransactionType type);
  Future<List<CategoryBreakdown>> getCategoryBreakdown(int year, int month);

  // Export
  Future<String> exportToCsv(List<Transaction> transactions);
}

// Problem: A simple list screen must depend on analytics/export methods it doesn't use
```

### Segregated Approach (✅ Used in Catat Cuan)

```dart
// GOOD - Small, focused interfaces

// lib/domain/repositories/transaction/transaction_read_repository.dart
abstract class TransactionReadRepository {
  Future<Either<Failure, List<TransactionEntity>>> getTransactions();
  Future<Either<Failure, TransactionEntity?>> getTransactionById(int id);
}

// lib/domain/repositories/transaction/transaction_write_repository.dart
abstract class TransactionWriteRepository {
  Future<Either<Failure, TransactionEntity>> addTransaction(TransactionEntity transaction);
  Future<Either<Failure, TransactionEntity>> updateTransaction(TransactionEntity transaction);
}

// lib/domain/repositories/transaction/transaction_query_repository.dart
abstract class TransactionQueryRepository {
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByDateRange({
    required DateTime start,
    required DateTime end,
  });
}

// lib/domain/repositories/transaction/transaction_search_repository.dart
abstract class TransactionSearchRepository {
  Future<Either<Failure, List<TransactionEntity>>> searchTransactions(String query);
}

// lib/domain/repositories/transaction/transaction_analytics_repository.dart
abstract class TransactionAnalyticsRepository {
  Future<Either<Failure, double>> getTotalByType({
    required TransactionType type,
    required int year,
    required int month,
  });
}

// lib/domain/repositories/transaction/transaction_export_repository.dart
abstract class TransactionExportRepository {
  Future<Either<Failure, String>> exportTransactionsToCsv(List<TransactionEntity> transactions);
}
```

### Benefits

1. **Single Responsibility**: Each interface has one reason to change
2. **Flexible Dependencies**: Clients only depend on methods they use
3. **Easier Testing**: Smaller interfaces are easier to mock
4. **Clear Intent**: Interface name describes its purpose

### Real Example: Category Repositories

```dart
// lib/domain/repositories/category/

// 1. Read operations (for listing, filtering)
abstract class CategoryReadRepository {
  Future<Either<Failure, List<CategoryEntity>>> getActiveCategories(TransactionType type);
  Future<Either<Failure, CategoryEntity?>> getCategoryById(int id);
}

// 2. Write operations (for create, update)
abstract class CategoryWriteRepository {
  Future<Either<Failure, CategoryEntity>> addCategory(CategoryEntity category);
  Future<Either<Failure, CategoryEntity>> updateCategory(CategoryEntity category);
}

// 3. Management operations (for deactivate, reorder)
abstract class CategoryManagementRepository {
  Future<Either<Failure, void>> deactivateCategory(int id);
  Future<Either<Failure, void>> reorderCategories(List<int> categoryIds);
}

// 4. Seeding operations (for default data)
abstract class CategorySeedingRepository {
  Future<Either<Failure, void>> seedDefaultCategories();
}
```

### Usage in Providers

```dart
// A provider that only needs to read categories
@riverpod
class CategoryListNotifier extends _$CategoryListNotifier {
  @override
  Future<List<CategoryEntity>> build() async {
    // Only depends on read repository
    final readRepo = ref.read(categoryReadRepositoryProvider);
    final result = await readRepo.getActiveCategories(TransactionType.expense);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (categories) => categories,
    );
  }
}

// A provider that only needs to manage categories
@riverpod
class CategoryManagementNotifier extends _$CategoryManagementNotifier {
  @override
  CategoryManagementState build() {
    return CategoryManagementState.initial();
  }

  Future<void> deactivateCategory(int id) async {
    // Only depends on management repository
    final managementRepo = ref.read(categoryManagementRepositoryProvider);
    final result = await managementRepo.deactivateCategory(id);
    // Handle result...
  }
}
```

---

## Controller Pattern

**Purpose**: Extract business logic from state management (providers) into dedicated controllers.

### Problem: Business Logic in Providers

```dart
// BAD - Business logic mixed with state management
@riverpod
class TransactionFormNotifier extends _$TransactionFormNotifier {
  @override
  TransactionFormState build() {
    return TransactionFormState.initial();
  }

  Future<void> submit() async {
    state = const TransactionFormState.loading();

    // Business logic embedded in provider
    final isAdd = state.existingTransaction == null;
    final entity = _mapToEntity(state);

    if (isAdd) {
      // Validation logic
      if (entity.amount <= 0) {
        state = TransactionFormState.error('Invalid amount');
        return;
      }

      // Add logic
      final result = await ref.read(addTransactionUseCaseProvider).execute(entity);
      result.fold(
        (failure) => state = TransactionFormState.error(failure.message),
        (success) {
          state = TransactionFormState.success(success);
          ref.invalidate(transactionListProvider);
        },
      );
    } else {
      // Update logic
      final result = await ref.read(updateTransactionUseCaseProvider).execute(entity);
      // Similar handling...
    }
  }

  // More business logic...
  TransactionEntity _mapToEntity(TransactionFormState state) { }
  void _handleSuccess(TransactionEntity entity) { }
  void _handleError(Failure failure) { }
}
```

### Solution: Extract to Controller

```dart
// GOOD - Business logic in controller
// lib/presentation/controllers/transaction_form_submission_controller.dart

/// Strategy pattern for different submission types
abstract class SubmissionStrategy {
  Future<Either<Failure, TransactionEntity>> execute(
    TransactionFormState formState,
    TransactionEntity? existingTransaction,
  );
}

class AddTransactionStrategy implements SubmissionStrategy {
  final AddTransactionUseCase _useCase;

  AddTransactionStrategy(this._useCase);

  @override
  Future<Either<Failure, TransactionEntity>> execute(
    TransactionFormState formState,
    TransactionEntity? existingTransaction,
  ) async {
    final entity = _mapToEntity(formState);
    return _useCase.execute(entity);
  }

  TransactionEntity _mapToEntity(TransactionFormState state) {
    return TransactionEntity(
      amount: state.nominal,
      type: state.type,
      dateTime: DateTime(state.date.year, state.date.month, state.date.day,
          state.time.hour, state.time.minute),
      categoryId: state.categoryId,
      note: state.note,
    );
  }
}

class UpdateTransactionStrategy implements SubmissionStrategy {
  final UpdateTransactionUseCase _useCase;

  UpdateTransactionStrategy(this._useCase);

  @override
  Future<Either<Failure, TransactionEntity>> execute(
    TransactionFormState formState,
    TransactionEntity? existingTransaction,
  ) async {
    final entity = _mapToEntity(formState, existingTransaction!);
    return _useCase.execute(entity);
  }

  TransactionEntity _mapToEntity(TransactionFormState state, TransactionEntity existing) {
    return existing.copyWith(
      amount: state.nominal,
      type: state.type,
      dateTime: DateTime(state.date.year, state.date.month, state.date.day,
          state.time.hour, state.time.minute),
      categoryId: state.categoryId,
      note: state.note,
    );
  }
}

/// Controller for transaction form submission
/// Following SRP: Only handles submission logic
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

// Provider becomes simple - only manages state
@riverpod
class TransactionFormNotifier extends _$TransactionFormNotifier {
  @override
  TransactionFormState build() {
    return TransactionFormState.initial();
  }

  Future<void> submit() async {
    state = const TransactionFormState.loading();

    // Delegate to controller
    final controller = _getSubmissionController();
    final result = await controller.submit(
      formState: state,
      existingTransaction: state.existingTransaction,
    );

    result.fold(
      (failure) => state = TransactionFormState.error(failure.message),
      (success) {
        state = TransactionFormState.success(success);
        ref.invalidate(transactionListProvider);
      },
    );
  }

  TransactionFormSubmissionController _getSubmissionController() {
    return TransactionFormSubmissionController(
      addStrategy: AddTransactionStrategy(ref.read(addTransactionUseCaseProvider)),
      updateStrategy: UpdateTransactionStrategy(ref.read(updateTransactionUseCaseProvider)),
    );
  }
}
```

### Available Controllers in Catat Cuan

1. **transaction_delete_controller.dart** - Handles deletion logic with confirmation
2. **receipt_scanning_controller.dart** - Coordinates OCR scanning workflow
3. **category_management_controller.dart** - Manages category operations
4. **transaction_form_submission_controller.dart** - Handles form submission with strategy pattern
5. **transaction_scan_result_controller.dart** - Processes scan results

---

## Service Layer Pattern

### Domain Services vs Application Services

#### Domain Services (in domain layer)
- Business logic that doesn't naturally fit in entities or value objects
- No dependencies on external frameworks
- Examples: `ExportService`, `InsightService`

```dart
// lib/domain/services/export_service.dart
abstract class ExportService {
  Future<Either<Failure, String>> exportTransactionsToCsv(List<TransactionEntity> transactions);
}

// Implementation in data layer
// lib/data/services/csv_export_service_impl.dart
class CsvExportServiceImpl implements ExportService {
  @override
  Future<Either<Failure, String>> exportTransactionsToCsv(
    List<TransactionEntity> transactions,
  ) async {
    try {
      final csv = transactions.map((t) => t.toCsvRow()).join('\n');
      return Right(csv);
    } catch (e) {
      return Left(ExportFailure(e.toString()));
    }
  }
}
```

#### Application Services (in data/presentation layer)
- Platform-specific implementations
- External library integrations
- Examples: `ReceiptOcrService`, `ImagePickerService`, `PermissionService`

```dart
// Domain interface
// lib/domain/services/ocr_service.dart
abstract class OcrService {
  Future<Either<Failure, String>> extractReceiptAmount(String imagePath);
}

// Data implementation
// lib/data/services/receipt_ocr_service_impl.dart
class ReceiptOcrServiceImpl implements OcrService {
  final TextRecognizer _textRecognizer;

  ReceiptOcrServiceImpl(this._textRecognizer);

  @override
  Future<Either<Failure, String>> extractReceiptAmount(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      final amount = ReceiptAmountParser.parse(recognizedText.text);
      if (amount == null) {
        return const Left(OcrFailure('No amount found in receipt'));
      }

      return Right(amount);
    } catch (e) {
      return Left(OcrFailure(e.toString()));
    }
  }
}
```

---

## Domain Layer

### Purpose: Encapsulate business logic without dependencies

#### Entities
```dart
// lib/domain/entities/transaction_entity.dart
class TransactionEntity {
  final int? id;
  final double amount;
  final TransactionType type;
  final DateTime dateTime;
  final int categoryId;
  final String? note;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TransactionEntity({
    this.id,
    required this.amount,
    required this.type,
    required this.dateTime,
    required this.categoryId,
    this.note,
    required this.createdAt,
    this.updatedAt,
  });

  // Business logic methods
  bool get isIncomes => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  TransactionEntity copyWith({
    int? id,
    double? amount,
    TransactionType? type,
    DateTime? dateTime,
    int? categoryId,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

#### Use Cases
```dart
// lib/domain/usecases/transaction/add_transaction_usecase.dart
class AddTransactionUseCase {
  final TransactionWriteRepository _repository;

  AddTransactionUseCase(this._repository);

  Future<Either<Failure, TransactionEntity>> execute(TransactionEntity transaction) async {
    // Business validation
    if (transaction.amount <= 0) {
      return const Left(ValidationFailure('Amount must be greater than 0'));
    }

    return await _repository.addTransaction(transaction);
  }
}
```

#### Repository Interfaces
```dart
// lib/domain/repositories/transaction/transaction_write_repository.dart
abstract class TransactionWriteRepository {
  Future<Either<Failure, TransactionEntity>> addTransaction(TransactionEntity transaction);
  Future<Either<Failure, TransactionEntity>> updateTransaction(TransactionEntity transaction);
}
```

---

## Data Layer

### Purpose: Implement domain interfaces and manage data sources

### Data Source Abstraction (SOLID Compliance)

The data layer uses a **LocalDataSource** abstraction to achieve 100% SOLID compliance (OCP, LSP, DIP):

```dart
// lib/data/datasources/local/local_data_source.dart
/// Abstract data source for local storage
///
/// Following OCP: Can be extended for SQLite, Hive, Isar, etc.
/// Following DIP: High-level modules depend on this abstraction
abstract class LocalDataSource {
  Future<List<Map<String, dynamic>>> query(String table, {...});
  Future<List<Map<String, dynamic>>> rawQuery(String sql, List<Object?>? arguments);
  Future<int> insert(String table, Map<String, dynamic> values);
  Future<int> update(String table, Map<String, dynamic> values, {...});
  Future<int> delete(String table, {...});
  Future<void> transaction(Future<void> Function() action);
  Future<void> close();
}

// SQLite implementation
// lib/data/datasources/local/sqlite_data_source.dart
class SqliteDataSource implements LocalDataSource {
  final DatabaseHelper _dbHelper;

  SqliteDataSource(this._dbHelper);

  @override
  Future<List<Map<String, dynamic>>> query(...) async {
    final db = await _dbHelper.database;
    return db.query(...);
  }
  // ... other methods
}
```

#### Repository Implementation (Following DIP)

```dart
// lib/data/repositories/transaction/transaction_write_repository_impl.dart
class TransactionWriteRepositoryImpl implements TransactionWriteRepository {
  final LocalDataSource _dataSource;  // ✅ Abstract dependency

  TransactionWriteRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, TransactionEntity>> addTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      final id = await _dataSource.insert(tableTransactions, model.toMap());
      final result = transaction.copyWith(id: id);
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await _dataSource.update(tableTransactions, model.toMap(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
      return Right(transaction);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
```

#### Benefits of Data Source Abstraction

1. **Open/Closed Principle**: New data sources can be added without modifying repositories
2. **Liskov Substitution**: Any `LocalDataSource` implementation can be substituted
3. **Dependency Inversion**: High-level modules depend on abstractions, not concretions
4. **Testability**: Easy to mock data sources for testing
5. **Flexibility**: Can switch between SQLite, Hive, Isar, or REST API

#### Database Helper (SQLite Connection)

```dart
// lib/data/datasources/local/database_helper.dart
class DatabaseHelper {
  static const String _databaseName = 'catat_cuan.db';
  static const int _databaseVersion = 2;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: DatabaseSchemaManager.onCreate,
      onUpgrade: DatabaseSchemaManager.onUpgrade,
    );
  }
}
```

#### Schema Manager
```dart
// lib/data/datasources/local/schema_manager.dart
class DatabaseSchemaManager {
  DatabaseSchemaManager._();

  static const int currentVersion = 2;

  static Future<void> onCreate(Database db, int version) async {
    await _createCategoriesTable(db);
    await _createTransactionsTable(db);
    await _createIndexes(db);
  }

  static Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createMonthlyAggregationIndex(db);
    }
  }
}
```

**Note**: For complete database schema documentation including tables, indexes, and migrations, see [DATABASE_SCHEMA.md](../v1/database/DATABASE_SCHEMA.md).

---

## Presentation Layer

### Purpose: UI and state management

### Provider Organization

```
lib/presentation/providers/
├── app_providers.dart                    # Central export
├── repository_providers.dart             # Repository DI
├── usecase_providers.dart                # UseCase DI
├── service_providers.dart                # Service DI
├── transaction/                          # Transaction feature
│   ├── transaction_list_provider.dart
│   ├── transaction_form_provider.dart
│   ├── transaction_filter_provider.dart
│   └── ...
├── category/                             # Category feature
│   ├── category_list_provider.dart
│   ├── category_form_provider.dart
│   └── ...
└── summary/                              # Summary feature
    └── monthly_summary_provider.dart
```

### Provider Pattern with Riverpod 3.x

```dart
// lib/presentation/providers/transaction/transaction_form_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_form_provider.g.dart';

@riverpod
class TransactionFormNotifier extends _$TransactionFormNotifier {
  @override
  TransactionFormState build() {
    // Initialize here, NOT in constructor
    return TransactionFormState.initial();
  }

  void setNominal(double value) {
    state = state.copyWith(nominal: value);
  }

  Future<void> submit() async {
    state = const TransactionFormState.loading();

    final controller = _getSubmissionController();
    final result = await controller.submit(
      formState: state,
      existingTransaction: state.existingTransaction,
    );

    result.fold(
      (failure) => state = TransactionFormState.error(failure.message),
      (success) => state = TransactionFormState.success(success),
    );
  }
}
```

### State Pattern with Freezed

```dart
// lib/presentation/states/transaction_form_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_form_state.freezed.dart';

@freezed
abstract class TransactionFormState with _$TransactionFormState {
  const factory TransactionFormState.initial({
    @Default(TransactionType.expense) TransactionType type,
    DateTime? date,
    DateTime? time,
    @Default(0.0) double nominal,
    @Default(0) int categoryId,
    String? note,
    TransactionEntity? existingTransaction,
    @Default({}) Map<String, String> validationErrors,
  }) = TransactionFormInitial;

  const factory TransactionFormState.loading() = TransactionFormLoading;

  const factory TransactionFormState.success(TransactionEntity transaction) =
      TransactionFormSuccess;

  const factory TransactionFormState.error(String message) = TransactionFormError;
}
```

### Screen Implementation

```dart
// lib/presentation/screens/transaction_form_screen.dart
class TransactionFormScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen>
    with ScreenStateMixin {
  @override
  Widget build(BuildContext context) {
    ref.listen<TransactionFormState>(
      transactionFormNotifierProvider,
      (previous, next) {
        next.maybeWhen(
          success: (transaction) {
            showSuccessSnackBar('Transaksi berhasil disimpan');
            context.pop();
          },
          error: (message) {
            showErrorSnackBar(message);
          },
          orElse: () {},
        );
      },
    );

    final state = ref.watch(transactionFormNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Transaksi')),
      body: state.when(
        initial: (form) => _buildForm(form),
        loading: () => const AppLoadingState(),
        success: (_) => const AppLoadingState(),
        error: (message) => _buildForm(state.asInitial!),
      ),
    );
  }

  Widget _buildForm(TransactionFormInitial form) {
    return SingleChildScrollView(
      padding: AppSpacing.lgAll,
      child: Column(
        children: [
          CurrencyInputField(
            value: form.nominal,
            onChanged: (value) {
              ref.read(transactionFormNotifierProvider.notifier).setNominal(value);
            },
          ),
          // ... other fields
        ],
      ),
    );
  }
}
```

---

## Dependency Injection Setup

### Provider Chain

```dart
// lib/presentation/providers/repository_providers.dart

// 1. Data source provider
@riverpod
DatabaseHelper databaseHelper(DatabaseHelperRef ref) {
  return DatabaseHelper();
}

// 2. Repository implementation providers
@riverpod
TransactionWriteRepository transactionWriteRepository(TransactionWriteRepositoryRef ref) {
  return TransactionWriteRepositoryImpl(ref.read(databaseHelperProvider));
}

@riverpod
TransactionReadRepository transactionReadRepository(TransactionReadRepositoryRef ref) {
  return TransactionReadRepositoryImpl(ref.read(databaseHelperProvider));
}

// lib/presentation/providers/usecase_providers.dart

// 3. Use case providers
@riverpod
AddTransactionUseCase addTransactionUseCase(AddTransactionUseCaseRef ref) {
  return AddTransactionUseCase(ref.read(transactionWriteRepositoryProvider));
}

// lib/presentation/providers/transaction/transaction_form_provider.dart

// 4. Feature providers
@riverpod
class TransactionFormNotifier extends _$TransactionFormNotifier {
  @override
  TransactionFormState build() {
    return TransactionFormState.initial();
  }

  Future<void> submit() async {
    final useCase = ref.read(addTransactionUseCaseProvider);
    // Use the use case...
  }
}
```

### Manual Dependency Injection (Alternative)

```dart
// In main.dart
void main() {
  final dataSources = DataSources();
  final repositories = Repositories(dataSources);
  final useCases = UseCases(repositories);

  runApp(
    ProviderScope(
      overrides: [
        databaseHelperProvider.overrideWithValue(dataSources.databaseHelper),
        transactionWriteRepositoryProvider.overrideWithValue(repositories.transactionWriteRepository),
        addTransactionUseCaseProvider.overrideWithValue(useCases.addTransaction),
      ],
      child: const AppWidget(),
    ),
  );
}
```

---

## Testing Strategy

### Unit Tests (Domain Layer)

```dart
// test/domain/usecases/add_transaction_usecase_test.dart
void main() {
  late AddTransactionUseCase useCase;
  late MockTransactionWriteRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionWriteRepository();
    useCase = AddTransactionUseCase(mockRepository);
  });

  test('should return validation failure when amount is zero', () async {
    // Arrange
    final transaction = TransactionEntity(
      amount: 0,
      type: TransactionType.expense,
      dateTime: DateTime.now(),
      categoryId: 1,
      createdAt: DateTime.now(),
    );

    // Act
    final result = await useCase.execute(transaction);

    // Assert
    expect(result.isLeft(), true);
    expect(result.fold((l) => l, (r) => null), isA<ValidationFailure>());
  });

  test('should add transaction successfully', () async {
    // Arrange
    final transaction = TransactionEntity(
      amount: 100,
      type: TransactionType.expense,
      dateTime: DateTime.now(),
      categoryId: 1,
      createdAt: DateTime.now(),
    );
    final expected = TransactionEntity.copyWith(id: 1);

    when(mockRepository.addTransaction(transaction))
        .thenAnswer((_) async => Right(expected));

    // Act
    final result = await useCase.execute(transaction);

    // Assert
    expect(result.isRight(), true);
    result.fold(
      (l) => fail('Should return Right'),
      (r) => expect(r.id, 1),
    );
    verify(mockRepository.addTransaction(transaction)).called(1);
  });
}
```

### Widget Tests (Presentation Layer)

```dart
// test/presentation/screens/transaction_form_screen_test.dart
void main() {
  testWidgets('should display all form fields', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionFormNotifierProvider
              .overrideWith(TransactionFormNotifier.new),
        ],
        child: const MaterialApp(home: TransactionFormScreen()),
      ),
    );

    expect(find.text('Nominal'), findsOneWidget);
    expect(find.text('Kategori'), findsOneWidget);
    expect(find.text('Catatan'), findsOneWidget);
  });
}
```

---

## Best Practices

### 1. Always Depend on Abstractions
```dart
// ✅ GOOD
class MyNotifier {
  final TransactionReadRepository _repository;
  MyNotifier(this._repository);
}

// ❌ BAD
class MyNotifier {
  final TransactionReadRepositoryImpl _repository;
  MyNotifier(this._repository);
}
```

### 2. Keep Use Cases Atomic
```dart
// ✅ GOOD - Single responsibility
class AddTransactionUseCase { }
class UpdateTransactionUseCase { }
class DeleteTransactionUseCase { }

// ❌ BAD - Too many responsibilities
class TransactionManagementUseCase {
  void add() { }
  void update() { }
  void delete() { }
}
```

### 3. Use Barrel Exports
```dart
// lib/domain/repositories/transaction/transaction_repositories.dart
export 'transaction_read_repository.dart';
export 'transaction_write_repository.dart';
export 'transaction_query_repository.dart';
// etc.

// Usage
import 'package:catat_cuan/domain/repositories/transaction/transaction_repositories.dart';
```

### 4. Initialize in build(), Not Constructor
```dart
// ✅ GOOD
@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  Future build() async {
    final useCase = ref.read(myUseCaseProvider);
    return await useCase.execute();
  }
}

// ❌ BAD
@riverpod
class MyNotifier extends _$MyNotifier {
  MyNotifier() {
    // Providers not available yet!
    load();
  }

  @override
  Future build() => Future.value();
}
```

---

## Related Documentation

- [SOLID.md](SOLID.md) - SOLID principles with examples
- [RIVERPOD_GUIDE.md](RIVERPOD_GUIDE.md) - Riverpod 3.x patterns
- [FREEZED_GUIDE.md](FREEZED_GUIDE.md) - Freezed 3.x guide
- [CODING_STANDARDS.md](CODING_STANDARDS.md) - File naming and conventions
- [AI_ASSISTANT_GUIDE.md](../AI_ASSISTANT_GUIDE.md) - Quick reference for AI assistants

---

**Last Updated**: 2026-03-27
**Architecture Version**: 2.0 (Clean Architecture with 100% SRP compliance)
