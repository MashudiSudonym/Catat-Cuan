# Architecture Patterns — Catat Cuan v2

**Domain:** Personal finance app (Flutter) adding budgeting, savings goals, cloud backup, dark mode, and enhanced reports
**Researched:** 2026-05-06
**Overall Confidence:** HIGH (analyzing existing codebase + well-documented PRD)

---

## Recommended Architecture

**Verdict:** Extend the existing Clean Architecture with repository segregation. Do not introduce new architectural patterns — the existing structure (domain/data/presentation with ISP-compliant repositories) is proven with 954 tests and cleanly accommodates all v2 features.

### System Overview (v2)

```text
┌──────────────────────────────────────────────────────────────────────────────────┐
│                            Presentation Layer                                     │
│  `lib/presentation/`                                                             │
├──────────┬──────────┬───────────┬──────────┬──────────┬──────────┬───────────────┤
│ Screens  │Providers │Controllers│ Widgets  │ States   │ Utils    │ Navigation    │
│(6 tabs)  │(feature) │(forms)    │(shared)  │(Freezed) │(theme,   │(GoRouter +    │
│          │          │           │          │          │ charts)  │ 3 tabs → 4)   │
└────┬─────┴────┬─────┴─────┬─────┴────┬─────┴────┬─────┴────┬─────┴───────────────┘
     │          │           │          │          │          │
     │  Riverpod DI         │          │          │          │
     ▼          ▼           ▼          ▼          ▼          ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│                             Domain Layer                                          │
│  `lib/domain/`                                                                   │
├──────────┬──────────┬───────────┬──────────┬──────────┬──────────┬───────────────┤
│ Use Cases│Entities  │Repository │Services  │Failures  │Validators│ Parsers       │
│(v2 ops)  │(Budget,  │Interfaces │(Backup,  │(Backup,  │(Budget,  │               │
│          │Goal,     │(segregated│Auth)     │Auth)     │Goal)     │               │
│          │Contrib)  │by agg)    │          │          │          │               │
└──────────┴──────────┴─────┬─────┴──────────┴──────────┴──────────┴───────────────┘
                            │ (interfaces only)
                            ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│                              Data Layer                                           │
│  `lib/data/`                                                                     │
├──────────┬──────────┬───────────┬──────────┬──────────────────────────────────────┤
│Repository│ Models   │Data Sources│Services  │                                      │
│Impls     │(Budget,  │(local +   │(Google   │                                      │
│(matching │Goal,     │ drive)    │Drive,    │                                      │
│segregated│Contrib)  │           │Auth)     │                                      │
│ifaces)   │          │           │          │                                      │
└──────────┴──────────┴─────┬─────┴──────────┴──────────────────────────────────────┘
                            │
              ┌─────────────┼──────────────────┐
              ▼             ▼                   ▼
      ┌──────────────┐ ┌────────────────┐ ┌──────────────────┐
      │SQLite (local) │ │Google Drive    │ │Secure Storage    │
      │catat_cuan.db  │ │(appdata scope) │ │(auth tokens)     │
      │Schema v3      │ │                │ │                  │
      └──────────────┘ └────────────────┘ └──────────────────┘
```

---

## Component Boundaries

### New Domain Components

| Component | Layer | Responsibility | Communicates With |
|-----------|-------|----------------|-------------------|
| `BudgetEntity` | Domain | Immutable budget data (categoryId, amount, period) | Use cases → Repository interfaces |
| `SavingsGoalEntity` | Domain | Immutable savings goal data (name, target, current, status) | Use cases → Repository interfaces |
| `GoalContributionEntity` | Domain | Immutable contribution/withdrawal records | Use cases → Repository interfaces |
| `BudgetReadRepository` | Domain | Interface: get budgets by period, get budget by category+period | BudgetRepositoryImpl |
| `BudgetWriteRepository` | Domain | Interface: create, update, delete budget | BudgetRepositoryImpl |
| `BudgetTrackingRepository` | Domain | Interface: get spent amount per category per period | BudgetRepositoryImpl (reads transactions) |
| `GoalReadRepository` | Domain | Interface: get goals (active, completed, all), get by ID | GoalRepositoryImpl |
| `GoalWriteRepository` | Domain | Interface: create, update (soft delete via status change) | GoalRepositoryImpl |
| `ContributionReadRepository` | Domain | Interface: get contributions by goal, get by date range | ContributionRepositoryImpl |
| `ContributionWriteRepository` | Domain | Interface: add contribution, add withdrawal | ContributionRepositoryImpl |
| `BackupService` (interface) | Domain | Abstract backup/restore contract | BackupServiceImpl (data layer) |
| `AuthService` (interface) | Domain | Abstract Google auth contract | AuthServiceImpl (data layer) |
| `BackupFailure` | Domain | Typed failure for backup errors | Result monad |
| `AuthFailure` | Domain | Typed failure for authentication errors | Result monad |
| `BudgetValidator` | Domain | Validate budget amount, period uniqueness | Budget use cases |
| `GoalValidator` | Domain | Validate goal name, target amount, contribution constraints | Goal use cases |

