# Project Status Catat Cuan

**Version**: 1.5.1
**Status**: ✅ v1.5.1 | ✅ 100% SRP Compliance | ✅ Phase 5 Tests Complete | ✅ Automated Versioning
**Last Updated**: 8 April 2026
**Platform**: Flutter (Android, iOS, macOS, Linux, Windows)
**Locale**: Indonesia (id_ID)

---

## Quick Reference

| Document | Language | Description |
|----------|----------|-------------|
| [AI_ASSISTANT_GUIDE.md](../AI_ASSISTANT_GUIDE.md) | English | High-priority guide for AI assistants |
| [ARCHITECTURE.md](../guides/ARCHITECTURE.md) | English | Complete Clean Architecture guide |
| [RIVERPOD_GUIDE.md](../guides/RIVERPOD_GUIDE.md) | English | Riverpod 3.3.1 patterns |
| [FREEZED_GUIDE.md](../guides/FREEZED_GUIDE.md) | English | Freezed 3.x with abstract keyword |
| [CODING_STANDARDS.md](../guides/CODING_STANDARDS.md) | English | File naming, imports, documentation |
| [SOLID.md](../guides/SOLID.md) | English | SOLID principles with real examples |
| [DESIGN_SYSTEM_GUIDE.md](../design/DESIGN_SYSTEM_GUIDE.md) | English | Glassmorphism design system |
| [DATABASE_SCHEMA.md](../database/DATABASE_SCHEMA.md) | English | Database schema documentation |
| [DATABASE_SCHEMA_ID.md](../database/DATABASE_SCHEMA_ID.md) | Indonesian | Dokumentasi skema database |
| [PRD v1](../product/00-PRD.md) | Indonesian | Product Requirements Document v1 |
| [PRD v2](../v2/product/00-PRD.md) | Indonesian | Product Requirements Document v2 |
| [SPEC v2](../v2/product/IMPLEMENTATION_STATUS.md) | English/Indonesian | v2 Implementation Status |
| [REFACTORING_HISTORY.md](REFACTORING_HISTORY.md) | English | Complete SOLID refactoring journey |
| [TEST_COVERAGE.md](TEST_COVERAGE.md) | English/Indonesian | Test coverage documentation (911 tests) |

---

## Executive Summary (English)

Catat Cuan is a personal expense tracking application with OCR receipt scanning capabilities. Designed for the Indonesian market, the app allows users to track unlimited income and expense transactions through manual entry or receipt scanning, providing monthly insights and spending recommendations.

### Core Value Proposition

- **Unlimited Tracking**: Track as many transactions as needed without artificial limits
- **Fast Input**: Manual entry ≤20 seconds, OCR scan ≤30 seconds
- **Privacy-First**: All data stored locally; OCR processed on-device
- **Actionable Insights**: Personalized recommendations based on spending patterns
- **Cross-Platform**: Works on mobile, desktop, and web from single codebase

### Technical Highlights

- **Architecture**: Clean Architecture with 100% SRP compliance
- **State Management**: Riverpod 3.3.1 with @riverpod annotation
- **Database**: SQLite with SchemaManager version 2
- **Navigation**: GoRouter 17.1.0 with type-safe routing
- **Design System**: Glassmorphism with complete component library
- **Code Quality**: 945/945 tests passing, 0 analyzer errors

---

# Status Proyek Catat Cuan

**Versi**: 1.5.0 (Selesai)
**Status**: ✅ v1 Selesai | ✅ 100% Kepatuhan SRP | ✅ Automated Versioning
**Terakhir Diperbarui**: 6 April 2026
**Platform**: Flutter (Android, iOS, macOS, Linux, Windows)
**Lokal**: Indonesia (id_ID)

---

## Ringkasan Eksekutif

Catat Cuan adalah aplikasi pencatatan keuangan pribadi dengan kemampuan pemindaian struk OCR. Dirancang untuk pasar Indonesia, aplikasi ini memungkinkan pengguna melacak transaksi pemasukan dan pengeluaran tanpa batas melalui input manual atau pemindaian struk, serta memberikan wawasan bulanan dan rekomendasi pengeluaran.

### Nilai Utama

- **Pelacakan Tanpa Batas**: Catat sebanyak mungkin transaksi tanpa batasan buatan
- **Input Cepat**: Input manual ≤20 detik, pemindaian OCR ≤30 detik
- **Privasi Prioritas**: Semua data disimpan lokal; OCR diproses di perangkat
- **Insight yang Dapat Ditindaklanjuti**: Rekomendasi personal berdasarkan pola pengeluaran
- **Cross-Platform**: Bekerja di mobile, desktop, dan web dari satu codebase

---

## Fitur yang Diimplementasikan

### Fitur v1 PRD ✅

| Fitur | Deskripsi | Status |
|-------|-----------|--------|
| Pelacakan transaksi tanpa batas | Catat transaksi pemasukan/pengeluaran tanpa limit | ✅ Selesai |
| Input manual cepat | Form dengan validasi real-time, selesai dalam ≤20 detik | ✅ Selesai |
| Pemindaian struk OCR | Kamera/galeri, ekstraksi nominal total otomatis | ✅ Selesai |
| Ringkasan bulanan | Total, saldo, top kategori, grafik visual | ✅ Selesai |
| Insight & rekomendasi | Analisis pola, saran penghematan personal | ✅ Selesai |
| CRUD lengkap dengan filter | Tambah, edit, hapus, filter transaksi | ✅ Selesai |

### Fitur Tambahan (Melampaui PRD) ✅

