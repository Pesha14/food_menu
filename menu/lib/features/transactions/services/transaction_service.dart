import '../../../core/network/api_client.dart';
import '../models/transaction.dart';

class TransactionService {
  final ApiClient _client;

  TransactionService({ApiClient? client}) : _client = client ?? ApiClient();

  /// POST /api/v1/transactions
  /// Discount and amount payable are computed entirely by the backend --
  /// the app only sends the chosen menu and payment method.
  Future<Transaction> createTransaction({
    required String token,
    required int menuId,
    required int paymentMethod,
  }) async {
    final data = await _client.post(
      '/transactions',
      token: token,
      body: {'menu_id': menuId, 'payment_method': paymentMethod},
    );

    return Transaction.fromJson(data as Map<String, dynamic>);
  }
}
