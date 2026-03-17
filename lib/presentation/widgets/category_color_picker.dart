import 'package:flutter/material.dart';
import 'package:catat_cuan/presentation/utils/app_colors.dart';
import 'package:catat_cuan/presentation/utils/color_helper.dart';

/// Widget untuk memilih warna kategori
class CategoryColorPicker extends StatelessWidget {
  final String selectedColor;
  final ValueChanged<String> onColorSelected;

  const CategoryColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: AppColors.categoryColors.length,
      itemBuilder: (context, index) {
        final color = AppColors.categoryColors[index];
        final colorHex = ColorHelper.colorToHex(color);
        final isSelected = selectedColor == colorHex;

        return GestureDetector(
          onTap: () => onColorSelected(colorHex),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 3,
              ),
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: ColorHelper.getContrastColor(color),
                    size: 20,
                  )
                : null,
          ),
        );
      },
    );
  }
}

/// Widget untuk menampilkan color picker dalam dialog
class CategoryColorPickerDialog extends StatelessWidget {
  final String selectedColor;
  final ValueChanged<String> onColorSelected;

  const CategoryColorPickerDialog({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pilih Warna'),
      content: SizedBox(
        width: 300,
        child: CategoryColorPicker(
          selectedColor: selectedColor,
          onColorSelected: (color) {
            onColorSelected(color);
            Navigator.of(context).pop();
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
      ],
    );
  }

  /// Show color picker dialog
  static Future<String?> show({
    required BuildContext context,
    required String selectedColor,
  }) {
    return showDialog<String>(
      context: context,
      // Use root navigator to avoid closing the bottom sheet
      useRootNavigator: true,
      builder: (context) => CategoryColorPickerDialog(
        selectedColor: selectedColor,
        onColorSelected: (color) {
          Navigator.of(context).pop(color);
        },
      ),
    );
  }
}
