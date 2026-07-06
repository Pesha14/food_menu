import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zcs_sdk_plugin/zcs_sdk_plugin.dart';
import '../models/menu_models.dart';
import '../providers/cart_provider.dart';

class MenuScreen extends ConsumerWidget {
  final String staffName;
  MenuScreen({super.key, required this.staffName});

  final List<MenuItem> items = [
    MenuItem(id: '1', name: 'Roasted Chicken', price: 1500.0, categoryId: '1'),
    MenuItem(id: '2', name: 'Beef Stew', price: 1200.0, categoryId: '1'),
    MenuItem(id: '3', name: 'Coffee', price: 200.0, categoryId: '2'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cartProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        title: Text(
          'Welcome, $staffName',
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
                Text('Balance:', style: GoogleFonts.lato(fontSize: 16)),
                Text(
                  'KSH ${notifier.balance.toStringAsFixed(2)}',
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF000080),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: DataTable(
              columnSpacing: 10,
              columns: const [
                DataColumn(
                  label: Text(
                    'Item',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Price',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(label: Text('Action')),
              ],
              rows: items
                  .map(
                    (item) => DataRow(
                      cells: [
                        DataCell(Text(item.name)),
                        DataCell(Text('KSH ${item.price.toStringAsFixed(2)}')),
                        DataCell(
                          ElevatedButton(
                            onPressed: () {
                              notifier.addItem(item);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${item.name} added to cart'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: const Text('Add'),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFC0A060),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CartScreen(staffName: staffName)),
        ),
        label: const Text('View Cart'),
        icon: const Icon(Icons.shopping_cart),
      ),
    );
  }
}

class CartScreen extends ConsumerWidget {
  final String staffName;
  const CartScreen({super.key, required this.staffName});

  Future<void> _printReceipt(List<CartItem> cart) async {
    final ZcsSdkPlugin printer = ZcsSdkPlugin();

    final double total = cart.fold(
      0.0,
      (sum, c) => sum + (c.item.price * c.quantity),
    );
    final double companyCover = 3000.0;
    final double discount = total > companyCover ? companyCover : total;
    final double toBePaid = total - discount;

    try {
      await printer.initializeDevice();
      await printer.openDevice();

      final Map<String, dynamic> receiptData = {
        "businessName": "MENU SYSTEM",
        "header":
            "STAFF: $staffName\nDATE: ${DateTime.now().toString().substring(0, 16)}",
        "items": cart
            .map(
              (c) => {
                "name": "${c.item.name} (Qty: ${c.quantity})",
                "price":
                    "KSH ${(c.item.price * c.quantity).toStringAsFixed(2)}",
              },
            )
            .toList(),
        "totals": {
          "total": "Total: KSH ${total.toStringAsFixed(2)}",
          "discount": "Company Discount: KSH ${discount.toStringAsFixed(2)}",
          "toPay": "To Be Paid: KSH ${toBePaid.toStringAsFixed(2)}",
        },
        "footer": "Thank you for your service!",
        "layoutStyle": "detailed",
      };

      await printer.printDynamic(receiptData, bothCopies: false);
      await printer.closeDevice();
    } catch (e) {
      debugPrint("Printing error: $e");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: const Color(0xFF000080),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(10),
        itemCount: cart.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final cartItem = cart[index];
          return ListTile(
            title: Text(
              cartItem.item.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Quantity: ${cartItem.quantity}'),
            trailing: Text(
              'KSH ${(cartItem.item.price * cartItem.quantity).toStringAsFixed(2)}',
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Grand Total: KSH ${notifier.total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Edit Choices'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000080),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _printReceipt(cart),
                    child: const Text('Print Receipt'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
