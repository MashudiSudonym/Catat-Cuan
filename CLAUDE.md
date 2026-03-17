# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Catat Cuan is a personal expense tracking Flutter application with OCR receipt scanning capabilities. It's a cross-platform app (Android, iOS, macOS, Linux, Windows) focused on Indonesian market localization (id_ID).

**Core value proposition**: Track unlimited personal income/expense transactions with manual entry or OCR-based receipt scanning, providing monthly insights and spending recommendations.

## Common Commands

### Development
```bash
flutter pub get              # Install dependencies
flutter run                  # Run on connected device/emulator
flutter run --debug          # Debug mode
flutter run --release        # Release mode
```

### Building
```bash
# Android
flutter build apk            # Debug APK
flutter build appbundle      # Release App Bundle (for Play Store)

# iOS
flutter build ios            # iOS build

# Other platforms
flutter build macos
flutter build linux
flutter build windows
```

### Testing
```bash
flutter test                 # Run all tests
flutter test test/widget_test.dart  # Run specific test file
```

### Code Generation
```bash
# For Riverpod code generation (if using @riverpod annotation)
flutter pub run build_runner build --delete-conflicting-outputs
flutter pub run build_runner watch  # Watch for changes
```

## Architecture

This codebase follows **Clean Architecture** with clear separation of concerns:

```
lib/
├── domain/              # Business logic (no Flutter dependencies)
│   ├── entities/        # Core business entities (Transaction, Category)
│   ├── usecases/        # Business logic operations (AddTransaction, ScanReceipt, etc.)
│   ├── repositories/    # Repository interfaces (contracts)
│   └── services/        # Domain services (InsightService)
│
├── data/                # Data layer (implementation details)
│   ├── datasources/     # Data sources (DatabaseHelper for SQLite)
│   ├── models/          # Data transfer objects, database models
│   ├── repositories/    # Repository implementations (CategoryRepositoryImpl)
│   └── services/        # Platform services (OCR, image picker, permissions)
│
└── presentation/        # UI and state management
    ├── providers/       # Riverpod StateNotifier providers
    ├── screens/         # Full-screen widgets
    ├── widgets/         # Reusable UI components
    └── utils/           # Theme, colors, helpers
```

### Dependency Flow
```
Presentation → Domain (UseCases) → Domain (Repositories) → Data (RepositoryImpl)
```

**Key principle**: Presentation layer depends on Domain interfaces, not Data implementations. Data layer implements Domain interfaces.

## State Management

Uses **Riverpod 2.6.1** with **AsyncNotifier** pattern and `@riverpod` code generation.

### Provider Registration
Providers are organized by feature in `lib/presentation/providers/`:
- `usecases/` - UseCase providers (dependency injection layer)
- `category/` - Category-related providers
- `transaction/` - Transaction-related providers
- `summary/` - Monthly summary providers
- `navigation/` - Navigation providers
- `receipt/` - Receipt/OCR providers

All providers are exported from `lib/presentation/providers/app_providers.dart` for easy importing.

### Key Providers
- `transactionListNotifierProvider` - Transaction list state (AsyncValue) - **DEPRECATED: Use transactionListPaginatedNotifierProvider**
- `transactionListPaginatedNotifierProvider` - Paginated transaction list with infinite scroll
- `transactionFormNotifierProvider` - Add/edit transaction form state
- `transactionFilterNotifierProvider` - Transaction filter criteria
- `transactionSearchNotifierProvider` - Transaction search state (AsyncValue)
- `categoryListNotifierProvider` - Active categories by type (AsyncValue)
- `categoryFormNotifierProvider` - Category form state
- `categoryManagementNotifierProvider` - Category CRUD operations with drag-drop reordering
- `monthlySummaryNotifierProvider` - Monthly insights and breakdown (AsyncValue)
- `receiptScanNotifierProvider` - OCR scanning state
- `navigationNotifierProvider` - Bottom navigation tab state
- `exportNotifierProvider` - CSV export state management

### Provider Pattern with Code Generation

**Modern AsyncNotifier Pattern (Recommended):**
```dart
// 1. Create provider with @riverpod annotation
@riverpod
class TransactionListNotifier extends _$TransactionListNotifier {
  @override
  Future<List<TransactionEntity>> build() async {
    // No constructor side effects - data loading in build()
    final getTransactionsUseCase = ref.read(getTransactionsUseCaseProvider);
    return await getTransactionsUseCase.execute();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

// 2. Run code generation
// flutter pub run build_runner build --delete-conflicting-outputs

// 3. Use in UI with AsyncValue pattern
class TransactionListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionListNotifierProvider);

    return transactionsAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
      data: (transactions) => ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) => TransactionCard(transactions[index]),
      ),
    );
  }
}
```