| Fitur | Deskripsi |
|-------|-----------|
| Pagination (infinite scroll) | 20 item per halaman |
| Pencarian full-text | Cari di catatan dan nama kategori |
| Ekspor CSV & share | Format Indonesia, SAF Download folder, share langsung |
| Impor CSV | Impor transaksi dari file CSV dengan deduplikasi |
| Drag-drop reorder kategori | Urutan kategori kustom |
| Hapus multi-select | Hapus beberapa transaksi sekaligus |
| Sistem desain glassmorphism | Konsistensi visual lengkap |
| Onboarding | 3 halaman walkthrough dengan navigasi swipe |
| Pengaturan mata uang | Dukungan IDR dan USD |
| Navigasi GoRouter | Routing bertipe aman dengan deep linking |
| **Home Screen Widgets** (v1.3) | Widget Android/iOS dengan ringkasan pengeluaran |
| **Widget Deep Linking** (v1.3) | Tap widget → buka form tambah transaksi |
| **Merchant Name Extraction** (v1.4) | Ekstraksi nama toko dari 50+ merchant Indonesia |
| **Category Prediction** (v1.4) | Prediksi kategori berdasarkan merchant yang dikenali |
| **ML Kit Latin Script** (v1.4) | Konfigurasi Latin script untuk teks Indonesia |

---

## Pekerjaan Saat Ini

### Refactoring Single Responsibility Principle (SRP)

**Status**: ✅ SEMUA FASE SELESAI (100% - 16/16 violations)

#### Ringkasan Fase Refactoring

| Fase | Deskripsi | File Baru |
|------|-----------|-----------|
| **Fase 1** | Data Layer - Repository Segregation | 4 category repositories + adapter |
| **Fase 2** | Presentation Controllers | 3 controllers (delete, scan, category) |
| **Fase 3** | Utilities & Services | TransactionFormatter, FileNamingService |
| **Fase 4** | Integration | Controller providers, screen updates |
| **Fase 5** | Utility Layer | 10 domain/purpose barrel files |
| **Fase 6** | Domain Layer - Final | Parser split + entity analyzers |

#### Hasil Akhir
- **16/16 violations addressed** (100% SRP compliance)
- **22 files created** (repositories, controllers, services, analyzers, barrels)
- **263/263 tests passing** ✅ → **911/911 tests passing** ✅
- **0 analyzer errors** ✅

#### File Baru yang Dibuat

**Data Layer**:
- `category_read_repository_impl.dart` - Read operations
- `category_write_repository_impl.dart` - Write operations
- `category_management_repository_impl.dart` - Management operations
- `category_seeding_repository_impl.dart` - Seeding operations
- `category_repository_adapter.dart` - Adapter pattern

**Presentation Controllers**:
- `transaction_delete_controller.dart` - Deletion logic
- `receipt_scanning_controller.dart` - OCR coordination
- `category_management_controller.dart` - Category management

**Domain Services**:
- `file_naming_service.dart` - File naming for exports
- `financial_health_analyzer.dart` - Financial health analysis
- `category_analyzer.dart` - Category breakdown analysis
- `insight/` - 4 segregated insight services

**Domain Parsers**:
- `receipt_date_parser.dart` - Date parsing only
- `receipt_time_parser.dart` - Time parsing only
- `receipt_date_time_composer.dart` - DateTime composer

**Utility Layers**:
- `utils/` barrel files (responsive, formatting, theme, mixins)
- `widgets/base/` barrel files (layout, states, effects)

---

## Testing Pyramid Implementation

**Status**: ✅ Phase 5 Completed | 945/945 Tests Passing

### Implementation Plan

Following the Testing Pyramid principle:
- **70% Unit Tests**: Test individual components in isolation
- **20% Integration Tests**: Verify component interactions
- **10% E2E Tests**: Critical user journeys only

### Progress

| Phase | Description | Status | Tests |
|-------|-------------|--------|-------|
| **Phase 1** | Test Infrastructure & Parsers | ✅ Completed | 42/42 passing |
| **Phase 2** | Entity, Validator & Analyzer Tests | ✅ Completed | 248/248 passing |
| **Phase 3** | Use Case Tests | ✅ Completed | 186/186 passing |
| **Phase 4** | Data Layer Tests | ✅ Completed | 120/120 passing |
| **Phase 5** | Presentation Tests | ✅ Completed | 34/34 passing |
| **Phase 6** | Integration Tests | ⏳ Pending | 0/8 planned |
| **Phase 7** | E2E Tests | ⏳ Pending | 0/5 planned |

**Total Test Count**: 945/945 tests passing ✅ | 0 analyzer errors ✅

### Phase 1: Foundation (Completed ✅)

**Completed**:
- ✅ Test infrastructure setup (helpers, fixtures, mocks)
- ✅ Receipt Amount Parser tests (42 tests)
  - Valid Indonesian formats (Rp 75.000, 75.000, 75.000,50)
  - Invalid formats and edge cases
  - Keyword-based extraction (Total, Jumlah, Tagihan, etc.)
  - Fallback extraction for largest amount
  - Real-world receipt examples
- ✅ Transaction Validator tests (48 tests)
  - validate() - general validation
  - validateForCreation() - creation-specific
  - validateForUpdate() - update-specific with ID check
  - validateAmount(), validateCategoryId(), validateNote()
  - ValidationResult success/error
  - Real-world validation scenarios
