import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:zcs_sdk_plugin/zcs_sdk_plugin.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/auth_screen.dart';
import '../../menu/providers/menu_provider.dart';
import '../../theme/app_tokens.dart';
import '../models/transaction.dart';

class ReceiptScreen extends ConsumerStatefulWidget {
  final Transaction transaction;

  const ReceiptScreen({super.key, required this.transaction});

  @override
  ConsumerState<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends ConsumerState<ReceiptScreen> {
  bool _printing = false;

  String _formatDate(DateTime dt) =>
      DateFormat("d MMM yyyy hh:mm a").format(dt.toLocal());

  /// Step 6 -- Logout: clear the JWT, staff info, and selected menu, then
  /// return to the login screen. No logout API call is required.
  void _logout() {
    ref.read(selectedMenuItemProvider.notifier).state = null;
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
    final t = widget.transaction;
    final printer = ZcsSdkPlugin();

    try {
      await printer.initializeDevice();
      await printer.openDevice();

      final receiptData = {
        "businessName": t.companyName,
        "header":
            "Receipt No\n${t.receiptNo}\n\nDate\n${_formatDate(t.transTime)}\n\nStaff\n${t.staffName}",
        "items": [
          {
            "name": "Meal\n${t.menuName}",
            "price": "Meal Price\nKES ${t.mealCost}",
          },
        ],
        "totals": {
          "discount": "Discount: KES ${t.discountAmount}",
          "toPay": "Amount Paid: KES ${t.paidAmount}",
          "method": "Payment Method: ${t.paymentMethodName}",
        },
        "footer": "Thank You",
        "layoutStyle": "detailed",
      };

      await printer.printDynamic(receiptData, bothCopies: false);
      await printer.closeDevice();

      // Step 6: logout happens automatically immediately after the
      // receipt is printed, per the guide.
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
    final t = widget.transaction;

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
                    t.companyName.toUpperCase(),
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
                  _ReceiptRow('Receipt No', t.receiptNo),
                  _ReceiptRow('Date', _formatDate(t.transTime)),
                  _ReceiptRow('Staff', t.staffName),
                  const Divider(height: 24, color: AppTokens.gold, thickness: 0.5),
                  _ReceiptRow('Meal', t.menuName),
                  _ReceiptRow('Meal Price', 'KSH ${t.mealCost}'),
                  _ReceiptRow('Discount', 'KSH ${t.discountAmount}', valueColor: AppTokens.success),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: AppTokens.gold.withValues(alpha: 0.3),
                          width: 1,
                        ),
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
                          'KSH ${t.paidAmount}',
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
                  _ReceiptRow('Payment Method', t.paymentMethodName),
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
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTokens.bg,
                              ),
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
