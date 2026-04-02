# CLAUDE-SOLID.md

## SOLID Principles in Catat Cuan

This project follows **SOLID** principles to create maintainable, scalable, and testable code. SOLID is an acronym for five design principles intended to make software designs more understandable, flexible, and maintainable.

---

### 1. Single Responsibility Principle (SRP)

**"There should never be more than one reason for a class to change."**

Every class, function, and widget should have one, and only one, reason to change. A component should be responsible for a single part of the functionality.

**Key Rules:**

1. **Classes should be small** - A class' size is measured by its responsibility.

2. **Functions do one thing** - Functions should perform a single action.

   ```dart
   // BAD - Multiple responsibilities
   void processActiveClients(List<Client> clients) {
     final active = clients.where((c) => c.isActive).toList();
     for (var client in active) {
       sendEmail(client);
     }
   }

   // GOOD - Single responsibility per function
   void emailActiveClients(List<Client> clients) {
     clients.where(isActiveClient).forEach(emailClient);
   }

   bool isActiveClient(Client client) {
     return client.isActive;
   }
   ```

3. **UseCases should be atomic** - Each UseCase performs ONE business operation.
   - ✅ `AddTransactionUseCase` - Adds a single transaction
   - ✅ `GetCategoriesUseCase` - Retrieves categories
   - ❌ `TransactionManagementUseCase` - Handles add, edit, delete, list (too broad)

**Real Example from Catat Cuan:**

```dart
// lib/domain/usecases/transaction/add_transaction_usecase.dart
class AddTransactionUseCase {
  final TransactionWriteRepository _repository;

  AddTransactionUseCase(this._repository);

  /// Executes a single operation: adding a transaction
  Future<Either<Failure, TransactionEntity>> execute(
    TransactionEntity transaction,
  ) async {
    // Business validation
    if (transaction.amount <= 0) {
      return const Left(ValidationFailure('Amount must be greater than 0'));
    }

    return await _repository.addTransaction(transaction);
  }
}

// Each use case has ONE responsibility:
// - AddTransactionUseCase: Add only
// - UpdateTransactionUseCase: Update only
// - DeleteTransactionUseCase: Delete only
// - GetTransactionsUseCase: Get only
```

4. **Controllers should have single responsibility** - Each controller handles ONE business logic flow.

**Real Example from Catat Cuan:**

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