- ✅ Entity tests (63 tests)
  - TransactionEntity (28 tests) - creation, immutability, types, amounts, equality
  - CategoryEntity (35 tests) - creation, immutability, colors, icons, active status
  - TransactionType enum (10 tests) - fromString, displayName, value
  - CategoryType enum (8 tests) - fromString, displayName, value

### Phase 2: Entity, Analyzer & Transaction Use Case Tests (Completed ✅)

**Completed**:
- ✅ Analyzer service tests (24 tests)
  - FinancialHealthAnalyzer (12 tests)
  - CategoryAnalyzer (12 tests)
- ✅ Entity tests (206 tests)
  - MonthlySummaryEntity (15 tests) - with delegated analyzer properties
  - CategoryBreakdownEntity (15 tests) - with delegated analyzer properties
  - PaginatedResultEntity (12 tests) - factory constructors and computed properties
  - PaginationParamsEntity (10 tests) - navigation methods
  - RecommendationEntity + enums (20 tests) - RecommendationType, RecommendationPriority
  - ImportResult + nested entities (12 tests) - ImportRowError, ParsedCsvRow
  - ExportAction + extension (6 tests)
  - CategoryWithCountEntity (6 tests)
  - ReceiptDataEntity (6 tests)
  - CategoryEntity (63 tests) - existing
  - TransactionEntity (28 tests) - existing
  - TransactionType enum (10 tests) - existing
  - CategoryType enum (8 tests) - existing
- ✅ Transaction use case tests (186 tests)
  - AddTransactionUseCase (8 tests)
  - UpdateTransactionUseCase (9 tests)
  - DeleteTransactionUseCase (5 tests)
  - DeleteMultipleTransactionsUseCase (6 tests)
  - DeleteAllTransactionsUseCase (3 tests)
  - SearchTransactionsUseCase (8 tests)
  - ExportTransactionsUseCase (6 tests)
  - ScanReceiptUseCase (7 tests)
  - GetTransactionsUseCase (5 tests)
  - GetTransactionsPaginatedUseCase (7 tests)
  - Category use cases (13 tests) - existing
  - ImportTransactionsUseCase tests - existing

**Current Test Count**: 911/911 passing ✅

### Phase 4: Data Layer Tests (Completed ✅)

**Completed**:
- ✅ Model tests (25 tests)
  - CategoryModel (14 tests) - fromMap, toMap, toEntity, fromEntity, round-trip
  - TransactionModel (14 tests) - fromMap, toMap, toEntity, fromEntity, round-trip
- ✅ Repository tests (34 tests)
  - CategoryReadRepositoryImpl (12 tests) - getById, getCategoriesByType, getCategoryByName, getCategoriesWithCount, getTransactionCount
  - TransactionWriteRepositoryImpl (11 tests) - addTransaction, updateTransaction, deleteTransaction, deleteAllTransactions, deleteMultipleTransactions
  - TransactionAnalyticsRepositoryImpl (11 tests) - getMonthlySummary, getAllTimeSummary, getCategoryBreakdown, getAllCategoryBreakdown, getMultiMonthSummary
- ✅ Service tests (61 tests)
  - CsvExportServiceImpl (12 tests) - generateCsvString with headers, date/time formatting, type translation, currency formatting, special characters escaping
  - CsvImportServiceImpl (14 tests) - header validation, row parsing, quoted fields, different line endings, edge cases
  - IndonesianMerchantPatternServiceImpl (35 tests) - findMatch, findMatchInHeader, findByName, findById, getPatterns, category mapping

**Test Infrastructure Added**:
- `test/data/data_mocks.dart` - MockLocalDataSource generator
- `test/data/models/` - Model test files
- `test/data/repositories/category/` - Category repository tests
- `test/data/repositories/transaction/` - Transaction repository tests
- `test/data/services/` - Service test files

**Current Test Count**: 945/945 passing ✅

### Phase 5: Presentation Tests (Completed ✅)

**Completed**:
- ✅ Controller tests (10 tests)
  - TransactionFormSubmissionController (6 tests) - add/update strategy selection, form validation, error handling, date/time combination
  - TransactionDeleteController (4 tests) - single delete, batch delete with validation, empty list handling, failure handling
- ✅ Provider tests (21 tests)
  - TransactionSelectionNotifier (10 tests) - toggle selection mode, select/deselect all, multiple item selection, clear selection
  - TransactionFormNotifier (11 tests) - form validation (nominal, category, date, time), load for edit, reset form, set note, clear error
- ✅ Widget tests (2 tests)
  - TransactionFormScreen (2 tests) - basic smoke tests for widget instantiation

**Test Infrastructure Added**:
- `test/presentation/presentation_mocks.dart` - Mock use cases for presentation layer
- `test/presentation/controllers/` - Controller test files
- `test/presentation/providers/` - Provider test files
- `test/presentation/widgets/` - Widget test files

**Current Test Count**: 945/945 passing ✅

### Test Infrastructure

Created reusable test utilities:
- `test/helpers/test_fixtures.dart` - Fake data generators
- `test/helpers/mock_helpers.dart` - Mock repository factories
- `test/test_config.dart` - Test configuration and helpers

---

## Database Migration History

| Version | Description | Changes |
|---------|-------------|---------|
| **1.0** | Initial schema | Categories and transactions tables |
| **2.0** | Performance optimization | Added index for monthly aggregation queries |

---

## Versioning Strategy

**Fully Automated Versioning** (v1.0.1+)

The project uses Conventional Commits-based fully automated versioning. Just push your commits and the rest happens automatically!

