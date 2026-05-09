import 'package:freezed_annotation/freezed_annotation.dart';

part 'savings_goal_entity.freezed.dart';

@freezed
abstract class SavingsGoalEntity with _$SavingsGoalEntity {
  const SavingsGoalEntity._();

  const factory SavingsGoalEntity({
    int? id,
    required String name,
    required double targetAmount,
    @Default(0.0) double currentAmount,
    DateTime? targetDate,
    String? icon,
    String? color,
    @Default('active') String status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SavingsGoalEntity;
}
