import 'package:flutter/material.dart';
import 'package:catat_cuan/domain/entities/category_with_count_entity.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';

// ColorHelper is exported from utils.dart via color_helper.dart

/// Widget untuk menampilkan item kategori di daftar
class CategoryListItem extends StatelessWidget {
  final CategoryWithCountEntity categoryWithCount;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showReorderHandle;
  final int? reorderIndex;

  const CategoryListItem({
    super.key,
    required this.categoryWithCount,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showReorderHandle = false,
    this.reorderIndex,
  });

  @override
  Widget build(BuildContext context) {
    final category = categoryWithCount.category;
    final transactionCount = categoryWithCount.transactionCount;

    return Dismissible(
      key: Key('category_${category.id}'),
      onDismissed: onDelete != null
          ? (direction) {
              if (direction == DismissDirection.endToStart) {
                onDelete?.call();
              }
            }
          : null,
      direction: onDelete != null ? DismissDirection.endToStart : DismissDirection.none,
      background: _buildDismissBackground(context),
      child: AppGlassContainer.glassCard(
        margin: AppSpacing.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mdAll,
          child: Padding(
            padding: AppSpacing.lgAll,
            child: Row(
              children: [
                // Reorder handle (if needed)
                if (showReorderHandle && reorderIndex != null)
                  ReorderableDragStartListener(
                    index: reorderIndex!,
                    child: Padding(
                      padding: AppSpacing.only(right: AppSpacing.md),
                      child: const Icon(Icons.drag_handle, color: Colors.grey),
                    ),
                  ),

                // Category icon with color background
                _CategoryIcon(
                  icon: category.icon ?? '📦',
                  color: ColorHelper.hexToColorWithFallback(category.color),
                  isActive: category.isActive,
                ),

                const AppSpacingWidget.horizontalLG(),

                // Category details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category name
                      Text(
                        category.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: category.isActive
                                  ? null
                                  : Colors.grey,
                            ),
                      ),

                      const AppSpacingWidget.verticalXS(),

                      // Transaction count and type
                      Row(
                        children: [
                          // Transaction count badge
                          if (transactionCount > 0)
                            Container(
                              padding: AppSpacing.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                              decoration: BoxDecoration(
                                color: category.isActive
                                    ? Colors.blue.withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.1),
                                borderRadius: AppRadius.mdAll,
                              ),
                              child: Text(
                                '$transactionCount transaksi',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: category.isActive
                                          ? Colors.blue
                                          : Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),

                          if (transactionCount > 0 &&
                              !category.isActive) ...[
                            const AppSpacingWidget.horizontalSM(),
                          ],

                                          // Inactive label
                          if (!category.isActive)
                            Container(
                              padding: AppSpacing.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: AppRadius.mdAll,
                              ),
                              child: Text(
                                'Tidak Aktif',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Edit button (if provided)
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: onEdit,
                    color: Colors.grey,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      alignment: Alignment.centerRight,
      padding: AppSpacing.only(right: 20),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.expense.withValues(alpha: 0.2)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: AppRadius.mdAll,
      ),
      child: Icon(
        Icons.delete_outline,
        color: isDark ? AppColors.getExpenseColor(true) : Colors.red,
      ),
    );
  }
}

/// Widget untuk menampilkan icon kategori dengan background color
class _CategoryIcon extends StatelessWidget {
  final String icon;
  final Color color;
  final bool isActive;

  const _CategoryIcon({
    required this.icon,
    required this.color,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      color: isActive
          ? color.withValues(alpha: 0.15)
          : Colors.grey.withValues(alpha: 0.1),
      borderRadius: AppRadius.lgAll,
      width: 48,
      height: 48,
      alignment: Alignment.center,
      child: Text(
        icon,
        style: TextStyle(
          fontSize: 24,
          color: isActive ? color : Colors.grey,
        ),
      ),
    );
  }
}
