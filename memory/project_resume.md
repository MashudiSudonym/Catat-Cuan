# Catat Cuan - Project Resume

**Version**: 1.0 (Complete)
**Last Updated**: March 22, 2026
**Platform**: Flutter (Android, iOS, macOS, Linux, Windows)
**Locale**: Indonesian (id_ID)

---

## Project Overview

Catat Cuan is a **personal expense tracking application** with OCR receipt scanning capabilities. Designed for the Indonesian market, it enables users to track unlimited income and expense transactions through manual entry or receipt scanning, providing monthly insights and spending recommendations.

### Value Proposition

- **Unlimited Tracking**: Record as many transactions as needed without artificial limits
- **Fast Input**: Manual entry in ≤20 seconds, OCR scanning in ≤30 seconds
- **Privacy-First**: All data stored locally; OCR processes on-device
- **Actionable Insights**: Get personalized recommendations based on spending patterns
- **Cross-Platform**: Works on mobile, desktop, and web from a single codebase

---

## Architecture

### Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  ┌────────────────────────────────────────────────────┐     │
│  │  • Screens (TransactionListScreen, etc.)           │     │
│  │  • Widgets (Reusable components)                   │     │
│  │  • Providers (Riverpod AsyncNotifiers)             │     │
│  │  • Utils (Design system, formatters)               │     │
│  └────────────────────────────────────────────────────┘     │
│                         ↓ depends on ↓                        │
├─────────────────────────────────────────────────────────────┤
│                      DOMAIN LAYER                            │
│  ┌────────────────────────────────────────────────────┐     │
│  │  • Entities (TransactionEntity, CategoryEntity)    │     │
│  │  • UseCases (AddTransaction, GetMonthlySummary)    │     │
│  │  • Repository Interfaces (Contracts)               │     │
│  │  • Services (InsightService, ExportService)        │     │
│  └────────────────────────────────────────────────────┘     │
│                         ↑ implemented by ↑                    │
├─────────────────────────────────────────────────────────────┤
│                       DATA LAYER                             │
│  ┌────────────────────────────────────────────────────┐     │
│  │  • Repository Implementations                      │     │
│  │  • DataSources (DatabaseHelper, ML Kit)            │     │
│  │  • Models (DTOs, mappers)                          │     │
│  │  • Services (OCR, ImagePicker, Permissions)        │     │
│  └────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

### Key Principles

- **Dependency Inversion**: High-level modules depend on abstractions
- **Single Responsibility**: Each class has one reason to change
- **Interface Segregation**: Small, focused interfaces
- **Open/Closed**: Open for extension, closed for modification
- **Liskov Substitution**: Subtypes are substitutable for their base types

---

## Technology Stack

### Core Technologies

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| **Framework** | Flutter | 3.x | Cross-platform UI framework |
| **Language** | Dart | 3.x | Application language |
| **State Management** | Riverpod | 2.6.1 | Reactive state management |
| **Database** | SQLite (sqflite) | 2.4.1 | Local data persistence |
| **OCR** | Google ML Kit | Text Recognition v2 | Receipt text extraction |
| **Charts** | fl_chart | - | Data visualization |
| **Code Generation** | build_runner | - | Riverpod provider generation |

### Additional Dependencies

| Package | Version | Usage |
|---------|---------|-------|
| csv | 6.0.0 | CSV export generation |
| share_plus | 7.2.1 | File sharing integration |
| path_provider | 2.1.5 | Temporary directory access |
| intl | 0.20.1 | Internationalization (id_ID) |
| path | 1.9.0 | File path utilities |

---

## Key Features

### 1. Transaction Management

**Manual Entry**
- Amount, type (income/expense), date/time, category, note
- Real-time validation with error messages
- Edit and delete with confirmation dialogs

**OCR Receipt Scanning**
- Camera capture or gallery selection
- On-device text recognition (no network required)
- Automatic "Total" amount extraction
- Manual correction capability

### 2. Category Management

- Default categories seeded on first launch
- Custom categories with icons and colors
- Deactivate (not delete) to preserve history
- Drag-and-drop reordering

### 3. Transaction List

