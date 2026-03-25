# Design System Implementation Guide

## Overview

This guide demonstrates how to use the new design system utilities and components in the Catat Cuan application.

## Foundation Layer (Phase 1) - Completed ✅

### 1. Responsive Utilities

#### AppSpacing
```dart
import 'package:catat_cuan/presentation/utils/utils.dart';

// Instead of hardcoded values:
// padding: const EdgeInsets.all(16)  // ❌

// Use AppSpacing constants:
padding: AppSpacing.all(AppSpacing.lg)  // ✅ 16px

// Or use preset EdgeInsets:
padding: AppSpacing.lgAll  // ✅ 16px all

// Horizontal/vertical spacing:
padding: AppSpacing.horizontal(AppSpacing.md)  // 12px horizontal
padding: AppSpacing.vertical(AppSpacing.xl)    // 20px vertical

// As a widget:
Column(
  children: [
    Text('Hello'),
    const AppSpacingWidget.verticalMD(),  // 12px vertical space
    Text('World'),
  ],
)

// Extension method:
Text('Hello').withSpacing(AppSpacing.lg)
```

**Spacing Scale:**
- `xs` = 4px
- `sm` = 8px
- `md` = 12px
- `lg` = 16px
- `xl` = 20px
- `xxl` = 24px
- `xxxl` = 32px

#### AppRadius
```dart
import 'package:catat_cuan/presentation/utils/utils.dart';

// Instead of:
// borderRadius: BorderRadius.circular(12)  // ❌

// Use AppRadius:
borderRadius: AppRadius.all(AppRadius.md)  // ✅ 12px

// Or use presets:
borderRadius: AppRadius.mdAll  // ✅ 12px all corners

// For shapes:
shape: AppBorderRadius.mdShape  // ✅ RoundedRectangleBorder with 12px radius
```

**Radius Scale:**
- `xs` = 4px
- `sm` = 8px
- `md` = 12px
- `lg` = 16px
- `xl` = 20px
- `xxl` = 24px
- `circle` = 999px

#### AppDimensions & ScreenSize
```dart
import 'package:catat_cuan/presentation/utils/utils.dart';

// Check screen size:
@override
Widget build(BuildContext context) {
  if (ScreenSize.isMobile(context)) {
    // Mobile layout
  } else if (ScreenSize.isDesktop(context)) {
    // Desktop layout
  }

  // Get responsive value:
final columns = ScreenSize.getValue(
    context: context,
    small: 1,
    medium: 2,
    large: 3,
  );

  // Responsive builder:
  return ResponsiveBuilder(
    small: (context, constraints) => MobileLayout(),
    medium: (context, constraints) => TabletLayout(),
    large: (context, constraints) => DesktopLayout(),
  );
}
```

### 2. Formatters

#### AppDateFormatter
```dart
import 'package:catat_cuan/presentation/utils/utils.dart';

// Format dates:
final now = DateTime.now();

AppDateFormatter.formatDayMonthYearDate(now)  // "13 Jan 2024"
AppDateFormatter.formatDayMonthDate(now)       // "13 Jan"
AppDateFormatter.formatMonthYearDate(now)      // "Januari 2024"
AppDateFormatter.formatRelativeDate(now)       // "Hari ini", "Kemarin", etc.
AppDateFormatter.formatRelativeDateTime(now)   // "Hari ini, 14:30"

// Date utilities:
if (AppDateFormatter.isToday(date)) {
  // Handle today's date
}

final startOfMonth = AppDateFormatter.startOfMonth(now);
final endOfMonth = AppDateFormatter.endOfMonth(now);
```

#### CurrencyFormatter (Existing)
```dart
import 'package:catat_cuan/presentation/utils/utils.dart';

// Format currency:
final amount = 1000000;
amount.toRupiah()  // "1.000.000" (without prefix)
amount.toRupiahWithoutPrefix()  // "1.000.000"
```

### 3. Base Widgets

#### AppEmptyState
```dart
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';

// Custom empty state:
AppEmptyState(
  icon: Icons.receipt_long,
  title: 'Belum ada transaksi',
  subtitle: 'Mulai lacak pengeluaran dan pemasukan Anda',
  actionLabel: 'Tambah Transaksi',
  onAction: () => Navigator.push(...),
)

// Pre-configured states:
AppEmptyStates.transactions(
  onAdd: () => showAddTransaction(),
)

AppEmptyStates.categories(
  onAdd: () => showAddCategory(),
)

AppEmptyStates.noResults(
  onClear: () => clearFilters(),
  filterDescription: 'Kategori: Makanan',
)
```

#### AppErrorState
```dart
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';

// Custom error state:
AppErrorState(
  title: 'Terjadi kesalahan',
  subtitle: 'Gagal memuat data. Silakan coba lagi.',
  onRetry: () => retry(),
)

// Pre-configured states:
AppErrorStates.generic(
  message: 'Gagal menyimpan data',
  onRetry: () => save(),
)

AppErrorStates.network(
  onRetry: () => reload(),
)

AppErrorStates.permission(
  permission: 'kamera',
  onOpenSettings: () => openAppSettings(),
)
```

