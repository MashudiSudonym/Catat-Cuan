import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:catat_cuan/domain/entities/receipt_data_entity.dart';
import 'package:catat_cuan/presentation/providers/app_providers.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:intl/intl.dart';

/// Screen untuk scan struk dan ekstrak nominal
class ScanReceiptScreen extends ConsumerStatefulWidget {
  const ScanReceiptScreen({super.key});

  @override
  ConsumerState<ScanReceiptScreen> createState() => _ScanReceiptScreenState();
}

class _ScanReceiptScreenState extends ConsumerState<ScanReceiptScreen> {
  final _amountController = TextEditingController();
  DateTime? _selectedDateTime;

  @override
  void dispose() {
    _amountController.dispose();
    // Note: Don't use ref.read here as it will cause "Cannot use ref after widget was disposed" error
    // Reset is handled:
    // 1. After successful transaction save (in transaction_form_screen.dart)
    // 2. When user clicks "Foto Ulang" button
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(receiptScanProvider);

    // Listen untuk error
    ref.listen<ReceiptScanState>(
      receiptScanProvider,
      (previous, next) {
        if (next.hasError && previous?.errorMessage != next.errorMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              action: next.errorMessage?.contains('Pengaturan') == true
                  ? SnackBarAction(
                      label: 'Buka',
                      textColor: Colors.white,
                      onPressed: () async {
                        await ref.read(permissionServiceProvider).openSettings();
                      },
                    )
                  : null,
            ),
          );
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Struk'),
        actions: [
          if (scanState.hasResult)
            TextButton(
              onPressed: () => _useScannedData(scanState.scanResult!),
              child: const Text(
                'Gunakan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: AppSpacing.lgAll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image preview
                _buildImagePreview(scanState),
                const AppSpacingWidget.verticalXXL(),

                // Scan buttons
                if (!scanState.hasResult) _buildScanButtons(scanState),

                // Result section
                if (scanState.hasResult) _buildResultSection(scanState),

                const SizedBox(height: 80), // Non-standard (80px) - extra space for loading
              ],
            ),
          ),

          // Loading overlay
          if (scanState.isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: AppGlassContainer.glassSurface(
                  padding: AppSpacing.all(AppSpacing.xxxl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const AppSpacingWidget.verticalLG(),
                      Text(
                        scanState.isProcessing
                            ? 'Membaca struk...'
                            : 'Mengambil gambar...',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Image preview widget
  Widget _buildImagePreview(ReceiptScanState scanState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (scanState.imagePath == null) {
      return AppGlassContainer.glassCard(
        height: 300,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
            ),
            const AppSpacingWidget.verticalLG(),
            Text(
              'Ambil foto struk atau pilih dari galeri',
              style: TextStyle(
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Get image dimensions to calculate aspect ratio
    final imageFile = File(scanState.imagePath!);

    return ClipRRect(
      borderRadius: AppRadius.mdAll,
      child: FutureBuilder<Size>(
        future: _getImageSize(imageFile),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData &&
              snapshot.data != null) {
            final imageSize = snapshot.data!;
            final aspectRatio = imageSize.width / imageSize.height;

            // Calculate height based on screen width and image aspect ratio
            // But limit max height to prevent taking too much screen space
            final screenWidth = MediaQuery.of(context).size.width - (AppSpacing.lg * 2); // Horizontal padding (16 * 2)
            final calculatedHeight = screenWidth / aspectRatio;
            final maxHeight = MediaQuery.of(context).size.height * 0.6; // Max 60% of screen height
            final finalHeight = calculatedHeight > maxHeight ? maxHeight : calculatedHeight;

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: maxHeight,
              ),
              child: Image.file(
                imageFile,
                width: double.infinity,
                height: finalHeight,
                fit: BoxFit.contain, // Use contain to show entire image without cropping
              ),
            );
          }

          // Fallback while loading
          return const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  /// Get image dimensions
  Future<Size> _getImageSize(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final decodedImage = await decodeImageFromList(bytes);
    return Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
  }

  /// Scan buttons (Camera & Gallery)
  Widget _buildScanButtons(ReceiptScanState scanState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: scanState.isLoading
              ? null
              : () => ref.read(receiptScanProvider.notifier).scanFromCamera(),
          icon: const Icon(Icons.camera_alt_outlined),
          label: const Text('Ambil Foto'),
          style: ElevatedButton.styleFrom(
            padding: AppSpacing.symmetric(vertical: AppSpacing.lg),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
        const AppSpacingWidget.verticalMD(),
        OutlinedButton.icon(
          onPressed: scanState.isLoading
              ? null
              : () =>
                  ref.read(receiptScanProvider.notifier).scanFromGallery(),
          icon: const Icon(Icons.photo_library_outlined),
          label: const Text('Pilih dari Galeri'),
          style: ElevatedButton.styleFrom(
            padding: AppSpacing.symmetric(vertical: AppSpacing.lg),
            foregroundColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  /// Result section showing extracted amount and date
  Widget _buildResultSection(ReceiptScanState scanState) {
    final result = scanState.scanResult!;
    final isConfident = result.confidenceScore >= 0.7;

    // Initialize controller and date when result is available
    if (_amountController.text.isEmpty && result.extractedAmount != null) {
      _amountController.text = _formatCurrency(result.extractedAmount!);
    }
    if (_selectedDateTime == null && result.extractedDate != null) {
      _selectedDateTime = result.extractedDate;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success indicator
        AppGlassContainer.glassCard(
          padding: AppSpacing.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(
                isConfident ? Icons.check_circle : Icons.warning,
                color: isConfident ? AppColors.success : AppColors.warning,
              ),
              const AppSpacingWidget.horizontalMD(),
              Expanded(
                child: Text(
                  isConfident
                      ? 'Data struk berhasil ditemukan!'
                      : 'Pastikan data yang terdeteksi sudah benar',
                  style: TextStyle(
                    color: isConfident ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const AppSpacingWidget.verticalXXL(),

        // Date and Time picker row
        Row(
          children: [
            // Date picker field
            Expanded(
              child: InkWell(
                onTap: () => _pickDate(result),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Tanggal',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today),
                    prefixIconConstraints: const BoxConstraints(minWidth: 48),
                    suffixIcon: _selectedDateTime != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _selectedDateTime = null;
                                final updatedResult = result.copyWith(extractedDate: null);
                                ref.read(receiptScanProvider.notifier).updateScanResult(updatedResult);
                              });
                            },
                          )
                        : null,
                  ),
                  child: Text(
                    _selectedDateTime != null
                        ? AppDateFormatter.formatDayMonthYearDate(_selectedDateTime!)
                        : 'Pilih tanggal',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
            const AppSpacingWidget.horizontalMD(),
            // Time picker field
            Expanded(
              child: InkWell(
                onTap: () => _pickTime(result),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Jam',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.access_time),
                    prefixIconConstraints: const BoxConstraints(minWidth: 48),
                  ),
                  child: Text(
                    _selectedDateTime != null
                        ? AppDateFormatter.formatTimeOnly(_selectedDateTime!)
                        : '--:--',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
          ],
        ),
        const AppSpacingWidget.verticalLG(),

        // Editable amount field
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Nominal',
            prefixText: 'Rp ',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.payments_outlined),
            prefixIconConstraints: const BoxConstraints(minWidth: 48),
          ),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          onChanged: (value) {
            // Update scan result when user edits
            final amount = _parseCurrency(value);
            if (amount != null) {
              final updatedResult = result.copyWith(extractedAmount: amount);
              ref.read(receiptScanProvider.notifier).updateScanResult(updatedResult);
            }
          },
        ),
        const AppSpacingWidget.verticalXXL(),

        // Retake button
        OutlinedButton.icon(
          onPressed: () {
            _amountController.clear();
            _selectedDateTime = null;
            ref.read(receiptScanProvider.notifier).reset();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Foto Ulang'),
        ),
      ],
    );
  }

  /// Pick date from date picker (preserves time)
  Future<void> _pickDate(ReceiptDataEntity result) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        // Preserve the time from the existing DateTime, or use current time if not set
        final existingTime = _selectedDateTime;
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          existingTime?.hour ?? now.hour,
          existingTime?.minute ?? now.minute,
          existingTime?.second ?? now.second,
        );
        final updatedResult = result.copyWith(extractedDate: _selectedDateTime);
        ref.read(receiptScanProvider.notifier).updateScanResult(updatedResult);
      });
    }
  }

  /// Pick time from time picker
  Future<void> _pickTime(ReceiptDataEntity result) async {
    final now = DateTime.now();
    final initialTime = _selectedDateTime ?? now;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialTime.hour, minute: initialTime.minute),
    );

    if (picked != null) {
      setState(() {
        // Preserve the date from the existing DateTime, or use today if not set
        final existingDate = _selectedDateTime;
        _selectedDateTime = DateTime(
          existingDate?.year ?? now.year,
          existingDate?.month ?? now.month,
          existingDate?.day ?? now.day,
          picked.hour,
          picked.minute,
          existingDate?.second ?? 0,
        );
        final updatedResult = result.copyWith(extractedDate: _selectedDateTime);
        ref.read(receiptScanProvider.notifier).updateScanResult(updatedResult);
      });
    }
  }

  /// Use scanned data and return to form
  void _useScannedData(ReceiptDataEntity result) {
    context.pop(result);
  }

  /// Format currency for display
  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );
    return formatter.format(amount).replaceAll(',', '.');
  }

  /// Parse currency string to double
  double? _parseCurrency(String value) {
    final cleaned = value.replaceAll('.', '').replaceAll('Rp', '').trim();
    return double.tryParse(cleaned);
  }
}
