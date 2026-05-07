import 'package:flutter/material.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import '../utils/utils.dart';
import 'base/base.dart';

/// Grid selection untuk kategori transaksi
/// Menampilkan kategori dalam grid 4 kolom dengan icon dan nama
class CategoryGrid extends StatelessWidget {
  final List<CategoryEntity> categories;
  final int? selectedCategoryId;
  final Function(int?) onCategorySelected;
  final bool enabled;
  final VoidCallback? onAddCategory;
  final bool showAddButton;

  const CategoryGrid({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
    this.enabled = true,
    this.onAddCategory,
    this.showAddButton = true,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Center(
        child: Padding(
          padding: AppSpacing.xxxlAll,
          child: Text('Tidak ada kategori tersedia'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const AppSpacingWidget.verticalMD(),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
          ),
          itemCount: showAddButton && onAddCategory != null
              ? categories.length + 1
              : categories.length,
          itemBuilder: (context, index) {
            // Show add button at the end
            if (index == categories.length && showAddButton) {
              return _AddCategoryItem(onTap: onAddCategory ?? () {});
            }

            final category = categories[index];
            final isSelected = selectedCategoryId == category.id;
            final color = _getCategoryColor(category);

            return _CategoryItem(
              icon: category.icon ?? '📦',
              name: category.name,
              isSelected: isSelected,
              color: color,
              onTap: enabled
                  ? () => onCategorySelected(category.id)
                  : null,
            );
          },
        ),
      ],
    );
  }

  Color _getCategoryColor(CategoryEntity category) {
    // Gunakan color dari category entity jika ada
    final colorStr = category.color;
    if (colorStr.isNotEmpty) {
      try {
        return Color(int.parse(colorStr, radix: 16));
      } catch (_) {
        // Fall through to default
      }
    }
    // Gunakan default color berdasarkan index
    return AppColors.getCategoryColor(category.id ?? 0);
  }
}

class _CategoryItem extends StatefulWidget {
  final String icon;
  final String name;
  final bool isSelected;
  final Color color;
  final VoidCallback? onTap;

  const _CategoryItem({
    required this.icon,
    required this.name,
    required this.isSelected,
    required this.color,
    this.onTap,
  });

  @override
  State<_CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<_CategoryItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(_CategoryItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected && widget.isSelected) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) {
        _animationController.forward();
      } : null,
      onTapUp: widget.onTap != null ? (_) {
        _animationController.reverse();
        widget.onTap!();
      } : null,
      onTapCancel: widget.onTap != null ? () {
        _animationController.reverse();
      } : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.color
                : widget.color.withValues(alpha: 0.1),
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: widget.isSelected
                  ? widget.color
                  : AppColors.textTertiary.withValues(alpha: 0.3),
              width: widget.isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              AppContainer(
                width: 32,
                height: 32,
                color: widget.isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : widget.color.withValues(alpha: 0.1),
                borderRadius: AppRadius.smAll,
                alignment: Alignment.center,
                child: Text(
                  widget.icon,
                  style: TextStyle(
                    fontSize: 18,
                    color: widget.isSelected ? Colors.white : widget.color,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  widget.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: widget.isSelected ? Colors.white : widget.color,
                    fontWeight: widget.isSelected
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget untuk tombol tambah kategori
class _AddCategoryItem extends StatelessWidget {
  final VoidCallback onTap;

  const _AddCategoryItem({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.textTertiary.withValues(alpha: 0.05),
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: AppColors.textTertiary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppContainer(
              width: 32,
              height: 32,
              color: AppColors.textTertiary.withValues(alpha: 0.1),
              borderRadius: AppRadius.smAll,
              alignment: Alignment.center,
              child: Icon(
                Icons.add,
                size: 18,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Tambah',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: AppColors.textTertiary,                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal scrollable category chips untuk compact layout
class CategoryChips extends StatelessWidget {
  final List<CategoryEntity> categories;
  final int? selectedCategoryId;
  final Function(int?) onCategorySelected;
  final bool enabled;

  const CategoryChips({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const AppSpacingWidget.verticalSM(),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: categories.map((category) {
            final isSelected = selectedCategoryId == category.id;
            final color = _getCategoryColor(category);

            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(category.icon ?? '📦'),
                  const AppSpacingWidget.horizontalXS(),
                  Text(category.name),
                ],
              ),
              selected: isSelected,
              onSelected: enabled
                  ? (selected) {
                      onCategorySelected(selected ? category.id : null);
                    }
                  : null,
              selectedColor: color,
              checkmarkColor: Colors.white,
              backgroundColor: color.withValues(alpha: 0.1),
              side: BorderSide(
                color: isSelected ? color : Colors.grey.shade300,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getCategoryColor(CategoryEntity category) {
    final colorStr = category.color;
    if (colorStr.isNotEmpty) {
      try {
        return Color(int.parse(colorStr, radix: 16));
      } catch (_) {
        // Fall through to default
      }
    }
    return AppColors.getCategoryColor(category.id ?? 0);
  }
}
