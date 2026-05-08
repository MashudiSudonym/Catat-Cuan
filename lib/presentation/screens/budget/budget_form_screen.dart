import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/entities/budget_entity.dart';
import 'package:catat_cuan/presentation/providers/app_providers.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/utils/error/error_message_mapper.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

/// Budget create/edit form with category picker and amount input
///
/// Per T-02-06: Amount field validates > 0 with number keyboard.
/// Per T-02-08: Only expense categories shown in dropdown.
class BudgetFormScreen extends ConsumerStatefulWidget {
  const BudgetFormScreen({
    super.key,
    this.year,
    this.month,
    this.budgetId,
  });

  final int? year;
  final int? month;
  final int? budgetId;

  @override
  ConsumerState<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends ConsumerState<BudgetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  int? _selectedCategoryId;
  bool _isLoading = false;
  bool _isEditing = false;
  late int _year;
  late int _month;
  BudgetEntity? _existingBudget;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = widget.year ?? now.year;
    _month = widget.month ?? now.month;
    _isEditing = widget.budgetId != null;

    if (_isEditing) {
      _loadExistingBudget();
    }
  }

  Future<void> _loadExistingBudget() async {
    setState(() => _isLoading = true);
    try {
      final controller = ref.read(budgetFormControllerProvider);
      final result = await controller.getBudgetsForMonth(_year, _month);

      if (result.isSuccess && result.data != null) {
        final budget = result.data!.firstWhere(
          (b) => b.id == widget.budgetId,
          orElse: () => throw Exception('Budget not found'),
        );
        setState(() {
          _existingBudget = budget;
          _selectedCategoryId = budget.categoryId;
          _amountController.text = CurrencyInputFormatter.formatRupiah(
            budget.amount.round(),
          );
        });
      }
    } catch (e) {
      AppLogger.e('BudgetForm: Error loading budget', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorMessageMapper.getUserMessage(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Anggaran' : 'Tambah Anggaran'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submit,
            child: const Text('Simpan'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : categoriesAsync.when(
              data: (categories) {
                // Per T-02-08: Only show expense categories
                final expenseCategories = categories
                    .where((c) =>
                        c.type == CategoryType.expense && c.isActive)
                    .toList();
                return _buildForm(expenseCategories);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text(ErrorMessageMapper.getUserMessage(error)),
              ),
            ),
    );
  }

  Widget _buildForm(List<CategoryEntity> categories) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: AppSpacing.lgAll,
        children: [
          // Month/Year label
          Text(
            AppDateFormatter.formatMonthYearDate(DateTime(_year, _month)),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const AppSpacingWidget.verticalLG(),

          // Category dropdown
          Text(
            'Kategori',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const AppSpacingWidget.verticalXS(),
          DropdownButtonFormField<int>(
            initialValue: _selectedCategoryId,
            decoration: InputDecoration(
              hintText: 'Pilih kategori pengeluaran',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              contentPadding: AppSpacing.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
            items: categories.map((category) {
              return DropdownMenuItem<int>(
                value: category.id,
                child: Row(
                  children: [
                    Text(category.icon ?? '💰', style: const TextStyle(fontSize: 18)),
                    const AppSpacingWidget.horizontalSM(),
                    Text(category.name),
                  ],
                ),
              );
            }).toList(),
            validator: (value) {
              if (value == null) return 'Kategori wajib dipilih';
              return null;
            },
            onChanged: (value) {
              setState(() => _selectedCategoryId = value);
            },
          ),
          const AppSpacingWidget.verticalLG(),

          // Amount field
          Text(
            'Jumlah Anggaran',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const AppSpacingWidget.verticalXS(),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [CurrencyInputFormatter()],
            decoration: InputDecoration(
              hintText: '0',
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
              if (value == null || value.isEmpty) return 'Jumlah wajib diisi';
              final amount = CurrencyInputFormatter.parseRupiah(value);
              if (amount == null || amount <= 0) {
                return 'Jumlah harus lebih dari 0';
              }
              return null;
            },
          ),
          const AppSpacingWidget.verticalXXXL(),

          // Submit button
          FilledButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(_isEditing ? 'Simpan Perubahan' : 'Buat Anggaran'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kategori terlebih dahulu'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final amount = CurrencyInputFormatter.parseRupiah(_amountController.text);
    if (amount == null || amount <= 0) return;

    setState(() => _isLoading = true);

    try {
      final controller = ref.read(budgetFormControllerProvider);
      Result<BudgetEntity> result;

      if (_isEditing && _existingBudget != null) {
        result = await controller.submitUpdate(
          id: _existingBudget!.id!,
          amount: amount.toDouble(),
        );
      } else {
        result = await controller.submitCreate(
          categoryId: _selectedCategoryId!,
          year: _year,
          month: _month,
          amount: amount.toDouble(),
        );
      }

      if (!mounted) return;

      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Anggaran berhasil diubah'
                  : 'Anggaran berhasil dibuat',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop(true);
      } else {
        // Per AGENTS.md: Never show technical errors to users
        final userMessage = ErrorMessageMapper.getUserMessage(result.failure);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.e('BudgetForm: Error submitting form', e, stackTrace);
      if (mounted) {
        // Per AGENTS.md: Never show technical errors to users
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
