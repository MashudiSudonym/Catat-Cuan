import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal_contribution_entity.freezed.dart';

@freezed
abstract class GoalContributionEntity with _$GoalContributionEntity {
  const GoalContributionEntity._();

  const factory GoalContributionEntity({
    int? id,
    required int goalId,
    required double amount,
    required double runningBalance,
    String? note,
    required DateTime date,
    required DateTime createdAt,
  }) = _GoalContributionEntity;

  bool get isContribution => amount > 0;

  bool get isWithdrawal => amount < 0;
}
