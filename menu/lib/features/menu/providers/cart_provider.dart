import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/menu_models.dart';

class CartItem {
  final MenuItem item;
  final int quantity;

  CartItem({required this.item, this.quantity = 1});

  CartItem copyWith({int? quantity}) =>
      CartItem(item: item, quantity: quantity ?? this.quantity);

  /// Display-only subtotal for this line -- just multiplying the menu's
  /// own listed price by quantity, not computing any discount.
  num get lineTotal => item.pricing.price * quantity;
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(MenuItem item) {
    final index = state.indexWhere((c) => c.item.menuId == item.menuId);
    if (index >= 0) {
      final updated = [...state];
      updated[index] = updated[index].copyWith(
        quantity: updated[index].quantity + 1,
      );
      state = updated;
    } else {
      state = [...state, CartItem(item: item)];
    }
  }

  void incrementItem(int index) {
    final updated = [...state];
    updated[index] = updated[index].copyWith(
      quantity: updated[index].quantity + 1,
    );
    state = updated;
  }

  void decrementItem(int index) {
    final current = state[index];
    if (current.quantity <= 1) {
      removeItem(index);
      return;
    }
    final updated = [...state];
    updated[index] = current.copyWith(quantity: current.quantity - 1);
    state = updated;
  }

  void removeItem(int index) {
    final updated = [...state]..removeAt(index);
    state = updated;
  }

  void clear() {
    state = [];
  }

  /// Sum of listed menu prices -- shown to staff as an estimate before
  /// checkout. The real discount and amount payable only exist once the
  /// backend has processed each item's transaction at checkout.
  num get subtotal => state.fold(0, (sum, c) => sum + c.lineTotal);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);