**StateNotifier Pattern (Legacy - for simple state):**
```dart
// For non-async state or form state
@riverpod
class TransactionFormNotifier extends _$TransactionFormNotifier {
  @override
  TransactionFormState build() {
    return TransactionFormState.initial();
  }

  void updateAmount(String value) {
    state = state.copyWith(amount: value);
  }
}

// Usage
final formState = ref.watch(transactionFormNotifierProvider);
```

### Provider Naming Conventions
- `*NotifierProvider` - The generated provider name (e.g., `transactionListNotifierProvider`)
- `*Notifier` - The notifier class (e.g., `TransactionListNotifier`)
- `AsyncValue<T>` - Return type for async providers
- State class names end with `State` (e.g., `TransactionFormState`)

### Watching Providers
```dart
// Watch for rebuilds
final state = ref.watch(myProvider);

// Read without watching (for callbacks)
final notifier = ref.read(myProvider.notifier);
notifier.someMethod();

// Watch only a value (for derived state)
final filtered = ref.watch(myProvider.select((value) => value.where(...)));

// Listen for side effects
ref.listen(myProvider, (previous, next) {
  if (next.hasError) {
    showErrorSnackBar(next.error);
  }
});
```

## Database Schema

SQLite with two main tables (see `DatabaseHelper`):

### Categories
- `id`, `name`, `type` (income/expense), `color`, `icon`
- `sort_order`, `is_active`, `created_at`, `updated_at`
- Indexed on: type, is_active

### Transactions
- `id`, `amount`, `type` (income/expense), `date_time`
- `category_id` (foreign key → categories), `note`
- `created_at`, `updated_at`
- Indexed on: date_time, category_id, type, composite (date_time+type), month+type

**Important**: Database version is tracked in `_databaseVersion`. Increment and update `_onUpgrade()` when modifying schema.

**Helper Methods:**
- `getTransactionsCount({filter})` - Get total count with optional filter
- `getTransactionsPaginated({limit, offset, filter})` - Get paginated transactions with LIMIT/OFFSET
- `searchTransactions({query, type, limit})` - Search transactions with SQL LIKE on note and category name

## Key Features & Implementation

### 1. Transaction Entry
- **Manual**: TransactionFormScreen with validation
- **OCR**: ReceiptScanScreen using Google ML Kit Text Recognition
  - `ReceiptOcrService` extracts text, finds "Total" pattern
  - `ImagePickerService` handles camera/gallery
  - `PermissionService` manages camera/storage permissions

### 2. Category Management
- Default categories seeded on first launch (via `appInitializationProvider`)
- Categories can be deactivated (not deleted) to preserve transaction history
- **Reordering via drag-and-drop**: Toggle reorder mode with FAB, drag items to reorder
  - `ReorderCategoriesUseCase` already implemented
  - UI uses `ReorderableListView.builder` with custom drag handles
- Custom icons and colors

### 3. Transaction List with Pagination
- **Infinite scroll pagination**: Loads 20 items per page automatically when scrolling
  - `transactionListPaginatedNotifierProvider` - Paginated list state provider
  - `GetTransactionsPaginatedUseCase` - Pagination with LIMIT/OFFSET queries
  - `PaginationParamsEntity` - Pagination parameters (page, limit, offset)
  - `PaginatedResultEntity` - Wrapper for paginated data with metadata
  - Automatically loads next page when 80% scrolled
  - Loading indicator shown during fetch

### 4. Transaction Search
- **Full-text search**: Search across transaction notes and category names
  - `transactionSearchNotifierProvider` - Search state provider
  - `SearchTransactionsUseCase` - SQL LIKE queries with JOIN on categories
  - `TransactionSearchBar` widget - Search bar with 500ms debouncing
  - Results shown in dedicated view with empty state
  - Clear button to reset search

### 5. CSV Export
- **Export to CSV**: Export transactions with Indonesian formatting
  - `exportNotifierProvider` - Export state management
  - `ExportTransactionsUseCase` - Export use case with filter support
  - `CsvExportServiceImpl` - CSV generation with `csv` package
  - `share_plus` integration for file sharing
  - Export options bottom sheet (all transactions or with current filter)
  - Indonesian date format (DD/MM/YYYY) and thousand separators