### Version Bump Rules (Auto-Applied)
| Commit Type | Version Bump | Example |
|---|---|---|
| `feat:` | MINOR (1.x.0) | New features |
| `fix:` | PATCH (1.0.x) | Bug fixes |
| Other types | No bump | Non-user-facing changes |

**Note**: Breaking changes (`feat!`, `BREAKING CHANGE`) require manual bump with `./scripts/bump_version.sh --major`

### Build Number
- Total git commit count (monotonically increasing)
- Auto-injected at build time
- No manual maintenance needed

### Fully Automated Release Workflow
1. **Push commits** to `main` branch
2. **Unified release workflow** (`.github/workflows/release.yml`):
   - Triggers on every push to main
   - Detects `feat:` or `fix:` commits since last tag
   - Auto-bumps version (minor for `feat:`, patch for `fix:`)
   - Creates git tag and pushes it
   - Builds release APK
   - Generates grouped changelog
   - Creates GitHub Release with SHA256 checksum

### Manual Bump (Optional)
If you need to force a specific version:
```bash
./scripts/bump_version.sh --patch    # 1.0.x
./scripts/bump_version.sh --minor    # 1.x.0
./scripts/bump_version.sh --major    # x.0.0
git push origin main --tags
```

---

## Catatan Penting

### Prinsip SOLID yang Diterapkan (100% Compliance)

- **Single Responsibility (SRP)**: ✅ 100% compliance
  - 16/16 violations addressed
  - Repository segregation (10+ segregated interfaces)
  - Controller extraction (3 controllers)
  - Service segregation (4 insight services)

- **Open/Closed Principle (OCP)**: ✅ Applied
  - Repository pattern for extensibility
  - Strategy pattern for business logic
  - Abstract classes for open extension

- **Liskov Substitution Principle (LSP)**: ✅ Applied
  - All repositories substitutable
  - Consistent interface contracts

- **Interface Segregation Principle (ISP)**: ✅ 100% compliance
  - 10+ small, focused interfaces
  - Clients only depend on methods they use

- **Dependency Inversion Principle (DIP)**: ✅ Applied
  - All dependencies inverted
  - Clean Architecture layering
  - Dependency injection via Riverpod

---

## Documentation Quick Links

### Guides (English)
- [AI_ASSISTANT_GUIDE.md](../AI_ASSISTANT_GUIDE.md) - **HIGH PRIORITY** - Quick reference for AI assistants
- [ARCHITECTURE.md](../guides/ARCHITECTURE.md) - Complete Clean Architecture guide with real examples
- [RIVERPOD_GUIDE.md](../guides/RIVERPOD_GUIDE.md) - Riverpod 3.3.1 with @riverpod annotation
- [FREEZED_GUIDE.md](../guides/FREEZED_GUIDE.md) - Freezed 3.x with abstract keyword requirement
- [CODING_STANDARDS.md](../guides/CODING_STANDARDS.md) - File naming, imports, documentation
- [SOLID.md](../guides/SOLID.md) - SOLID principles with real codebase examples

### Design (English)
- [DESIGN_SYSTEM_GUIDE.md](../design/DESIGN_SYSTEM_GUIDE.md) - Glassmorphism design system with Riverpod 3.x integration

### Product (Indonesian)
- [00-PRD.md](../product/00-PRD.md) - Product Requirements Document
- [01-SPEC-LOG-001-Pencatatan-Transaksi-Manual.md](../product/01-SPEC-LOG-001-Pencatatan-Transaksi-Manual.md) - Manual transaction entry spec
- [02-SPEC-LOG-002-Input-via-Struk-OCR.md](../product/02-SPEC-LOG-002-Input-via-Struk-OCR.md) - OCR receipt scanning spec
- [03-SPEC-LOG-003-Ringkasan-Bulanan-Insight.md](../product/03-SPEC-LOG-003-Ringkasan-Bulanan-Insight.md) - Monthly summary spec
- [04-SPEC-LOG-004-Manajemen-Kategori.md](../product/04-SPEC-LOG-004-Manajemen-Kategori.md) - Category management spec

### Product (English Translations)
- [EN-01-SPEC-LOG-001-Manual-Transaction-Entry.md](../product/EN-01-SPEC-LOG-001-Manual-Transaction-Entry.md)
- [EN-02-SPEC-LOG-002-OCR-Receipt-Scanning.md](../product/EN-02-SPEC-LOG-002-OCR-Receipt-Scanning.md)
- [EN-03-SPEC-LOG-003-Monthly-Summary-Insights.md](../product/EN-03-SPEC-LOG-003-Monthly-Summary-Insights.md)
- [EN-04-SPEC-LOG-004-Category-Management.md](../product/EN-04-SPEC-LOG-004-Category-Management.md)

### Project (English)
- [REFACTORING_HISTORY.md](REFACTORING_HISTORY.md) - Complete SOLID refactoring journey
- [TEST_COVERAGE.md](TEST_COVERAGE.md) - Test coverage documentation (911 tests)
- [IMPLEMENTATION_STATUS.md](../product/IMPLEMENTATION_STATUS.md) - Verification dashboard for all SPEC checklists
- [CHECKLIST_VERIFICATION.md](../product/CHECKLIST_VERIFICATION.md) - Verification methodology

---
- **Single Responsibility**: Setiap class memiliki satu tanggung jawab
- **Open/Closed**: Open for extension, closed for modification
- **Liskov Substitution**: Subtype dapat diganti dengan base type
- **Interface Segregation**: Interface kecil dan fokus
- **Dependency Inversion**: Bergantung pada abstraksi, bukan konkretnya

