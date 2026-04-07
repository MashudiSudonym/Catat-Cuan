import 'package:catat_cuan/domain/entities/widget/widget_data_entity.dart';

/// Serializer for widget data entities
///
/// Handles conversion between WidgetDataEntity and JSON
/// for storage in shared preferences (accessed by native widgets)
class WidgetDataSerializer {
  /// Convert WidgetDataEntity to JSON
  static Map<String, dynamic> toJson(WidgetDataEntity data) => {
        'currentMonthExpenses': data.currentMonthExpenses,
        'currentMonthIncome': data.currentMonthIncome,
        'transactionCount': data.transactionCount,
        'recentTransactions': data.recentTransactions
            .map((t) => TransactionPreviewSerializer.toJson(t))
            .toList(),
        'lastUpdated': data.lastUpdated.toIso8601String(),
        'currency': data.currency,
      };

  /// Create WidgetDataEntity from JSON
  static WidgetDataEntity fromJson(Map<String, dynamic> json) =>
      WidgetDataEntity(
        currentMonthExpenses: (json['currentMonthExpenses'] as num).toDouble(),
        currentMonthIncome: (json['currentMonthIncome'] as num).toDouble(),
        transactionCount: json['transactionCount'] as int,
        recentTransactions: (json['recentTransactions'] as List)
            .map((item) => TransactionPreviewSerializer.fromJson(item as Map<String, dynamic>))
            .toList(),
        lastUpdated: DateTime.parse(json['lastUpdated'] as String),
        currency: json['currency'] as String,
      );
}

/// Serializer for transaction preview entities
class TransactionPreviewSerializer {
  /// Convert TransactionPreviewEntity to JSON
  static Map<String, dynamic> toJson(TransactionPreviewEntity entity) => {
        'id': entity.id,
        'title': entity.title,
        'amount': entity.amount,
        'category': entity.category,
        'categoryColor': entity.categoryColor,
        'date': entity.date.toIso8601String(),
        'isExpense': entity.isExpense,
      };

  /// Create TransactionPreviewEntity from JSON
  static TransactionPreviewEntity fromJson(Map<String, dynamic> json) =>
      TransactionPreviewEntity(
        id: json['id'] as int,
        title: json['title'] as String,
        amount: (json['amount'] as num).toDouble(),
        category: json['category'] as String,
        categoryColor: json['categoryColor'] as String,
        date: DateTime.parse(json['date'] as String),
        isExpense: json['isExpense'] as bool,
      );
}