### New Data Components

| Component | Responsibility | Implements |
|-----------|----------------|------------|
| `BudgetModel` | Freezed model with `fromMap()`/`toMap()`/`toEntity()` | Maps DB rows ↔ `BudgetEntity` |
| `SavingsGoalModel` | Freezed model for goals | Maps DB rows ↔ `SavingsGoalEntity` |
| `GoalContributionModel` | Freezed model for contributions | Maps DB rows ↔ `GoalContributionEntity` |
| `BudgetReadRepositoryImpl` | SQLite queries for budget reads | `BudgetReadRepository` |
| `BudgetWriteRepositoryImpl` | SQLite inserts/updates/deletes for budgets | `BudgetWriteRepository` |
| `BudgetTrackingRepositoryImpl` | Cross-table queries (transactions + budgets) | `BudgetTrackingRepository` |
| `GoalReadRepositoryImpl` | SQLite queries for goals | `GoalReadRepository` |
| `GoalWriteRepositoryImpl` | SQLite writes for goals | `GoalWriteRepository` |
| `ContributionReadRepositoryImpl` | SQLite queries for contributions | `ContributionReadRepository` |
| `ContributionWriteRepositoryImpl` | SQLite writes for contributions | `ContributionWriteRepository` |
| `GoogleDriveBackupServiceImpl` | Google Drive API v3 backup/restore | `BackupService` |
| `GoogleAuthServiceImpl` | google_sign_in + secure token storage | `AuthService` |
| `BackupMetadataModel` | JSON serialization for backup manifest | N/A (data-only) |

### New Presentation Components

| Component | Responsibility | Location |
|-----------|----------------|----------|
| `BudgetScreen` | Budget list with progress bars | `screens/` |
| `BudgetFormScreen` | Create/edit budget per category | `screens/` |
| `SavingsGoalScreen` | Goals list with circular progress | `screens/` |
| `GoalFormScreen` | Create/edit goal | `screens/` |
| `ContributionFormScreen` | Add contribution/withdrawal | `screens/` |
| `EnhancedReportScreen` | Tabbed daily/weekly/monthly/yearly charts | `screens/` |
| `BackupSettingsScreen` | Backup/restore controls + status | `screens/` (or section in Settings) |
| Budget providers | State management for budgets | `providers/budget/` |
| Goal providers | State management for goals + contributions | `providers/goal/` |
| Report providers | State management for enhanced reports | `providers/report/` |
| Backup providers | State management for backup/restore | `providers/backup/` |
| `BudgetOverviewCard` | Home screen budget summary widget | `widgets/` |
| `GoalOverviewCard` | Home screen goals summary widget | `widgets/` |
| `BudgetProgressBar` | Reusable budget progress indicator | `widgets/` |
| `GoalProgressRing` | Reusable circular goal progress | `widgets/` |
| `ConfettiCelebration` | Goal completion celebration overlay | `widgets/` |

---

## Repository Segregation for New Features

### Budget Aggregate (3 interfaces)

Following the existing ISP pattern (Category has 4, Transaction has 6+):

```text
lib/domain/repositories/budget/
├── budget_read_repository.dart         # getBudgetsByPeriod, getBudgetByCategoryAndPeriod
├── budget_write_repository.dart        # createBudget, updateBudget, deleteBudget
├── budget_tracking_repository.dart     # getSpentByCategoryAndPeriod, getBudgetOverview
└── budget_repositories.dart            # barrel export
```

**Why 3, not fewer:**
- `BudgetTrackingRepository` needs to JOIN transactions + budgets — it's a cross-aggregate query concern, not a simple read. Separating it keeps read operations (fetching budget records) distinct from analytics (computing spent vs budget).
- Write operations follow the same pattern as existing `CategoryWriteRepository` / `TransactionWriteRepository`.

### Savings Goal Aggregate (4 interfaces)

```text
lib/domain/repositories/goal/
├── goal_read_repository.dart           # getActiveGoals, getGoalById, getCompletedGoals
├── goal_write_repository.dart          # createGoal, updateGoal (including soft-delete)
├── contribution_read_repository.dart   # getContributionsByGoal, getContributionsByDateRange
├── contribution_write_repository.dart  # addContribution, addWithdrawal
└── goal_repositories.dart              # barrel export
```

**Why 4:**
- Goals and contributions are distinct aggregates (a goal has many contributions). Each has its own read/write split.
- Contribution write is separate from goal write because the operations are fundamentally different (add amount vs update metadata).
- Soft delete (status = cancelled) goes in `GoalWriteRepository` — it's an update, not a special operation.

### Backup (Service interface, not repository)

```text
lib/domain/services/
├── backup_service.dart                 # backupToCloud, restoreFromCloud, listBackups
├── auth_service.dart                   # signIn, signOut, isAuthenticated, getAuthHeaders
```

**Why service, not repository:**
- Backup doesn't map to a local database table — it's a cross-cutting infrastructure concern that serializes the entire database state to/from cloud storage.
- The existing pattern for cross-cutting services (`OcrService`, `PermissionService`, `ImagePickerService`) is a domain interface with data-layer implementation. Backup follows this exactly.

