import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/domain/entities/savings_goal_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'savings_goal_model.freezed.dart';

@freezed
abstract class SavingsGoalModel with _$SavingsGoalModel {
  const SavingsGoalModel._();

  const factory SavingsGoalModel({
    int? id,
    required String name,
    required double targetAmount,
    @Default(0.0) double currentAmount,
    String? targetDate,
    String? icon,
    String? color,
    @Default('active') String status,
    required String createdAt,
    required String updatedAt,
  }) = _SavingsGoalModel;

  factory SavingsGoalModel.fromMap(Map<String, dynamic> map) {
    return SavingsGoalModel(
      id: map[SavingsGoalFields.id] as int?,
      name: map[SavingsGoalFields.name] as String? ?? '',
      targetAmount: (map[SavingsGoalFields.targetAmount] as num?)?.toDouble() ?? 0.0,
      currentAmount: (map[SavingsGoalFields.currentAmount] as num?)?.toDouble() ?? 0.0,
      targetDate: map[SavingsGoalFields.targetDate]?.toString(),
      icon: map[SavingsGoalFields.icon]?.toString(),
      color: map[SavingsGoalFields.color]?.toString(),
      status: map[SavingsGoalFields.status] as String? ?? 'active',
      createdAt: map[SavingsGoalFields.createdAt]?.toString() ?? DateTime.now().toIso8601String(),
      updatedAt: map[SavingsGoalFields.updatedAt]?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) SavingsGoalFields.id: id,
      SavingsGoalFields.name: name,
      SavingsGoalFields.targetAmount: targetAmount,
      SavingsGoalFields.currentAmount: currentAmount,
      SavingsGoalFields.targetDate: targetDate,
      SavingsGoalFields.icon: icon,
      SavingsGoalFields.color: color,
      SavingsGoalFields.status: status,
      SavingsGoalFields.createdAt: createdAt,
      SavingsGoalFields.updatedAt: updatedAt,
    };
  }

  SavingsGoalEntity toEntity() {
    return SavingsGoalEntity(
      id: id,
      name: name,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      targetDate: targetDate != null ? DateTime.parse(targetDate!) : null,
      icon: icon,
      color: color,
      status: status,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  factory SavingsGoalModel.fromEntity(SavingsGoalEntity entity) {
    return SavingsGoalModel(
      id: entity.id,
      name: entity.name,
      targetAmount: entity.targetAmount,
      currentAmount: entity.currentAmount,
      targetDate: entity.targetDate?.toIso8601String(),
      icon: entity.icon,
      color: entity.color,
      status: entity.status,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }
}
