import 'menu_item_model.dart';

class CartItem {
  final MenuItem menuItem;
  int quantity;

  CartItem({required this.menuItem, this.quantity = 1});

  double get totalPrice => menuItem.basePrice * quantity;

  Map<String, dynamic> toJson() {
    return {
      'menuItemId': menuItem.id,
      'cafeId': menuItem.cafeId,
      'quantity': quantity,
      'name': menuItem.name,
      'basePrice': menuItem.basePrice,
      'imageUrl': menuItem.imageUrl,
      'category': menuItem.category,
      'subcategory': menuItem.subcategory,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Simplified MenuItem for cart purposes
    final menuItem = MenuItem(
      id: json['menuItemId'] ?? '',
      cafeId: json['cafeId'] ?? '',
      category: json['category'] ?? '',
      subcategory: json['subcategory'] ?? '',
      name: json['name'] ?? '',
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'],
    );

    return CartItem(menuItem: menuItem, quantity: json['quantity'] ?? 1);
  }
}
