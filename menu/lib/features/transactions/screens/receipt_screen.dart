import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:zcs_sdk_plugin/zcs_sdk_plugin.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/auth_screen.dart';
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

  /// Step 6 -- Logout: clear JWT, staff info, and selected menu, then
  /// return to the login screen. No logout API call is required.
  void _logout() {
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
          SnackBar(content: Text('Printing error: $e')),
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
        backgroundColor: const Color(0xFFFDFBF7),
        appBar: AppBar(
          title: Text('Receipt', style: GoogleFonts.playfairDisplay()),
          backgroundColor: const Color(0xFF000080),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black26),
              ),
              width: 340,
              child: Column(
                children: [
                  Text(
                    t.companyName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 30),
                  _ReceiptRow('Receipt No', t.receiptNo),
                  _ReceiptRow('Date', _formatDate(t.transTime)),
                  _ReceiptRow('Staff', t.staffName),
                  _ReceiptRow('Meal', t.menuName),
                  _ReceiptRow('Meal Price', 'KES ${t.mealCost}'),
                  _ReceiptRow('Discount', 'KES ${t.discountAmount}'),
                  _ReceiptRow('Amount Paid', 'KES ${t.paidAmount}'),
                  _ReceiptRow('Payment Method', t.paymentMethodName),
                  const Divider(height: 30),
                  Text(
                    'Thank You',
                    style: GoogleFonts.lato(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _printing ? null : _printReceipt,
                  icon: _printing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.print),
                  label: const Text('Print Receipt'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000080),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: _logout,
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReceiptRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.lato(color: Colors.black54)),
          Text(
            value,
            style: GoogleFonts.lato(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
