import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../services/transaction_service.dart';

final transactionServiceProvider = Provider<TransactionService>(
  (ref) => TransactionService(client: ref.read(apiClientProvider)),
);
