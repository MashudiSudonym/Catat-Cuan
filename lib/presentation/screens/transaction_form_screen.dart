import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/domain/entities/receipt_data_entity.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/presentation/providers/app_providers.dart';
import 'package:catat_cuan/presentation/widgets/currency_input_field.dart';
import 'package:catat_cuan/presentation/widgets/transaction_type_toggle.dart';
import 'package:catat_cuan/presentation/widgets/category_grid.dart';
import 'package:catat_cuan/presentation/widgets/quick_add_category.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:catat_cuan/presentation/navigation/routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Screen untuk form input transaksi (create & edit)
/// Menggunakan custom widgets dengan design sesuai UI reference
class TransactionFormScreen extends ConsumerStatefulWidget {
  final TransactionEntity? transactionToEdit;
  final int? transactionId;

  const TransactionFormScreen({
    super.key,
    this.transactionToEdit,
    this.transactionId,
  });

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _noteController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load data untuk mode edit (AC-LOG-006.1)
    if (widget.transactionToEdit != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(transactionFormProvider.notifier)
            .loadForEdit(widget.transactionToEdit!);
        _populateNote(widget.transactionToEdit!);
      });
    } else if (widget.transactionId != null) {
      // Load transaction by ID from route
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await ref
            .read(transactionFormProvider.notifier)
            .loadById(widget.transactionId!);
      });
    }
  }

  void _populateNote(TransactionEntity transaction) {
    _noteController.text = transaction.note ?? '';
  }

  @override
  void dispose() {
    _noteController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(transactionFormProvider);

    // Listen untuk submit success
    ref.listen<TransactionFormState>(
      transactionFormProvider,
      (previous, next) {
        // Clear error setelah submit sukses
        if (previous?.submitError != null && next.submitError == null) {
          // Error was cleared (after successful submit)
        }
        // Show snackbar jika ada error
        if (next.submitError != null && previous?.submitError != next.submitError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.submitError!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transactionToEdit == null
            ? 'Tambah Transaksi'
            : 'Edit Transaksi'),
        actions: [
          if (widget.transactionToEdit != null)
            TextButton(
              onPressed: formState.isSubmitting
                  ? null
                  : () => _showDeleteConfirmation(context, formState),
              child: Text(
                'Hapus',
                style: TextStyle(color: AppColors.expense),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: AppSpacing.lgAll,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Scan struk button
              _buildScanButton(),
              const AppSpacingWidget.verticalLG(),

              // Large currency input field (sesuai reference design)
              _buildCurrencyInput(formState),
              const AppSpacingWidget.verticalXXL(),

              // Type toggle (Pemasukan/Pengeluaran) - AC-LOG-001.1
              TransactionTypeToggle(
                selectedType: formState.type,
                onTypeChanged: (type) {
                  ref.read(transactionFormProvider.notifier).setType(type);
                },
              ),
              if (formState.validationErrors.containsKey('type')) ...[
                const AppSpacingWidget.verticalXS(),
                Padding(
                  padding: AppSpacing.only(left: AppSpacing.lg),
                  child: Text(
                    formState.validationErrors['type']!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
              const AppSpacingWidget.verticalXXL(),

              // Category grid (menggantikan dropdown) - AC-LOG-001.1
              _buildCategoryGrid(formState),
              const AppSpacingWidget.verticalXXL(),

              // Date & Time inputs - AC-LOG-001.1
              Row(
                children: [
                  Expanded(child: _buildDateField(formState)),
                  const AppSpacingWidget.horizontalMD(),
                  Expanded(child: _buildTimeField(formState)),
                ],
              ),
              const AppSpacingWidget.verticalXXL(),

              // Note input (opsional) - AC-LOG-001.1
              _buildNoteField(formState),
              const AppSpacingWidget.verticalXXXL(),

              // Submit button - AC-LOG-002.3
              _buildSubmitButton(formState),
            ],
          ),
        ),
      ),
    );
  }

  /// Large currency input field sesuai reference design
  Widget _buildCurrencyInput(TransactionFormState formState) {
    return CurrencyInputField(
      initialValue: formState.nominal,
      onChanged: (value) {
        ref.read(transactionFormProvider.notifier).setNominal(value);
      },
      errorText: formState.validationErrors['nominal'],
      labelText: 'Nominal',
    );
  }

  /// Category grid untuk memilih kategori
  Widget _buildCategoryGrid(TransactionFormState formState) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return categoriesAsync.when(
      data: (categories) {
        // Filter categories based on selected type
        final filteredCategories = formState.type == TransactionType.income
            ? categories.where((c) => c.type.value == 'income').toList()
            : categories.where((c) => c.type.value == 'expense').toList();

        return CategoryGrid(
          categories: filteredCategories,
          selectedCategoryId: formState.categoryId,
          onCategorySelected: (categoryId) {
            ref.read(transactionFormProvider.notifier).setCategory(categoryId);
          },
          onAddCategory: () => _showQuickAddCategory(formState),
        );
      },
      loading: () => AppGlassContainer.glassCard(
        height: 120,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      ),
      error: (error, _) => AppGlassContainer.glassCard(
        height: 120,
        padding: AppSpacing.all(AppSpacing.md),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppColors.expense),
            const SizedBox(height: 8),
            Text(
              'Gagal memuat kategori',
              style: TextStyle(color: AppColors.expense),
            ),
          ],
        ),
      ),
    );
  }

  /// Date input dengan date picker
  Widget _buildDateField(TransactionFormState formState) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: formState.date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          ref.read(transactionFormProvider.notifier).setDate(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Tanggal',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.calendar_today),
          prefixIconConstraints: const BoxConstraints(minWidth: 48),
        ),
        child: Text(
          formState.date != null
              ? DateFormat('dd MMM yyyy', 'id_ID').format(formState.date!)
              : 'Pilih tanggal',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  /// Time input dengan time picker
  Widget _buildTimeField(TransactionFormState formState) {
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showTimePicker(
          context: context,
          initialTime: formState.time != null
              ? TimeOfDay.fromDateTime(formState.time!)
              : TimeOfDay.fromDateTime(now),
        );
        if (picked != null) {
          final newDateTime = DateTime(
            formState.date?.year ?? now.year,
            formState.date?.month ?? now.month,
            formState.date?.day ?? now.day,
            picked.hour,
            picked.minute,
          );
          ref.read(transactionFormProvider.notifier).setTime(newDateTime);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Waktu',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.access_time),
          prefixIconConstraints: const BoxConstraints(minWidth: 48),
        ),
        child: Text(
          formState.time != null
              ? DateFormat('HH:mm', 'id_ID').format(formState.time!)
              : 'Pilih waktu',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  /// Note input (opsional)
  Widget _buildNoteField(TransactionFormState formState) {
    return TextFormField(
      controller: _noteController,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Catatan',
        hintText: 'Tambahkan catatan (opsional)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.note_add_outlined),
        prefixIconConstraints: BoxConstraints(minWidth: 48),
      ),
      onChanged: (value) {
        ref.read(transactionFormProvider.notifier).setNote(value);
      },
    );
  }

  /// Scan struk button untuk mengambil nominal dari gambar
  Widget _buildScanButton() {
    return ElevatedButton.icon(
      onPressed: _scanReceipt,
      icon: const Icon(Icons.camera_alt_outlined),
      label: const Text('Scan Struk'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        foregroundColor: AppColors.primary,
      ),
    );
  }

  /// Handle scan receipt action
  Future<void> _scanReceipt() async {
    final result = await context.push<ReceiptDataEntity>(AppRoutes.scanReceipt);

    if (result != null) {
      // Pre-fill form with scanned data
      if (result.extractedAmount != null) {
        ref
            .read(transactionFormProvider.notifier)
            .setNominal(result.extractedAmount!);
      }

      if (result.extractedDate != null) {
        // Gunakan DateTime yang sudah diekstrak (termasuk waktu dari struk)
        ref.read(transactionFormProvider.notifier).setDate(result.extractedDate!);
        ref.read(transactionFormProvider.notifier).setTime(result.extractedDate!);
      }

      // Show success message
      if (mounted) {
        final messageParts = <String>[];
        if (result.extractedAmount != null) {
          messageParts.add('Nominal: ${_formatCurrency(result.extractedAmount!)}');
        }
        if (result.extractedDate != null) {
          messageParts.add('Tanggal: ${AppDateFormatter.formatDayMonthYearDate(result.extractedDate!)}');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(messageParts.join('\n')),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Format currency for display
  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Submit button
  Widget _buildSubmitButton(TransactionFormState formState) {
    final isValid = formState.isValid;

    return ElevatedButton(
      onPressed: formState.isSubmitting
          ? null
          : () async {
              if (!isValid) {
                // Show validation error
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mohon lengkapi semua field yang wajib diisi'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              final success = await ref
                  .read(transactionFormProvider.notifier)
                  .submit();

              if (success && mounted) {
                // Clear receipt scan session after successful transaction save
                final scanController = ref.read(receiptScanningControllerProvider);
                scanController.reset();

                // Show success snackbar (AC-LOG-004.2)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      widget.transactionToEdit == null
                          ? 'Transaksi berhasil ditambahkan'
                          : 'Transaksi berhasil diperbarui',
                    ),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                // Navigate back (AC-LOG-004.3)
                context.pop();
              }
            },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        disabledBackgroundColor: Colors.grey.shade300,
      ),
      child: formState.isSubmitting
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              widget.transactionToEdit == null
                  ? 'Simpan Transaksi'
                  : 'Update Transaksi',
              style: const TextStyle(fontSize: 16),
            ),
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation(
    BuildContext context,
    TransactionFormState formState,
  ) async {
    final controller = ref.read(transactionDeleteControllerProvider);
    final success = await controller.showDeleteConfirmation(
      context,
      widget.transactionToEdit!.id!,
    );

    if (context.mounted) {
      if (success) {
        // Invalidate transaction list providers and summary to trigger refresh
        ref.invalidate(transactionListProvider);
        ref.invalidate(transactionListPaginatedProvider);
        ref.invalidate(monthlySummaryProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi berhasil dihapus'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus transaksi'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Show quick add category bottom sheet
  void _showQuickAddCategory(TransactionFormState formState) async {
    final newCategory = await showQuickAddCategorySheet(
      context: context,
      type: formState.type == TransactionType.income
          ? CategoryType.income
          : CategoryType.expense,
    );

    if (newCategory != null) {
      // Refresh categories and select the new category
      ref.read(categoryListProvider.notifier).loadCategories();
      ref
          .read(transactionFormProvider.notifier)
          .setCategory(newCategory.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Kategori "${newCategory.name}" ditambahkan dan dipilih',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
