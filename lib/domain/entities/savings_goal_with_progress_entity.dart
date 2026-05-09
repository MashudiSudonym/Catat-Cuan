import 'dart:ui';
import 'package:catat_cuan/domain/entities/savings_goal_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'savings_goal_with_progress_entity.freezed.dart';

@freezed
abstract class SavingsGoalWithProgressEntity with _$SavingsGoalWithProgressEntity {
  const SavingsGoalWithProgressEntity._();

  const factory SavingsGoalWithProgressEntity({
    required SavingsGoalEntity goal,
  }) = _SavingsGoalWithProgressEntity;

  double get progressPercentage {
    if (goal.targetAmount <= 0) return 0.0;
    return (goal.currentAmount / goal.targetAmount * 100).clamp(0.0, 100.0);
  }

  Color getProgressColor(bool isDark) {
    if (progressPercentage >= 75) {
      return isDark ? const Color(0xFF34D399) : const Color(0xFF10B981);
    }
    if (progressPercentage >= 50) {
      return isDark ? const Color(0xFFFACC15) : const Color(0xFFEAB308);
    }
    if (progressPercentage >= 25) {
      return isDark ? const Color(0xFFFB923C) : const Color(0xFFF97316);
    }
    return isDark ? const Color(0xFFF87171) : const Color(0xFFEF4444);
  }

  bool get isCompleted => goal.currentAmount >= goal.targetAmount;

  int? get daysRemaining {
    if (goal.targetDate == null) return null;
    return goal.targetDate!.difference(DateTime.now()).inDays;
  }

  bool get isOverdue => daysRemaining != null && daysRemaining! < 0;
}
