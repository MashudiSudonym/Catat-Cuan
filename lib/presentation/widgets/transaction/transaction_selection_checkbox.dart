import 'package:flutter/material.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';

/// Transaction selection checkbox widget
///
/// Following SRP: Only handles selection checkbox rendering
class TransactionSelectionCheckbox extends StatelessWidget {
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isCompact;

  const TransactionSelectionCheckbox({
    super.key,
    required this.isSelected,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = isCompact ? 20.0 : 24.0;
    final iconSize = isCompact ? 14.0 : 16.0;
    final borderWidth = isCompact ? 1.5 : 2.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? AppColors.primary
              : (isDark
                  ? AppColors.getGlassSurface(isDark: true, alpha: 0.3)
                  : AppColors.getGlassSurface(isDark: false, alpha: 0.5)),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark
                    ? AppColors.textOnDark.withValues(alpha: 0.3)
                    : AppColors.textSecondary.withValues(alpha: 0.3)),
            width: borderWidth,
          ),
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                size: iconSize,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}
