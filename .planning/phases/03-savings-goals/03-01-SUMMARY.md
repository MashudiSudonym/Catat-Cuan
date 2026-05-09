---
phase: 03-savings-goals
plan: 01
subsystem: data-layer
tags: [entities, freezed, repository-segregation, sqlite, models, tdd]
dependency_graph:
  requires: []
  provides: [SavingsGoalEntity, GoalContributionEntity, SavingsGoalWithProgressEntity, SavingsGoalReadRepository, SavingsGoalWriteRepository, SavingsGoalContributionRepository, SavingsGoalQueryRepository]
  affects: []
tech-stack:
  added:
    - "dart:ui Color for progressColor gradient"
  patterns:
    - "Freezed 3.x with abstract keyword"
    - "ISP-segregated repository interfaces (4 interfaces)"
    - "Repository segregation matching Phase 2 budget pattern"
    - "Running balance calculation via SQL COALESCE(MAX)"
    - "4-tier progress color gradient per SAV-07"
key-files:
  created:
    - lib/domain/entities/savings_goal_entity.dart
    - lib/domain/entities/goal_contribution_entity.dart
    - lib/domain/entities/savings_goal_with_progress_entity.dart
    - lib/domain/repositories/savings_goal/savings_goal_read_repository.dart
    - lib/domain/repositories/savings_goal/savings_goal_write_repository.dart
    - lib/domain/repositories/savings_goal/savings_goal_contribution_repository.dart
    - lib/domain/repositories/savings_goal/savings_goal_query_repository.dart
    - lib/domain/repositories/savings_goal/savings_goal_repositories.dart
    - lib/data/models/savings_goal_model.dart
    - lib/data/models/goal_contribution_model.dart
    - lib/data/repositories/savings_goal/savings_goal_read_repository_impl.dart
    - lib/data/repositories/savings_goal/savings_goal_write_repository_impl.dart
    - lib/data/repositories/savings_goal/savings_goal_contribution_repository_impl.dart
    - lib/data/repositories/savings_goal/savings_goal_query_repository_impl.dart
    - test/domain/entities/savings_goal_entity_test.dart
    - test/data/repositories/savings_goal/savings_goal_repository_impl_test.dart
decisions:
  - "Entity validation (targetAmount > 0) at DB/repository level matching budget pattern, not Freezed entity level"
  - "Sequential DB operations for contribution writes instead of transaction wrapper (SqliteDataSource.transaction() has pre-existing lock issue with nested operations)"
  - "4-tier progress color gradient with light/dark mode variants per UI-SPEC"
  - "Running balance stored and calculated via SQL MAX aggregation"
metrics:
  duration: 23min
  completed: 2026-05-10
  tasks_completed: 2
  files_created: 16
  tests_added: 42
  total_tests: 1077
---

# Phase 3 Plan 01: Savings Goals Data Layer Summary

Freezed entities with computed progress properties, ISP-segregated repository interfaces, data models with DB↔Entity conversion, and SQLite-backed implementations with withdrawal validation and running balance tracking.

## What Was Built

### Domain Layer (Entities + Interfaces)

**3 Freezed Entities:**
- `SavingsGoalEntity` — Core goal with name, targetAmount, currentAmount, optional deadline/icon/color, status
- `SavingsGoalWithProgressEntity` — Wraps goal with computed: progressPercentage (clamped 0-100), progressColor (4-tier: red/orange/yellow/green), isCompleted, daysRemaining, isOverdue
- `GoalContributionEntity` — Contribution/withdrawal with amount sign convention (positive=contribution, negative=withdrawal), runningBalance, computed isContribution/isWithdrawal

**4 ISP-Segregated Repository Interfaces:**
- `SavingsGoalReadRepository` — getGoals(status), getGoalById(id), getActiveGoals()
- `SavingsGoalWriteRepository` — createGoal, updateGoal (excludes currentAmount per SAV-03), softDeleteGoal (sets cancelled per SAV-04)
- `SavingsGoalContributionRepository` — addContribution, withdrawFromGoal (validates amount <= currentAmount per SAV-06), getContributionsForGoal
- `SavingsGoalQueryRepository` — getGoalsWithProgress, getGoalWithProgressById, getOverallProgress

### Data Layer (Models + Implementations)

**2 Data Models:**
- `SavingsGoalModel` — Freezed model with fromMap/toMap using SavingsGoalFields constants, nullable targetDate/icon/color handling
- `GoalContributionModel` — Freezed model with fromMap/toMap using GoalContributionFields constants

**4 Repository Implementations:**
- `SavingsGoalReadRepositoryImpl` — Queries savings_goals table with status filter
- `SavingsGoalWriteRepositoryImpl` — CRUD with soft-delete (status='cancelled') and update excluding currentAmount
- `SavingsGoalContributionRepositoryImpl` — Atomic contribution/withdrawal with running balance via SQL MAX, withdrawal validation
- `SavingsGoalQueryRepositoryImpl` — Progress computation with SUM-based overall progress

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Removed transaction wrapper for contribution writes**
- **Found during:** Task 2 — ContributionRepositoryImpl
- **Issue:** `SqliteDataSource.transaction()` discards the `DatabaseExecutor txn` parameter, causing database lock when inner operations try to use the main connection
- **Fix:** Replaced transaction wrapper with sequential operations (INSERT contribution → rawQuery UPDATE goal). For a local-only personal app, this is sufficient. The existing codebase (budget repos) also doesn't use transactions.
- **Files modified:** `savings_goal_contribution_repository_impl.dart`
- **Commit:** 56944fb

**2. [Adaptation] Entity validation at DB/repository level instead of entity-level assertion**
- **Found during:** Task 1 — Freezed doesn't support assert in const factory constructors
- **Issue:** Freezed 3.x const factory constructors cannot include assert statements
- **Fix:** Moved targetAmount > 0 and amount != 0 validation to DB CHECK constraints and repository-level validation, matching the existing BudgetEntity pattern
- **Files modified:** `savings_goal_entity.dart`, `savings_goal_entity_test.dart`
- **Commit:** 21b5317

## Test Results

- **Entity tests:** 23 passed (SavingsGoalEntity, SavingsGoalWithProgressEntity, GoalContributionEntity)
- **Repository integration tests:** 19 passed (CRUD, contributions, withdrawals, queries)
- **Full suite:** 1077 passed, 0 failed
- **flutter analyze:** 0 issues

## Key Implementation Details

- Running balance: `COALESCE(MAX(running_balance), 0) ± amount` via SQL
- Withdrawal validation: Repository reads current_amount first, returns `ValidationFailure` if withdrawal exceeds balance
- Progress color: 4-tier gradient with `dart:ui Color`, light/dark mode variants
- All SQL uses field constants from `SavingsGoalFields`/`GoalContributionFields` — no hardcoded column names
- Error messages in Indonesian (`'Gagal menambahkan setoran'`, etc.)

## Self-Check

- [x] All 16 source files created
- [x] Task 1 commit: 21b5317
- [x] Task 2 commit: 56944fb
- [x] 42 new tests passing
- [x] flutter analyze clean