- **Pagination**: 20 items per page with infinite scroll
- **Search**: Full-text search across notes and categories
- **Filter**: By type, category, and date range
- **Sort**: Chronological order with date grouping

### 4. Monthly Summary

- Total income, expenses, and balance
- Top 3 spending categories
- Category breakdown with percentages
- Visual charts (pie and bar)

### 5. Insights & Recommendations

- Pattern-based spending analysis
- Personalized savings recommendations
- Category-specific insights

### 6. CSV Export

- Export all transactions or apply current filter
- Indonesian formatting (DD/MM/YYYY, thousand separators)
- Share directly to other apps

---

## Database Schema

### Categories Table

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key |
| name | TEXT | Category name |
| type | TEXT | 'income' or 'expense' |
| color | TEXT | Hex color code |
| icon | TEXT | Icon identifier |
| sort_order | INTEGER | Display order |
| is_active | INTEGER | 0=inactive, 1=active |
| created_at | TEXT | ISO datetime |
| updated_at | TEXT | ISO datetime |

**Indexes**: type, is_active

### Transactions Table

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key |
| amount | REAL | Transaction amount |
| type | TEXT | 'income' or 'expense' |
| date_time | TEXT | ISO datetime |
| category_id | INTEGER | Foreign key → categories |
| note | TEXT | Optional notes |
| created_at | TEXT | ISO datetime |
| updated_at | TEXT | ISO datetime |

**Indexes**: date_time, category_id, type, (date_time+type), (month+type)

---

## Design System

### Spacing (4px Grid)

```dart
AppSpacing.xs    // 4px
AppSpacing.sm    // 8px
AppSpacing.md    // 12px
AppSpacing.lg    // 16px
AppSpacing.xl    // 20px
AppSpacing.xxl   // 24px
AppSpacing.xxxl  // 32px
```

### Border Radius

```dart
AppRadius.xs     // 4px
AppRadius.sm     // 8px
AppRadius.md     // 12px
AppRadius.lg     // 16px
AppRadius.xl     // 20px
AppRadius.xxl    // 24px
AppRadius.circle // 999px
```

### Glassmorphism

- **glassCard**: 12px blur, 0.85 alpha (cards)
- **glassSurface**: 20px blur, 0.95 alpha (forms, dialogs)
- **glassPill**: 4px blur, 0.70 alpha (chips, tags)
- **glassNavigation**: 30px blur, 0.90 alpha (bars)

### Base Widgets

- `AppContainer`: Preset container styles
- `AppGlassContainer`: Glassmorphism variants
- `AppEmptyState`: Unified empty states
- `AppErrorState`: Unified error/loading states

---

## State Management Pattern

### AsyncNotifier Pattern (Recommended)

```dart
@riverpod
class TransactionListNotifier extends _$TransactionListNotifier {
  @override
  Future<List<TransactionEntity>> build() async {
    final useCase = ref.read(getTransactionsUseCaseProvider);
    return await useCase.execute();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
```

### Usage in UI

```dart
final transactionsAsync = ref.watch(transactionListNotifierProvider);

return transactionsAsync.when(
  loading: () => const AppLoadingState(),
  error: (error, stack) => AppErrorStates.generic(
    message: error.toString(),
    onRetry: () => ref.read(transactionListNotifierProvider.notifier).refresh(),
  ),
  data: (transactions) => TransactionListView(transactions),
);
```

---

## Important File Locations

### Core Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point with ProviderScope |
| `lib/presentation/providers/app_providers.dart` | Central provider registry |
| `lib/data/datasources/local/database_helper.dart` | Database schema and migrations |
| `lib/domain/usecases/` | Business logic operations |

### UI Components

| Path | Purpose |
|------|---------|
| `lib/presentation/screens/` | Full-screen widgets |
| `lib/presentation/widgets/` | Reusable components |
| `lib/presentation/utils/` | Design system utilities |
| `lib/presentation/widgets/base/` | Base widgets |

### Feature Files

| Feature | Key Files |
|---------|-----------|
| **Pagination** | `transaction_list_paginated_provider.dart`, `GetTransactionsPaginatedUseCase` |
| **Search** | `transaction_search_provider.dart`, `SearchTransactionsUseCase` |
| **Export** | `export_provider.dart`, `CsvExportServiceImpl` |
| **OCR** | `ReceiptOcrServiceImpl`, `ImagePickerService` |

