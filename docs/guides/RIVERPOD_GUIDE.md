# Riverpod 3.x Guide - Catat Cuan

**Last Updated**: 2026-03-27
**Project**: Catat Cuan (Flutter Expense Tracking App)
**Riverpod Version**: 3.3.1
**Annotation Package**: riverpod_annotation 4.0.2
**Code Generator**: riverpod_generator 4.0.3

---

## Table of Contents
1. [Setup](#setup)
2. [@riverpod Annotation Pattern](#riverpod-annotation-pattern)
3. [Code Generation Workflow](#code-generation-workflow)
4. [Provider Types](#provider-types)
5. [Provider Organization](#provider-organization)
6. [Best Practices](#best-practices)
7. [Common Patterns](#common-patterns)
8. [Testing with Riverpod](#testing-with-riverpod)

---

## Setup

### Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter_riverpod: ^3.3.1
  riverpod_annotation: ^4.0.2

dev_dependencies:
  build_runner: ^2.4.13
  riverpod_generator: ^4.0.3
```

### Main.dart Configuration

```dart
// lib/main.dart
void main() {
  runApp(
    const ProviderScope(
      child: AppWidget(),
    ),
  );
}
```

---

## @riverpod Annotation Pattern

Riverpod 3.x uses code generation with the `@riverpod` annotation. This is the **primary pattern** used in Catat Cuan.

### Critical Rule: Initialize in build(), NOT Constructor

⚠️ **CRITICAL**: Never initialize state or read providers in the constructor. Always use the `build()` method.

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

  Future<void> _loadTransactions() async {
    // This will fail because providers aren't ready
    final useCase = ref.read(getTransactionsUseCaseProvider);
  }
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
    // Invalidate to trigger rebuild
    ref.invalidateSelf();
  }
}
```

### Basic AsyncNotifier Pattern

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_provider.g.dart';

@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  Future<DataType> build() async {
    // Initialize here - providers are available
    final useCase = ref.read(myUseCaseProvider);
    return await useCase.execute();
  }

  Future<void> performAction() async {
    // Set loading state
    state = const AsyncValue.loading();

    // Execute and handle result
    state = await AsyncValue.guard(() async {
      final result = await someAsyncOperation();
      return result;
    });
  }

  Future<void> refresh() async {
    // Invalidate to trigger rebuild
    ref.invalidateSelf();
  }
}
```

### Basic Notifier Pattern (Synchronous)

```dart
@riverpod
class MySyncNotifier extends _$MySyncNotifier {
  @override
  DataType build() {
    // Return initial state
    return DataType.initial();
  }

  void updateValue(DataType newValue) {
    // Update state
    state = newValue;
  }

  void reset() {
    // Reset to initial
    state = DataType.initial();
  }
}
```

---

## Code Generation Workflow

### Step 1: Create Provider with Annotation

```dart
// lib/presentation/providers/transaction/transaction_form_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_form_provider.g.dart'; // ← Required

@riverpod // ← Annotation
class TransactionFormNotifier extends _$TransactionFormNotifier {
  @override
  TransactionFormState build() {
    return TransactionFormState.initial();
  }
}
```

### Step 2: Run Code Generation

```bash
# One-time build
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (recommended during development)
flutter pub run build_runner watch
```

### Step 3: Generated File

The generator creates `transaction_form_provider.g.dart`:

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// Provider for TransactionFormNotifier
typedef TransactionFormNotifierRef = AutoDisposeNotifierProviderRef<TransactionFormNotifier>;
typedef TransactionFormNotifierNotifier = AutoDisposeNotifier<TransactionFormState>;

@$Riverpod(
  <TransactionFormState>[TransactionFormNotifier],
)
final transactionFormNotifierProvider =
    AutoDisposeNotifierProvider<TransactionFormNotifier, TransactionFormState>.internal(
  TransactionFormNotifier.new,
  name: r'transactionFormNotifierProvider',
  debugGetCreateStateHash: (ref) => TransactionFormNotifier,
);

// Extension for accessing the provider
extension TransactionFormNotifierRef$ on TransactionFormNotifierRef {}

// More generated code...
```

### Step 4: Use in UI

```dart
class TransactionFormScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider
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

---

## Provider Types

### 1. AsyncNotifier (Async Data)

For asynchronous state with loading/error/data states:

```dart
@riverpod
class TransactionListNotifier extends _$TransactionListNotifier {
  @override
  Future<List<TransactionEntity>> build() async {
    final useCase = ref.read(getTransactionsUseCaseProvider);
    return await useCase.execute();
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull ?? [];
    state = const AsyncValue.loading();

    final more = await ref.read(getTransactionsPaginatedUseCaseProvider).execute(
          PaginatedParams(offset: current.length),
        );

    more.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (newItems) => state = AsyncValue.data([...current, ...newItems]),
    );
  }
}
```

### 2. Notifier (Sync Data)

For simple synchronous state:

```dart
@riverpod
class FilterNotifier extends _$FilterNotifier {
  @override
  TransactionFilterState build() {
    return TransactionFilterState.initial();
  }

  void setType(TransactionType? type) {
    state = state.copyWith(type: type);
  }

  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(startDate: start, endDate: end);
  }

  void reset() {
    state = TransactionFilterState.initial();
  }
}
```

### 3. Provider (Computed Values)

For derived/computed values:

```dart
@riverpod
List<TransactionEntity> filteredTransactions(FilteredTransactionsRef ref) {
  final all = ref.watch(transactionListProvider);
  final filter = ref.watch(transactionFilterProvider);

  return all.where((t) {
    if (filter.type != null && t.type != filter.type) return false;
    if (filter.startDate != null && t.dateTime.isBefore(filter.startDate!)) return false;
    if (filter.endDate != null && t.dateTime.isAfter(filter.endDate!)) return false;
    return true;
  }).toList();
}
```

### 4. FutureProvider (One-shot Async)

For one-time asynchronous operations:

```dart
@riverpod
Future<AppInitializationData> appInitialization(AppInitializationRef ref) async {
  final onboardingRepo = ref.read(onboardingRepositoryProvider);
  final isOnboarded = await onboardingRepo.isOnboarded();

  final categoryRepo = ref.read(categorySeedingRepositoryProvider);
  await categoryRepo.seedDefaultCategories();

  return AppInitializationData(isOnboarded: isOnboarded);
}
```

---

## Provider Organization

### Directory Structure

```
lib/presentation/providers/
├── app_providers.dart                    # Central export file
├── repository_providers.dart             # Repository DI
├── usecases/                             # UseCase providers
│   ├── transaction_usecase_providers.dart
│   └── category_usecase_providers.dart
├── services/                             # Service providers
│   └── service_providers.dart
├── transaction/                          # Transaction feature
│   ├── transaction_list_provider.dart
│   ├── transaction_form_provider.dart
│   ├── transaction_filter_provider.dart
│   ├── transaction_search_provider.dart
│   ├── transaction_list_paginated_provider.dart
│   └── transaction_selection_provider.dart
├── category/                             # Category feature
│   ├── category_list_provider.dart
│   ├── category_form_provider.dart
│   └── category_management_provider.dart
├── summary/                              # Summary feature
│   └── monthly_summary_provider.dart
├── currency/                             # Currency settings
│   └── currency_provider.dart
├── onboarding/                           # Onboarding
│   └── onboarding_provider.dart
└── cache/                                # App initialization cache
    └── cache_provider.dart
```

### Central Export File

```dart
// lib/presentation/providers/app_providers.dart

// ============================================================================
// Core Dependencies
// ============================================================================

// App widgets
export 'package:catat_cuan/presentation/app/app_widget.dart';

// Repository providers
export 'repositories/repository_providers.dart';

// Use case providers
export 'usecases/transaction_usecase_providers.dart';
export 'usecases/category_usecase_providers.dart';

// Service providers
export 'services/service_providers.dart';

// ============================================================================
// Feature Providers
// ============================================================================

// Navigation
export 'navigation/navigation_provider.dart';

// Transaction providers
export 'transaction/transaction_filter_provider.dart';
export 'transaction/transaction_list_provider.dart';
export 'transaction/transaction_form_provider.dart';
export 'transaction/transaction_search_provider.dart';
export 'transaction/transaction_list_paginated_provider.dart';
export 'transaction/transaction_selection_provider.dart';

// Category providers
export 'category/category_list_provider.dart';
export 'category/category_form_provider.dart';
export 'category/category_management_provider.dart';

// Summary providers
export 'summary/monthly_summary_provider.dart';

// Settings providers
export 'currency/currency_provider.dart';
export 'onboarding/onboarding_provider.dart';
```

### Repository Providers

```dart
// lib/presentation/providers/repositories/repository_providers.dart

// Data sources
@riverpod
DatabaseHelper databaseHelper(DatabaseHelperRef ref) {
  return DatabaseHelper();
}

// Category repositories
@riverpod
CategoryReadRepository categoryReadRepository(CategoryReadRepositoryRef ref) {
  return CategoryReadRepositoryImpl(ref.read(databaseHelperProvider));
}

@riverpod
CategoryWriteRepository categoryWriteRepository(CategoryWriteRepositoryRef ref) {
  return CategoryWriteRepositoryImpl(ref.read(databaseHelperProvider));
}

@riverpod
CategoryManagementRepository categoryManagementRepository(
  CategoryManagementRepositoryRef ref,
) {
  return CategoryManagementRepositoryImpl(ref.read(databaseHelperProvider));
}

@riverpod
CategorySeedingRepository categorySeedingRepository(CategorySeedingRepositoryRef ref) {
  return CategorySeedingRepositoryImpl(ref.read(databaseHelperProvider));
}

// Transaction repositories
@riverpod
TransactionReadRepository transactionReadRepository(TransactionReadRepositoryRef ref) {
  return TransactionReadRepositoryImpl(ref.read(databaseHelperProvider));
}

@riverpod
TransactionWriteRepository transactionWriteRepository(
  TransactionWriteRepositoryRef ref,
) {
  return TransactionWriteRepositoryImpl(ref.read(databaseHelperProvider));
}

// ... more transaction repositories
```

### UseCase Providers

```dart
// lib/presentation/providers/usecases/transaction_usecase_providers.dart

// Add
@riverpod
AddTransactionUseCase addTransactionUseCase(AddTransactionUseCaseRef ref) {
  return AddTransactionUseCase(ref.read(transactionWriteRepositoryProvider));
}

// Update
@riverpod
UpdateTransactionUseCase updateTransactionUseCase(UpdateTransactionUseCaseRef ref) {
  return UpdateTransactionUseCase(ref.read(transactionWriteRepositoryProvider));
}

// Delete
@riverpod
DeleteTransactionUseCase deleteTransactionUseCase(DeleteTransactionUseCaseRef ref) {
  return DeleteTransactionUseCase(ref.read(transactionDeleteRepositoryProvider));
}

// Get
@riverpod
GetTransactionsUseCase getTransactionsUseCase(GetTransactionsUseCaseRef ref) {
  return GetTransactionsUseCase(ref.read(transactionReadRepositoryProvider));
}

// ... more use cases
```

---

## Best Practices

### 1. Always Use @riverpod Annotation

```dart
// ✅ GOOD - With annotation
@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  Future build() async => [];
}

// ❌ BAD - Manual definition (deprecated)
final myProvider = FutureProvider<List<Transaction>>((ref) async {
  return [];
});
```

### 2. Initialize in build() Method

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
    // Don't initialize here!
  }

  @override
  Future build() async => [];
}
```

### 3. Use AsyncValue.guard for Error Handling

```dart
// ✅ GOOD
Future<void> submit() async {
  state = const AsyncValue.loading();
  state = await AsyncValue.guard(() async {
    return await _performSubmission();
  });
}

// ❌ BAD
Future<void> submit() async {
  state = const AsyncValue.loading();
  try {
    final result = await _performSubmission();
    state = AsyncValue.data(result);
  } catch (e, st) {
    state = AsyncValue.error(e, st);
  }
}
```

### 4. Use ref.read for Callbacks

```dart
// ✅ GOOD
void onSubmit() {
  ref.read(transactionFormNotifierProvider.notifier).submit();
}

// ❌ BAD
void onSubmit() {
  // Don't use ref.watch in callbacks!
  final notifier = ref.watch(transactionFormNotifierProvider.notifier);
  notifier.submit();
}
```

### 5. Use ref.listen for Side Effects

```dart
// ✅ GOOD
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
  return _buildUI(state);
}
```

### 6. Use Select for Derived State

```dart
// ✅ GOOD - Only rebuild when totalCount changes
final totalCount = ref.watch(
  transactionListProvider.select((value) => value.value?.length ?? 0),
);

// ❌ BAD - Rebuilds on any change
final transactions = ref.watch(transactionListProvider);
final totalCount = transactions.value?.length ?? 0;
```

---

## Common Patterns

### Pattern 1: Form with Validation

```dart
@riverpod
class TransactionFormNotifier extends _$TransactionFormNotifier {
  final TransactionFormValidator _validator = const TransactionFormValidator();

  @override
  TransactionFormState build() {
    return TransactionFormState.initial();
  }

  void setNominal(double value) {
    final errors = Map<String, String>.from(state.validationErrors);
    final error = _validator.validateNominal(value);

    if (error != null) {
      errors['nominal'] = error;
    } else {
      errors.remove('nominal');
    }

    state = state.copyWith(
      nominal: value,
      validationErrors: errors,
    );
  }

  Future<void> submit() async {
    // Validate all fields
    final errors = _validator.validateAll(state);
    if (errors.isNotEmpty) {
      state = state.copyWith(validationErrors: errors);
      return;
    }

    // Submit
    state = const TransactionFormState.loading();
    final controller = _getSubmissionController();
    final result = await controller.submit(formState: state);

    result.fold(
      (failure) => state = TransactionFormState.error(failure.message),
      (success) => state = TransactionFormState.success(success),
    );
  }
}
```

### Pattern 2: Infinite Scroll (Pagination)

```dart
@riverpod
class TransactionListPaginatedNotifier extends _$TransactionListPaginatedNotifier {
  static const _pageSize = 20;

  @override
  Future<PaginatedResult<TransactionEntity>> build() async {
    return await _loadPage(offset: 0);
  }

  Future<PaginatedResult<TransactionEntity>> _loadPage({required int offset}) async {
    final useCase = ref.read(getTransactionsPaginatedUseCaseProvider);
    final result = await useCase.execute(
      PaginatedParams(limit: _pageSize, offset: offset),
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (data) => data,
    );
  }

  Future<void> loadNextPage() async {
    final current = state.valueOrNull;
    if (current == null || current.hasMore == false) return;

    state = const AsyncValue.loading();

    final next = await _loadPage(offset: current.items.length);

    state = AsyncValue.data(PaginatedResult(
      items: [...current.items, ...next.items],
      hasMore: next.hasMore,
    ));
  }
}
```

### Pattern 3: Multi-Select

```dart
@riverpod
class TransactionSelectionNotifier extends _$TransactionSelectionNotifier {
  @override
  TransactionSelectionState build() {
    return TransactionSelectionState.initial();
  }

  void toggleSelection(int transactionId) {
    final selected = Set<int>.from(state.selectedIds);

    if (selected.contains(transactionId)) {
      selected.remove(transactionId);
    } else {
      selected.add(transactionId);
    }

    state = state.copyWith(selectedIds: selected);
  }

  void selectAll(List<int> allIds) {
    state = state.copyWith(selectedIds: Set.from(allIds));
  }

  void deselectAll() {
    state = state.copyWith(selectedIds: {});
  }

  Future<void> deleteSelected() async {
    if (state.selectedIds.isEmpty) return;

    final deleteRepo = ref.read(transactionDeleteRepositoryProvider);

    for (final id in state.selectedIds) {
      await deleteRepo.deleteTransaction(id);
    }

    deselectAll();
    ref.invalidate(transactionListProvider);
  }
}
```

### Pattern 4: Search with Debounce

```dart
@riverpod
class TransactionSearchNotifier extends _$TransactionSearchNotifier {
  Timer? _debounceTimer;

  @override
  TransactionSearchState build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });

    return TransactionSearchState.initial();
  }

  void onQueryChanged(String query) {
    state = state.copyWith(query: query);

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      state = TransactionSearchState.initial();
      return;
    }

    state = state.copyWith(isSearching: true);

    final searchRepo = ref.read(transactionSearchRepositoryProvider);
    final result = await searchRepo.searchTransactions(query);

    result.fold(
      (failure) => state = state.copyWith(
        isSearching: false,
        errorMessage: failure.message,
      ),
      (results) => state = state.copyWith(
        isSearching: false,
        results: results,
      ),
    );
  }

  void clear() {
    state = TransactionSearchState.initial();
    _debounceTimer?.cancel();
  }
}
```

### Pattern 5: Dependent Providers

```dart
// Provider that depends on another provider's value
@riverpod
List<TransactionEntity> filteredTransactions(FilteredTransactionsRef ref) {
  // Watch filter state
  final filter = ref.watch(transactionFilterProvider);

  // Watch all transactions
  final allAsync = ref.watch(transactionListProvider);

  // Transform based on filter
  return allAsync.when(
    loading: () => [],
    error: (_, __) => [],
    data: (transactions) {
      return transactions.where((t) {
        if (filter.type != null && t.type != filter.type) return false;
        if (filter.startDate != null && t.dateTime.isBefore(filter.startDate!)) {
          return false;
        }
        if (filter.endDate != null && t.dateTime.isAfter(filter.endDate!)) {
          return false;
        }
        return true;
      }).toList();
    },
  );
}
```

---

## Testing with Riverpod

### Unit Test for Provider

```dart
// test/presentation/providers/transaction_form_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    // Create container with mocked dependencies
    container = ProviderContainer(
      overrides: [
        addTransactionUseCaseProvider.overrideWithValue(mockAddUseCase),
        updateTransactionUseCaseProvider.overrideWithValue(mockUpdateUseCase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('should validate nominal field', () {
    // Arrange
    final notifier = container.read(transactionFormNotifierProvider.notifier);

    // Act
    notifier.setNominal(-100);

    // Assert
    final state = container.read(transactionFormNotifierProvider);
    expect(state.validationErrors['nominal'], isNotNull);
    expect(state.validationErrors['nominal'], contains('lebih dari 0'));
  });

  test('should submit transaction successfully', () async {
    // Arrange
    final notifier = container.read(transactionFormNotifierProvider.notifier);
    final transaction = TransactionEntity(/* ... */);

    when(mockAddUseCase.execute(any))
        .thenAnswer((_) async => Right(transaction));

    // Act
    await notifier.submit();

    // Assert
    final state = container.read(transactionFormNotifierProvider);
    expect(state, isA<TransactionFormSuccess>());
    verify(mockAddUseCase.execute(any)).called(1);
  });
}
```

### Widget Test with Provider

```dart
// test/presentation/screens/transaction_form_screen_test.dart
void main() {
  testWidgets('should display validation error', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionFormNotifierProvider.overrideWith(TransactionFormNotifier.new),
        ],
        child: const MaterialApp(home: TransactionFormScreen()),
      ),
    );

    // Find nominal field
    final nominalField = find.byKey(const Key('nominal_field'));

    // Enter invalid value
    await tester.enterText(nominalField, '-100');
    await tester.pump();

    // Verify error message
    expect(find.text('Nominal harus lebih dari 0'), findsOneWidget);
  });
}
```

---

## Riverpod Modifiers

### AutoDispose (Automatic Cleanup)

```dart
// Provider is automatically disposed when no longer watched
@riverpod
class TemporalNotifier extends _$TemporalNotifier {
  @override
  Future build() async {
    return await _loadData();
  }
}

// Generated provider is auto-disposed
// Good for: temporary state, form data, etc.
```

### Family (Parameterized Providers)

```dart
// Provider with parameter
@riverpod
Future<List<Transaction>> transactionsByDate(
  TransactionsByDateRef ref, {
  required DateTime date,
}) async {
  final repo = ref.read(transactionQueryRepositoryProvider);
  return await repo.getTransactionsByDate(date);
}

// Usage
final state = ref.watch(transactionsByDateProvider(date: DateTime.now()));
```

### Keep Alive (Prevent Disposal)

```dart
@Riverpod(keepAlive: true)
class PersistentNotifier extends _$PersistentNotifier {
  @override
  Value build() {
    return Value();
  }
}

// Provider stays alive even when not watched
// Good for: caches, user sessions, etc.
```

---

## Migration from Riverpod 2.x

### Key Changes

1. **No more manual provider definitions**
   ```dart
   // OLD (2.x)
   final myProvider = StateNotifierProvider<MyNotifier, MyState>((ref) {
     return MyNotifier();
   });

   // NEW (3.x)
   @riverpod
   class MyNotifier extends _$MyNotifier {
     @override
     MyState build() => MyState.initial();
   }
   ```

2. **Constructor initialization replaced by build()**
   ```dart
   // OLD (2.x)
   class MyNotifier extends StateNotifier<MyState> {
     MyNotifier(this.ref) : super(MyState.initial()) {
       _loadData();
     }
   }

   // NEW (3.x)
   @riverpod
   class MyNotifier extends _$MyNotifier {
     @override
     MyState build() {
       _loadData(); // ← Initialize here
       return MyState.initial();
     }
   }
   ```

3. **Code generation required**
   ```bash
   # Run after creating/modifying providers
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

---

## Common Issues & Solutions

### Issue 1: "Provider not found"

**Cause**: Provider not generated or not imported

**Solution**:
```bash
# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Verify import
import 'package:catat_cuan/presentation/providers/my_feature/my_provider.dart';
```

### Issue 2: "setState() called after dispose"

**Cause**: Modifying state after widget unmount

**Solution**:
```dart
Future<void> someAsyncOperation() async {
  if (!mounted) return; // ← Check mounted

  state = const AsyncValue.loading();
  // ...
}
```

### Issue 3: Provider not updating

**Cause**: Not using ref.watch or ref.listen

**Solution**:
```dart
// ✅ GOOD - Watch for changes
final state = ref.watch(myProvider);

// ❌ BAD - Read once, no updates
final state = ref.read(myProvider);
```

---

## Related Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) - Clean Architecture with Riverpod
- [FREEZED_GUIDE.md](FREEZED_GUIDE.md) - Freezed for state classes
- [CODING_STANDARDS.md](CODING_STANDARDS.md) - File naming and conventions
- [AI_ASSISTANT_GUIDE.md](../AI_ASSISTANT_GUIDE.md) - Quick reference

---

## Additional Resources

- [Riverpod Official Documentation](https://riverpod.dev/)
- [Riverpod 3.0 Migration Guide](https://riverpod.dev/docs/concepts/modifiers/family)
- [Riverpod Code Generation](https://riverpod.dev/docs/concepts/code_generation)

---

**Last Updated**: 2026-03-27
**Riverpod Version**: 3.3.1
**Pattern**: @riverpod annotation with code generation
