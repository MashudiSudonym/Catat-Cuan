import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/repositories/category_repository_impl.dart';
import 'package:catat_cuan/data/repositories/transaction_repository_impl.dart';
import 'package:catat_cuan/domain/repositories/category_repository.dart';
import 'package:catat_cuan/domain/repositories/transaction_repository.dart';

/// Provider untuk DatabaseHelper
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

/// Provider untuk TransactionRepository
/// Following DIP: Provides abstraction (TransactionRepository), not concrete implementation
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(ref.read(databaseHelperProvider));
});

/// Provider untuk CategoryRepository
/// Following DIP: Provides abstraction (CategoryRepository), not concrete implementation
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.read(databaseHelperProvider));
});