---

## Teknologi Stack

| Komponen | Teknologi | Versi | Tujuan |
|----------|-----------|-------|--------|
| **Framework** | Flutter | 3.x | Framework UI cross-platform |
| **Bahasa** | Dart | 3.5.0+ | Bahasa aplikasi |
| **State Management** | Riverpod | 3.3.1 | Manajemen state reaktif dengan @riverpod annotation |
| **Riverpod Annotation** | riverpod_annotation | 4.0.2 | Code generation untuk Riverpod |
| **Riverpod Generator** | riverpod_generator | 4.0.3 | Generasi provider otomatis |
| **Navigasi** | GoRouter | 17.1.0 | Routing bertipe aman dengan deep linking |
| **GoRouter Builder** | go_router_builder | 4.2.0 | Type-safe routing |
| **Database** | SQLite (sqflite) | 2.4.1 | Persistensi data lokal |
| **Database Schema** | SchemaManager | 2.0 | Schema management dengan migration support |
| **OCR** | Google ML Kit | 0.15.1 | Ekstraksi teks struk |
| **Charts** | fl_chart | 1.2.0 | Visualisasi data |
| **Code Generation** | build_runner | 2.4.13 | Generasi provider Riverpod dan Freezed |
| **Immutable Data** | Freezed | 3.2.5 | Class data immutable dengan abstract keyword |
| **Freezed Annotation** | freezed_annotation | 3.1.0 | Annotation untuk Freezed classes |

---

## Arsitektur

### Clean Architecture dengan Repository Segregation

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  • Screens (TransactionListScreen, dll.)                   │
│  • Widgets (Komponen reusable dengan Glassmorphism)        │
│  • Providers (Riverpod @riverpod AsyncNotifiers)           │
│  • Controllers (Business logic controllers)                │
│  • Utils (Sistem desain, formatter, mixins)                │
└─────────────────────────────────────────────────────────────┘
│                         ↓ depends on ↓                        │
├─────────────────────────────────────────────────────────────┤
│                      DOMAIN LAYER                            │
│  • Entities (TransactionEntity, CategoryEntity)            │
│  • UseCases (AddTransaction, GetCategories, dll.)          │
│  • Repository Interfaces (Segregated by operation)          │
│    - TransactionReadRepository                             │
│    - TransactionWriteRepository                            │
│    - TransactionQueryRepository                            │
│    - TransactionSearchRepository                           │
│    - TransactionAnalyticsRepository                        │
│    - TransactionExportRepository                           │
│  • Services (ExportService, InsightService)                │
│  • Parsers (Receipt parsers dengan SRP)                    │
└─────────────────────────────────────────────────────────────┘
│                         ↑ implemented by ↑                    │
├─────────────────────────────────────────────────────────────┤
│                       DATA LAYER                             │
│  • Repository Implementations (Segregated)                  │
│    - transaction_read_repository_impl.dart                 │
│    - transaction_write_repository_impl.dart                │
│    - dll.                                                  │
│  • DataSources (DatabaseHelper, SchemaManager)             │
│  • Models (TransactionModel, CategoryModel)                │
│  • Services (Platform: OCR, ImagePicker, dll.)             │
└─────────────────────────────────────────────────────────────┘
```

### Repository Segregation Pattern

**Transaction Repositories (6 interfaces)**:
- `TransactionReadRepository` - Get operations
- `TransactionWriteRepository` - Add/update operations
- `TransactionQueryRepository` - Query operations
- `TransactionSearchRepository` - Search operations
- `TransactionAnalyticsRepository` - Analytics operations
- `TransactionExportRepository` - Export operations

**Category Repositories (4 interfaces)**:
- `CategoryReadRepository` - Read operations
- `CategoryWriteRepository` - Write operations
- `CategoryManagementRepository` - Management operations
- `CategorySeedingRepository` - Seeding operations

### Clean Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  • Screens (TransactionListScreen, dll.)                   │
│  • Widgets (Komponen reusable)                             │
│  • Providers (Riverpod AsyncNotifiers)                     │
│  • Utils (Sistem desain, formatter)                        │
└─────────────────────────────────────────────────────────────┘
│                         ↓ depends on ↓                        │
├─────────────────────────────────────────────────────────────┤
│                      DOMAIN LAYER                            │
│  • Entities (TransactionEntity, CategoryEntity)            │
│  • UseCases (AddTransaction, GetMonthlySummary)            │
│  • Repository Interfaces (Kontrak)                         │
│  • Services (InsightService, ExportService)                │
└─────────────────────────────────────────────────────────────┘
│                         ↑ implemented by ↑                    │
├─────────────────────────────────────────────────────────────┤
│                       DATA LAYER                             │
│  • Repository Implementations                              │
│  • DataSources (DatabaseHelper, ML Kit)                    │
│  • Models (DTOs, mappers)                                  │
│  • Services (OCR, ImagePicker, Permissions)                │
└─────────────────────────────────────────────────────────────┘
```

### Prinsip Utama

- **Dependency Inversion**: Modul high-level bergantung pada abstraksi
- **Single Responsibility**: Setiap class memiliki satu alasan untuk berubah
- **Interface Segregation**: Interface kecil dan fokus
- **Open/Closed**: Open for extension, closed for modification
- **Liskov Substitution**: Subtype dapat diganti dengan base type

---

## Kualitas Kode

### Sistem Desain ✅

