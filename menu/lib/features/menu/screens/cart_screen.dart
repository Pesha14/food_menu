import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/providers/auth_provider.dart';
import '../../theme/app_tokens.dart';
import '../../transactions/models/cart_receipt.dart';
import '../../transactions/models/payment_method.dart';
import '../../transactions/models/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/screens/receipt_screen.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _checkingOut = false;

  /// The backend only accepts one menu_id per transaction, so checkout
  /// fires one POST /transactions call per unit of quantity in the cart.
  /// Every discount and paid-amount figure in the resulting receipt is a
  /// straight sum of what the backend returned for each call -- the app
  /// never computes a discount itself.
  Future<void> _checkout() async {
    final session = ref.read(authProvider);
    final cart = ref.read(cartProvider);
    if (session == null || cart.isEmpty) return;

    setState(() => _checkingOut = true);
    final transactionService = ref.read(transactionServiceProvider);
    final List<Transaction> results = [];

    try {
      for (final cartItem in cart) {
        for (var i = 0; i < cartItem.quantity; i++) {
          final transaction = await transactionService.createTransaction(
            token: session.token,
            menuId: cartItem.item.menuId,
            paymentMethod: PaymentMethod.cash,
          );
          results.add(transaction);
        }
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptScreen(receipt: CartReceipt(results)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            results.isEmpty
                ? 'Checkout failed: $e'
                : 'Checkout failed partway through (${results.length} of ${cart.fold<int>(0, (s, c) => s + c.quantity)} items charged): $e',
          ),
          backgroundColor: AppTokens.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _checkingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);

    return Scaffold(
      backgroundColor: AppTokens.bg,
      appBar: AppBar(title: const Text('Cart')),
      body: cart.isEmpty
          ? Center(
              child: Text(
                'Your cart is empty.',
                style: GoogleFonts.inter(color: AppTokens.mutedText),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final cartItem = cart[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: AppTokens.cardDecoration,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cartItem.item.menuName,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTokens.ivory,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'KSH ${cartItem.item.pricing.price} each',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTokens.mutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppTokens.gold),
                            onPressed: () => notifier.decrementItem(index),
                          ),
                          Text(
                            '${cartItem.quantity}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTokens.ivory,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppTokens.gold),
                            onPressed: () => notifier.incrementItem(index),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'KSH ${cartItem.lineTotal.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTokens.gold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              decoration: BoxDecoration(
                color: AppTokens.surface,
                border: Border(top: BorderSide(color: AppTokens.cardBorder, width: 0.5)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal',
                          style: GoogleFonts.inter(fontSize: 14, color: AppTokens.mutedText),
                        ),
                        Text(
                          'KSH ${notifier.subtotal.toStringAsFixed(2)}',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTokens.gold,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 12),
                      child: Text(
                        'Discount is applied by the server at checkout',
                        style: GoogleFonts.inter(fontSize: 11, color: AppTokens.mutedText),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _checkingOut ? null : _checkout,
                        icon: _checkingOut
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppTokens.bg),
                              )
                            : const Icon(Icons.receipt_long_rounded),
                        label: const Text('Checkout & Print'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
