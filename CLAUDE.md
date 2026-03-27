# CLAUDE.md

**Catat Cuan** - Aplikasi pelacakan pengeluaran pribadi Flutter dengan OCR struk.

**Status**: ✅ Production Ready | 100% SRP Compliance | 263/263 Tests Passing

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

### 5. Post-Change Workflow - Commit & Update Documentation ⚠️
**⚠️ CRITICAL**: After making any code changes, AI MUST:
1. Commit the changes with proper git commit message
2. Update `docs/v1/project/PROJECT_STATUS.md` if applicable

**Why**: Ensures changes are tracked in git history and project documentation stays synchronized with implementation.

**Workflow**:
```bash
# After completing changes and running tests
git add .
git commit -m "type: description of changes

Co-Authored-By: Claude (glm-4.7) <noreply@anthropic.com>"
```

**When to update PROJECT_STATUS.md**:
- New features implemented → Add to "Fitur yang Diimplementasikan"
- Bug fixes → Update status if applicable
- Refactoring → Update "Pekerjaan Saat Ini" section
- Database changes → Add to "Database Migration History"
- Documentation changes → Update "Last Updated" date

**Example Commit Message Types**:
- `feat:` New feature
- `fix:` Bug fix
- `refactor:` Code refactoring
- `docs:` Documentation changes
- `test:` Test additions/changes
- `chore:` Maintenance tasks

### 6. Context7 Documentation Reference ⚠️
**⚠️ CRITICAL**: Before providing any implementation guidance for third-party packages, AI MUST:
1. Query Context7 for the latest package documentation
2. Use the most up-to-date information available
3. Reference the specific library ID used

**Why**: Flutter/Dart ecosystem evolves rapidly. Using outdated patterns can lead to deprecated APIs, breaking changes, or missed improvements. Context7 provides current documentation and examples.

**When to use Context7**:
- Providing examples for flutter_riverpod, go_router, freezed, etc.
- Explaining package-specific patterns or APIs
- Suggesting implementation approaches for third-party packages
- Answering questions about package features or best practices
- ANY time you're about to write code using external packages

**Key Packages to Always Check**:
- `riverpod` - /refiic/riverpod
- `go_router` - /flutter/packages
- `freezed` - /rrousselGit/freezed
- `sqflite` - /tekartik/sqflite

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

### Database
- **[DATABASE_SCHEMA.md](./docs/v1/database/DATABASE_SCHEMA.md)** - Database schema documentation (English)
- **[DATABASE_SCHEMA_ID.md](./docs/v1/database/DATABASE_SCHEMA_ID.md)** - Dokumentasi skema database (Indonesian)

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
- **Tests**: 263/263 passing ✅
- **Analyzer**: 0 errors ✅
- **Documentation**: 21 files, fully bilingual (EN/ID)

---

**Last Updated**: 2026-03-28
**Documentation**: 21 comprehensive guides available in `docs/`
**Quick Help**: See [AI_ASSISTANT_GUIDE.md](./docs/AI_ASSISTANT_GUIDE.md) for critical rules