- **AppSpacing**: Grid 4px (xs: 4px, sm: 8px, md: 12px, lg: 16px, xl: 20px, xxl: 24px, xxxl: 32px)
- **AppRadius**: Border radius konsisten (xs: 4px, sm: 8px, md: 12px, lg: 16px, xl: 20px, xxl: 24px, circle: 999px)
- **AppGlassContainer**: Variants glassmorphism (glassCard, glassSurface, glassPill, glassNavigation)
- **Base Widgets**: AppContainer, AppEmptyState, AppErrorState, AppShimmer
- **Formatters**: AppDateFormatter, CurrencyFormatter, TransactionFormatter
- **Mixins**: ScreenStateMixin, ConsumerScreenStateMixin

**Status**: ✅ Selesai (31 file refactored, ~301 is resolved)

**Lihat**: [DESIGN_SYSTEM_GUIDE.md](../design/DESIGN_SYSTEM_GUIDE.md)

### SOLID Principles ✅

Proyek ini mengikuti prinsip SOLID. Lihat [SOLID.md](../../../guides/SOLID.md) untuk panduan lengkap.

---

## Skema Database

### Tabel Categories

| Kolom | Tipe | Deskripsi |
|-------|------|-----------|
| id | INTEGER | Primary key |
| name | TEXT | Nama kategori |
| type | TEXT | 'income' atau 'expense' |
| color | TEXT | Kode warna hex |
| icon | TEXT | Identifier icon |
| sort_order | INTEGER | Urutan tampilan |
| is_active | INTEGER | 0=inactive, 1=active |
| created_at | TEXT | ISO datetime |
| updated_at | TEXT | ISO datetime |

**Indexes**: type, is_active

### Tabel Transactions

| Kolom | Tipe | Deskripsi |
|-------|------|-----------|
| id | INTEGER | Primary key |
| amount | REAL | Jumlah transaksi |
| type | TEXT | 'income' atau 'expense' |
| date_time | TEXT | ISO datetime |
| category_id | INTEGER | Foreign key → categories |
| note | TEXT | Catatan opsional |
| created_at | TEXT | ISO datetime |
| updated_at | TEXT | ISO datetime |

**Indexes**: date_time, category_id, type, (date_time+type), (month+type)

---

## Dokumen Terkait

### Dokumen Produk
- [00-PRD.md](../product/00-PRD.md) - Product Requirements Document
- [01-SPEC-LOG-001-Pencatatan-Transaksi-Manual.md](../product/01-SPEC-LOG-001-Pencatatan-Transaksi-Manual.md) - Spesifikasi fitur transaksi manual
- [02-SPEC-LOG-002-Input-via-Struk-OCR.md](../product/02-SPEC-LOG-002-Input-via-Struk-OCR.md) - Spesifikasi fitur OCR
- [03-SPEC-LOG-003-Ringkasan-Bulanan-Insight.md](../product/03-SPEC-LOG-003-Ringkasan-Bulanan-Insight.md) - Spesifikasi ringkasan bulanan
- [04-SPEC-LOG-004-Manajemen-Kategori.md](../product/04-SPEC-LOG-004-Manajemen-Kategori.md) - Spesifikasi manajemen kategori

### Dokumen Desain
- [DESIGN_SYSTEM_GUIDE.md](../design/DESIGN_SYSTEM_GUIDE.md) - Panduan sistem desain lengkap

### Dokumen Proyek
- [PROJECT_STATUS.md](./PROJECT_STATUS.md) - Status proyek terkini (termasuk ringkasan refactoring SRP)

### Panduan Pengembangan
- [SOLID.md](../../guides/SOLID.md) - Panduan prinsip SOLID
- [CLAUDE.md](../../../CLAUDE.md) - Panduan pengembangan untuk Claude Code

---

## Langkah Selanjutnya

### Prioritas Tinggi 🔴

1. **✅ REFACTORING SRP SELESAI 100%**
   - Semua 6 fase selesai
   - 16 / 16 violations addressed (100%)
   - SRP Compliance tercapai

### Prioritas Sedang 🟡

2. **Testing**
   - Tambah unit tests untuk domain layer
   - Tambah widget tests untuk komponen UI
   - Tambah integration tests untuk flow end-to-end

3. **Optimasi**
   - Review dan optimasi performa database
   - Optimasi ukuran aplikasi
   - Review penggunaan memori

### Prioritas Rendah 🟢

4. **Dokumentasi**
   - Tambah inline documentation untuk API publik
   - Buat user guide untuk end-user
   - Buat contributor guide untuk developer

5. **Fitur v2 (Rencana)**
   - ✅ PRD v2 completed → See [docs/v2/product/00-PRD.md](../v2/product/00-PRD.md)
   - Google Drive Backup/Restore
   - Full Budgeting
   - Savings Goals
   - Dark Mode
   - Enhanced Reports

---

## Roadmap v2 - Cloud, Budgeting & Enhanced Features

**Status**: 📝 Planning Phase
**Target**: Short-term (2-3 months)
**PRD**: [docs/v2/product/00-PRD.md](../v2/product/00-PRD.md)

### Features Planned

| Feature | Description | Priority |
|---------|-------------|----------|
| **Google Drive Backup/Restore** | Manual backup/restore via Google Drive | P0 |
| **Full Budgeting** | Budget per category with alerts | P0 |
| **Savings Goals** | Target savings with progress tracking | P0 |
| **Dark Mode** | Dark theme for the app | P1 |
| **Enhanced Reports** | More detailed monthly financial reports | P1 |

### Timeline

