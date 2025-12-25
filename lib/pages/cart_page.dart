import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../services/firebase_service.dart';
import '../theme/brand_colors.dart';
import 'auth_page.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.cream,
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: BrandColors.espressoBrown,
          ),
        ),
        backgroundColor: BrandColors.cream,
        elevation: 0,
        iconTheme: const IconThemeData(color: BrandColors.espressoBrown),
        actions: [
          Consumer<CartService>(
            builder: (context, cartService, child) {
              if (cartService.cartItems.isEmpty) return const SizedBox.shrink();

              return TextButton(
                onPressed: () {
                  _showClearCartDialog(context, cartService);
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(
                    color: BrandColors.warmRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartService>(
        builder: (context, cartService, child) {
          if (cartService.cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 120,
                    color: BrandColors.steamedMilk.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: BrandColors.mediumRoast,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Add items to get started',
                    style: TextStyle(
                      fontSize: 15,
                      color: BrandColors.mediumRoast,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.explore_rounded),
                    label: const Text('Explore Menu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BrandColors.caramel,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Cart Items List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartService.cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartService.cartItems[index];
                    final menuItem = cartItem.menuItem;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: BrandColors.latteFoam,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: BrandColors.steamedMilk),
                        boxShadow: [
                          BoxShadow(
                            color: BrandColors.steamedMilk.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Item Image
                          ClipRRect(
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(16),
                            ),
                            child: menuItem.imageUrl != null
                                ? Image.network(
                                    menuItem.imageUrl!,
                                    width: 100,
                                    height: 110,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildPlaceholderImage();
                                    },
                                  )
                                : _buildPlaceholderImage(),
                          ),

                          // Item Details
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    menuItem.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: BrandColors.deepEspresso,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getCategoryColor(
                                        menuItem.category,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      menuItem.subcategory,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${menuItem.basePrice.toStringAsFixed(0)} TK',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: BrandColors.caramel,
                                        ),
                                      ),
                                      // Quantity Controls
                                      Container(
                                        decoration: BoxDecoration(
                                          color: BrandColors.lightFoam,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: BrandColors.caramel,
                                            width: 1.2,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                cartService.decreaseQuantity(
                                                  menuItem.id,
                                                );
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: const Padding(
                                                padding: EdgeInsets.all(6),
                                                child: Icon(
                                                  Icons.remove_rounded,
                                                  size: 18,
                                                  color: BrandColors.caramel,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                  ),
                                              child: Text(
                                                '${cartItem.quantity}',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      BrandColors.deepEspresso,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                cartService.increaseQuantity(
                                                  menuItem.id,
                                                );
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: const Padding(
                                                padding: EdgeInsets.all(6),
                                                child: Icon(
                                                  Icons.add_rounded,
                                                  size: 18,
                                                  color: BrandColors.caramel,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Delete Button
                          IconButton(
                            onPressed: () {
                              cartService.removeFromCart(menuItem.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${menuItem.name} removed from cart',
                                  ),
                                  backgroundColor: BrandColors.warmRed,
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.delete_outline_rounded),
                            color: BrandColors.warmRed,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Summary & Checkout
              Container(
                decoration: BoxDecoration(
                  color: BrandColors.latteFoam,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Summary
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Items:',
                            style: TextStyle(
                              fontSize: 15,
                              color: BrandColors.mediumRoast,
                            ),
                          ),
                          Text(
                            '${cartService.itemCount}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: BrandColors.deepEspresso,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: BrandColors.deepEspresso,
                            ),
                          ),
                          Text(
                            '${cartService.totalPrice.toStringAsFixed(0)} TK',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: BrandColors.caramel,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Checkout Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _showCheckoutDialog(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BrandColors.caramel,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Proceed to Checkout',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 100,
      height: 110,
      color: BrandColors.lightFoam,
      child: const Center(
        child: Icon(
          Icons.local_cafe_rounded,
          size: 40,
          color: BrandColors.steamedMilk,
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'coffee':
        return BrandColors.espressoBrown;
      case 'drink':
        return BrandColors.caramel;
      case 'food':
        return BrandColors.mocha;
      case 'dessert':
        return BrandColors.mediumRoast;
      default:
        return BrandColors.deepEspresso;
    }
  }

  void _showClearCartDialog(BuildContext context, CartService cartService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BrandColors.latteFoam,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Clear Cart?',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: BrandColors.deepEspresso,
          ),
        ),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
          style: TextStyle(color: BrandColors.mediumRoast),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: BrandColors.mediumRoast),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              cartService.clearCart();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Cart cleared'),
                  backgroundColor: BrandColors.warmRed,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BrandColors.warmRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context) async {
    // Check if user is logged in
    if (firebase.currentUser == null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AuthPage()),
      );

      // If user didn't log in, return
      if (result == null && firebase.currentUser == null) {
        return;
      }
    }

    final cartService = context.read<CartService>();

    if (cartService.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Your cart is empty'),
          backgroundColor: BrandColors.warmRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    // Get cafe info from the first cart item
    final cafeId = cartService.cartItems.first.menuItem.cafeId;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: BrandColors.caramel),
      ),
    );

    try {
      // Fetch cafe details
      final cafeDoc = await firebase.cafesCollection.doc(cafeId).get();

      if (!context.mounted) return;
      Navigator.pop(context); // Remove loading indicator

      if (!cafeDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cafe information not found'),
            backgroundColor: BrandColors.warmRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }

      final cafeData = cafeDoc.data()!;
      final cafeName = cafeData['name'] ?? 'Unknown Cafe';
      final ownerAdminId = cafeData['ownerAdminId'] ?? '';

      // Navigate to checkout page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutPage(
            cafeId: cafeId,
            cafeName: cafeName,
            ownerAdminId: ownerAdminId,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Remove loading indicator

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: BrandColors.warmRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}
