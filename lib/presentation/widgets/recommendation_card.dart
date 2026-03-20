import 'package:flutter/material.dart';
import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';

/// Card untuk menampilkan rekomendasi keuangan
class RecommendationCard extends StatelessWidget {
  final List<RecommendationEntity> recommendations;

  const RecommendationCard({
    super.key,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: AppSpacing.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const AppSpacingWidget.horizontalSM(),
              Text(
                'Rekomendasi',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
              ),
            ],
          ),
        ),

        // Recommendation Cards
        ...recommendations.asMap().entries.map<_RecommendationItem>((entry) {
          final index = entry.key;
          final recommendation = entry.value;
          return _RecommendationItem(
            recommendation: recommendation,
            isFirst: index == 0,
          );
        }),

        const AppSpacingWidget.verticalSM(),
      ],
    );
  }
}

/// Single recommendation item widget
class _RecommendationItem extends StatelessWidget {
  final RecommendationEntity recommendation;
  final bool isFirst;

  const _RecommendationItem({
    required this.recommendation,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final secondaryColor = isDark ? AppColors.textOnDark.withValues(alpha: 0.7) : AppColors.textSecondary;

    return AppGlassContainer.glassCard(
      margin: AppSpacing.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: isFirst ? AppSpacing.md : AppSpacing.sm,
        top: isFirst ? 0 : AppSpacing.sm,
      ),
      padding: AppSpacing.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          AppContainer(
            padding: AppSpacing.all(AppSpacing.sm),
            color: priorityColor.withValues(alpha: 0.15),
            borderRadius: AppRadius.smAll,
            child: Text(
              recommendation.type.icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const AppSpacingWidget.horizontalMD(),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        recommendation.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                      ),
                    ),
                    // Priority Badge
                    _PriorityBadge(priority: recommendation.priority),
                  ],
                ),
                const AppSpacingWidget.horizontalSM(),

                // Message
                Text(
                  recommendation.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: secondaryColor,
                        height: 1.4,
                      ),
                ),

                // Value display (if any)
                if (recommendation.value != null) ...[
                  const AppSpacingWidget.verticalSM(),
                  _ValueIndicator(
                    value: recommendation.value!,
                    type: recommendation.type,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor() {
    switch (recommendation.priority) {
      case RecommendationPriority.high:
        return AppColors.error;
      case RecommendationPriority.medium:
        return AppColors.warning;
      case RecommendationPriority.low:
        return AppColors.success;
    }
  }
}

/// Priority badge widget
class _PriorityBadge extends StatelessWidget {
  final RecommendationPriority priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (priority) {
      RecommendationPriority.high => ('Tinggi', AppColors.error),
      RecommendationPriority.medium => ('Sedang', AppColors.warning),
      RecommendationPriority.low => ('Rendah', AppColors.success),
    };

    return AppContainer.pill(
      padding: AppSpacing.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      color: color.withValues(alpha: 0.15),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Value indicator widget for showing percentage/amount
class _ValueIndicator extends StatelessWidget {
  final double value;
  final RecommendationType type;

  const _ValueIndicator({
    required this.value,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark ? AppColors.textOnDark.withValues(alpha: 0.7) : AppColors.textSecondary;
    final tertiaryColor = isDark ? AppColors.textOnDark.withValues(alpha: 0.3) : AppColors.textTertiary.withValues(alpha: 0.2);

    final (label, color, percentage) = switch (type) {
      RecommendationType.imbalance => (
          'Deficit',
          AppColors.error,
          value.clamp(0, 100),
        ),
      RecommendationType.excessiveSpending => (
          'Pengeluaran',
          AppColors.warning,
          value.clamp(0, 100),
        ),
      RecommendationType.potentialSavings => (
          'Potensi Tabungan',
          AppColors.success,
          value.clamp(0, 100),
        ),
      RecommendationType.healthy => (
          'Saldo',
          AppColors.success,
          value.clamp(0, 100),
        ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: secondaryColor,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const AppSpacingWidget.horizontalXS(),
        ClipRRect(
          borderRadius: AppRadius.xsAll,
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: tertiaryColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
