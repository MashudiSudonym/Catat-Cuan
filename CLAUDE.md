# CLAUDE.md

**Catat Cuan** - Aplikasi pelacakan pengeluaran pribadi Flutter dengan OCR struk.

**Status**: ✅ Production Ready | 100% SRP Compliance | 97/97 Tests Passing

---

## 🚀 Quick Start

```bash
flutter pub get                                    # Install dependencies
flutter pub run build_runner build --delete-conflicting-outputs  # Generate code
flutter run                                        # Run app
flutter test                                       # Run tests
```

---

## 📋 Architecture Overview

**Clean Architecture** dengan repository segregation pattern:

```
lib/
├── domain/          # Business logic (entities, use cases, repository interfaces)
├── data/            # Data layer (repository implementations, data sources)
└── presentation/    # UI & state management (providers, screens, widgets, controllers)
```

**Key Pattern**: Presentation → Domain (interfaces) ← Data (implementations)

---

## ⚡ Critical Rules (MUST READ)

### 1. Freezed 3.x - `abstract` Keyword REQUIRED ⚠️
```dart
// ❌ WRONG
@freezed
class MyState with _$MyState { }

// ✅ CORRECT
@freezed
abstract class MyState with _$MyState { }
```

### 2. Riverpod 3.x - Initialize in `build()`, NOT constructor ⚠️
```dart
// ❌ WRONG
@riverpod
class MyNotifier extends _$MyNotifier {
  MyNotifier() { load(); }  // Don't initialize here!
  @override
  Future build() => Future.value();
}

// ✅ CORRECT
@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  Future build() async {  // Initialize here
    final useCase = ref.read(myUseCaseProvider);
    return await useCase.execute();
  }
}
```

### 3. Repository Segregation Pattern
- **Category**: 4 interfaces (Read, Write, Management, Seeding)
- **Transaction**: 6+ interfaces (Read, Write, Query, Search, Analytics, Export)

### 4. Code Generation
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📁 Reference Locations

| Layer | Location | Purpose |
|-------|----------|---------|
| **Entities** | `lib/domain/entities/` | Core business entities |
| **Use Cases** | `lib/domain/usecases/` | Business operations |
| **Repository Interfaces** | `lib/domain/repositories/` | Contracts (segregated by operation) |
| **Repository Implementations** | `lib/data/repositories/` | Concrete implementations |
| **Providers** | `lib/presentation/providers/` | Riverpod state management |
| **Controllers** | `lib/presentation/controllers/` | Business logic controllers |
| **Screens** | `lib/presentation/screens/` | Full-screen widgets |
| **Utils** | `lib/presentation/utils/utils.dart` | Design system export |

---

## 🎯 Common Tasks

### Add New Feature
1. Create entity → Create repository interface → Implement repository
2. Create use case → Create provider with `@riverpod`
3. Run code generation → Build UI

### Database Migration
```dart
// Increment version in lib/data/datasources/local/schema_manager.dart
static const int currentVersion = 3;  // Increment from 2

// Add migration logic in onUpgrade()
```

### Testing
```bash
flutter test                                      # All tests
flutter test test/domain/usecases/my_test.dart    # Specific test
flutter test --coverage                            # With coverage
```

---

## 📚 Documentation (Comprehensive Guides)

### ⭐ START HERE
- **[AI_ASSISTANT_GUIDE.md](./docs/AI_ASSISTANT_GUIDE.md)** - Critical rules & quick reference

### Technical Guides
- **[ARCHITECTURE.md](./docs/guides/ARCHITECTURE.md)** - Clean Architecture with real examples
- **[RIVERPOD_GUIDE.md](./docs/guides/RIVERPOD_GUIDE.md)** - Riverpod 3.3.1 patterns
- **[FREEZED_GUIDE.md](./docs/guides/FREEZED_GUIDE.md)** - Freezed 3.x (abstract keyword)
- **[CODING_STANDARDS.md](./docs/guides/CODING_STANDARDS.md)** - File naming, imports, documentation
- **[SOLID.md](./docs/guides/SOLID.md)** - SOLID principles with codebase examples

### Design System
- **[DESIGN_SYSTEM_GUIDE.md](./docs/v1/design/DESIGN_SYSTEM_GUIDE.md)** - Glassmorphism + Riverpod 3.x

### Product Specs (Indonesian/English)
- **[docs/v1/product/](./docs/v1/product/)** - All SPEC documents with verified checklists
- **[docs/v1/product/IMPLEMENTATION_STATUS.md](./docs/v1/product/IMPLEMENTATION_STATUS.md)** - Verification dashboard

### Project Status
- **[docs/v1/project/PROJECT_STATUS.md](./docs/v1/project/PROJECT_STATUS.md)** - Project status (EN/ID)
- **[docs/v1/project/REFACTORING_HISTORY.md](./docs/v1/project/REFACTORING_HISTORY.md)** - SOLID refactoring journey

---

## 🔑 Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_riverpod | 3.3.1 | State management |
| riverpod_annotation | 4.0.2 | Code generation |
| freezed | 3.2.5 | Immutable data |
| go_router | 17.1.0 | Navigation |
| sqflite | 2.4.1 | Database |

---

## 🎨 Quick Design System Reference

```dart
import 'package:catat_cuan/presentation/utils/utils.dart';

// Spacing
AppSpacing.lg  // 16px

// Border Radius
AppRadius.md  // 12px

// Glass Containers
AppGlassContainer.glassCard(child: ...)

// Empty States
AppEmptyState.transactions(onAdd: ...)

// Date Formatting
AppDateFormatter.formatDayMonthYearDate(date)
```

---

## ✅ Current Status

- **Architecture**: Clean Architecture with 100% SRP compliance
- **State Management**: Riverpod 3.3.1 with @riverpod annotation
- **Database**: SQLite with SchemaManager version 2
- **Tests**: 97/97 passing ✅
- **Analyzer**: 0 errors ✅
- **Documentation**: 21 files, fully bilingual (EN/ID)

---

**Last Updated**: 2026-03-27
**Documentation**: 21 comprehensive guides available in `docs/`
**Quick Help**: See [AI_ASSISTANT_GUIDE.md](./docs/AI_ASSISTANT_GUIDE.md) for critical rules