---

## Data Flow

### Budget Tracking Flow (cross-aggregate query)

```text
User opens BudgetScreen
    │
    ▼
BudgetListProvider (Riverpod, @riverpod)
    │ watches: currentPeriodProvider
    │ calls: GetBudgetsByPeriodUseCase
    │
    ▼
GetBudgetsByPeriodUseCase
    │ reads: BudgetReadRepository.getBudgetsByPeriod(month, year)
    │ reads: BudgetTrackingRepository.getSpentByCategoryAndPeriod(month, year)
    │ combines: budget.amount + spent → progress, remaining, status
    │ returns: List<BudgetWithProgressEntity> (presentation-friendly composite)
    │
    ▼
UI renders: BudgetProgressBar (green/yellow/red based on percentage)
```

**Key insight:** `BudgetTrackingRepository` reads from BOTH `budgets` and `transactions` tables. It's the only repository that crosses aggregate boundaries. This is acceptable because:
1. It's a read-only analytics concern (no writes)
2. The alternative (passing spent data from transaction repo up to use case and computing in use case) creates more coupling in the presentation layer
3. The SQL JOIN is efficient: `SELECT b.*, COALESCE(SUM(t.amount), 0) as spent FROM budgets b LEFT JOIN transactions t ON ...`

### Savings Goal Contribution Flow

```text
User adds contribution on GoalDetailScreen
    │
    ▼
AddContributionController (presentation controller)
    │ calls: AddContributionUseCase
    │
    ▼
AddContributionUseCase
    │ validates: amount > 0, goal is active
    │ calls: ContributionWriteRepository.addContribution(contribution)
    │ calls: GoalWriteRepository.updateGoal(goal.copyWith(currentAmount: updated))
    │ checks: if currentAmount >= targetAmount → updateGoal(status: completed)
    │ returns: Result<GoalContributionEntity>
    │
    ▼
Database transaction (atomic):
    1. INSERT into goal_contributions
    2. UPDATE savings_goals SET current_amount = current_amount + contribution
    3. IF completed: UPDATE savings_goals SET status = 'completed'
    │
    ▼
UI: if goal completed → show ConfettiCelebration
```

**Critical:** The contribution + goal update must be atomic. Use `LocalDataSource.transaction()` (existing API at `lib/data/datasources/local/local_data_source.dart:92`) to wrap both operations.

### Google Drive Backup Flow

```text
User taps "Backup to Google Drive" in Settings
    │
    ▼
BackupProvider (Riverpod state: idle/authenticating/backing up/success/failure)
    │ checks: AuthService.isAuthenticated
    │   NO → triggers Google Sign-In flow
    │   YES → proceeds to backup
    │
    ▼
BackupToCloudUseCase
    │ calls: BackupService.backupToCloud()
    │
    ▼
GoogleDriveBackupServiceImpl
    │ 1. Reads all data from LocalDataSource (transactions, categories, budgets, goals, contributions)
    │ 2. Serializes to JSON with BackupMetadataModel (timestamp, device, version)
    │ 3. Gets auth headers from AuthService
    │ 4. Uploads to Google Drive appdata folder via googleapis
    │ returns: Result<BackupMetadata>
    │
    ▼
UI: Progress indicator → Success snackbar with timestamp
```

**Data serialization format:** JSON (not raw SQLite file). Rationale:
1. Schema migration safety — restoring from v3 to a future v4 app can map fields during deserialization
2. Human-readable for debugging
3. Smaller file size for typical datasets (<10K transactions = <2MB JSON)
4. Cross-platform restore potential (if iOS version is built later)

### Enhanced Reports Data Flow

```text
User switches to Reports tab → selects "Weekly" sub-tab
    │
    ▼
WeeklyReportProvider (Riverpod, @riverpod)
    │ watches: selectedMonthProvider
    │ calls: GetWeeklyBreakdownUseCase
    │
    ▼
GetWeeklyBreakdownUseCase
    │ reads: TransactionAnalyticsRepository (existing!)
    │   → rawQuery for grouped-by-week aggregation
    │ computes: weekly totals, week-over-week delta, burn rate
    │ returns: WeeklyBreakdownEntity
    │
    ▼
UI renders: BarChart (fl_chart) with interactive tap-for-detail
```

**Key insight:** Enhanced reports mostly extend the EXISTING `TransactionAnalyticsRepository`. New queries (weekly breakdown, month-over-month comparison, trend analysis) are additional methods on the existing interface, not a new repository. The domain service `InsightService` may also be extended for new insight types.

### Dark Mode Flow (already partially implemented)

