import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/domain/entities/category_breakdown_entity.dart';
import 'package:catat_cuan/domain/entities/paginated_result_entity.dart';

/// Test fixtures for generating fake data in tests
class TestFixtures {
  // === Date Helpers ===
  static DateTime get today => DateTime.now();
  static DateTime get yesterday => today.subtract(const Duration(days: 1));
  static DateTime get tomorrow => today.add(const Duration(days: 1));

  static DateTime get march18_2026 => const DateTime(2026, 3, 18, 14, 30);
  static DateTime get march20_2026 => const DateTime(2026, 3, 20, 10, 15);

  // === Category Entity Fixtures ===
  static CategoryEntity categoryFood({
    int? id,
    String? name,
    String? icon,
    String? color,
    CategoryType? type,
    int? sortOrder,
    bool? isActive,
  }) =>
      CategoryEntity(
        id: id ?? 1,
        name: name ?? 'Makan',
        icon: icon ?? '🍽️',
        color: color ?? '#FF64748B',
        type: type ?? CategoryType.expense,
        sortOrder: sortOrder ?? 1,
        isActive: isActive ?? true,
        createdAt: march18_2026,
        updatedAt: march18_2026,
      );

  static CategoryEntity categoryTransport({
    int? id,
    String? name,
    String? icon,
    String? color,
    CategoryType? type,
    int? sortOrder,
    bool? isActive,
  }) =>
      CategoryEntity(
        id: id ?? 2,
        name: name ?? 'Transport',
        icon: icon ?? '🚗',
        color: color ?? '#FF59E6C6',
        type: type ?? CategoryType.expense,
        sortOrder: sortOrder ?? 2,
        isActive: isActive ?? true,
        createdAt: march18_2026,
        updatedAt: march18_2026,
      );

  static CategoryEntity categorySalary({
    int? id,
    String? name,
    String? icon,
    String? color,
    CategoryType? type,
    int? sortOrder,
    bool? isActive,
  }) =>
      CategoryEntity(
        id: id ?? 3,
        name: name ?? 'Gaji',
        icon: icon ?? '💰',
        color: color ?? '#FF34D399',
        type: type ?? CategoryType.income,
        sortOrder: sortOrder ?? 1,
        isActive: isActive ?? true,
        createdAt: march18_2026,
        updatedAt: march18_2026,
      );

  static List<CategoryEntity> get defaultCategories => [
        categoryFood(),
        categoryTransport(),
        categorySalary(),
      ];