#### AppContainer
```dart
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';

// Card style:
AppContainer.card(
  child: Text('Content'),
  onTap: () => handleClick(),
)

// Bordered:
AppContainer.bordered(
  child: Text('Content'),
)

// Rounded:
AppContainer.rounded(
  child: Text('Content'),
)

// Pill-shaped:
AppContainer.pill(
  child: Text('Chip'),
)

// Custom:
AppContainer(
  padding: AppSpacing.lgAll,
  color: AppColors.primary,
  borderRadius: AppRadius.lgAll,
  child: Text('Custom'),
)
```

#### AppShimmer (Loading Skeleton)
```dart
import 'package:catat_cuan/presentation/widgets/base/base.dart';

// Shimmer box for skeleton loading:
AppShimmerBox(
  width: double.infinity,
  height: 60,
  borderRadius: AppRadius.mdAll,
)

// Wrap any widget:
AppShimmer(
  child: YourWidget(),
)
```

### 4. Screen Mixins

#### ScreenStateMixin (for StatefulWidget)
```dart
import 'package:flutter/material.dart';
import 'package:catat_cuan/presentation/utils/mixins/screen_mixin.dart';

class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen>
    with ScreenStateMixin {

  void _handleSuccess() {
    showSuccessSnackBar('Data berhasil disimpan');
  }

  void _handleError() {
    showErrorSnackBar('Gagal menyimpan data');
  }

  Future<void> _handleDelete() async {
    final confirmed = await showConfirmDialog(
      title: 'Hapus Data',
      content: 'Apakah Anda yakin ingin menghapus data ini?',
      isDestructive: true,
    );

    if (confirmed == true) {
      // Delete logic
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: _handleSuccess,
          child: Text('Show Success'),
        ),
      ),
    );
  }
}
```

#### ConsumerScreenStateMixin (for ConsumerStatefulWidget)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/presentation/utils/mixins/screen_mixin.dart';

class MyScreen extends ConsumerStatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends ConsumerState<MyScreen>
    with ConsumerScreenStateMixin {

  void _handleSuccess() {
    showSuccessSnackBar('Data berhasil disimpan');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myProvider);

    return Scaffold(
      body: state.when(
        loading: () => AppLoadingState(),
        error: (error, stack) => AppErrorStates.generic(
          message: error.toString(),
          onRetry: () => ref.read(myProvider.notifier).refresh(),
        ),
        data: (data) => ContentWidget(data: data),
      ),
    );
  }
}
```

## Migration Guide

### Before (Hardcoded Values)
```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.shade300),
  ),
  child: Column(
    children: [
      const SizedBox(height: 8),
      Text('Title'),
      const SizedBox(height: 16),
      Text('Content'),
    ],
  ),
)
```

### After (Design System)
```dart
AppContainer.bordered(
  child: Column(
    children: [
      const AppSpacingWidget.verticalSM(),
      Text('Title'),
      const AppSpacingWidget.verticalLG(),
      Text('Content'),
    ],
  ),
)
```

## Benefits

1. **Consistency**: All spacing, radii, and colors follow a defined scale
2. **Maintainability**: Changes to design tokens propagate everywhere
3. **Type Safety**: Constants prevent typos (e.g., `AppSpacing.lg` vs `16.0`)
4. **Responsiveness**: Built-in utilities for adaptive layouts
5. **Reusability**: Pre-configured widgets reduce code duplication

## Next Steps

- [ ] Replace hardcoded values in existing screens
- [ ] Consolidate duplicate widgets (TransactionCard, TransactionTypeToggle, etc.)
- [ ] Refactor large build methods using composition pattern
- [ ] Implement responsive layouts for different screen sizes
- [ ] Create navigation abstraction layer

## Files Created

```
lib/presentation/utils/
├── responsive/
│   ├── app_spacing.dart       # 4px grid spacing system
│   ├── app_radius.dart        # Consistent border radius
│   ├── app_dimensions.dart    # Responsive dimensions & breakpoints
│   └── responsive_builder.dart # Responsive builder widgets
├── formatters/
│   └── app_date_formatter.dart # Centralized date formatting
├── mixins/
│   └── screen_mixin.dart      # Common screen behaviors
└── utils.dart                 # Export file for easy importing

lib/presentation/widgets/base/
├── app_container.dart         # Consistent container with presets
├── app_empty_state.dart       # Unified empty state
├── app_error_state.dart       # Unified error & loading states
└── base.dart                  # Export file
```

**Total Lines of Code**: 1,669 lines

## Testing

Run the following to ensure everything works:

```bash
# Run all tests
flutter test

# Run the app
flutter run

# Analyze code
flutter analyze
```

All tests should pass and the app should run without errors.