```text
User selects theme in Settings
    │
    ▼
ThemeNotifier.setThemeMode(option)  [EXISTS at lib/presentation/providers/theme/theme_provider.dart]
    │ saves to SharedPreferences
    │ updates state → themeModeProvider rebuilds
    │
    ▼
AppWidget.build()  [EXISTS at lib/presentation/app/app_widget.dart]
    │ watches: themeModeProvider
    │ passes: themeMode to MaterialApp.router
    │
    ▼
AppTheme.lightTheme / AppTheme.darkTheme  [EXISTS at lib/presentation/utils/app_theme.dart]
    │ Applied via ColorScheme + component themes
    │ Glassmorphism colors via AppColors.getGlassXxx(isDark:)  [EXISTS]
```

**What already exists:**
- `AppTheme.lightTheme` and `AppTheme.darkTheme` — fully defined (477 lines in `app_theme.dart`)
- `AppColors` with `isDark` parameter for every glassmorphism color — fully defined
- `ThemeNotifier` with SharedPreferences persistence — fully defined
- `ThemeModeOption` enum (system/light/dark) — fully defined
- `AppWidget` already watches `themeModeProvider`

**What's needed:**
- Audit all existing screens/widgets for hardcoded light-mode colors (replace with `AppColors.getXxx(isDark:)` or `Theme.of(context)` calls)
- Add dark-mode-specific glassmorphism adjustments if contrast is insufficient
- Test glassmorphism blur effects on dark backgrounds

---

## Database Schema Changes

### Migration v2 → v3

```sql
-- New table: budgets
CREATE TABLE budgets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  category_id INTEGER NOT NULL,
  amount REAL NOT NULL CHECK(amount > 0),
  period_month INTEGER NOT NULL CHECK(period_month BETWEEN 1 AND 12),
  period_year INTEGER NOT NULL CHECK(period_year >= 2020),
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
  UNIQUE(category_id, period_month, period_year)
);

-- New table: savings_goals
CREATE TABLE savings_goals (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  target_amount REAL NOT NULL CHECK(target_amount > 0),
  current_amount REAL NOT NULL DEFAULT 0 CHECK(current_amount >= 0),
  target_date TEXT,
  icon TEXT NOT NULL DEFAULT '🎯',
  color TEXT NOT NULL DEFAULT '#EC5B13',
  status TEXT NOT NULL DEFAULT 'active' CHECK(status IN ('active', 'completed', 'cancelled')),
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

-- New table: goal_contributions
CREATE TABLE goal_contributions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  goal_id INTEGER NOT NULL,
  amount REAL NOT NULL CHECK(amount != 0),  -- positive = contribution, negative = withdrawal
  type TEXT NOT NULL CHECK(type IN ('contribution', 'withdrawal')),
  note TEXT,
  date TEXT NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (goal_id) REFERENCES savings_goals(id) ON DELETE CASCADE
);

-- Indexes for budget queries
CREATE INDEX idx_budgets_period ON budgets(period_year, period_month);
CREATE INDEX idx_budgets_category ON budgets(category_id);

-- Indexes for goal queries
CREATE INDEX idx_goals_status ON savings_goals(status);
CREATE INDEX idx_contributions_goal ON goal_contributions(goal_id);
CREATE INDEX idx_contributions_date ON goal_contributions(date DESC);
```

### Schema Manager Extension

```dart
// In DatabaseSchemaManager:
static const int currentVersion = 3;  // Bumped from 2

static Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    await _createMonthlyAggregationIndex(db);
  }
  if (oldVersion < 3) {
    await _createBudgetsTable(db);
    await _createBudgetsIndexes(db);
    await _createSavingsGoalsTable(db);
    await _createSavingsGoalsIndexes(db);
    await _createGoalContributionsTable(db);
    await _createGoalContributionsIndexes(db);
  }
}
```

### DatabaseHelper Extension

```dart
// Add new table name constants
static const String tableBudgets = 'budgets';
static const String tableSavingsGoals = 'savings_goals';
static const String tableGoalContributions = 'goal_contributions';

// Update clearAllTables to include new tables
Future<void> clearAllTables() async {
  final db = await database;
  await db.delete(tableGoalContributions);
  await db.delete(tableSavingsGoals);
  await db.delete(tableBudgets);
  await db.delete(tableTransactions);
  await db.delete(tableCategories);
}
```

---

## New File Structure

