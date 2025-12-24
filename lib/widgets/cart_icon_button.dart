import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../pages/cart_page.dart';
import '../theme/brand_colors.dart';

class CartIconButton extends StatelessWidget {
  final Color iconColor;
  final Color badgeColor;

  const CartIconButton({
    super.key,
    this.iconColor = Colors.white,
    this.badgeColor = BrandColors.warmRed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartService>(
      builder: (context, cartService, child) {
        final itemCount = cartService.itemCount;

        return Stack(
          children: [
            IconButton(
              icon: Icon(Icons.shopping_cart_rounded, color: iconColor),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                );
              },
            ),
            if (itemCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      itemCount > 99 ? '99+' : '$itemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