| Phase | Duration | Focus |
|-------|----------|-------|
| Phase 1 | Week 1-2 | Database schema + Dark mode |
| Phase 2 | Week 3-4 | Full Budgeting |
| Phase 3 | Week 5-6 | Savings Goals |
| Phase 4 | Week 7-8 | Google Drive Backup |
| Phase 5 | Week 9-10 | Enhanced Reports |
| Phase 6 | Week 11-12 | Polish & Testing |

### New Dependencies

| Package | Purpose |
|---------|---------|
| google_sign_in | OAuth for Google Drive |
| googleapis | Google Drive API v3 |
| extension_google_sign_in_as_googleapis_auth | Auth adapter |

### Database Schema Changes

**New Tables:**
- `budgets` - Budget per category per month
- `savings_goals` - Savings targets
- `goal_contributions` - Goal contribution history

---

## Roadmap v1.3 - Home Screen Widgets

**Status**: ✅ Selesai (7 April 2026)

### Fitur yang Diimplementasikan

| Fitur | Status | Deskripsi |
|-------|--------|-----------|
| **Widget Data Layer** | ✅ Selesai | WidgetDataEntity, WidgetRepository, WidgetLocalDatasource |
| **Widget Provider** | ✅ Selesai | WidgetNotifier untuk update data widget |
| **Android Widget** | ✅ Selesai | ExpenseWidgetProvider dengan home_widget 0.9.0 |
| **iOS Widget** | ✅ Selesai | SwiftUI widget dengan TimelineProvider |
| **Deep Linking** | ✅ Selesai | URL scheme catatcuan://widget/add |

### File Baru (22 files)

**Flutter Layer (7 files)**:
- `lib/domain/entities/widget/widget_data_entity.dart` - Widget data entity
- `lib/domain/entities/widget/widget_data_serializer.dart` - JSON serializer
- `lib/domain/repositories/widget/widget_repository.dart` - Repository interface
- `lib/data/repositories/widget/widget_repository_impl.dart` - Implementation
- `lib/data/datasources/widget/widget_local_datasource.dart` - home_widget integration
- `lib/presentation/providers/widget/widget_provider.dart` - Riverpod provider

**Android (5 files)**:
- `android/app/src/main/kotlin/.../widget/ExpenseGlanceWidget.kt` - GlanceAppWidget
- `android/app/src/main/kotlin/.../widget/WidgetData.kt` - Data model
- `android/app/src/main/res/xml/widget_info.xml` - Widget configuration
- `android/app/src/main/res/layout/widget_loading.xml` - Loading layout
- `android/app/src/main/res/values/strings.xml` - String resources

**iOS (4 files)**:
- `ios/Runner/Widgets/ExpenseWidgetData.swift` - Data model
- `ios/Runner/Widgets/ExpenseWidgetProvider.swift` - TimelineProvider
- `ios/Runner/Widgets/ExpenseWidgetView.swift` - SwiftUI view
- `ios/Runner/ExpenseBundle.swift` - Widget bundle

**Configuration Files (3 files)**:
- `pubspec.yaml` - home_widget: ^0.9.0
- `android/app/build.gradle.kts` - Glance dependencies
- `android/app/src/main/AndroidManifest.xml` - Widget registration + deep links
- `ios/Runner/Info.plist` - URL scheme configuration
- `lib/presentation/navigation/routes/app_router.dart` - Deep link route

### Dependencies Updated
- `home_widget`: ^0.5.0 → ^0.9.0 (Flutter 3.41 compatibility)
- `androidx.glance:glance-appwidget:1.0.0` (Android widget)
- `androidx.glance:glance-material3:1.0.0` (Android widget)

### Cara Menggunakan Widget

**Android:**
1. Long press pada home screen
2. Pilih "Widgets"
3. Cari "Catat Cuan"
4. Pilih ukuran (small/medium/large)

**iOS:**
1. Long press pada home screen
2. Pilih "Edit"
3. Pilih "+" di pojok kiri atas
4. Cari "Catat Cuan"
5. Pilih ukuran (small/medium/large)

**Tap Widget:**
- Widget akan membuka aplikasi ke form tambah transaksi
- Data widget otomatis update setelah ada transaksi baru

---

## Roadmap v1.4 - Enhanced AI Model

**Status**: ✅ Selesai (7 April 2026)

### Fitur yang Diimplementasikan

| Fitur | Status | Deskripsi |
|-------|--------|-----------|
| **ML Kit Latin Script Configuration** | ✅ Selesai | TextRecognitionScript.latin untuk teks Indonesia |
| **Merchant Pattern Library** | ✅ Selesai | 50+ pola merchant Indonesia |
| **Merchant Name Parser** | ✅ Selesai | Ekstraksi nama merchant dari teks struk |
| **Category Prediction** | ✅ Selesai | Prediksi kategori berdasarkan merchant |
| **UI Update** | ✅ Selesai | Tampilkan nama merchant di hasil scan |

### File Baru (4 files)

**Domain Layer (3 files)**:
- `lib/domain/entities/merchant_pattern_entity.dart` - MerchantPatternEntity & MerchantParseResult
- `lib/domain/services/merchant_pattern_service.dart` - Service interface untuk merchant pattern matching
- `lib/domain/parsers/receipt_merchant_parser.dart` - Parser untuk ekstraksi nama merchant

**Data Layer (1 file)**:
- `lib/data/services/indonesian_merchant_pattern_service_impl.dart` - 50+ pola merchant Indonesia

