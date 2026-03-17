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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
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

        const SizedBox(height: 8),
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
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: isFirst ? 12 : 8,
        top: isFirst ? 0 : 8,
      ),
      padding: AppSpacing.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: priorityColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              recommendation.type.icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),

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
                const SizedBox(height: 6),

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
                  const SizedBox(height: 8),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
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
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
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
