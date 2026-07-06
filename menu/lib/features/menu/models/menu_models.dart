class MenuItem {
  final String id;
  final String name;
  final double price;
  final String categoryId;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.categoryId,
  });
}

class CartItem {
  final MenuItem item;
  int quantity;

  CartItem({required this.item, this.quantity = 1});
}
