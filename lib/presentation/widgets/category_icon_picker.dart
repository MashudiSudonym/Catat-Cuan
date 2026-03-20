import 'package:flutter/material.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';

/// Widget untuk memilih icon kategori
class CategoryIconPicker extends StatefulWidget {
  final String? selectedIcon;
  final CategoryType type;
  final ValueChanged<String?> onIconSelected;

  const CategoryIconPicker({
    super.key,
    this.selectedIcon,
    required this.type,
    required this.onIconSelected,
  });

  @override
  State<CategoryIconPicker> createState() => _CategoryIconPickerState();
}

class _CategoryIconPickerState extends State<CategoryIconPicker> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filteredIcons {
    final icons = widget.type == CategoryType.income
        ? CategoryConstants.incomeIcons
        : CategoryConstants.expenseIcons;

    if (_searchQuery.isEmpty) {
      return icons;
    }

    // Filter by search query (icon names can be described by their meaning)
    return icons.where((icon) {
      // Since icons are emojis, we can't really search by text
      // But we could search by description/index if needed
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search field
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cari icon...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: AppRadius.mdAll,
            ),
            contentPadding: AppSpacing.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
        ),

        const AppSpacingWidget.verticalLG(),

        // Icon grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1,
          ),
          itemCount: _filteredIcons.length,
          itemBuilder: (context, index) {
            final icon = _filteredIcons[index];
            final isSelected = widget.selectedIcon == icon;

            return GestureDetector(
              onTap: () => widget.onIconSelected(icon),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withValues(
                            alpha: 0.1,
                          )
                      : Colors.grey.withValues(alpha: 0.05),
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Widget untuk menampilkan icon picker dalam dialog
class CategoryIconPickerDialog extends StatelessWidget {
  final String? selectedIcon;
  final CategoryType type;
  final ValueChanged<String?> onIconSelected;

  const CategoryIconPickerDialog({
    super.key,
    this.selectedIcon,
    required this.type,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Pilih Icon - ${type.displayName}'),
      content: SizedBox(
        width: 350,
        height: 400,
        child: CategoryIconPicker(
          selectedIcon: selectedIcon,
          type: type,
          onIconSelected: (icon) {
            onIconSelected(icon);
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

  /// Show icon picker dialog
  static Future<String?> show({
    required BuildContext context,
    required String? selectedIcon,
    required CategoryType type,
  }) {
    return showDialog<String>(
      context: context,
      // Use root navigator to avoid closing the bottom sheet
      useRootNavigator: true,
      builder: (context) => CategoryIconPickerDialog(
        selectedIcon: selectedIcon,
        type: type,
        onIconSelected: (icon) {
          Navigator.of(context).pop(icon);
        },
      ),
    );
  }
}