### 6. Monthly Summary & Insights
- `GetMonthlySummaryUseCase` - Aggregates transactions by month
- `GetCategoryBreakdownUseCase` - Spending per category
- `InsightService` - Generates recommendations based on patterns
- Charts rendered with `fl_chart`

### 7. Navigation
- Bottom navigation with 2 tabs: Transaksi (TransactionListScreen), Ringkasan (MonthlySummaryScreen)
- `IndexedStack` preserves state when switching tabs
- Routes defined as named routes for modals (transaction form, category management)

## Testing

- Unit tests: Domain layer (use cases, entities)
- Widget tests: UI components
- Integration tests: End-to-end flows
- Uses `mockito` for mocking dependencies

Run with: `flutter test`

## Localization

- Indonesian locale (id_ID) configured in `main.dart`
- Date formatting uses `intl` package with id_ID
- All UI strings are in Indonesian

## Platform-Specific Notes

### Android
- Camera and storage permissions in `android/app/src/main/AndroidManifest.xml`
- Target SDK should match current Flutter version requirements

### OCR Implementation
- Uses Google ML Kit on-device text recognition
- Processes images to extract receipt amounts
- No network call required (privacy-focused)

## Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter_riverpod: ^2.6.1      # State management
  riverpod_annotation: ^2.6.1  # Code generation
  sqflite: ^2.4.1               # Database
  path: ^1.9.0                   # Path utilities
  intl: ^0.20.1                  # Internationalization
```

### Export Dependencies (Added for CSV Export)
```yaml
dependencies:
  csv: ^6.0.0                  # CSV generation
  share_plus: ^7.2.1           # File sharing
  path_provider: ^2.1.5        # Temp directory access
```

## Important File Locations

### Core Files
- `lib/main.dart` - App entry point with ProviderScope
- `lib/presentation/providers/app_providers.dart` - All provider definitions
- `lib/presentation/utils/utils.dart` - Central export for all utilities (design system)
- `lib/presentation/widgets/base/base.dart` - Central export for base widgets
- `lib/presentation/DESIGN_SYSTEM_GUIDE.md` - Comprehensive design system documentation
- `lib/data/datasources/local/database_helper.dart` - Database schema and migrations
- `lib/domain/usecases/` - Business logic operations
- `PLANS/` - Product requirements and specifications (PRD, specs, implementation plans)

### New Feature Files (Added in Latest Update)

#### Pagination
- `lib/domain/entities/pagination_params_entity.dart` - Pagination parameters (page, limit, offset)
- `lib/domain/entities/paginated_result_entity.dart` - Paginated data wrapper with metadata
- `lib/domain/usecases/get_transactions_paginated_usecase.dart` - Pagination use case
- `lib/presentation/providers/transaction/transaction_list_paginated_provider.dart` - Paginated list provider

#### Transaction Search
- `lib/domain/usecases/search_transactions_usecase.dart` - Search use case
- `lib/presentation/providers/transaction/transaction_search_provider.dart` - Search state provider
- `lib/presentation/widgets/transaction_search_bar.dart` - Search bar widget with debouncing

#### CSV Export
- `lib/domain/services/export_service.dart` - Export service interface
- `lib/data/services/csv_export_service_impl.dart` - CSV generation implementation
- `lib/domain/usecases/export_transactions_usecase.dart` - Export use case
- `lib/presentation/providers/export/export_provider.dart` - Export state provider
- `lib/presentation/widgets/export_bottom_sheet.dart` - Export options UI

#### Category Reordering (UI Implementation)
- `lib/presentation/screens/category_management_screen.dart` - Updated with ReorderableListView
- `lib/presentation/widgets/category_list_item.dart` - Added reorderIndex parameter

## Design System

This project uses a comprehensive design system to ensure UI consistency and maintainability. All spacing, sizing, and styling should use the provided utilities.

### Responsive Utilities

Import all design system utilities:
```dart
import 'package:catat_cuan/presentation/utils/utils.dart';
```

#### Spacing (AppSpacing)
Based on 4px grid system. Always use these constants instead of hardcoded values.

```dart
// Spacing scale
AppSpacing.xs   // 4px
AppSpacing.sm   // 8px
AppSpacing.md   // 12px
AppSpacing.lg   // 16px
AppSpacing.xl   // 20px
AppSpacing.xxl  // 24px
AppSpacing.xxxl // 32px

