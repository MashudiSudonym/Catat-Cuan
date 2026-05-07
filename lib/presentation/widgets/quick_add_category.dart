import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/presentation/providers/app_providers.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';

/// Bottom sheet untuk menambah kategori dengan cepat
/// Icon dan warna otomatis dideteksi dari nama kategori
class QuickAddCategorySheet extends ConsumerStatefulWidget {
  final CategoryType type;
  final ValueChanged<CategoryEntity>? onCategoryAdded;

  const QuickAddCategorySheet({
    super.key,
    required this.type,
    this.onCategoryAdded,
  });

  @override
  ConsumerState<QuickAddCategorySheet> createState() =>
      _QuickAddCategorySheetState();
}

class _QuickAddCategorySheetState extends ConsumerState<QuickAddCategorySheet> {
  final _nameController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  // Auto-detected icon and color (shown as preview)
  String? _previewIcon;
  String? _previewColor;

  @override
  void initState() {
    super.initState();
    // Set initial preview
    _updatePreview();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _updatePreview() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _previewIcon = null;
        _previewColor = null;
      });
      return;
    }

    setState(() {
      _previewIcon = CategoryConstants.detectIconFromName(
        name,
        widget.type.value,
      );
      _previewColor = CategoryConstants.detectColorFromName(name);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get keyboard height for bottom padding
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: AppSpacing.only(bottom: keyboardHeight),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Padding(
              padding: AppSpacing.only(top: AppSpacing.md),
              child: Center(
                child: AppContainer(
                  width: 40,
                  height: 4,
                  color: AppColors.textTertiary.withValues(alpha: 0.3),
                  borderRadius: AppRadius.xsAll,
                  alignment: Alignment.center,
                  child: const SizedBox.shrink(),
                ),
              ),
            ),

            // Header
            Padding(
              padding: AppSpacing.lgAll,
              child: Row(
                children: [
                  Icon(
                    widget.type == CategoryType.income
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: widget.type == CategoryType.income
                        ? Colors.green
                        : Colors.red,
                  ),
                  const AppSpacingWidget.horizontalMD(),
                  Text(
                    'Tambah Kategori ${widget.type.displayName}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Form
            Padding(
              padding: AppSpacing.horizontal(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name input
                  TextField(
                    controller: _nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Nama Kategori',
                      hintText: 'Contoh: Makan, Transport, Gaji, dll.',
                      border: const OutlineInputBorder(),
                      errorText: _errorMessage,
                    ),
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => _updatePreview(),
                    onSubmitted: _isSubmitting ? null : (_) => _submit(),
                  ),

                  const AppSpacingWidget.verticalMD(),

                  // Auto-detected icon and color preview
                  if (_previewIcon != null && _previewColor != null)
                    AppContainer(
                      padding: AppSpacing.all(AppSpacing.md),
                      color: AppColors.textTertiary.withValues(alpha: 0.05),
                      borderRadius: AppRadius.mdAll,
                      child: Row(
                        children: [
                          AppContainer(
                            width: 45,
                            height: 45,
                            color: ColorHelper.hexToColorWithFallback(_previewColor!),
                            borderRadius: AppRadius.circular(10),
                            alignment: Alignment.center,
                            child: Text(
                              _previewIcon!,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                          const AppSpacingWidget.horizontalMD(),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Icon & Warna Otomatis',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                const AppSpacingWidget.horizontalXS(),
                                Text(
                                  'Terdeteksi dari nama kategori',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.auto_awesome,
                            color: _previewColor != null
                                ? ColorHelper.hexToColorWithFallback(_previewColor!)
                                : AppColors.textTertiary,
                          ),
                        ],
                      ),
                    ),

                  const AppSpacingWidget.verticalMD(),

                  // Info text
                  Text(
                    'Icon dan warna akan otomatis disesuaikan '
                    'berdasarkan nama kategori.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const AppSpacingWidget.verticalMD(),

                  // Submit button
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: AppSpacing.symmetric(vertical: AppSpacing.lg),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Tambah Kategori'),
                  ),

                  const AppSpacingWidget.verticalLG(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();

    // Validate
    final validationError = CategoryConstants.validateName(name);
    if (validationError != null) {
      setState(() => _errorMessage = validationError);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      // Auto-detect icon and color from name
      final detectedIcon = CategoryConstants.detectIconFromName(
        name,
        widget.type.value,
      );
      final detectedColor = CategoryConstants.detectColorFromName(name);

      // Create category with auto-detected values
      final category = CategoryEntity(
        name: name,
        type: widget.type,
        color: detectedColor,
        icon: detectedIcon,
        sortOrder: 999,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await ref.read(addCategoryUseCaseProvider)(category);

      if (result.isFailure || result.data == null) {
        setState(() {
          _errorMessage = result.failure?.message ?? 'Gagal menambah kategori';
          _isSubmitting = false;
        });
        return;
      }

      final newCategory = result.data!;

      if (mounted) {
        // Refresh category list so it appears in filters
        ref.read(categoryListProvider.notifier).loadCategories();

        widget.onCategoryAdded?.call(newCategory);
        Navigator.of(context).pop(newCategory);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Kategori "$name" berhasil ditambahkan',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal menambahkan kategori. Silakan coba lagi.';
        _isSubmitting = false;
      });
    }
  }
}

/// Show quick add category bottom sheet
Future<CategoryEntity?> showQuickAddCategorySheet({
  required BuildContext context,
  required CategoryType type,
}) {
  return showModalBottomSheet<CategoryEntity>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => QuickAddCategorySheet(type: type),
  );
}
