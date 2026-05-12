import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/savings_goal_entity.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/utils/error/error_message_mapper.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:catat_cuan/presentation/widgets/category_color_picker.dart';
import 'package:catat_cuan/presentation/widgets/category_icon_picker.dart';
import 'package:catat_cuan/presentation/providers/controllers/controller_providers.dart';
import 'package:catat_cuan/presentation/providers/savings_goal/savings_goal_providers.dart';

class SavingsGoalFormScreen extends ConsumerStatefulWidget {
  const SavingsGoalFormScreen({super.key, this.goalId});

  final int? goalId;

  @override
  ConsumerState<SavingsGoalFormScreen> createState() => _SavingsGoalFormScreenState();
}

class _SavingsGoalFormScreenState extends ConsumerState<SavingsGoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  DateTime? _targetDate;
  String _selectedColor = '';
  String? _selectedIcon;
  bool _isLoading = false;
  bool _isEditing = false;
  SavingsGoalEntity? _existingGoal;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.goalId != null;

    if (_isEditing) {
      _loadExistingGoal();
    } else {
      _selectedColor = CategoryConstants.getRandomColor();
      _selectedIcon = CategoryConstants.getDefaultIcon('expense');
    }
  }

  Future<void> _loadExistingGoal() async {
    setState(() => _isLoading = true);
    try {
      final useCase = ref.read(getSavingsGoalWithProgressUseCaseProvider);
      final result = await useCase(const NoParams());
      if (result.isSuccess && result.data != null) {
        final goals = result.data!;
        final goalWithProgress = goals.where(
          (g) => g.goal.id == widget.goalId,
        ).firstOrNull;

        if (goalWithProgress != null) {
          final goal = goalWithProgress.goal;
          setState(() {
            _existingGoal = goal;
            _nameController.text = goal.name;
            _targetAmountController.text = CurrencyInputFormatter.formatRupiah(
              goal.targetAmount.round(),
            );
            _targetDate = goal.targetDate;
            _selectedColor = goal.color ?? CategoryConstants.getRandomColor();
            _selectedIcon = goal.icon;
          });
        }
      }
    } catch (e) {
      AppLogger.e('SavingsGoalForm: Error loading goal', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorMessageMapper.getUserMessage(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Goal Tabungan' : 'Buat Goal Tabungan'),
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _isLoading ? null : _submit,
              child: const Text('Simpan'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: AppSpacing.lgAll,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildNameField(),
                      const AppSpacingWidget.verticalLG(),
                      _buildTargetAmountField(),
                      const AppSpacingWidget.verticalLG(),
                      _buildDeadlineField(),
                      const AppSpacingWidget.verticalLG(),
                      _buildIconPicker(),
                      const AppSpacingWidget.verticalLG(),
                      _buildColorPicker(),
                      const AppSpacingWidget.verticalXXL(),
                      if (!_isEditing) _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nama Goal',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const AppSpacingWidget.verticalXS(),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Contoh: iPhone baru, Liburan',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            contentPadding: AppSpacing.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Nama goal wajib diisi';
            return null;
          },
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }

  Widget _buildTargetAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target Tabungan',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const AppSpacingWidget.verticalXS(),
        TextFormField(
          controller: _targetAmountController,
          keyboardType: TextInputType.number,
          inputFormatters: [CurrencyInputFormatter()],
          decoration: InputDecoration(
            hintText: 'Masukkan jumlah target',
            prefixText: 'Rp ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            contentPadding: AppSpacing.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Jumlah target wajib diisi';
            final amount = CurrencyInputFormatter.parseRupiah(value);
            if (amount == null || amount <= 0) return 'Jumlah harus lebih dari 0';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDeadlineField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tenggat Waktu (Opsional)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const AppSpacingWidget.verticalXS(),
        InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: AppSpacing.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
                const AppSpacingWidget.horizontalSM(),
                Text(
                  _targetDate != null
                      ? AppDateFormatter.formatDayMonthYearDate(_targetDate!)
                      : 'Pilih tanggal tenggat',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _targetDate != null ? null : AppColors.textTertiary,
                      ),
                ),
                const Spacer(),
                if (_targetDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () => setState(() => _targetDate = null),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Ikon',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const AppSpacingWidget.verticalXS(),
        InkWell(
          onTap: _showIconPicker,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: AppSpacing.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(AppRadius.md),
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
                      _selectedIcon ?? '🎯',
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

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Warna',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const AppSpacingWidget.verticalXS(),
        InkWell(
          onTap: _showColorPicker,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: AppSpacing.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(AppRadius.md),
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

  Widget _buildSubmitButton() {
    return FilledButton(
      onPressed: _isLoading ? null : _submit,
      child: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Text(_isEditing ? 'Simpan Perubahan' : 'Buat Goal'),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  Future<void> _showIconPicker() async {
    final icon = await CategoryIconPickerDialog.show(
      context: context,
      selectedIcon: _selectedIcon,
      type: CategoryType.expense,
    );
    if (icon != null) {
      setState(() => _selectedIcon = icon);
    }
  }

  Future<void> _showColorPicker() async {
    final color = await CategoryColorPickerDialog.show(
      context: context,
      selectedColor: _selectedColor,
    );
    if (color != null) {
      setState(() => _selectedColor = color);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = CurrencyInputFormatter.parseRupiah(_targetAmountController.text);
    if (amount == null || amount <= 0) return;

    setState(() => _isLoading = true);

    try {
      final controller = ref.read(savingsGoalFormControllerProvider);
      Result<SavingsGoalEntity> result;

      if (_isEditing && _existingGoal != null) {
        result = await controller.updateGoal(
          id: _existingGoal!.id!,
          name: _nameController.text.trim(),
          targetAmount: amount.toDouble(),
          targetDate: _targetDate,
          icon: _selectedIcon,
          color: _selectedColor,
        );
      } else {
        result = await controller.createGoal(
          name: _nameController.text.trim(),
          targetAmount: amount.toDouble(),
          targetDate: _targetDate,
          icon: _selectedIcon,
          color: _selectedColor,
        );
      }

      if (!mounted) return;

      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'Goal berhasil diperbarui' : 'Goal berhasil dibuat',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        ref.invalidate(savingsGoalsWithProgressProvider);
        context.pop(true);
      } else {
        final userMessage = ErrorMessageMapper.getUserMessage(result.failure);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.e('SavingsGoalForm: Error submitting form', e, stackTrace);
      if (mounted) {
        final userMessage = ErrorMessageMapper.getUserMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