// Usage examples
padding: AppSpacing.all(AppSpacing.lg)              // 16px all
padding: AppSpacing.horizontal(AppSpacing.md)       // 12px horizontal
padding: AppSpacing.lgAll                           // Preset: 16px all

// As a widget
Column(
  children: [
    Text('Hello'),
    const AppSpacingWidget.verticalMD(),  // 12px vertical space
    Text('World'),
  ],
)
```

#### Border Radius (AppRadius)
Consistent border radius matching the spacing system.

```dart
// Radius scale
AppRadius.xs    // 4px
AppRadius.sm    // 8px
AppRadius.md    // 12px
AppRadius.lg    // 16px
AppRadius.xl    // 20px
AppRadius.xxl   // 24px
AppRadius.circle // 999px (fully rounded)

// Usage
borderRadius: AppRadius.mdAll                      // 12px all corners
shape: AppBorderRadius.mdShape                     // RoundedRectangleBorder with 12px
```

#### Responsive Design (ScreenSize)
Utilities for building responsive layouts.

```dart
// Check screen size
if (ScreenSize.isMobile(context)) { /* mobile layout */ }
if (ScreenSize.isDesktop(context)) { /* desktop layout */ }

// Get responsive value
final columns = ScreenSize.getValue(
  context: context,
  small: 1,
  medium: 2,
  large: 3,
);

// Responsive builder widget
ResponsiveBuilder(
  small: (context, constraints) => MobileLayout(),
  medium: (context, constraints) => TabletLayout(),
  large: (context, constraints) => DesktopLayout(),
)
```

### Formatters

#### Date Formatting (AppDateFormatter)
Centralized date formatting with Indonesian locale.

```dart
// Format dates
AppDateFormatter.formatDayMonthYearDate(date)     // "13 Jan 2024"
AppDateFormatter.formatDayMonthDate(date)          // "13 Jan"
AppDateFormatter.formatMonthYearDate(date)         // "Januari 2024"
AppDateFormatter.formatRelativeDate(date)          // "Hari ini", "Kemarin", etc.
AppDateFormatter.formatRelativeDateTime(date)      // "Hari ini, 14:30"

// Date utilities
AppDateFormatter.isToday(date)
AppDateFormatter.startOfMonth(date)
AppDateFormatter.endOfMonth(date)
```

#### Currency Formatting
Existing currency formatter for Indonesian Rupiah.

```dart
final amount = 1000000;
amount.toRupiah()               // "1.000.000" (without prefix)
amount.toRupiahWithoutPrefix()  // "1.000.000"
```

### Base Widgets

Import all base widgets:
```dart
import 'package:catat_cuan/presentation/widgets/base/base.dart';
```

#### AppContainer
Consistent container with preset styles.

```dart
// Card style
AppContainer.card(child: Text('Content'))

// Bordered
AppContainer.bordered(child: Text('Content'))

// Rounded
AppContainer.rounded(child: Text('Content'))

// Pill-shaped
AppContainer.pill(child: Text('Chip'))
```

#### AppEmptyState
Unified empty state for consistent "no data" screens.

```dart
// Custom empty state
AppEmptyState(
  icon: Icons.receipt_long,
  title: 'Belum ada transaksi',
  subtitle: 'Mulai lacak pengeluaran dan pemasukan Anda',
  actionLabel: 'Tambah Transaksi',
  onAction: () => Navigator.push(...),
)

// Pre-configured states
AppEmptyStates.transactions(onAdd: () => showAdd())
AppEmptyStates.categories(onAdd: () => showAdd())
AppEmptyStates.noResults(onClear: () => clearFilters())
```

#### AppErrorState
Unified error and loading states.

```dart
// Custom error state
AppErrorState(
  title: 'Terjadi kesalahan',
  subtitle: 'Gagal memuat data',
  onRetry: () => reload(),
)

// Pre-configured states
AppErrorStates.generic(message: 'Error', onRetry: () => retry())
AppErrorStates.network(onRetry: () => reload())
AppErrorStates.permission(permission: 'kamera', onOpenSettings: () => openSettings())

// Loading state
AppLoadingState(message: 'Memuat data...')
```

### Screen Mixins

#### ScreenStateMixin
Mixin providing common screen behaviors for StatefulWidget.

```dart
import 'package:catat_cuan/presentation/utils/mixins/screen_mixin.dart';