### File Dimodifikasi (5 files)
- `lib/data/services/receipt_ocr_service_impl.dart` - Added TextRecognitionScript.latin
- `lib/domain/usecases/scan_receipt.dart` - Integrasi merchant extraction
- `lib/presentation/providers/services/service_providers.dart` - New providers
- `lib/presentation/screens/scan_receipt_screen.dart` - Tampilkan nama merchant
- `test/domain/usecases/scan_receipt_usecase_test.dart` - Updated tests

### Merchant yang Didukung (50+ pola)

**Minimarkets (10)**: Indomaret, Alfamart, Superindo, Giant, Lotte Mart, Hypermart, Lawson, Circle K, 7-Eleven, Transmart

**Coffee Shops & Cafes (8)**: Starbucks, Excelso, Coffee Bean, J.Co, Dunkin', Kopi Kenangan, Janji Jiwa, Coffee Toffee

**Fast Food (10)**: KFC, McDonald's, Burger King, Pizza Hut, Domino's, Hokben, A&W, Texas Chicken, Yoshinoya, Pepper Lunch

**Food Delivery (3)**: GoFood, GrabFood, ShopeeFood

**E-commerce (7)**: Tokopedia, Shopee, Lazada, Blibli, Bukalapak, JD.ID, TikTok Shop

**Transportation (6)**: Traveloka, Gojek, Grab, Blue Bird, Maxim, inDrive

**Utilities/Bills (9)**: PLN, PDAM, Telkom, XL, Telkomsel, Indosat, Tri, Smartfren, Netflix, Spotify

**Gas Stations (2)**: Pertamina, Shell

**Pharmacies (3)**: Kimia Farma, K-24, Century Healthcare

### Cara Menggunakan

1. Scan struk seperti biasa
2. Jika merchant dikenali, nama toko akan muncul di hasil scan
3. Kategori default akan disarankan berdasarkan merchant
4. User dapat mengedit nama merchant dan kategori sesuai kebutuhan

### Technical Details

- **Confidence Scoring**: Amount (40%) + DateTime (30%) + Merchant (30%)
- **Pattern Matching**: Header matching (95% confidence), Keyword matching (70%+ confidence), Pattern matching (60%+ confidence)
- **Category Mapping**: Setiap merchant memiliki kategori default (e.g., Indomaret → Belanja Harian)
- **Performance**: < 100ms untuk merchant extraction

---

---

## Perintah Umum

### Pengembangan
```bash
flutter pub get              # Install dependencies
flutter run                  # Run di device/emulator yang terhubung
flutter run --debug          # Debug mode
flutter run --release        # Release mode
```

### Building
```bash
# Android
flutter build apk            # Debug APK
flutter build appbundle      # Release App Bundle (untuk Play Store)

# iOS
flutter build ios            # iOS build

# Platform lain
flutter build macos
flutter build linux
flutter build windows
```

### Testing
```bash
flutter test                 # Jalankan semua tests
flutter test test/widget_test.dart  # Jalankan file test spesifik
```

### Code Generation
```bash
# Untuk Riverpod/Freezed code generation
flutter pub run build_runner build --delete-conflicting-outputs
flutter pub run build_runner watch  # Watch untuk perubahan
```

---

## Lokasi File Penting

### File Core
- `lib/main.dart` - Entry point aplikasi dengan ProviderScope
- `lib/presentation/providers/app_providers.dart` - Registry provider utama
- `lib/data/datasources/local/database_helper.dart` - Schema database dan migrations
- `lib/domain/usecases/` - Operasi business logic

### UI Components
- `lib/presentation/screens/` - Widget full-screen
- `lib/presentation/widgets/` - Komponen reusable
- `lib/presentation/utils/` - Utilitas sistem desain
- `lib/presentation/widgets/base/` - Base widgets

---

## Lokalisasi

Semua konten dalam Bahasa Indonesia (id_ID):

- **Format Tanggal**: DD/MM/YYYY atau "13 Januari 2024"
- **Mata Uang**: Rp dengan thousand separator (contoh: "1.000.000")
- **Tanggal Relatif**: "Hari ini", "Kemarin", dll.
- **Label UI**: Semua string dalam Bahasa Indonesia

---

## Coding Standards

### English-Only Comments (⚠️ MANDATORY)

**Effective**: 8 April 2026

All code comments, documentation, and annotations MUST be written in English.

**Why**: English is the universal language of software development, ensuring:
- Codebase accessibility to international contributors
- Consistency with standard programming terminology
- Better collaboration in open-source environments
- Alignment with Flutter/Dart ecosystem conventions

**Scope**:
- ✅ All code comments (`//`, `///`, `/* */`)
- ✅ Documentation comments
- ✅ TODO comments
- ✅ Variable/Function naming (always English)
- ❌ User-facing strings (UI text remains Indonesian)

**Documentation**:
- See [CODING_STANDARDS.md](../guides/CODING_STANDARDS.md#language-requirements) for details
- See [AI_ASSISTANT_GUIDE.md](../AI_ASSISTANT_GUIDE.md#critical-rule-9-code-comments-must-be-in-english) for AI guidelines

**Status**: ✅ Enforced - All code comments converted to English

---

## Status Proyek

**✅ v1 100% SELESAI** - Semua persyaratan PRD diimplementasikan dengan peningkatan tambahan.

**✅ REFACTORING SRP 100% SELESAI** - Semua 16 pelanggaran SRP telah diatasi. Codebase sekarang mematuhi prinsip Single Responsibility Principle.

**Siap untuk produksi.** Kualitas kode optimal dengan SRP compliance tercapai.
