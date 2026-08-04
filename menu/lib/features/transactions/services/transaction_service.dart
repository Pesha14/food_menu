import '../../../core/network/api_client.dart';
import '../models/transaction.dart';

class TransactionService {
  final ApiClient _client;

  TransactionService({ApiClient? client}) : _client = client ?? ApiClient();

  /// POST /api/v1/transactions
  /// Discount and amount payable are computed entirely by the backend.
  ///
  /// staff_id is required by the backend's Joi validation middleware,
  /// which runs before the service layer's own logic that overwrites
  /// staff_id with the JWT's staffId for USER-role staff anyway -- so
  /// this value only exists to satisfy validation; the backend does not
  /// trust it for identity.
 Future<Transaction> createTransaction({
  required String token,
  required String staffId,
  required int menuId,
  required int paymentMethod,
}) async {
  final data = await _client.post(
    '/transactions',
    token: token,
    body: {
      'staff_id': staffId,
      'menu_id': menuId,
      'payment_method': paymentMethod,
      'booking_id': 0,
    },
  );

  return Transaction.fromJson(data as Map<String, dynamic>);
}
}

