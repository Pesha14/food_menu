import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/providers/auth_provider.dart';
import '../../transactions/models/payment_method.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/screens/receipt_screen.dart';
import '../models/menu_models.dart';
import '../providers/menu_provider.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider);
    final menusAsync = ref.watch(availableMenusProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        title: Text(
          'Welcome, ${session?.staff.fullName ?? ''}',
          style: GoogleFonts.playfairDisplay(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF000080),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Company:', style: GoogleFonts.lato(fontSize: 16)),
                Text(
                  session?.staff.company.name ?? '',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF000080),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: menusAsync.when(
              data: (menus) {
                if (menus.isEmpty) {
                  return const Center(
                    child: Text('No menus available right now.'),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: menus.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = menus[index];
                    return ListTile(
                      title: Text(
                        item.menuName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(item.category.name),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('KSH ${item.pricing.price}'),
                          if (item.pricing.discountable)
                            const Text(
                              'Discount Available',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                              ),
                            )
                          else
                            const Text(
                              'No Discount',
                              style: TextStyle(
                                color: Colors.black45,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      onTap: () => _confirmAndBuy(context, ref, item),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Failed to load menus: $err'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Steps 3 & 4 -- staff taps a meal, confirms, and the transaction is
  /// created immediately. One meal per transaction; the backend computes
  /// discount and amount payable.
  Future<void> _confirmAndBuy(
    BuildContext context,
    WidgetRef ref,
    MenuItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Purchase'),
        content: Text('Buy "${item.menuName}" for KSH ${item.pricing.price}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    ref.read(selectedMenuItemProvider.notifier).state = item;
    final session = ref.read(authProvider);
    if (session == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final transactionService = ref.read(transactionServiceProvider);
      final transaction = await transactionService.createTransaction(
        token: session.token,
        menuId: item.menuId,
        paymentMethod: PaymentMethod.cash,
      );

      if (!context.mounted) return;
      Navigator.pop(context); // close loading dialog

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptScreen(transaction: transaction),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaction failed: $e')),
      );
    }
  }
}
