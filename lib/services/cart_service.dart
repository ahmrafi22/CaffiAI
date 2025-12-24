import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';
import '../models/menu_item_model.dart';

class CartService extends ChangeNotifier {
  static const String _cartKey = 'cart_items';
  List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  CartService() {
    _loadCart();
  }

  // Load cart from local storage
  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);

      if (cartJson != null) {
        final List<dynamic> decoded = jsonDecode(cartJson);
        _cartItems = decoded.map((item) => CartItem.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  // Save cart to local storage
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(
        _cartItems.map((item) => item.toJson()).toList(),
      );
      await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  // Add item to cart or increase quantity if already exists
  Future<void> addToCart(MenuItem menuItem) async {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.menuItem.id == menuItem.id,
    );

    if (existingIndex != -1) {
      _cartItems[existingIndex].quantity++;
    } else {
      _cartItems.add(CartItem(menuItem: menuItem));
    }

    await _saveCart();
    notifyListeners();
  }

  // Remove item from cart
  Future<void> removeFromCart(String menuItemId) async {
    _cartItems.removeWhere((item) => item.menuItem.id == menuItemId);
    await _saveCart();
    notifyListeners();
  }

  // Increase quantity
  Future<void> increaseQuantity(String menuItemId) async {
    final index = _cartItems.indexWhere(
      (item) => item.menuItem.id == menuItemId,
    );
    if (index != -1) {
      _cartItems[index].quantity++;
      await _saveCart();
      notifyListeners();
    }
  }

  // Decrease quantity
  Future<void> decreaseQuantity(String menuItemId) async {
    final index = _cartItems.indexWhere(
      (item) => item.menuItem.id == menuItemId,
    );
    if (index != -1) {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
      } else {
        _cartItems.removeAt(index);
      }
      await _saveCart();
      notifyListeners();
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    _cartItems.clear();
    await _saveCart();
    notifyListeners();
  }

  // Get quantity of specific item in cart
  int getItemQuantity(String menuItemId) {
    final item = _cartItems.firstWhere(
      (item) => item.menuItem.id == menuItemId,
      orElse: () => CartItem(
        menuItem: MenuItem(
          id: '',
          cafeId: '',
          category: '',
          subcategory: '',
          name: '',
          basePrice: 0,
        ),
        quantity: 0,
      ),
    );
    return item.quantity;
  }

  // Check if item is in cart
  bool isInCart(String menuItemId) {
    return _cartItems.any((item) => item.menuItem.id == menuItemId);
  }
}
