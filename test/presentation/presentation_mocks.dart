import 'package:catat_cuan/domain/usecases/add_transaction.dart';
import 'package:catat_cuan/domain/usecases/delete_transaction.dart';
import 'package:catat_cuan/domain/usecases/delete_multiple_transactions_usecase.dart';
import 'package:catat_cuan/domain/usecases/update_transaction.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([
  MockSpec<AddTransactionUseCase>(),
  MockSpec<UpdateTransactionUseCase>(),
  MockSpec<DeleteTransactionUseCase>(),
  MockSpec<DeleteMultipleTransactionsUseCase>(),
])
import 'presentation_mocks.mocks.dart';