  static List<CategoryEntity> categoriesWithType({
    required CategoryType type,
    int count = 5,
  }) {
    final now = DateTime.now();
    return List.generate(
      count,
      (i) => CategoryEntity(
        id: i + 1,
        name: 'Category $i',
        icon: '📁',
        color: '#FF000000',
        type: type,
        sortOrder: i,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  // === Transaction Entity Fixtures ===
  static TransactionEntity transactionLunch({
    int? id,
    int? categoryId,
    String? note,
    double? amount,
    TransactionType? type,
    DateTime? dateTime,
  }) =>
      TransactionEntity(
        id: id ?? 1,
        categoryId: categoryId ?? 1,
        note: note ?? 'Makan siang',
        amount: amount ?? 25000,
        type: type ?? TransactionType.expense,
        dateTime: dateTime ?? march18_2026,
        createdAt: march18_2026,
        updatedAt: march18_2026,
      );

  static TransactionEntity transactionTransport({
    int? id,
    int? categoryId,
    String? note,
    double? amount,
    TransactionType? type,
    DateTime? dateTime,
  }) =>
      TransactionEntity(
        id: id ?? 2,
        categoryId: categoryId ?? 2,
        note: note ?? 'Bensin',
        amount: amount ?? 50000,
        type: type ?? TransactionType.expense,
        dateTime: dateTime ?? march18_2026,
        createdAt: march18_2026,
        updatedAt: march18_2026,
      );

  static TransactionEntity transactionSalary({
    int? id,
    int? categoryId,
    String? note,
    double? amount,
    TransactionType? type,
    DateTime? dateTime,
  }) =>
      TransactionEntity(
        id: id ?? 3,
        categoryId: categoryId ?? 3,
        note: note ?? 'Gaji bulanan',
        amount: amount ?? 5000000,
        type: type ?? TransactionType.income,
        dateTime: dateTime ?? march18_2026,
        createdAt: march18_2026,
        updatedAt: march18_2026,
      );

  static List<TransactionEntity> get defaultTransactions => [
        transactionLunch(),
        transactionTransport(),
        transactionSalary(),
      ];

  static List<TransactionEntity> transactionsWithAmount({
    required double amount,
    int count = 5,
    TransactionType? type,
  }) {
    final now = DateTime.now();
    return List.generate(
      count,
      (i) => TransactionEntity(
        id: i + 1,
        categoryId: 1,
        note: 'Transaction $i',
        amount: amount,
        type: type ?? TransactionType.expense,
        dateTime: now,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  // === Monthly Summary Entity Fixtures ===
  static MonthlySummaryEntity monthlySummaryHealthy({
    String? yearMonth,
    double? totalIncome,
    double? totalExpense,
    double? balance,
    int? transactionCount,
  }) =>
      MonthlySummaryEntity(
        yearMonth: yearMonth ?? '2026-03',
        totalIncome: totalIncome ?? 1000000,
        totalExpense: totalExpense ?? 700000,
        balance: balance ?? 300000,
        transactionCount: transactionCount ?? 25,
        createdAt: march18_2026,
      );

  static MonthlySummaryEntity monthlySummaryImbalance({
    String? yearMonth,
    double? totalIncome,
    double? totalExpense,
    double? balance,
    int? transactionCount,
  }) =>
      MonthlySummaryEntity(
        yearMonth: yearMonth ?? '2026-03',
        totalIncome: totalIncome ?? 500000,
        totalExpense: totalExpense ?? 600000,
        balance: balance ?? -100000,
        transactionCount: transactionCount ?? 15,
        createdAt: march18_2026,
      );

  // === Category Breakdown Entity Fixtures ===
  static CategoryBreakdownEntity categoryBreakdownFood({
    int? categoryId,
    String? categoryName,
    String? categoryIcon,
    String? categoryColor,
    double? totalAmount,
    double? percentage,
    int? transactionCount,
  }) =>
      CategoryBreakdownEntity(
        categoryId: categoryId ?? 1,
        categoryName: categoryName ?? 'Makan',
        categoryIcon: categoryIcon ?? '🍽️',
        categoryColor: categoryColor ?? '#FF64748B',
        totalAmount: totalAmount ?? 450000,
        percentage: percentage ?? 45.0,
        transactionCount: transactionCount ?? 10,
      );

  static CategoryBreakdownEntity categoryBreakdownTransport({
    int? categoryId,
    String? categoryName,
    String? categoryIcon,
    String? categoryColor,
    double? totalAmount,
    double? percentage,
    int? transactionCount,
  }) =>
      CategoryBreakdownEntity(
        categoryId: categoryId ?? 2,
        categoryName: categoryName ?? 'Transport',
        categoryIcon: categoryIcon ?? '🚗',
        categoryColor: categoryColor ?? '#FF59E6C6',
        totalAmount: totalAmount ?? 250000,
        percentage: percentage ?? 25.0,
        transactionCount: transactionCount ?? 5,
      );

  static List<CategoryBreakdownEntity> get defaultCategoryBreakdown => [
        categoryBreakdownFood(),
        categoryBreakdownTransport(),
      ];

  // === Pagination Fixtures ===
  static PaginatedResultEntity<TransactionEntity> paginatedTransactions({
    List<TransactionEntity>? data,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    int? itemsPerPage,
    bool? hasNextPage,
    bool? hasPreviousPage,
  }) =>
      PaginatedResultEntity(
        data: data ?? defaultTransactions,
        currentPage: currentPage ?? 1,
        totalPages: totalPages ?? 1,
        totalItems: totalItems ?? 3,
        itemsPerPage: itemsPerPage ?? 10,
        hasNextPage: hasNextPage ?? false,
        hasPreviousPage: hasPreviousPage ?? false,
      );

  // === Amount Formatting Fixtures ===
  static const List<String> validAmountFormats = [
    '50K',
    '50.000',
    '50000',
    'Rp 50.000',
    'RP 50000',
    '50,000',
  ];

  static const List<String> invalidAmountFormats = [
    'abc',
    '',
    '50.000.000', // Too large for receipt
    '0',
  ];

  // === Date Formatting Fixtures ===
  static const List<String> validDateFormats = [
    '18/03/2026',
    '18-03-2026',
    '18 March 2026',
    '18 Mar 2026',
    '18 Maret 2026',
  ];

  static const List<String> invalidDateFormats = [
    '32/13/2026', // Invalid day/month
    'abc',
    '',
  ];
}