class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> with ScreenStateMixin {
  void _handleSuccess() {
    showSuccessSnackBar('Data berhasil disimpan');
  }

  void _handleError() {
    showErrorSnackBar('Gagal menyimpan data');
  }

  Future<void> _handleDelete() async {
    final confirmed = await showConfirmDialog(
      title: 'Hapus Data',
      content: 'Apakah Anda yakin?',
      isDestructive: true,
    );

    if (confirmed == true) {
      // Delete logic
    }
  }
}
```

Available methods:
- `showSuccessSnackBar(message)` - Show success snackbar
- `showErrorSnackBar(message)` - Show error snackbar
- `showInfoSnackBar(message)` - Show info snackbar
- `showWarningSnackBar(message)` - Show warning snackbar
- `showConfirmDialog(...)` - Show confirmation dialog
- `showErrorDialog(...)` - Show error dialog
- `showSuccessDialog(...)` - Show success dialog
- `showLoadingDialog(...)` - Show loading dialog
- `dismissDialog()` - Dismiss current dialog
- `showBottomSheet(...)` - Show modal bottom sheet
- `unfocusKeyboard()` - Unfocus keyboard
- Navigation helpers: `pushRoute`, `popRoute`, etc.

For ConsumerStatefulWidget (Riverpod), use `ConsumerScreenStateMixin` instead.

### Design System Rules

1. **No hardcoded spacing**: Always use `AppSpacing` constants
2. **No hardcoded border radius**: Always use `AppRadius` constants
3. **Use base widgets**: Prefer `AppContainer`, `AppEmptyState`, `AppErrorState` over custom implementations
4. **Centralized formatting**: Use `AppDateFormatter` for all date formatting
5. **Responsive by default**: Consider different screen sizes when building layouts
6. **Use mixins**: Apply screen mixins for common behaviors

See `lib/presentation/DESIGN_SYSTEM_GUIDE.md` for comprehensive usage examples and documentation.

## Glassmorphism Design System

This project uses glassmorphism (frosted glass) UI design throughout the application. All UI components should use glass effects while maintaining the orange color scheme.

### Glass Container Usage

Always use `AppGlassContainer` for glassmorphism effects:

```dart
import 'package:catat_cuan/presentation/widgets/base/base.dart';

// Glass card for transaction/summary cards
AppGlassContainer.glassCard(
  child: Text('Content'),
)

// Glass surface for forms, dialogs, sheets
AppGlassContainer.glassSurface(
  child: Form(...),
)

// Glass pill for chips, tags, category indicators
AppGlassContainer.glassPill(
  child: Text('Chip'),
)

// Glass navigation for bars
AppGlassContainer.glassNavigation(
  child: BottomNavigationBar(...),
)

// Subtle glass for minimal blur effect
AppGlassContainer.subtle(
  child: Text('Content'),
)
```

### Glassmorphism Rules

1. **Always use glass containers** - Use AppGlassContainer variants instead of Card or Container for all visible UI elements
2. **Preserve color scheme** - Use existing colors with alpha for glass effects
3. **Consistent blur intensity** - Use predefined GlassBlur values
4. **Proper transparency** - Use predefined GlassAlpha values
5. **Subtle borders** - GlassBorder constants for border styling
6. **Performance aware** - Don't nest glass containers excessively (max 2 levels deep)

### Glass Effect Variants

| Variant | Blur | Alpha | Use Case |
|---------|------|-------|----------|
| glassCard | 12px | 0.85 | Transaction cards, summary cards |
| glassSurface | 20px | 0.95 | Forms, dialogs, bottom sheets |
| glassPill | 4px | 0.70 | Chips, tags, category indicators |
| glassNavigation | 30px | 0.90 | Bottom bar, app bar |
| subtle | 2px | 0.50 | Minimal backgrounds |
| glassOverlay | 30px | 0.90 | Bottom sheets, overlays |

### Glass Utilities

Import glassmorphism utilities:
```dart
import 'package:catat_cuan/presentation/utils/utils.dart';
```

Available utilities:
- `GlassBlur` - Blur intensity scale (xs: 2, sm: 4, md: 8, lg: 12, xl: 20, xxl: 30)
- `GlassAlpha` - Transparency levels (high: 0.95, medium: 0.85, low: 0.70, minimal: 0.50)
- `GlassBorder` - Border styling (width: 1.5, alpha: 0.15)
- `GlassVariant` - Enum with predefined glass types
- `GlassDecoration` - Factory methods for glass decorations
- `GlassImageFilter` - ImageFilter factory for blur effects

### Glass Colors

Get glass colors with transparency:
```dart
import 'package:catat_cuan/presentation/utils/app_colors.dart';