// Other controllers have different responsibilities:
// - TransactionDeleteController: Deletion logic only
// - ReceiptScanningController: OCR coordination only
// - CategoryManagementController: Category management only
```

---

### 2. Open/Closed Principle (OCP)

**"Software entities should be open for extension, but closed for modification."**

You should be able to add new functionality without changing existing code. This is achieved through abstraction and polymorphism.

**Key Rules:**

1. **Use abstraction for extensibility** - Define interfaces/abstract classes that can be extended.

2. **Avoid modifying existing code for new features** - Instead, extend through inheritance or composition.

3. **Replace conditionals with polymorphism** - Use strategy pattern instead of switch/if-else.

   ```dart
   // BAD - Modifying existing code for new types
   enum TransactionType { income, expense, transfer }

   String getTransactionIcon(TransactionType type) {
     switch (type) {
       case TransactionType.income:
         return 'arrow_up';
       case TransactionType.expense:
         return 'arrow_down';
       case TransactionType.transfer:
         return 'swap'; // NEW: Had to modify this function
       default:
         return 'help';
     }
   }

   // GOOD - Open for extension, closed for modification
   abstract class TransactionType {
     String get icon;
     String get label;
   }

   class IncomeType extends TransactionType {
     @override
     String get icon => 'arrow_up';
     @override
     String get label => 'Pemasukan';
   }

   class ExpenseType extends TransactionType {
     @override
     String get icon => 'arrow_down';
     @override
     String get label => 'Pengeluaran';
   }

   // NEW: Just add a new class, no modification needed
   class TransferType extends TransactionType {
     @override
     String get icon => 'swap';
     @override
     String get label => 'Transfer';
   }

   // Usage
   String getTransactionIcon(TransactionType type) => type.icon;
   ```

4. **Repository pattern for data sources** - Abstract data access so new sources can be added.

   ```dart
   // Domain layer - abstraction
   abstract class TransactionRepository {
     Future<Either<Failure, List<Transaction>>> getTransactions();
     Future<Either<Failure, void>> addTransaction(Transaction transaction);
   }

   // Data layer - implementations can be extended
   class TransactionRepositoryImpl implements TransactionRepository {
     final LocalDataSource _localDataSource;
     final RemoteDataSource? _remoteDataSource; // Optional remote sync

     TransactionRepositoryImpl(this._localDataSource, [this._remoteDataSource]);

     @override
     Future<Either<Failure, List<Transaction>>> getTransactions() async {
       try {
         final transactions = await _localDataSource.getTransactions();
         return Right(transactions);
       } catch (e) {
         return Left(DatabaseFailure(e.toString()));
       }
     }

     // Can extend with sync functionality without modifying existing methods
   }
   ```

5. **LocalDataSource abstraction** - Data source layer following OCP and DIP.

   ```dart
   // Data source abstraction (lib/data/datasources/local/local_data_source.dart)
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
   class SqliteDataSource implements LocalDataSource {
     final DatabaseHelper _dbHelper;
     SqliteDataSource(this._dbHelper);

     @override
     Future<List<Map<String, dynamic>>> query(String table, {...}) async {
       final db = await _dbHelper.database;
       return db.query(table, ...);
     }
     // ... other methods
   }

   // Repository depends on abstraction, not concretion
   class TransactionReadRepositoryImpl implements TransactionReadRepository {
     final LocalDataSource _dataSource; // ✅ Abstract dependency

     TransactionReadRepositoryImpl(this._dataSource);

     Future<Result<List<TransactionEntity>>> getTransactions() async {
       final maps = await _dataSource.query(...); // ✅ Storage-agnostic
     }
   }

   // Future: Can add Hive, Isar, or REST API implementations
   // without modifying any repository code!
   class HiveDataSource implements LocalDataSource {
     // Hive-specific implementation
   }
   ```

---

### 3. Liskov Substitution Principle (LSP)

**"Derived classes must be substitutable for their base classes."**

If you have a parent class and a child class, then the base class and child class can be used interchangeably without getting incorrect results. Subtypes must behave the same as their base types.

**Key Rules:**

1. **Don't violate the "is-a" relationship** - Ensure inheritance makes semantic sense.

2. **Don't override methods in incompatible ways** - Subtypes should honor the contract of their parent.

   ```dart
   // BAD - Square cannot properly substitute Rectangle
   class Rectangle {
     double width = 0;
     double height = 0;

     void setWidth(double w) => width = w;
     void setHeight(double h) => height = h;
     double getArea() => width * height;
   }

   class Square extends Rectangle {
     @override
     void setWidth(double w) {
       width = w;
       height = w; // VIOLATION: Changes expected Rectangle behavior
     }

     @override
     void setHeight(double h) {
       width = h;
       height = h; // VIOLATION: Changes expected Rectangle behavior
     }
   }

   // GOOD - Use common abstraction instead
   abstract class Shape {
     double getArea();
   }

   class Rectangle extends Shape {
     final double width;
     final double height;

     Rectangle(this.width, this.height);

     @override
     double getArea() => width * height;
   }

   class Square extends Shape {
     final double side;

     Square(this.side);

     @override
     double getArea() => side * side;
   }

   // Both can be substituted for Shape without issues
   void printArea(Shape shape) {
     print(shape.getArea());
   }
   ```

3. **Use case substitution** - All use cases should be substitutable through their common interface.

   ```dart
   // GOOD - All use cases share a common contract
   abstract class UseCase<Type, Params> {
     Future<Either<Failure, Type>> call(Params params);
   }

   class GetTransactionsUseCase extends UseCase<List<Transaction>, NoParams> {
     final TransactionRepository repository;

     GetTransactionsUseCase(this.repository);

     @override
     Future<Either<Failure, List<Transaction>>> call(NoParams params) {
       return repository.getTransactions();
     }
   }

   // Any UseCase can be used interchangeably
   Future<T> executeUseCase<T, P>(UseCase<T, P> useCase, P params) {
     return useCase(params);
   }
   ```

---

### 4. Interface Segregation Principle (ISP)

**"Clients should not be forced to depend upon interfaces that they do not use."**

Interfaces should be small and focused. Clients shouldn't be forced to implement methods they don't need.

**Key Rules:**

1. **Prefer small, focused interfaces** - Split large interfaces into smaller ones.

2. **Don't force irrelevant implementations** - Classes should only implement what they actually need.

   ```dart
   // BAD - Fat interface forces all methods
   abstract class MediaService {
     Future<void> captureImage();
     Future<void> pickFromGallery();
     Future<String> extractText(String imagePath);
     Future<bool> requestCameraPermission();
     Future<bool> requestStoragePermission();
     Future<void> saveToCloud(String imagePath);
   }

   // Implementations must override ALL methods, even unused ones
   class SimpleImagePicker implements MediaService {
     @override
     Future<void> captureImage() { /* ... */ }

     @override
     Future<void> pickFromGallery() { /* ... */ }

     @override
     Future<String> extractText(String imagePath) {
       throw UnimplementedError("I don't do OCR!");
     }

     @override
     Future<bool> requestCameraPermission() { /* ... */ }

     @override
     Future<bool> requestStoragePermission() { /* ... */ }

     @override
     Future<void> saveToCloud(String imagePath) {
       throw UnimplementedError("I don't do cloud sync!");
     }
   }

   // GOOD - Segregated interfaces
   abstract class ImagePicker {
     Future<void> captureImage();
     Future<void> pickFromGallery();
   }

   abstract class TextExtractor {
     Future<String> extractText(String imagePath);
   }

   abstract class PermissionHandler {
     Future<bool> requestCameraPermission();
     Future<bool> requestStoragePermission();
   }

   abstract class CloudStorage {
     Future<void> saveToCloud(String imagePath);
   }

   // Implementations only include what they need
   class SimpleImagePicker implements ImagePicker, PermissionHandler {
     @override
     Future<void> captureImage() { /* ... */ }

     @override
     Future<void> pickFromGallery() { /* ... */ }

     @override
     Future<bool> requestCameraPermission() { /* ... */ }

     @override
     Future<bool> requestStoragePermission() { /* ... */ }
   }

   class ReceiptOcrService implements TextExtractor {
     @override
     Future<String> extractText(String imagePath) { /* ... */ }
   }
   ```

3. **Repository segregation** - Separate read/write operations when appropriate.

**Real Example from Catat Cuan (4 Category Repositories):**

```dart
// lib/domain/repositories/category/