```text
lib/
├── domain/
│   ├── entities/
│   │   ├── budget_entity.dart                        # NEW
│   │   ├── budget_with_progress_entity.dart          # NEW (composite: budget + spent)
│   │   ├── savings_goal_entity.dart                  # NEW
│   │   ├── goal_contribution_entity.dart             # NEW
│   │   ├── weekly_breakdown_entity.dart              # NEW
│   │   ├── monthly_comparison_entity.dart            # NEW
│   │   └── backup_metadata_entity.dart               # NEW
│   ├── repositories/
│   │   ├── budget/                                    # NEW
│   │   │   ├── budget_read_repository.dart
│   │   │   ├── budget_write_repository.dart
│   │   │   ├── budget_tracking_repository.dart
│   │   │   └── budget_repositories.dart
│   │   └── goal/                                      # NEW
│   │       ├── goal_read_repository.dart
│   │       ├── goal_write_repository.dart
│   │       ├── contribution_read_repository.dart
│   │       ├── contribution_write_repository.dart
│   │       └── goal_repositories.dart
│   ├── services/
│   │   ├── backup_service.dart                        # NEW (interface)
│   │   └── auth_service.dart                          # NEW (interface)
│   ├── usecases/
│   │   ├── budget/                                    # NEW
│   │   │   ├── create_budget_usecase.dart
│   │   │   ├── update_budget_usecase.dart
│   │   │   ├── delete_budget_usecase.dart
│   │   │   ├── get_budgets_by_period_usecase.dart
│   │   │   └── get_budget_overview_usecase.dart
│   │   ├── goal/                                      # NEW
│   │   │   ├── create_goal_usecase.dart
│   │   │   ├── update_goal_usecase.dart
│   │   │   ├── add_contribution_usecase.dart
│   │   │   ├── add_withdrawal_usecase.dart
│   │   │   ├── get_active_goals_usecase.dart
│   │   │   └── get_goal_detail_usecase.dart
│   │   ├── backup/                                    # NEW
│   │   │   ├── backup_to_cloud_usecase.dart
│   │   │   ├── restore_from_cloud_usecase.dart
│   │   │   └── list_backups_usecase.dart
│   │   └── report/                                    # NEW
│   │       ├── get_weekly_breakdown_usecase.dart
│   │       ├── get_monthly_comparison_usecase.dart
│   │       └── get_spending_trend_usecase.dart
│   ├── failures/
│   │   ├── backup_failure.dart                        # NEW
│   │   └── auth_failure.dart                          # NEW
│   └── validators/
│       ├── budget_validator.dart                      # NEW
│       └── goal_validator.dart                        # NEW
├── data/
│   ├── models/
│   │   ├── budget_model.dart                          # NEW
│   │   ├── savings_goal_model.dart                    # NEW
│   │   ├── goal_contribution_model.dart               # NEW
│   │   └── backup_metadata_model.dart                 # NEW
│   ├── repositories/
│   │   ├── budget/                                    # NEW
│   │   │   ├── budget_read_repository_impl.dart
│   │   │   ├── budget_write_repository_impl.dart
│   │   │   └── budget_tracking_repository_impl.dart
│   │   └── goal/                                      # NEW
│   │       ├── goal_read_repository_impl.dart
│   │       ├── goal_write_repository_impl.dart
│   │       ├── contribution_read_repository_impl.dart
│   │       └── contribution_write_repository_impl.dart
│   ├── services/
│   │   ├── google_drive_backup_service_impl.dart      # NEW
│   │   └── google_auth_service_impl.dart              # NEW
│   └── datasources/
│       └── (no new data sources needed — LocalDataSource handles all SQLite)
└── presentation/
    ├── screens/
    │   ├── budget_screen.dart                         # NEW
    │   ├── budget_form_screen.dart                    # NEW
    │   ├── savings_goal_screen.dart                   # NEW
    │   ├── goal_form_screen.dart                      # NEW
    │   ├── contribution_form_screen.dart              # NEW
    │   └── enhanced_report_screen.dart                # NEW
    ├── providers/
    │   ├── budget/                                    # NEW
    │   │   ├── budget_list_provider.dart
    │   │   ├── budget_form_provider.dart
    │   │   └── budget_overview_provider.dart
    │   ├── goal/                                      # NEW
    │   │   ├── goal_list_provider.dart
    │   │   ├── goal_form_provider.dart
    │   │   └── contribution_provider.dart
    │   ├── report/                                    # NEW
    │   │   ├── report_period_provider.dart
    │   │   └── enhanced_report_provider.dart
    │   └── backup/                                    # NEW
    │       └── backup_provider.dart
    ├── controllers/
    │   ├── budget_form_controller.dart                # NEW
    │   ├── contribution_controller.dart               # NEW
    │   └── backup_controller.dart                     # NEW
    ├── widgets/
    │   ├── budget/                                    # NEW
    │   │   ├── budget_progress_bar.dart
    │   │   ├── budget_overview_card.dart
    │   │   └── budget_list_item.dart
    │   ├── goal/                                      # NEW
    │   │   ├── goal_progress_ring.dart
    │   │   ├── goal_overview_card.dart
    │   │   ├── goal_list_item.dart
    │   │   └── confetti_celebration.dart
    │   └── report/                                    # NEW
    │       ├── weekly_breakdown_chart.dart
    │       ├── monthly_comparison_chart.dart
    │       └── trend_indicator.dart
    └── states/
        ├── budget_form_state.dart                     # NEW
        ├── goal_form_state.dart                       # NEW
        └── contribution_form_state.dart               # NEW
```

---

## Navigation Changes

### GoRouter: 2 tabs → 4 tabs

```text
Current (v1):
  Tab 0: Transactions (TransactionListScreen)
  Tab 1: Summary (MonthlySummaryScreen)

Proposed (v2):
  Tab 0: Transactions (TransactionListScreen) — unchanged
  Tab 1: Budget (BudgetScreen) — NEW
  Tab 2: Goals (SavingsGoalScreen) — NEW
  Tab 3: Reports (EnhancedReportScreen) — replaces "Summary" tab

Settings remains a full-screen route (not a tab).
Monthly Summary moves into Reports as a sub-tab.
```

