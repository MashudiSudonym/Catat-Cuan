import 'package:flutter/material.dart';
import 'package:catat_cuan/domain/usecases/delete_transaction.dart';
import 'package:catat_cuan/domain/usecases/delete_multiple_transactions_usecase.dart';

/// Controller for handling transaction deletion operations
///
/// Responsibility: Managing all transaction deletion flows including
/// single deletion, batch deletion, and user confirmation dialogs
///
/// Following SRP - Only handles deletion operations and confirmation flows
class TransactionDeleteController {
  final DeleteTransactionUseCase _deleteTransactionUseCase;
  final DeleteMultipleTransactionsUseCase _deleteMultipleTransactionsUseCase;

  TransactionDeleteController(
    this._deleteTransactionUseCase,
    this._deleteMultipleTransactionsUseCase,
  );

  /// Show confirmation dialog and delete a single transaction
  ///
  /// Returns true if deletion was successful, false otherwise
  Future<bool> showDeleteConfirmation(
    BuildContext context,
    int transactionId,
  ) async {
    final confirmed = await _showConfirmationDialog(
      context,
      title: 'Hapus Transaksi',
      content: 'Apakah Anda yakin ingin menghapus transaksi ini?',
      confirmText: 'Hapus',
    );

    if (!confirmed) return false;

    return await _deleteSingleTransaction(transactionId);
  }

  /// Show confirmation dialog and delete multiple transactions
  ///
  /// Returns true if all deletions were successful, false otherwise
  Future<bool> showBatchDeleteConfirmation(
    BuildContext context,
    List<int> transactionIds,
  ) async {
    if (transactionIds.isEmpty) return false;

    final confirmed = await _showConfirmationDialog(
      context,
      title: 'Hapus ${transactionIds.length} Transaksi',
      content:
          'Apakah Anda yakin ingin menghapus ${transactionIds.length} transaksi yang dipilih?',
      confirmText: 'Hapus',
    );

    if (!confirmed) return false;

    return await _deleteBatchTransactions(transactionIds);
  }

  /// Delete a single transaction without confirmation
  ///
  /// This is useful when confirmation is handled elsewhere
  Future<void> deleteTransaction(int id) async {
    await _deleteSingleTransaction(id);
  }

  /// Delete multiple transactions without confirmation
  ///
  /// This is useful when confirmation is handled elsewhere
  Future<void> deleteBatch(List<int> ids) async {
    await _deleteBatchTransactions(ids);
  }

  /// Internal method to delete a single transaction
  Future<bool> _deleteSingleTransaction(int id) async {
    try {
      await _deleteTransactionUseCase.execute(id);
      return true;
    } catch (e) {
      debugPrint('Failed to delete transaction: $e');
      return false;
    }
  }

  /// Internal method to delete multiple transactions
  Future<bool> _deleteBatchTransactions(List<int> ids) async {
    try {
      await _deleteMultipleTransactionsUseCase.execute(ids);
      return true;
    } catch (e) {
      debugPrint('Failed to delete transactions: $e');
      return false;
    }
  }

  /// Show a confirmation dialog
  ///
  /// Returns true if user confirmed, false otherwise
  Future<bool> _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
