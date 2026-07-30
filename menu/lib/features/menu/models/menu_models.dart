class MenuCategory {
  final int id;
  final String name;

  MenuCategory({required this.id, required this.name});

  factory MenuCategory.fromJson(Map<String, dynamic> json) => MenuCategory(
        id: json['cat_id'] as int,
        name: json['cat_name'] as String,
      );
}

class MenuPricing {
  final num price;
  final bool discountable;
  final num discountAmount;

  MenuPricing({
    required this.price,
    required this.discountable,
    required this.discountAmount,
  });

  factory MenuPricing.fromJson(Map<String, dynamic> json) => MenuPricing(
        price: json['menu_price'] as num,
        discountable: json['discountable'] as bool? ?? false,
        discountAmount: json['discount_amt'] as num? ?? 0,
      );
}

class MenuItem {
  final int menuId;
  final String menuName;
  final int companyId;
  final String companyName;
  final MenuCategory category;
  final MenuPricing pricing;

  MenuItem({
    required this.menuId,
    required this.menuName,
    required this.companyId,
    required this.companyName,
    required this.category,
    required this.pricing,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    final company = json['company'] as Map<String, dynamic>;
    return MenuItem(
      menuId: json['menu_id'] as int,
      menuName: json['menu_name'] as String,
      companyId: company['company_id'] as int,
      companyName: company['company_name'] as String,
      category: MenuCategory.fromJson(json['category'] as Map<String, dynamic>),
      pricing: MenuPricing.fromJson(json['pricing'] as Map<String, dynamic>),
    );
  }
}