**Rationale for 4 tabs:**
- Budget and Goals are primary features that deserve first-class navigation access
- The existing "Summary" tab content is subsumed by the more powerful "Reports" tab
- 4 tabs fit well within the existing `BottomNavigationBar` + `StatefulShellRoute` pattern
- Adding a 5th tab for Settings would be conventional but Settings is accessed infrequently — keeping it as a route from the app bar is better UX

### New Routes

```dart
// Add to AppRoutes
static const String budgets = '/budgets';
static const String addBudget = '/budgets/add';
static const String editBudget = '/budgets/edit/:id';
static const String goals = '/goals';
static const String addGoal = '/goals/add';
static const String editGoal = '/goals/edit/:id';
static const String addContribution = '/goals/:id/contribute';
static const String reports = '/reports';
```

---

## Patterns to Follow

### Pattern 1: Budget Entity with Freezed 3.x

**What:** Immutable budget entity following the exact same pattern as `TransactionEntity`
**When:** Budget domain modeling

```dart
@freezed
abstract class BudgetEntity with _$BudgetEntity {
  const BudgetEntity._();

  const factory BudgetEntity({
    int? id,
    required int categoryId,
    required double amount,
    required int periodMonth,
    required int periodYear,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _BudgetEntity;
}
```

### Pattern 2: Budget With Progress (Composite Entity)

**What:** A domain entity that combines budget + spent data for the UI
**When:** Budget tracking display

```dart
@freezed
abstract class BudgetWithProgressEntity with _$BudgetWithProgressEntity {
  const BudgetWithProgressEntity._();

  const factory BudgetWithProgressEntity({
    required BudgetEntity budget,
    required double spentAmount,
    required CategoryEntity category,  // For display name/icon
  }) = _BudgetWithProgressEntity;

  // Computed properties — NOT stored in DB
  double get remainingAmount => budget.amount - spentAmount;
  double get progressPercentage => budget.amount > 0 ? (spentAmount / budget.amount) * 100 : 0;
  bool get isOverspending => spentAmount > budget.amount;
  bool get isWarning => progressPercentage >= 75 && !isOverspending;
}
```

### Pattern 3: Atomic Contribution + Goal Update

**What:** Use `LocalDataSource.transaction()` for contribution writes that also update goal currentAmount
**When:** Adding a contribution or withdrawal

```dart
class ContributionWriteRepositoryImpl implements ContributionWriteRepository {
  final LocalDataSource _dataSource;

  @override
  Future<Result<GoalContributionEntity>> addContribution(/* ... */) async {
    await _dataSource.transaction(() async {
      // 1. Insert contribution record
      final id = await _dataSource.insert(
        DatabaseHelper.tableGoalContributions,
        contributionModel.toMap(),
      );
      // 2. Update goal current_amount
      await _dataSource.update(
        DatabaseHelper.tableSavingsGoals,
        {'current_amount': goal.currentAmount + contribution.amount},
        where: 'id = ?',
        whereArgs: [goal.id],
      );
      // 3. If goal reached, update status
      if (goal.currentAmount + contribution.amount >= goal.targetAmount) {
        await _dataSource.update(
          DatabaseHelper.tableSavingsGoals,
          {'status': 'completed', 'updated_at': DateTime.now().toIso8601String()},
          where: 'id = ?',
          whereArgs: [goal.id],
        );
      }
    });
  }
}
```

### Pattern 4: Google Drive Service (Domain Interface + Data Implementation)

**What:** Define abstract service in domain, implement with googleapis in data
**When:** Cloud backup/restore

```dart
// Domain: lib/domain/services/backup_service.dart
abstract class BackupService {
  Future<Result<BackupMetadataEntity>> backupToCloud();
  Future<Result<BackupMetadataEntity>> restoreFromCloud(String backupId);
  Future<Result<List<BackupMetadataEntity>>> listBackups();
}

// Domain: lib/domain/services/auth_service.dart
abstract class AuthService {
  Future<Result<void>> signIn();
  Future<void> signOut();
  Future<bool> isAuthenticated();
  Future<Map<String, String>> getAuthHeaders();
}
```

### Pattern 5: Backup Provider State Machine

**What:** Explicit state machine for backup/restore flow
**When:** Backup UI state management

```dart
@freezed
abstract class BackupState with _$BackupState {
  const factory BackupState.initial() = _BackupInitial;
  const factory BackupState.authenticating() = _BackupAuthenticating;
  const factory BackupState.loading() = _BackupLoading;
  const factory BackupState.backingUp({required double progress}) = _BackupBackingUp;
  const factory BackupState.restoring({required double progress}) = _BackupRestoring;
  const factory BackupState.success({required BackupMetadataEntity metadata}) = _BackupSuccess;
  const factory BackupState.failure({required Failure failure}) = _BackupFailure;
}
```

### Pattern 6: Enhanced Reports via Existing Analytics Repository

