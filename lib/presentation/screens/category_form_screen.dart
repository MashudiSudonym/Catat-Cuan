import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/presentation/providers/app_providers.dart';
import 'package:catat_cuan/presentation/widgets/category_color_picker.dart';
import 'package:catat_cuan/presentation/widgets/category_icon_picker.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';

/// Screen untuk menambah atau mengedit kategori
class CategoryFormScreen extends ConsumerStatefulWidget {
  final CategoryEntity? categoryToEdit;
  final CategoryType? initialType;
  final int? categoryId;

  const CategoryFormScreen({
    super.key,
    this.categoryToEdit,
    this.initialType,
    this.categoryId,
  }) : assert(
          categoryToEdit == null || initialType == null,
          'Cannot specify both categoryToEdit and initialType',
        );

  @override
  ConsumerState<CategoryFormScreen> createState() =>
      _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedColor = '';
  String? _selectedIcon;

  @override
  void initState() {
    super.initState();

    // Initialize with category to edit or default values
    if (widget.categoryToEdit != null) {
      _initializeForEdit(widget.categoryToEdit!);
    } else if (widget.categoryId != null) {
      // Load category by ID from route
      _initializeForCreate();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await ref.read(categoryFormNotifierProvider.notifier).loadById(widget.categoryId!);
      });
    } else {
      _initializeForCreate();
    }
  }

  void _initializeForEdit(CategoryEntity category) {
    _nameController.text = category.name;
    _selectedColor = category.color;
    _selectedIcon = category.icon;

    // Load form state for editing
    ref.read(categoryFormNotifierProvider.notifier).loadForEdit(category);
  }

  void _initializeForCreate() {
    final type = widget.initialType ?? CategoryType.expense;

    // Initialize with default color and icon
    _selectedColor = CategoryConstants.getRandomColor();
    _selectedIcon = CategoryConstants.getDefaultIcon(type.value);

    // Initialize form state
    ref.read(categoryFormNotifierProvider.notifier).initializeWithType(type);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoryFormNotifierProvider);
    final isEditMode = widget.categoryToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Kategori' : 'Tambah Kategori',
        ),
        actions: [
          if (isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showDeleteConfirmation(context),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.lgAll,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Kategori',
                    hintText: 'Contoh: Makan, Transport, dll.',
                    border: const OutlineInputBorder(),
                    errorText: state.validationErrors['name'],
                  ),
                  onChanged: (value) {
                    ref
                        .read(categoryFormNotifierProvider.notifier)
                        .setName(value);
                  },
                  textInputAction: TextInputAction.next,
                ),

                const AppSpacingWidget.verticalLG(),

                // Type selector (only for create mode)
                if (!isEditMode) _buildTypeSelector(state),

                const AppSpacingWidget.verticalLG(),

                // Color picker
                _buildColorPicker(state),

                const AppSpacingWidget.verticalLG(),

                // Icon picker
                _buildIconPicker(state),

                const AppSpacingWidget.verticalXXL(),

                // Submit error
                if (state.submitError != null) ...[
                  AppGlassContainer.glassCard(
                    padding: AppSpacing.all(AppSpacing.md),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error),
                        const AppSpacingWidget.horizontalMD(),
                        Expanded(
                          child: Text(
                            state.submitError!,
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const AppSpacingWidget.verticalLG(),
                ],

                // Submit button
                ElevatedButton(
                  onPressed: state.isSubmitting
                      ? null
                      : () => _submitForm(state),
                  style: ElevatedButton.styleFrom(
                    padding: AppSpacing.symmetric(vertical: AppSpacing.lg),
                  ),
                  child: state.isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEditMode ? 'Simpan' : 'Tambah'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(CategoryFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipe Kategori',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const AppSpacingWidget.verticalSM(),
        SegmentedButton<CategoryType>(
          segments: const [
            ButtonSegment(
              value: CategoryType.income,
              label: Text('Pemasukan'),
              icon: Icon(Icons.arrow_downward, size: 18),
            ),
            ButtonSegment(
              value: CategoryType.expense,
              label: Text('Pengeluaran'),
              icon: Icon(Icons.arrow_upward, size: 18),
            ),
          ],
          selected: {state.type},
          onSelectionChanged: (Set<CategoryType> newSelection) {
            ref
                .read(categoryFormNotifierProvider.notifier)
                .setType(newSelection.first);
          },
        ),
      ],
    );
  }

  Widget _buildColorPicker(CategoryFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Warna Kategori',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const AppSpacingWidget.verticalSM(),
        InkWell(
          onTap: () => _showColorPicker(context),
          borderRadius: AppRadius.mdAll,
          child: Container(
            padding: AppSpacing.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: AppRadius.mdAll,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ColorHelper.hexToColorWithFallback(_selectedColor),
                    borderRadius: AppRadius.smAll,
                  ),
                ),
                const AppSpacingWidget.horizontalMD(),
                Expanded(
                  child: Text(
                    'Pilih warna',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconPicker(CategoryFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Icon Kategori',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const AppSpacingWidget.verticalSM(),
        InkWell(
          onTap: () => _showIconPicker(context, state),
          borderRadius: AppRadius.mdAll,
          child: Container(
            padding: AppSpacing.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: AppRadius.mdAll,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: AppRadius.smAll,
                  ),
                  child: Center(
                    child: Text(
                      _selectedIcon ?? '📦',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const AppSpacingWidget.horizontalMD(),
                Expanded(
                  child: Text(
                    'Pilih icon',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showColorPicker(BuildContext context) async {
    final color = await CategoryColorPickerDialog.show(
      context: context,
      selectedColor: _selectedColor,
    );

    if (color != null) {
      setState(() => _selectedColor = color);
      ref.read(categoryFormNotifierProvider.notifier).setColor(color);
    }
  }

  void _showIconPicker(BuildContext context, CategoryFormState state) async {
    final icon = await CategoryIconPickerDialog.show(
      context: context,
      selectedIcon: _selectedIcon,
      type: state.type,
    );

    if (icon != null) {
      setState(() => _selectedIcon = icon);
      ref.read(categoryFormNotifierProvider.notifier).setIcon(icon);
    }
  }

  void _submitForm(CategoryFormState state) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Update color and icon in form state
    ref.read(categoryFormNotifierProvider.notifier).setColor(_selectedColor);
    ref.read(categoryFormNotifierProvider.notifier).setIcon(_selectedIcon);

    final success = await ref.read(categoryFormNotifierProvider.notifier).submit();

    if (success && mounted) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.categoryToEdit != null
                ? 'Kategori berhasil diperbarui'
                : 'Kategori berhasil ditambahkan',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: const Text(
          'Untuk menghapus kategori, silakan nonaktifkan kategori ini terlebih dahulu. '
          'Fitur hapus permanen belum tersedia.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
