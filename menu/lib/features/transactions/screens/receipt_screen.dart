import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:zcs_sdk_plugin/zcs_sdk_plugin.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/auth_screen.dart';
import '../../menu/providers/cart_provider.dart';
import '../../theme/app_tokens.dart';
import '../models/cart_receipt.dart';

class ReceiptScreen extends ConsumerStatefulWidget {
  final CartReceipt receipt;

  const ReceiptScreen({super.key, required this.receipt});

  @override
  ConsumerState<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends ConsumerState<ReceiptScreen> {
  bool _printing = false;

  String _formatDate(DateTime dt) =>
      DateFormat("d MMM yyyy hh:mm a").format(dt.toLocal());

  /// Step 6 -- Logout: clear the JWT, staff info, and cart, then return
  /// to the login screen. No logout API call is required.
  void _logout() {
    ref.read(cartProvider.notifier).clear();
    ref.read(authProvider.notifier).logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _printReceipt() async {
    setState(() => _printing = true);
    final r = widget.receipt;
    final first = r.first;
    final printer = ZcsSdkPlugin();

    try {
      await printer.initializeDevice();
      await printer.openDevice();

      final receiptData = {
        "businessName": first.companyName,
        "header":
            "Receipt No(s)\n${r.combinedReceiptNo}\n\nDate\n${_formatDate(first.transTime)}\n\nStaff\n${first.staffName}",
        "items": r.transactions
            .map((t) => {
                  "name": t.menuName,
                  "price": "KES ${t.mealCost}",
                })
            .toList(),
        "totals": {
          "subtotal": "Subtotal: KES ${r.subtotal}",
          "discount": "Discount: KES ${r.totalDiscount}",
          "toPay": "Amount Paid: KES ${r.totalPaid}",
          "method": "Payment Method: ${first.paymentMethodName}",
        },
        "footer": "Thank You",
        "layoutStyle": "detailed",
      };

      await printer.printDynamic(receiptData, bothCopies: false);
      await printer.closeDevice();

      // Step 6: logout happens automatically immediately after the
      // receipt is printed.
      _logout();
      return;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Printing error: $e'),
            backgroundColor: AppTokens.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.receipt;
    final first = r.first;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppTokens.bg,
        appBar: AppBar(
          title: const Text('Receipt'),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(20),
              width: 340,
              decoration: BoxDecoration(
                color: AppTokens.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTokens.cardBorder, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '══════════════════════════',
                    style: TextStyle(
                      color: AppTokens.gold.withValues(alpha: 0.5),
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    first.companyName.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTokens.gold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '══════════════════════════',
                    style: TextStyle(
                      color: AppTokens.gold.withValues(alpha: 0.5),
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _ReceiptRow('Date', _formatDate(first.transTime)),
                  _ReceiptRow('Staff', first.staffName),
                  const Divider(height: 24, color: AppTokens.gold, thickness: 0.5),
                  for (final t in r.transactions) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.menuName,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppTokens.ivory,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          'KSH ${t.mealCost}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTokens.gold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                  const Divider(height: 20, color: AppTokens.gold, thickness: 0.5),
                  _ReceiptRow('Subtotal', 'KSH ${r.subtotal}'),
                  _ReceiptRow('Discount', 'KSH ${r.totalDiscount}', valueColor: AppTokens.success),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppTokens.gold.withValues(alpha: 0.3), width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'AMOUNT PAID',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTokens.gold,
                          ),
                        ),
                        Text(
                          'KSH ${r.totalPaid}',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTokens.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  _ReceiptRow('Payment Method', first.paymentMethodName),
                  const SizedBox(height: 16),
                  Text(
                    'Thank You',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontStyle: FontStyle.italic,
                      color: AppTokens.mutedText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          decoration: BoxDecoration(
            color: AppTokens.surface,
            border: Border(top: BorderSide(color: AppTokens.cardBorder, width: 0.5)),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _printing ? null : _printReceipt,
                      icon: _printing
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTokens.bg),
                            )
                          : const Icon(Icons.receipt_long_rounded),
                      label: const Text('Print Receipt'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _logout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTokens.ivory,
                      side: const BorderSide(color: AppTokens.cardBorder),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _ReceiptRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppTokens.mutedText)),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppTokens.ivory,
            ),
          ),
        ],
      ),
    );
  }
}
