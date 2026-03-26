import 'package:catat_cuan/domain/entities/transaction_entity.dart';

/// Parameter object untuk filter transaksi
class TransactionFilterParams {
  final DateTime? startDate;
  final DateTime? endDate;
  final int? categoryId;
  final TransactionType? type;

  const TransactionFilterParams({
    this.startDate,
    this.endDate,
    this.categoryId,
    this.type,
  });
}
