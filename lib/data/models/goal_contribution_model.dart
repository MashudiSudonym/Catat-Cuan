import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/domain/entities/goal_contribution_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal_contribution_model.freezed.dart';

@freezed
abstract class GoalContributionModel with _$GoalContributionModel {
  const GoalContributionModel._();

  const factory GoalContributionModel({
    int? id,
    required int goalId,
    required double amount,
    required double runningBalance,
    String? note,
    required String date,
    required String createdAt,
  }) = _GoalContributionModel;

  factory GoalContributionModel.fromMap(Map<String, dynamic> map) {
    return GoalContributionModel(
      id: map[GoalContributionFields.id] as int?,
      goalId: map[GoalContributionFields.goalId] as int? ?? 0,
      amount: (map[GoalContributionFields.amount] as num?)?.toDouble() ?? 0.0,
      runningBalance: (map[GoalContributionFields.runningBalance] as num?)?.toDouble() ?? 0.0,
      note: map[GoalContributionFields.note]?.toString(),
      date: map[GoalContributionFields.date]?.toString() ?? DateTime.now().toIso8601String(),
      createdAt: map[GoalContributionFields.createdAt]?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) GoalContributionFields.id: id,
      GoalContributionFields.goalId: goalId,
      GoalContributionFields.amount: amount,
      GoalContributionFields.runningBalance: runningBalance,
      GoalContributionFields.note: note,
      GoalContributionFields.date: date,
      GoalContributionFields.createdAt: createdAt,
    };
  }

  GoalContributionEntity toEntity() {
    return GoalContributionEntity(
      id: id,
      goalId: goalId,
      amount: amount,
      runningBalance: runningBalance,
      note: note,
      date: DateTime.parse(date),
      createdAt: DateTime.parse(createdAt),
    );
  }

  factory GoalContributionModel.fromEntity(GoalContributionEntity entity) {
    return GoalContributionModel(
      id: entity.id,
      goalId: entity.goalId,
      amount: entity.amount,
      runningBalance: entity.runningBalance,
      note: entity.note,
      date: entity.date.toIso8601String(),
      createdAt: entity.createdAt.toIso8601String(),
    );
  }
}
