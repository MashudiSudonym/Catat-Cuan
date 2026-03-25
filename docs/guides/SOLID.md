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

   ```dart
   // GOOD - Segregated by operation type
   abstract class ReadableRepository<T> {
     Future<Either<Failure, List<T>>> getAll();
     Future<Either<Failure, T?>> getById(int id);
   }

   abstract class WritableRepository<T> {
     Future<Either<Failure, void>> add(T item);
     Future<Either<Failure, void>> update(T item);
     Future<Either<Failure, void>> delete(int id);
   }

   // Read-only cache implementation
   class CachedCategoryRepository implements ReadableRepository<Category> {
     @override
     Future<Either<Failure, List<Category>>> getAll() { /* ... */ }

     @override
     Future<Either<Failure, Category?>> getById(int id) { /* ... */ }
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

## References

- [Clean Code TypeScript - SOLID](https://github.com/labs42io/clean-code-typescript)
- [SOLID Principles in Flutter](https://bloclibrary.dev/#core-concepts)