**What:** Extend `TransactionAnalyticsRepository` with new query methods rather than creating a new repository
**When:** Weekly breakdown, monthly comparison, trend analysis

```dart
// ADD to existing TransactionAnalyticsRepository interface:
abstract class TransactionAnalyticsRepository {
  // ... existing methods ...

  // NEW v2 methods
  Future<Result<List<WeeklyBreakdownEntity>>> getWeeklyBreakdown(int year, int month);
  Future<Result<MonthlyComparisonEntity>> getMonthlyComparison(int year, int month);
  Future<Result<List<SpendingTrendEntity>>> getSpendingTrend(int months);
}
```

---

## Anti-Patterns to Avoid

### Anti-Pattern 1: Budget Tracking in UI Layer

**What:** Computing spent amounts in providers or screens by fetching all transactions and summing in Dart
**Why bad:** O(n) computation in Dart vs O(1) with SQL aggregation. Fetching all transactions defeats pagination. Performance degrades as data grows.
**Instead:** Use `BudgetTrackingRepository` with SQL `SUM()` and `GROUP BY`. The database does the aggregation efficiently.

### Anti-Pattern 2: GoogleSignIn in Domain Layer

**What:** Importing `google_sign_in` package in domain entities or use cases
**Why bad:** Violates dependency inversion — domain layer must have zero external package dependencies.
**Instead:** Define `AuthService` abstract interface in domain. Implement with `google_sign_in` in data layer (`GoogleAuthServiceImpl`).

### Anti-Pattern 3: Raw SQLite File Backup

**What:** Copying `catat_cuan.db` file directly to Google Drive
**Why bad:** Schema version mismatches on restore. Binary file is fragile. Cannot do partial restore or version migration.
**Instead:** Serialize to JSON with schema version metadata. Deserialization can handle version mapping.

### Anti-Pattern 4: Mixing Budget and Transaction Repositories

**What:** Adding budget methods to `TransactionAnalyticsRepository`
**Why bad:** Budget is a separate aggregate root. Budget CRUD (create/update/delete budgets) has nothing to do with transaction analytics. Budget tracking (read-only cross-aggregate queries) is fine as a separate `BudgetTrackingRepository`.
**Instead:** Budget CRUD → `BudgetWriteRepository`. Budget analytics → `BudgetTrackingRepository`. Transaction analytics → keep in `TransactionAnalyticsRepository`.

### Anti-Pattern 5: Contribution Without Atomic Goal Update

**What:** Inserting a contribution record and separately updating the goal's currentAmount
**Why bad:** If the goal update fails after contribution insert, data is inconsistent. Goal shows wrong progress.
**Instead:** Wrap both operations in `LocalDataSource.transaction()` — all succeed or all roll back.

### Anti-Pattern 6: Home Screen Widget Overload

**What:** Adding budget overview card, goals overview card, AND keeping existing summary on the transaction list screen
**Why bad:** Home screen becomes cluttered. v1 already shows monthly summary on the transaction list. Adding 2 more cards is too much information density.
**Instead:** Show a minimal budget status bar (single line) on the transaction list. Full budget/goal overview is on their respective tabs. Progressive disclosure.

---

## Scalability Considerations

| Concern | At 100 transactions | At 10K transactions | At 100K transactions |
|---------|--------------------|--------------------|---------------------|
| Budget tracking query | Instant (<5ms) | Fast (<50ms) | May need materialized view or pre-computed summary table |
| Weekly breakdown query | Instant | Fast (<100ms) | Acceptable (<500ms) with proper indexes |
| JSON backup serialization | Instant (<100ms) | 1-2 seconds | 5-10 seconds — show progress indicator |
| Goal contribution history | Instant | Fast | Paginate contribution list |
| Google Drive upload | <1 second | 1-3 seconds | 5-15 seconds — needs cancel support |

**Index strategy for budget tracking:**
- `idx_transactions_month_type` (already exists from schema v2) serves budget tracking queries
- `idx_budgets_period` ensures fast budget lookup by month/year
- `idx_budgets_category` + `UNIQUE(category_id, period_month, period_year)` prevents duplicate budgets and accelerates lookups

---

## Suggested Build Order

Based on dependency analysis between components:

