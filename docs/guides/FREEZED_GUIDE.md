# Freezed 3.x Guide - Catat Cuan

**Last Updated**: 2026-03-27
**Project**: Catat Cuan (Flutter Expense Tracking App)
**Freezed Version**: 3.2.5
**Freezed Annotation Version**: 3.1.0

---

## Table of Contents
1. [Critical Requirement: abstract Keyword](#critical-requirement-abstract-keyword)
2. [Setup](#setup)
3. [Code Generation Workflow](#code-generation-workflow)
4. [Common Patterns](#common-patterns)
5. [Union Types](#union-types)
6. [Immutable Classes](#immutable-classes)
7. [CopyWith Pattern](#copywith-pattern)
8. [Migration from Freezed 2.x](#migration-from-freezed-2x)
9. [Best Practices](#best-practices)

---

## Critical Requirement: abstract Keyword

⚠️ **CRITICAL**: Freezed 3.x **requires** the `abstract` keyword before class definitions. This is a breaking change from Freezed 2.x.

### The Error You'll Get Without `abstract`

```dart
// ❌ WRONG - Missing 'abstract' keyword
@freezed
class MyState with _$MyState {
  const factory MyState.initial() = MyStateInitial;
}

// Error: The class 'MyState' can't be designated as a '@freezed' class
// because it doesn't have the 'abstract' keyword.
```

### The Fix

```dart
// ✅ CORRECT - Includes 'abstract' keyword
@freezed
abstract class MyState with _$MyState {
  const factory MyState.initial() = MyStateInitial;
}
```

### Real Example from Catat Cuan

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

---

## Setup

### Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  freezed_annotation: ^3.1.0

dev_dependencies:
  freezed: ^3.2.5
  build_runner: ^2.4.13
```

### Import Statements

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_file.freezed.dart';  // ← Required
```

---

## Code Generation Workflow

### Step 1: Define Freezed Class

```dart
// lib/presentation/states/my_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_state.freezed.dart';

@freezed
abstract class MyState with _$MyState {
  const factory MyState.initial() = MyStateInitial;
  const factory MyState.loading() = MyStateLoading;
  const factory MyState.data(String data) = MyStateData;
  const factory MyState.error(String message) = MyStateError;
}
```

### Step 2: Run Code Generation

```bash
# One-time build
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (recommended during development)
flutter pub run build_runner watch

# Clean build (if issues occur)
flutter pub run build_runner build --delete-conflicting-outputs --delete-conflicting-outputs
```

### Step 3: Generated File

The generator creates `my_state.freezed.dart`:

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// ...
// Generated implementation
// ...
```

### Step 4: Use in Code

```dart
void main() {
  // Create instances
  final initial = MyState.initial();
  final loading = MyState.loading();
  final data = MyState.data('Hello');
  final error = MyState.error('Something went wrong');

  // Pattern matching
  state.when(
    initial: () => print('Initial'),
    loading: () => print('Loading'),
    data: (value) => print('Data: $value'),
    error: (message) => print('Error: $message'),
  );
}
```

---

## Common Patterns

### Pattern 1: State Classes for Riverpod

```dart
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

// Usage in provider
@riverpod
class TransactionFormNotifier extends _$TransactionFormNotifier {
  @override
  TransactionFormState build() {
    return TransactionFormState.initial();
  }

  Future<void> submit() async {
    state = const TransactionFormState.loading();

    try {
      final result = await _submitForm();
      state = TransactionFormState.success(result);
    } catch (e) {
      state = TransactionFormState.error(e.toString());
    }
  }
}

// Usage in UI
class TransactionFormScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionFormNotifierProvider);

    return state.when(
      initial: (form) => _buildForm(form),
      loading: () => const AppLoadingState(),
      success: (transaction) => _buildSuccess(transaction),
      error: (message) => _buildError(message),
    );
  }
}
```

### Pattern 2: Immutable Entities

```dart
@freezed
abstract class TransactionEntity with _$TransactionEntity {
  const TransactionEntity._(); // Private constructor for custom methods

  const factory TransactionEntity({
    int? id,
    required double amount,
    required TransactionType type,
    required DateTime dateTime,
    required int categoryId,
    String? note,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _TransactionEntity;

  // Computed properties
  bool get isIncomes => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  // Custom methods
  String get formattedAmount {
    return CurrencyFormatter.format(amount, type: type);
  }

  TransactionEntity toCopyWithId(int newId) {
    return copyWith(id: newId);
  }
}

// Usage
final transaction = TransactionEntity(
  amount: 100,
  type: TransactionType.expense,
  dateTime: DateTime.now(),
  categoryId: 1,
  createdAt: DateTime.now(),
);

// Update with copyWith
final updated = transaction.copyWith(
  amount: 200,
  note: 'Updated note',
);

// Access computed properties
print(transaction.isExpense); // true
print(transaction.formattedAmount); // "-Rp100"
```

### Pattern 3: Result Type (Either Alternative)

```dart
@freezed
abstract class Result<T> with _$Result<T> {
  const factory Result.success(T data) = ResultSuccess;
  const factory Result.failure(String message) = ResultFailure;
}

// Usage
Future<Result<TransactionEntity>> addTransaction(TransactionEntity entity) async {
  try {
    final id = await _database.insert(entity);
    final result = entity.copyWith(id: id);
    return Result.success(result);
  } catch (e) {
    return Result.failure(e.toString());
  }
}

// Handle result
final result = await addTransaction(transaction);
result.when(
  success: (data) => print('Success: $data'),
  failure: (message) => print('Error: $message'),
);
```

### Pattern 4: Configuration Classes

```dart
@freezed
abstract class AppConfig with _$AppConfig {
  const factory AppConfig({
    @Default(true) bool enableAnalytics,
    @Default(false) bool isDebugMode,
    @Default(30) int sessionTimeoutMinutes,
    String? apiBaseUrl,
  }) = AppConfigData;

  // Custom validation
  static AppConfig? validate(AppConfig config) {
    if (config.sessionTimeoutMinutes < 1) {
      return null;
    }
    return config;
  }
}

// Usage
final config = AppConfig(
  enableAnalytics: true,
  isDebugMode: false,
  sessionTimeoutMinutes: 30,
);

final updated = config.copyWith(
  apiBaseUrl: 'https://api.example.com',
);
```

### Pattern 5: API Response Models

```dart
@freezed
abstract class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({
    required bool success,
    required String message,
    T? data,
    String? error,
  }) = ApiResponseData;

  factory ApiResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiResponseFromJson(json);
}

// Usage with generics
final userResponse = ApiResponse<User>(
  success: true,
  message: 'User fetched successfully',
  data: user,
);

final errorResponse = ApiResponse(
  success: false,
  message: 'Failed to fetch user',
  error: 'User not found',
);
```

---

## Union Types

### What Are Union Types?

Union types allow a class to represent different states with different data. Each state is called a "union type" or "variant".

### Example: UI State

```dart
@freezed
abstract class UiState<T> with _$UiState<T> {
  const factory UiState.initial() = UiStateInitial;
  const factory UiState.loading() = UiStateLoading;
  const factory UiState.data(T data) = UiStateData;
  const factory UiState.error(String message) = UiStateError;
}

// Usage
UiState<List<Transaction>> state = UiState.initial();

// Pattern matching
state.when(
  initial: () => print('Initial state'),
  loading: () => print('Loading...'),
  data: (transactions) => print('Loaded ${transactions.length} items'),
  error: (message) => print('Error: $message'),
);

// Type-safe access
if (state is UiStateData<List<Transaction>>) {
  final transactions = (state as UiStateData<List<Transaction>>).data;
  print('First transaction: ${transactions.first}');
}
```

### Example: AsyncValue Alternative

```dart
@freezed
abstract class AsyncData<T> with _$AsyncData<T> {
  const factory AsyncData.initial() = AsyncDataInitial;
  const factory AsyncData.loading() = AsyncDataLoading;
  const factory AsyncData.data(T value) = AsyncDataData;
  const factory AsyncData.error(Object error, StackTrace stackTrace) =
      AsyncDataError;
}

// Usage
@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  AsyncData<List<Transaction>> build() {
    return const AsyncData.initial();
  }

  Future<void> load() async {
    state = const AsyncData.loading();

    try {
      final data = await _loadData();
      state = AsyncData.data(data);
    } catch (e, st) {
      state = AsyncData.error(e, st);
    }
  }
}
```

---

## Immutable Classes

### What Are Immutable Classes?

Immutable classes cannot be modified after creation. Freezed makes this easy by generating `copyWith` methods.

### Example: Immutable Entity

```dart
@freezed
abstract class CategoryEntity with _$CategoryEntity {
  const CategoryEntity._();

  const factory CategoryEntity({
    int? id,
    required String name,
    required TransactionType type,
    required String color,
    String? icon,
    @Default(0) int sortOrder,
    @Default(true) bool isActive,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _CategoryEntity;

  // Business logic
  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  String get displayName => isActive ? name : '$name (Non-aktif)';

  // Custom method
  CategoryEntity activate() {
    return copyWith(isActive: true);
  }

  CategoryEntity deactivate() {
    return copyWith(isActive: false);
  }
}

// Usage
final category = CategoryEntity(
  name: 'Makanan',
  type: TransactionType.expense,
  color: '#FF5722',
  createdAt: DateTime.now(),
);

// Can't modify directly
// category.name = 'New Name'; // ❌ Compilation error

// Use copyWith to create new instance
final updated = category.copyWith(
  name: 'Makanan & Minuman',
); // ✅ Creates new instance

// Use custom methods
final activated = category.activate();
final deactivated = category.deactivate();
```

---

## CopyWith Pattern

### Basic CopyWith

```dart
@freezed
abstract class User with _$User {
  const factory User({
    required String name,
    required int age,
    String? email,
  }) = _User;
}

final user = User(name: 'John', age: 30);

// Copy with changes
final updated = user.copyWith(
  age: 31,
  email: 'john@example.com',
);

// Original unchanged
print(user.name); // John
print(user.age); // 30

// New instance with changes
print(updated.name); // John
print(updated.age); // 31
print(updated.email); // john@example.com
```

### Nested CopyWith

```dart
@freezed
abstract class Address with _$Address {
  const factory Address({
    required String street,
    required String city,
  }) = _Address;
}

@freezed
abstract class Person with _$Person {
  const factory Person({
    required String name,
    required Address address,
  }) = _Person;
}

final person = Person(
  name: 'John',
  address: Address(street: '123 Main St', city: 'NYC'),
);

// Update nested property
final updated = person.copyWith(
  address: address.copyWith(
    city: 'Los Angeles',
  ),
);

print(person.address.city); // NYC
print(updated.address.city); // Los Angeles
```

### Conditional CopyWith

```dart
@freezed
abstract class Transaction with _$Transaction {
  const factory Transaction({
    required double amount,
    required TransactionType type,
    String? note,
  }) = _Transaction;
}

final transaction = Transaction(
  amount: 100,
  type: TransactionType.expense,
);

// Conditional update
final updated = transaction.copyWith(
  note: transaction.note?.isNotEmpty == true ? transaction.note : 'No note',
);
```

---

## Migration from Freezed 2.x

### Key Changes

1. **abstract keyword is now required**
   ```dart
   // OLD (2.x)
   @freezed
   class MyState with _$MyState {
     const factory MyState.initial() = MyStateInitial;
   }

   // NEW (3.x)
   @freezed
   abstract class MyState with _$MyState {
     const factory MyState.initial() = MyStateInitial;
   }
   ```

2. **Builder pattern changes**
   ```dart
   // OLD (2.x)
   @FreezedUnionValue('') // No longer needed
   const factory MyState.initial() = MyStateInitial;

   // NEW (3.x)
   const factory MyState.initial() = MyStateInitial;
   ```

3. **JsonSerializable integration**
   ```dart
   // OLD (2.x)
   @freezed
   abstract class MyModel with _$MyModel {
     factory MyModel.fromJson(Map<String, dynamic> json) =>
         _$MyModelFromJson(json);
   }

   // NEW (3.x)
   @freezed
   abstract class MyModel with _$MyModel {
     const factory MyModel({}) = _MyModel;

     factory MyModel.fromJson(Map<String, dynamic> json) =>
         _$MyModelFromJson(json);
   }
   ```

### Migration Checklist

- [ ] Add `abstract` keyword to all Freezed classes
- [ ] Remove `@FreezedUnionValue` annotations (if any)
- [ ] Update constructor syntax (if using custom constructors)
- [ ] Regenerate code with `build_runner`
- [ ] Test all union type variants
- [ ] Verify `copyWith` methods work correctly

---

## Best Practices

### 1. Always Use const Factory Constructors

```dart
// ✅ GOOD
const factory MyState.initial() = MyStateInitial;
const factory MyState.loading() = MyStateLoading;

// ❌ BAD
factory MyState.initial() = MyStateInitial;
factory MyState.loading() = MyStateLoading;
```

### 2. Use Default Values for Optional Parameters

```dart
// ✅ GOOD
const factory MyState({
  @Default(0) int count,
  @Default([]) List<String> items,
  String? name,
}) = _MyState;

// ❌ BAD
const factory MyState({
  int count = 0,
  List<String> items = const [],
  String? name,
}) = _MyState;
```

### 3. Use Private Constructors for Custom Methods

```dart
@freezed
abstract class MyEntity with _$MyEntity {
  const MyEntity._(); // ← Private constructor

  const factory MyEntity({
    required String name,
  }) = _MyEntity;

  // Custom method
  String get displayName => name.toUpperCase();
}
```

### 4. Use Union Types for State Management

```dart
// ✅ GOOD - Union types for UI state
@freezed
abstract class UiState with _$UiState {
  const factory UiState.initial() = UiStateInitial;
  const factory UiState.loading() = UiStateLoading;
  const factory UiState.data(Data data) = UiStateData;
  const factory UiState.error(String message) = UiStateError;
}

// ❌ BAD - Single class with nullable properties
class UiState {
  final bool isLoading;
  final Data? data;
  final String? error;
}
```

### 5. Document Union Type Variants

```dart
/// Represents the state of a transaction form
///
/// - [TransactionFormInitial]: Initial state with form fields
/// - [TransactionFormLoading]: Form is being submitted
/// - [TransactionFormSuccess]: Transaction successfully saved
/// - [TransactionFormError]: Submission failed with error message
@freezed
abstract class TransactionFormState with _$TransactionFormState {
  const factory TransactionFormState.initial({
    @Default(TransactionType.expense) TransactionType type,
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

---

## Common Issues & Solutions

### Issue 1: "The class can't be designated as a '@freezed' class"

**Cause**: Missing `abstract` keyword

**Solution**:
```dart
// Add 'abstract' before 'class'
@freezed
abstract class MyState with _$MyState { }
```

### Issue 2: "Type 'X' has no method 'copyWith'"

**Cause**: Code not generated or not imported

**Solution**:
```bash
# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Verify import
import 'package:my_app/my_state.dart';
```

### Issue 3: "Invalid constant value"

**Cause**: Using non-const values in const constructor

**Solution**:
```dart
// ❌ BAD
const factory MyState({
  required DateTime timestamp, // DateTime is not const
}) = _MyState;

// ✅ GOOD
const factory MyState({
  DateTime? timestamp, // Make nullable
}) = _MyState;

// Or remove const
factory MyState({
  required DateTime timestamp,
}) = _MyState;
```

### Issue 4: "Default values not supported for positional parameters"

**Cause**: Using @Default with positional parameters

**Solution**:
```dart
// ❌ BAD
const factory MyState(
  [@Default(0) int count,]
) = _MyState;

// ✅ GOOD
const factory MyState({
  @Default(0) int count,
}) = _MyState;
```

---

## Advanced Features

### FromJson/ToJson with JsonSerializable

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_serializable/json_serializable.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

@freezed
abstract class TransactionModel with _$TransactionModel {
  const TransactionModel._();

  const factory TransactionModel({
    int? id,
    required double amount,
    @JsonKey(name: 'type') required String typeStr,
    @JsonKey(name: 'date_time') required String dateTimeStr,
    required int categoryId,
    String? note,
    @JsonKey(name: 'created_at') required String createdAtStr,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  // Convert to entity
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      amount: amount,
      type: typeStr == 'income' ? TransactionType.income : TransactionType.expense,
      dateTime: DateTime.parse(dateTimeStr),
      categoryId: categoryId,
      note: note,
      createdAt: DateTime.parse(createdAtStr),
    );
  }

  // Convert from entity
  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      amount: entity.amount,
      typeStr: entity.type.name,
      dateTimeStr: entity.dateTime.toIso8601String(),
      categoryId: entity.categoryId,
      note: entity.note,
      createdAtStr: entity.createdAt.toIso8601String(),
    );
  }
}
```

### Union Types with Generics

```dart
@freezed
abstract class Result<T> with _$Result<T> {
  const factory Result.success(T data) = ResultSuccess<T>;
  const factory Result.failure(Failure failure) = ResultFailure<T>;
}

// Usage
Future<Result<TransactionEntity>> addTransaction(TransactionEntity entity) async {
  try {
    final id = await _database.insert(entity);
    final result = entity.copyWith(id: id);
    return Result.success(result);
  } catch (e) {
    return Result.failure(DatabaseFailure(e.toString()));
  }
}

// Handle
final result = await addTransaction(transaction);
result.when(
  success: (data) => print('Success: $data'),
  failure: (failure) => print('Failure: ${failure.message}'),
);
```

---

## Related Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) - Clean Architecture with Freezed
- [RIVERPOD_GUIDE.md](RIVERPOD_GUIDE.md) - Riverpod 3.x patterns with Freezed
- [CODING_STANDARDS.md](CODING_STANDARDS.md) - File naming and conventions
- [AI_ASSISTANT_GUIDE.md](../AI_ASSISTANT_GUIDE.md) - Quick reference

---

## Additional Resources

- [Freezed Official Documentation](https://pub.dev/packages/freezed)
- [Freezed Annotation](https://pub.dev/packages/freezed_annotation)
- [JsonSerializable](https://pub.dev/packages/json_serializable)

---

**Last Updated**: 2026-03-27
**Freezed Version**: 3.2.5
**Critical Requirement**: `abstract` keyword required
