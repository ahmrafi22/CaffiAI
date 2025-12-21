import 'package:flutter/material.dart';
import '../models/menu_item_model.dart';
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
            color: BrandColors.steamedMilk.withOpacity(0.3),
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