```text
Phase 1: Foundation (no feature dependencies)
  ┌─────────────────────────────────────────────┐
  │ 1A. Schema v3 migration (budgets, goals,    │
  │     contributions tables + indexes)          │
  │ 1B. Dark mode audit (verify existing theme   │
  │     works on all screens)                    │
  │ 1C. Navigation restructure (2→4 tabs)        │
  └─────────────────────────────────────────────┘

Phase 2: Budgeting (depends on Phase 1A schema)
  ┌─────────────────────────────────────────────┐
  │ 2A. BudgetEntity + BudgetModel               │
  │ 2B. Budget repository interfaces (3)          │
  │ 2C. Budget repository implementations         │
  │ 2D. Budget use cases + validators             │
  │ 2E. Budget providers + screens + widgets      │
  │ 2F. Budget overview on home screen            │
  └─────────────────────────────────────────────┘

Phase 3: Savings Goals (depends on Phase 1A schema)
  ┌─────────────────────────────────────────────┐
  │ 3A. GoalEntity, ContributionEntity + Models   │
  │ 3B. Goal + Contribution repository interfaces │
  │ 3C. Repository implementations (atomic ops)   │
  │ 3D. Use cases + validators                    │
  │ 3E. Providers + screens + widgets             │
  │ 3F. Confetti celebration                      │
  │ 3G. Goal overview on home screen              │
  └─────────────────────────────────────────────┘
  Note: Phase 2 and Phase 3 are independent of each other
        (can be parallelized or reordered)

Phase 4: Cloud Backup (depends on all prior schemas being stable)
  ┌─────────────────────────────────────────────┐
  │ 4A. AuthService interface + Google impl       │
  │ 4B. BackupService interface + Drive impl      │
  │ 4C. Backup/restore use cases                  │
  │ 4D. Backup providers + state machine          │
  │ 4E. Backup UI in Settings                     │
  │ 4F. Error handling (network, auth, quota)     │
  └─────────────────────────────────────────────┘
  Why last data feature: Backup must serialize ALL tables including
  budgets and goals. Building it after those features are stable
  avoids rework.

Phase 5: Enhanced Reports (depends on existing analytics repo)
  ┌─────────────────────────────────────────────┐
  │ 5A. Extend TransactionAnalyticsRepository     │
  │ 5B. New chart entities                        │
  │ 5C. Report use cases                          │
  │ 5D. Report providers                          │
  │ 5E. Chart widgets (fl_chart)                  │
  │ 5F. Interactive report screen with tabs       │
  └─────────────────────────────────────────────┘
  Why can overlap with Phase 4: Reports only read transaction data,
  which is v1-stable. No dependency on budgets/goals for core reports.
  Budget vs Actual reports can be added as Phase 5 extension.

Phase 6: Polish & Integration
  ┌─────────────────────────────────────────────┐
  │ 6A. Home screen integration (budget bar +     │
  │     goal quick actions)                       │
  │ 6B. Budget alerts (notification on 75%/100%)  │
  │ 6C. Integration testing                       │
  │ 6D. Performance optimization                  │
  │ 6E. Documentation update                      │
  └─────────────────────────────────────────────┘
```

---

## Dependency Graph (Critical Path)

```text
Schema v3 ──────────┬──────────────────────────────────────┐
                    │                                       │
                    ▼                                       ▼
              Budget CRUD ──► Budget Tracking          Goal CRUD ──► Contributions
                    │                                       │
                    │                                       │
                    └─────────────┬─────────────────────────┘
                                  │
                                  ▼
                        Cloud Backup (serializes all tables)
                                  │
                                  ▼
                           Polish & Integration

  Dark Mode ──────────── Independent (can start anytime)
  Enhanced Reports ───── Independent (reads v1 transaction data only)
  Navigation ─────────── Independent (tab restructuring)
```

---

## Cross-Cutting Concerns for v2

### Budget Alerts

Budget alerts (75%, 100%, overspending) need to trigger AFTER transaction creation. The integration point is the existing `AddTransactionUseCase`:

1. After successful transaction INSERT, check if the transaction's category has a budget for the current period
2. If yes, compute new spent total vs budget
3. If threshold crossed (75%, 100%, or overspending), trigger a notification

This doesn't require changing the transaction use case itself — it should be a POST-hook using Riverpod's `ref.listen()` in a provider that watches the transaction list state and budget state. Alternatively, the `TransactionFormSubmissionController` can check budgets after successful submission.

### Backup Includes New Tables

The backup service must serialize all tables:
- `categories` (v1)
- `transactions` (v1)
- `budgets` (v2)
- `savings_goals` (v2)
- `goal_contributions` (v2)
- Settings (theme preference, etc.)

The restore must handle schema version mapping — a v1 backup (no budgets/goals tables) should restore cleanly into a v3 app.

### Dark Mode Testing Strategy

Since dark mode infrastructure already exists (`AppTheme`, `AppColors`, `ThemeNotifier`), the work is:
1. **Visual audit:** Every screen in both light and dark mode
2. **Hardcoded color grep:** Search for `Colors.white`, `Colors.black`, `Color(0xFF...)` in presentation layer
3. **Glassmorphism on dark:** Verify blur effects, alpha values, contrast ratios

---

## Sources

- Existing codebase analysis: `lib/domain/`, `lib/data/`, `lib/presentation/` (HIGH confidence — directly read source files)
- v2 PRD: `docs/v2/product/00-PRD.md` (HIGH confidence — project's own spec)
- v2 Specs: `docs/v2/product/01-*` through `05-*` (HIGH confidence — detailed requirements)
- v1 Architecture: `.planning/codebase/ARCHITECTURE.md` (HIGH confidence — verified against source)
- Database schema: `lib/data/datasources/local/schema_manager.dart` (HIGH confidence — source of truth)
- Repository pattern: `lib/domain/repositories/transaction/`, `lib/domain/repositories/category/` (HIGH confidence — existing pattern)
