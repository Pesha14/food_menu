import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/menu_models.dart';
import '../providers/cart_provider.dart';

class MenuScreen extends ConsumerWidget {
  final String staffName;
  MenuScreen({required this.staffName});

  final List<MenuItem> items = [
    MenuItem(id: '1', name: 'Roasted Chicken', price: 15.0, categoryId: '1'),
    MenuItem(id: '2', name: 'Beef Stew', price: 12.0, categoryId: '1'),
    MenuItem(id: '3', name: 'Coffee', price: 2.0, categoryId: '2'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);
    
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7), // Softer Cream
      appBar: AppBar(
        title: Text('Welcome, $staffName', style: GoogleFonts.playfairDisplay(color: Colors.white)),
        backgroundColor: const Color(0xFF000080),
        foregroundColor: Colors.white,
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
                Text('\KSH ${notifier.balance.toStringAsFixed(2)}', style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF000080))),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(10),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('KSH ${item.price.toStringAsFixed(2)}'),
                  trailing: ElevatedButton(
                    onPressed: () => notifier.addItem(item),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF000080), foregroundColor: Colors.white),
                    child: const Text('Add'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFC0A060), // Classic Gold accent
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CartScreen())),
        label: const Text('View Cart'),
        icon: const Icon(Icons.shopping_cart),
      ),
    );
  }
}

class CartScreen extends ConsumerWidget {
  Future<void> _generateReceipt(List<CartItem> cart, String staffName) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Menu System Receipt', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('Staff: $staffName'),
            pw.Text('Date: ${DateTime.now().toString()}'),
            pw.Divider(),
            pw.SizedBox(height: 10),
            ...cart.map((c) => pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('${c.item.name} x${c.quantity}'),
                pw.Text('KSH ${(c.item.price * c.quantity).toStringAsFixed(2)}'),
              ],
            )),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('KSH ${cart.fold(0.0, (sum, c) => sum + (c.item.price * c.quantity)).toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);
    
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        title: const Text('Cart', style: TextStyle(fontFamily: 'PlayfairDisplay')),
        backgroundColor: const Color(0xFF000080),
        foregroundColor: Colors.white,
      ),
      body: cart.isEmpty 
          ? Center(child: Text('Your cart is empty', style: GoogleFonts.lato(fontSize: 18)))
          : ListView.separated(
              padding: const EdgeInsets.all(10),
              itemCount: cart.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final cartItem = cart[index];
                return ListTile(
                  title: Text(cartItem.item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Qty: ${cartItem.quantity}'),
                  trailing: Text('KSH ${(cartItem.item.price * cartItem.quantity).toStringAsFixed(2)}'),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('KSH ${notifier.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF000080))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300], foregroundColor: Colors.black),
                    child: const Text('Edit Choices'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _generateReceipt(cart, 'test21'), // Passing staffName
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF000080), foregroundColor: Colors.white),
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
