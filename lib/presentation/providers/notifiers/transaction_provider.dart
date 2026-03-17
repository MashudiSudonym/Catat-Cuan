import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/presentation/notifiers/transaction_form_notifier.dart';
import 'package:catat_cuan/presentation/notifiers/transaction_list_notifier.dart';
import 'package:catat_cuan/presentation/providers/usecases/transaction_usecase_providers.dart';
import 'package:catat_cuan/presentation/states/transaction_form_state.dart';
import 'package:catat_cuan/presentation/states/transaction_list_state.dart';

/// Provider untuk TransactionListNotifier
/// Following DIP: Injects UseCase dependencies through constructor
final transactionListProvider =
    StateNotifierProvider<TransactionListNotifier, TransactionListState>((ref) {
  return TransactionListNotifier(
    ref.read(getTransactionsUseCaseProvider),
  );
});

/// Provider untuk TransactionFormNotifier
/// Following DIP: Injects UseCase and Validator dependencies through constructor
final transactionFormProvider =
    StateNotifierProvider<TransactionFormNotifier, TransactionFormState>((ref) {
  return TransactionFormNotifier(
    ref.read(addTransactionUseCaseProvider),
    ref.read(updateTransactionUseCaseProvider),
  );
});
