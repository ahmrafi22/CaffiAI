import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/menu_item_model.dart';
import '../services/cart_service.dart';
import '../theme/brand_colors.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem item;

  const MenuItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BrandColors.latteFoam,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrandColors.steamedMilk),
        boxShadow: [
          BoxShadow(
            color: BrandColors.steamedMilk.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          if (item.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                item.imageUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage();
                },
              ),
            )
          else
            _buildPlaceholderImage(),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Badge and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(item.category),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.subcategory,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      '${item.basePrice.toStringAsFixed(0)} TK',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: BrandColors.deepEspresso,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Name
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: BrandColors.deepEspresso,
                  ),
                ),

                // Description
                if (item.description != null &&
                    item.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.description!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: BrandColors.mediumRoast,
                      height: 1.4,
                    ),
                  ),
                ],

                // Coffee-specific details
                if (item.category == 'coffee') ...[
                  const SizedBox(height: 10),

                  // Strength
                  if (item.strength != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.bolt_rounded,
                          size: 16,
                          color: BrandColors.mocha,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Strength: ${_capitalize(item.strength!)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: BrandColors.mediumRoast,
                          ),
                        ),
                      ],
                    ),

                  // Taste Profile
                  if (item.tasteProfile.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: item.tasteProfile.map((taste) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: BrandColors.lightFoam,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: BrandColors.steamedMilk,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            taste,
                            style: const TextStyle(
                              fontSize: 11,
                              color: BrandColors.mediumRoast,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],

                // Add to Cart Button
                const SizedBox(height: 14),
                Consumer<CartService>(
                  builder: (context, cartService, child) {
                    final isInCart = cartService.isInCart(item.id);
                    final quantity = cartService.getItemQuantity(item.id);

                    if (isInCart && quantity > 0) {
                      // Show quantity controls
                      return Container(
                        decoration: BoxDecoration(
                          color: BrandColors.lightFoam,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: BrandColors.caramel,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                cartService.decreaseQuantity(item.id);
                              },
                              icon: const Icon(Icons.remove_rounded),
                              color: BrandColors.caramel,
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                            ),
                            Text(
                              '$quantity',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: BrandColors.deepEspresso,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                cartService.increaseQuantity(item.id);
                              },
                              icon: const Icon(Icons.add_rounded),
                              color: BrandColors.caramel,
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      );
                    }

                    // Show Add to Cart button
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          cartService.addToCart(item);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${item.name} added to cart'),
                              backgroundColor: BrandColors.mintGreen,
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.add_shopping_cart_rounded,
                          size: 20,
                        ),
                        label: const Text(
                          'Add to Cart',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BrandColors.caramel,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: BrandColors.lightFoam,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: const Center(
        child: Icon(
          Icons.local_cafe_rounded,
          size: 64,
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

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
