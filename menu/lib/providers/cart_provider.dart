import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/menu_models.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);
  
  double balance = 3000.0; // Simulation balance

  double get total => state.fold(0, (sum, item) => sum + (item.item.price * item.quantity));

  void addItem(MenuItem item) {
    // ... (rest of the addItem logic)
    final index = state.indexWhere((cartItem) => cartItem.item.id == item.id);
    if (index != -1) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index)
            CartItem(item: state[i].item, quantity: state[i].quantity + 1)
          else
            state[i]
      ];
    } else {
      state = [...state, CartItem(item: item)];
    }
  }

  void removeItem(String itemId) {
    state = state.where((cartItem) => cartItem.item.id != itemId).toList();
  }

  void clear() {
    state = [];
    balance = 100.0; // Reset balance
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});