AppColors.getGlassSurface(isDark: false, alpha: 0.95)
AppColors.getGlassCard(isDark: false, alpha: 0.85)
AppColors.getGlassPill(isDark: false, alpha: 0.70)
AppColors.getGlassNavigation(isDark: false, alpha: 0.90)
AppColors.getGlassOverlay(isDark: false, alpha: 0.90)
AppColors.getGlassBorder(isDark: false)
AppColors.getGlassShadow(alpha: 0.1)
```

### Direct BackdropFilter

For custom glass effects, use the extension:
```dart
import 'package:catat_cuan/presentation/utils/glassmorphism/app_glassmorphism.dart';

Container(
  decoration: BoxDecoration(
    color: AppColors.getGlassCard(isDark: false, alpha: 0.85),
    borderRadius: AppRadius.mdAll,
    border: Border.all(
      color: AppColors.getGlassBorder(isDark: false).withOpacity(GlassBorder.alpha),
      width: GlassBorder.width,
    ),
  ),
).withGlassBlur(
  blur: GlassBlur.lg,
  borderRadius: AppRadius.mdAll,
)
```

See `lib/presentation/utils/glassmorphism/app_glassmorphism.dart` for complete glassmorphism utilities.

## Development Guidelines

1. **Adding a new feature**:
   - Create entity in `domain/entities/`
   - Create repository interface in `domain/repositories/`
   - Implement repository in `data/repositories/`
   - Create use case in `domain/usecases/`
   - Create AsyncNotifier provider with `@riverpod` annotation in `presentation/providers/`
   - Run `flutter pub run build_runner build --delete-conflicting-outputs`
   - Build UI with AsyncValue pattern in `presentation/screens/` or `presentation/widgets/`
   - **Use design system utilities** for all spacing, sizing, and styling

2. **UI Development**:
   - **Always use `AppSpacing` constants** instead of hardcoded values (e.g., `AppSpacing.lg` instead of `16.0`)
   - **Always use `AppRadius` constants** instead of hardcoded border radius (e.g., `AppRadius.md` instead of `12.0`)
   - **Use glassmorphism containers** - Prefer `AppGlassContainer` variants (glassCard, glassSurface, glassPill) over Card or Container
   - **Use base widgets** (`AppContainer`, `AppEmptyState`, `AppErrorState`) for consistency
   - **Use `AppDateFormatter`** for all date formatting
   - **Apply screen mixins** (`ScreenStateMixin` or `ConsumerScreenStateMixin`) for common behaviors
   - **Build responsive layouts** using `ScreenSize` utilities and `ResponsiveBuilder`
   - **Never hardcode dimensions** - use `AppDimensions` constants

3. **Database migrations**:
   - Increment `_databaseVersion` in `DatabaseHelper`
   - Implement migration logic in `_onUpgrade()`

4. **State management**:
   - Use `@riverpod` annotation with `AsyncNotifier` for async data
   - Use `AsyncValue.when()` for handling loading, error, and data states
   - Keep state immutable (create new instances on changes)
   - Avoid constructor side effects - use `build()` method for initialization
   - Use `ref.invalidateSelf()` for refresh operations
   - Export state classes from their respective provider files for UI imports

5. **Code generation workflow**:
   ```bash
   # One-time generation
   flutter pub run build_runner build --delete-conflicting-outputs

   # Watch mode for development
   flutter pub run build_runner watch
   ```

## Code Quality Guidelines

### SOLID Principles

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

### SOLID Benefits

When all SOLID principles are applied together:

- **Maintainable**: Changes are isolated and don't cascade
- **Testable**: Dependencies can be mocked easily
- **Flexible**: New features can be added without modifying existing code
- **Scalable**: Codebase can grow without becoming unmanageable
- **Reusable**: Small, focused components are easier to reuse

**References:**
- [Clean Code TypeScript - SOLID](https://github.com/labs42io/clean-code-typescript)

## Related Documentation

- `PLANS/PRD.md` - Product Requirements Document
- `PLANS/SPEC-LOG-*.md` - Feature specifications
- `PLANS/PLAN-LOG-*.md` - Implementation plans
