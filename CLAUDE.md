# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Catat Cuan is a personal expense tracking Flutter application with OCR receipt scanning capabilities. It's a cross-platform app (Android, iOS, macOS, Linux, Windows) focused on Indonesian market localization (id_ID).

**Core value proposition**: Track unlimited personal income/expense transactions with manual entry or OCR-based receipt scanning, providing monthly insights and spending recommendations.

## Quick Start Commands

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
# For Riverpod/Freezed code generation
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
    ├── providers/       # Riverpod providers
    ├── screens/         # Full-screen widgets
    ├── widgets/         # Reusable UI components
    └── utils/           # Theme, colors, helpers
```

### Dependency Flow
```
Presentation → Domain (UseCases) → Domain (Repositories) → Data (RepositoryImpl)
```

**Key principle**: Presentation layer depends on Domain interfaces, not Data implementations. Data layer implements Domain interfaces.

## State Management (Riverpod 3.x)

Uses **Riverpod 3.3.1** with **AsyncNotifier** pattern and `@riverpod` code generation.

### Provider Registration
Providers are organized by feature in `lib/presentation/providers/`:
- `usecases/` - UseCase providers (dependency injection layer)
- `category/` - Category-related providers
- `transaction/` - Transaction-related providers
- `summary/` - Monthly summary providers
- `currency/` - Currency settings provider
- `onboarding/` - Onboarding state provider
- `cache/` - App initialization cache provider

All providers are exported from `lib/presentation/providers/app_providers.dart`.

### Key Providers
- `transactionListPaginatedNotifierProvider` - Paginated transaction list (infinite scroll)
- `transactionFormNotifierProvider` - Add/edit transaction form state
- `transactionFilterNotifierProvider` - Transaction filter criteria
- `transactionSearchNotifierProvider` - Transaction search state
- `transactionSelectionProvider` - Multi-select deletion state
- `categoryListNotifierProvider` - Active categories by type
- `categoryFormNotifierProvider` - Category form state
- `categoryManagementNotifierProvider` - Category CRUD with drag-drop reordering
- `monthlySummaryNotifierProvider` - Monthly insights and breakdown
- `receiptScanNotifierProvider` - OCR scanning state
- `onboardingProvider` - Onboarding completion state
- `currencyNotifierProvider` - Currency mode (IDR/USD) settings
- `exportNotifierProvider` - CSV export state management

### Riverpod 3.x Pattern

```dart
// 1. Create provider with @riverpod annotation
@riverpod
class TransactionListNotifier extends _$TransactionListNotifier {
  @override
  Future<List<TransactionEntity>> build() async {
    // Initialization in build(), NOT constructor
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

### Freezed 3.x Pattern

```dart
// Note: 'abstract' keyword is REQUIRED in Freezed 3.x
@freezed
abstract class TransactionFormState with _$TransactionFormState {
  const factory TransactionFormState.initial() = TransactionFormInitial;
  const factory TransactionFormState.loading() = TransactionFormLoading;
  const factory TransactionFormState.data(TransactionEntity transaction) = TransactionFormData;
  const factory TransactionFormState.error(String message) = TransactionFormError;
}
```

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

## Key Features

### Core Features
1. **Transaction Entry** - Manual form with validation or OCR receipt scanning
2. **Category Management** - CRUD operations with drag-drop reordering
3. **Paginated Transaction List** - Infinite scroll (20 items/page)
4. **Full-text Search** - Search across notes and category names
5. **CSV Export** - Manual CSV generation with Indonesian formatting
6. **Monthly Summary & Insights** - Charts and spending recommendations

### New Features (Latest Updates)

#### GoRouter Navigation
- **File**: `lib/presentation/navigation/routes/app_router.dart`
- StatefulShellRoute for bottom navigation preservation
- Type-safe routing with go_router_builder
- Automatic onboarding redirects
- Deep linking support
- Routes: `/` (redirect), `/transactions`, `/transactions/add`, `/transactions/edit/:id`, `/transactions/scan`, `/summary`, `/settings`

#### Onboarding System
- **File**: `lib/presentation/screens/onboarding_screen.dart`
- 3-page walkthrough with swipe navigation
- Persistent onboarding state via SharedPreferences
- Smooth page indicators
- Auto-redirect for completed users

#### Currency Settings
- **File**: `lib/presentation/providers/currency/currency_provider.dart`
- IDR and USD currency support
- Dynamic formatting throughout app
- SharedPreferences persistence
- CurrencyOption enum with symbol and separator

#### Multi-Select Transaction Deletion
- **File**: `lib/presentation/providers/transaction/transaction_selection_provider.dart`
- Toggle selection mode
- Select all/deselect all
- Bulk delete with confirmation dialog

#### Motivational Insights
- **File**: `lib/domain/services/insight_service.dart`
- 5 Indonesian messages for new users (0-4 transactions)
- Always shows recommendation section
- Priority-based insights (high/medium/low)

#### App Initialization Flow
- **File**: `lib/presentation/app/app_widget.dart`
- Loading state with InitializationScreen
- Error handling with AppInitializationErrorScreen
- Cache-based initialization (prevents re-seeding)

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

**Important**: Database version tracked in `_databaseVersion`. Increment and update `_onUpgrade()` when modifying schema.

**Helper Methods:**
- `getTransactionsCount({filter})` - Total count with optional filter
- `getTransactionsPaginated({limit, offset, filter})` - Paginated transactions
- `searchTransactions({query, type, limit})` - SQL LIKE search on note + category

## Dependencies

### Core Dependencies (Updated)
```yaml
dependencies:
  # State Management
  flutter_riverpod: ^3.3.1
  riverpod_annotation: ^4.0.2

  # Navigation
  go_router: ^17.1.0

  # Database
  sqflite: ^2.4.1
  path: ^1.9.0

  # Storage & Path
  path_provider: ^2.1.5
  shared_preferences: ^2.3.4

  # Internationalization
  intl: ^0.20.1

  # Form Validation
  form_field_validator: ^1.1.0

  # DateTime
  timezone: ^0.11.0

  # UUID
  uuid: ^4.5.1

  # OCR & Image Processing
  google_mlkit_text_recognition: ^0.15.1
  image_picker: ^1.1.2
  permission_handler: ^12.0.1

  # UI & Fonts
  google_fonts: ^8.0.2
  fl_chart: ^1.2.0
  package_info_plus: ^9.0.0
  smooth_page_indicator: ^2.0.1

  # CSV Export (manual generation, no csv package)
  share_plus: ^12.0.1

  # Logging
  logger: ^2.0.0

  # Immutable Data
  freezed_annotation: ^3.1.0

dev_dependencies:
  # Build Tools
  build_runner: ^2.4.13
  riverpod_generator: ^4.0.3
  freezed: ^3.2.5
  go_router_builder: ^4.2.0

  # Testing
  mockito: ^5.4.4
```

## Design System

Catat Cuan uses comprehensive glassmorphism design system. See [docs/v1/design/DESIGN_SYSTEM_GUIDE.md](./docs/v1/design/DESIGN_SYSTEM_GUIDE.md) for complete documentation.

### Quick Reference
```dart
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';

// Spacing
AppSpacing.lg  // 16px

// Border Radius
AppRadius.md  // 12px

// Glass Containers
AppGlassContainer.glassCard(child: ...)
AppGlassContainer.glassSurface(child: ...)
AppGlassContainer.glassPill(child: ...)

// Empty States
AppEmptyState.transactions(onAdd: ...)

// Date Formatting
AppDateFormatter.formatDayMonthYearDate(date)
```

### Status: ✅ Complete (2026-03-21)
- 31 files refactored
- ~301 issues resolved
- See: `docs/v1/design/DESIGN-SYSTEM-REFACTORING-[COMPLETED]-2026-03-21.md`

## Code Quality

This project follows SOLID principles. See [docs/guides/SOLID.md](./docs/guides/SOLID.md) for detailed guide.

### Quick Reference
- **SRP**: Each class/function has one responsibility
- **OCP**: Open for extension, closed for modification
- **LSP**: Derived classes must be substitutable for base classes
- **ISP**: Small, focused interfaces
- **DIP**: Depend on abstractions, not concretions

## Development Guidelines

### Adding a New Feature
1. Create entity in `domain/entities/`
2. Create repository interface in `domain/repositories/`
3. Implement repository in `data/repositories/`
4. Create use case in `domain/usecases/`
5. Create AsyncNotifier provider with `@riverpod` annotation in `presentation/providers/`
6. Run `flutter pub run build_runner build --delete-conflicting-outputs`
7. Build UI with AsyncValue pattern in `presentation/screens/` or `presentation/widgets/`
8. **Use design system utilities** for all spacing, sizing, and styling

### UI Development
- **Always use `AppSpacing` constants** instead of hardcoded values
- **Always use `AppRadius` constants** instead of hardcoded border radius
- **Use glassmorphism containers** - Prefer `AppGlassContainer` variants
- **Use base widgets** (`AppContainer`, `AppEmptyState`, `AppErrorState`)
- **Use `AppDateFormatter`** for all date formatting
- **Apply screen mixins** (`ScreenStateMixin` or `ConsumerScreenStateMixin`)
- **Build responsive layouts** using `ScreenSize` utilities

### Database Migrations
- Increment `_databaseVersion` in `DatabaseHelper`
- Implement migration logic in `_onUpgrade()`

### State Management
- Use `@riverpod` annotation with `AsyncNotifier` for async data
- Use `AsyncValue.when()` for handling loading, error, and data states
- Keep state immutable (create new instances on changes)
- Avoid constructor side effects - use `build()` method for initialization
- Use `ref.invalidateSelf()` for refresh operations

## Important File Locations

### Core Files
- `lib/main.dart` - App entry point with ProviderScope
- `lib/presentation/providers/app_providers.dart` - All provider definitions
- `lib/presentation/utils/utils.dart` - Central utilities export (design system)
- `lib/presentation/widgets/base/base.dart` - Base widgets export
- `lib/data/datasources/local/database_helper.dart` - Database schema and migrations
- `lib/domain/usecases/` - Business logic operations
- `lib/presentation/navigation/routes/app_router.dart` - GoRouter configuration

### New Feature Files
- `lib/presentation/screens/onboarding_screen.dart` - Onboarding UI
- `lib/presentation/providers/currency/currency_provider.dart` - Currency settings
- `lib/presentation/providers/transaction/transaction_selection_provider.dart` - Multi-select
- `lib/domain/services/insight_service.dart` - Motivational insights
- `lib/presentation/app/app_widget.dart` - App initialization flow
- `lib/presentation/providers/cache_provider.dart` - Initialization cache
- `lib/presentation/utils/logger/app_logger.dart` - Logger utility

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

## Related Documentation

- `docs/guides/SOLID.md` - SOLID principles detailed guide
- `docs/v1/design/DESIGN_SYSTEM_GUIDE.md` - Design system complete documentation
- `docs/v1/product/00-PRD.md` - Product Requirements Document
- `docs/v1/product/*.md` - Feature specifications
- `docs/v1/implementation/*.md` - Implementation plans
- `docs/v1/project/project_progress_review.md` - Progress review against PRD
- `docs/v1/project/project_resume.md` - Comprehensive project resume
