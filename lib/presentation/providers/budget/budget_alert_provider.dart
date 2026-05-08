import 'package:catat_cuan/domain/usecases/budget/check_budget_alerts_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State for budget alert display
///
/// Tracks the current alert type, associated budget info, and visibility state.
class BudgetAlertState {
  final BudgetAlertType alertType;
  final double spentAmount;
  final double budgetAmount;
  final int categoryId;
  final String? categoryName;
  final bool isVisible;

  const BudgetAlertState({
    this.alertType = BudgetAlertType.none,
    this.spentAmount = 0.0,
    this.budgetAmount = 0.0,
    this.categoryId = 0,
    this.categoryName,
    this.isVisible = false,
  });

  BudgetAlertState copyWith({
    BudgetAlertType? alertType,
    double? spentAmount,
    double? budgetAmount,
    int? categoryId,
    String? categoryName,
    bool? isVisible,
  }) {
    return BudgetAlertState(
      alertType: alertType ?? this.alertType,
      spentAmount: spentAmount ?? this.spentAmount,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  /// Initial empty state with no alert
  static const initial = BudgetAlertState();
}

/// Provider for budget alert state
///
/// Manages the visibility and data of budget alerts shown to the user.
/// Per D-01: Alerts use SnackBar — appears briefly at bottom, does not block workflow.
final budgetAlertProvider =
    NotifierProvider<BudgetAlertNotifier, BudgetAlertState>(() {
  return BudgetAlertNotifier();
});

/// Notifier for budget alert state management
///
/// Uses Riverpod 3.x Notifier pattern (not StateNotifier).
class BudgetAlertNotifier extends Notifier<BudgetAlertState> {
  @override
  BudgetAlertState build() {
    return BudgetAlertState.initial;
  }

  /// Show a budget alert with the given details
  void showAlert({
    required BudgetAlertType type,
    required double spentAmount,
    required double budgetAmount,
    required int categoryId,
    String? categoryName,
  }) {
    state = BudgetAlertState(
      alertType: type,
      spentAmount: spentAmount,
      budgetAmount: budgetAmount,
      categoryId: categoryId,
      categoryName: categoryName,
      isVisible: true,
    );
  }

  /// Dismiss the current alert (user dismissed SnackBar)
  void dismissAlert() {
    state = state.copyWith(isVisible: false);
  }

  /// Reset to no-alert state
  void reset() {
    state = BudgetAlertState.initial;
  }
}