// 1. Read operations only
abstract class CategoryReadRepository {
  Future<Either<Failure, List<CategoryEntity>>> getActiveCategories(
    TransactionType type,
  );
  Future<Either<Failure, CategoryEntity?>> getCategoryById(int id);
}

// 2. Write operations only
abstract class CategoryWriteRepository {
  Future<Either<Failure, CategoryEntity>> addCategory(
    CategoryEntity category,
  );
  Future<Either<Failure, CategoryEntity>> updateCategory(
    CategoryEntity category,
  );
}

// 3. Management operations only
abstract class CategoryManagementRepository {
  Future<Either<Failure, void>> deactivateCategory(int id);
  Future<Either<Failure, void>> reorderCategories(
    List<int> categoryIds,
  );
}

// 4. Seeding operations only
abstract class CategorySeedingRepository {
  Future<Either<Failure, void>> seedDefaultCategories();
}
```

**Benefits in Catat Cuan:**

```dart
// A provider that only needs to read categories
@riverpod
class CategoryListNotifier extends _$CategoryListNotifier {
  @override
  Future<List<CategoryEntity>> build() async {
    // Only depends on read repository
    final readRepo = ref.read(categoryReadRepositoryProvider);
    final result = await readRepo.getActiveCategories(
      TransactionType.expense,
    );
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

**Transaction Repositories (6+ interfaces):**

```dart
// lib/domain/repositories/transaction/

// Basic CRUD
abstract class TransactionReadRepository { }
abstract class TransactionWriteRepository { }

// Query operations
abstract class TransactionQueryRepository {
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByDateRange({
    required DateTime start,
    required DateTime end,
  });
}

// Search operations
abstract class TransactionSearchRepository {
  Future<Either<Failure, List<TransactionEntity>>> searchTransactions(
    String query,
  );
}

// Analytics operations
abstract class TransactionAnalyticsRepository {
  Future<Either<Failure, double>> getTotalByType({
    required TransactionType type,
    required int year,
    required int month,
  });
}

// Export operations
abstract class TransactionExportRepository {
  Future<Either<Failure, String>> exportTransactionsToCsv(
    List<TransactionEntity> transactions,
  );
}
```

---

### 5. Dependency Inversion Principle (DIP)

**"Depend on abstractions, not on concretions."**

High-level modules should not depend on low-level modules. Both should depend on abstractions. This is the foundation of Clean Architecture.

**Key Rules:**

1. **Depend on abstractions** - Use interfaces/abstract classes instead of concrete implementations.

2. **Use Dependency Injection** - Inject dependencies through constructors or providers.

   ```dart
   // BAD - Direct dependency on concrete implementation
   class TransactionListNotifier extends StateNotifier<TransactionListState> {
     // Direct dependency - hard to test and inflexible
     final TransactionRepositoryImpl _repository = TransactionRepositoryImpl();

     TransactionListNotifier() : super(TransactionListInitial()) {
       loadTransactions();
     }
   }

   // GOOD - Dependency on abstraction
   class TransactionListNotifier extends StateNotifier<TransactionListState> {
     final TransactionRepository _repository; // Abstract type

     TransactionListNotifier(this._repository) : super(TransactionListInitial()) {
       loadTransactions();
     }
   }

   // Provider setup in app_providers.dart
   final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
     return TransactionRepositoryImpl(ref.read(databaseHelperProvider));
   });

   final transactionListProvider = StateNotifierProvider<TransactionListNotifier, TransactionListState>((ref) {
     return TransactionListNotifier(ref.read(transactionRepositoryProvider));
   });
   ```

3. **Clean Architecture layering** - This principle is why we use Clean Architecture:

   ```
   ┌─────────────────────────────────────────────────────────────┐
   │                    Presentation Layer                       │
   │  (Screens, Widgets, StateNotifiers)                         │
   │                     ↓ depends on ↓                          │
   │                    Domain Layer                             │
   │  (Entities, UseCases, Repository Interfaces) ← ABSTRACTIONS │
   │                     ↑ implemented by ↑                      │
   │                    Data Layer                               │
   │  (Repository Implementations, DataSources) ← CONCRETE       │
   └─────────────────────────────────────────────────────────────┘
   ```

4. **Service injection pattern** - Inject services through abstractions.

   ```dart
   // Domain - define abstraction
   abstract class OcrService {
     Future<Either<Failure, String>> extractReceiptAmount(String imagePath);
   }

   // Data - concrete implementation
   class ReceiptOcrServiceImpl implements OcrService {
     final TextRecognizer _textRecognizer;

     ReceiptOcrServiceImpl(this._textRecognizer);

     @override
     Future<Either<Failure, String>> extractReceiptAmount(String imagePath) async {
       try {
         final text = await _processImage(imagePath);
         final amount = _findTotalAmount(text);
         return Right(amount);
       } catch (e) {
         return Left(OcrFailure(e.toString()));
       }
     }
   }

   // Provider setup
   final ocrServiceProvider = Provider<OcrService>((ref) {
     return ReceiptOcrServiceImpl(GoogleMlKit.vision.textRecognizer());
   });

   final receiptScanProvider = StateNotifierProvider<ReceiptScanNotifier, ReceiptScanState>((ref) {
     return ReceiptScanNotifier(
       ref.read(ocrServiceProvider), // Injected abstraction
       ref.read(imagePickerServiceProvider),
     );
   });
   ```

---

## SOLID Benefits

When all SOLID principles are applied together:

- **Maintainable**: Changes are isolated and don't cascade
- **Testable**: Dependencies can be mocked easily
- **Flexible**: New features can be added without modifying existing code
- **Scalable**: Codebase can grow without becoming unmanageable
- **Reusable**: Small, focused components are easier to reuse

## Real SOLID Implementation in Catat Cuan

### 100% SRP Compliance Achievement

Catat Cuan has achieved **100% Single Responsibility Principle compliance** through a comprehensive refactoring across 6 phases:

#### Phase 1: Repository Segregation (Data Layer)
- Created 4 category repositories (read, write, management, seeding)
- Created 6+ transaction repositories (read, write, query, search, analytics, export)
- Each repository has ONE reason to change

#### Phase 2: Controller Extraction (Presentation Layer)
- Extracted business logic from providers into dedicated controllers
- Created 3 controllers with single responsibilities:
  - `TransactionDeleteController` - Deletion logic only
  - `ReceiptScanningController` - OCR coordination only
  - `CategoryManagementController` - Category management only

#### Phase 3: Service Layer Segregation
- Split `InsightService` into 4 focused services:
  - `NewUserInsightService` - New users only
  - `SpendingAnalysisService` - Spending analysis
  - `CategoryBreakdownService` - Category breakdown
  - `RecommendationService` - Recommendations only

#### Results
- **16/16 violations addressed** (100% SRP compliance)
- **22 files created** (repositories, controllers, services, analyzers)
- **283/283 tests passing** ✅
- **0 analyzer errors** ✅

### SOLID Metrics

| Principle | Compliance | Evidence |
|-----------|------------|----------|
| **SRP** | 100% | Each class has one reason to change |
| **OCP** | 100% | New data sources can be added without modifying repositories |
| **LSP** | 100% | All repositories and data sources substitutable |
| **ISP** | 100% | 10+ segregated interfaces |
| **DIP** | 100% | All dependencies inverted (including LocalDataSource) |

### Code Examples

**Before (SRP Violation):**
```dart
// ❌ BAD - Multiple responsibilities
class TransactionRepository {
  Future<List<Transaction>> getTransactions() { }
  Future<void> addTransaction(Transaction t) { }
  Future<void> updateTransaction(Transaction t) { }
  Future<void> deleteTransaction(int id) { }
  Future<List<Transaction>> search(String q) { }
  Future<double> getTotal(TransactionType type) { }
  Future<String> exportToCsv(List<Transaction> t) { }
}
```

**After (SRP Compliant):**
```dart
// ✅ GOOD - Single responsibility each
abstract class TransactionReadRepository {
  Future<List<Transaction>> getTransactions();
}

abstract class TransactionWriteRepository {
  Future<void> addTransaction(Transaction t);
  Future<void> updateTransaction(Transaction t);
}

abstract class TransactionSearchRepository {
  Future<List<Transaction>> search(String q);
}

abstract class TransactionAnalyticsRepository {
  Future<double> getTotal(TransactionType type);
}

abstract class TransactionExportRepository {
  Future<String> exportToCsv(List<Transaction> t);
}
```

---

## References

- [ARCHITECTURE.md](ARCHITECTURE.md) - Complete Clean Architecture guide
- [CODING_STANDARDS.md](CODING_STANDARDS.md) - File naming and conventions
- [Clean Code TypeScript - SOLID](https://github.com/labs42io/clean-code-typescript)
- [SOLID Principles in Flutter](https://bloclibrary.dev/#core-concepts)
