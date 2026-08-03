import 'transaction.dart';

/// One checkout can now contain several menu items. Since the backend's
/// /transactions endpoint only accepts one menu_id at a time, checkout
/// fires one POST per cart item (per unit of quantity) and this class
/// bundles the resulting transactions into a single combined receipt.
///
/// Every figure here is a straight sum of values the backend already
/// returned per transaction -- meal_cost, discount_amt, paid_amt. No
/// discount or payable amount is computed on the app; we only add up
/// numbers the backend already calculated for us.
class CartReceipt {
  final List<Transaction> transactions;

  CartReceipt(this.transactions);

  Transaction get first => transactions.first;

  num get subtotal =>
      transactions.fold<num>(0, (sum, t) => sum + t.mealCost);

  num get totalDiscount =>
      transactions.fold<num>(0, (sum, t) => sum + t.discountAmount);

  num get totalPaid =>
      transactions.fold<num>(0, (sum, t) => sum + t.paidAmount);

  String get combinedReceiptNo =>
      transactions.map((t) => t.receiptNo).join(', ');
}