---

## Development Workflow

### Adding a New Feature

1. **Domain Layer**
   - Create entity in `domain/entities/`
   - Create repository interface in `domain/repositories/`
   - Create use case in `domain/usecases/`

2. **Data Layer**
   - Implement repository in `data/repositories/`
   - Create data source if needed

3. **Presentation Layer**
   - Create provider with `@riverpod` annotation
   - Run code generation: `flutter pub run build_runner build --delete-conflicting-outputs`
   - Build UI with AsyncValue pattern
   - **Use design system utilities** for all spacing and styling

### Code Generation

```bash
# One-time generation
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for development
flutter pub run build_runner watch
```

---

## Localization

All content is in Indonesian (id_ID):

- **Date Format**: DD/MM/YYYY or "13 Januari 2024"
- **Currency**: Rp with thousand separators (e.g., "1.000.000")
- **Relative Dates**: "Hari ini", "Kemarin", etc.
- **UI Labels**: All strings in Indonesian

---

## Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart
```

### Test Structure

- **Unit Tests**: Domain layer (use cases, entities)
- **Widget Tests**: UI components
- **Integration Tests**: End-to-end flows
- **Mocking**: Uses `mockito` for dependencies

---

## Common Commands

```bash
# Development
flutter pub get              # Install dependencies
flutter run                  # Run on connected device
flutter run --debug          # Debug mode
flutter run --release        # Release mode

# Building
flutter build apk            # Android APK
flutter build appbundle      # Android App Bundle
flutter build ios            # iOS build
flutter build macos          # macOS build
flutter build linux          # Linux build
flutter build windows        # Windows build
```

---

## Design Guidelines

### UI Development Rules

1. **Always use `AppSpacing` constants** instead of hardcoded values
2. **Always use `AppRadius` constants** instead of hardcoded border radius
3. **Use `AppGlassContainer` variants** for glassmorphism effects
4. **Use base widgets** (`AppContainer`, `AppEmptyState`, `AppErrorState`)
5. **Use `AppDateFormatter`** for all date formatting
6. **Apply screen mixins** for common behaviors
7. **Build responsive layouts** using `ScreenSize` utilities

### State Management Rules

1. Use `@riverpod` annotation with `AsyncNotifier` for async data
2. Use `AsyncValue.when()` for handling states
3. Keep state immutable (create new instances on changes)
4. Avoid constructor side effects - use `build()` method
5. Use `ref.invalidateSelf()` for refresh operations

---

## Related Documentation

- `memory/project_progress_review.md` - Detailed progress review against PRD
- `CLAUDE.md` - Comprehensive development guidelines
- `PLANS/PRD.md` - Product Requirements Document
- `PLANS/SPEC-LOG-*.md` - Feature specifications
- `PLANS/PLAN-LOG-*.md` - Implementation plans
- `PLANS/ROADMAP-PRIORITAS-SELANJUTNYA.md` - v2 development roadmap
- `lib/presentation/DESIGN_SYSTEM_GUIDE.md` - Design system documentation

---

## Project Status

**✅ v1 100% COMPLETE** - All PRD requirements implemented with additional enhancements.

### Completed Features (PRD v1)
| Feature | Status |
|---------|--------|
| Unlimited transaction tracking | ✅ Complete |
| Fast manual input | ✅ Complete |
| OCR receipt scanning | ✅ Complete |
| Monthly summary | ✅ Complete |
| Insights & recommendations | ✅ Complete |
| Full CRUD with filter | ✅ Complete |

### Additional Features (Beyond PRD)
| Feature | Status |
|---------|--------|
| Pagination (infinite scroll) | ✅ Complete |
| Full-text search | ✅ Complete |
| CSV export & share | ✅ Complete |
| Category drag-drop reorder | ✅ Complete |
| Multi-select delete | ✅ Complete |
| Glassmorphism design system | ✅ Complete |

**Ready for production deployment.**

For v2 development plans, see `PLANS/ROADMAP-PRIORITAS-SELANJUTNYA.md`.
