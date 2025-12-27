import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ai_chat_message_model.dart';
import '../services/cart_service.dart';
import '../theme/brand_colors.dart';

/// A beautiful coffee recommendation card for the chat interface
class ChatCoffeeCard extends StatelessWidget {
  final CoffeeRecommendation recommendation;

  const ChatCoffeeCard({super.key, required this.recommendation});

  @override
  Widget build(BuildContext context) {
    final item = recommendation.item;
    final cafe = recommendation.cafe;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: BrandColors.espressoBrown.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with overlay gradient
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? Image.network(
                        item.imageUrl!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage();
                        },
                      )
                    : _buildPlaceholderImage(),
              ),
              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Match score badge
              if (recommendation.matchScore > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _getMatchColor(recommendation.matchScore),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.favorite,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recommendation.matchScore * 10}% match',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Price badge
              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: BrandColors.caramel,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${item.basePrice.toStringAsFixed(0)} TK',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Content section
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and category row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: BrandColors.deepEspresso,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Category badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: BrandColors.mocha.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _capitalize(item.subcategory),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: BrandColors.mocha,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Add to cart button
                    _buildAddButton(context),
                  ],
                ),

                // Cafe info
                if (cafe != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: BrandColors.latteFoam,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.storefront_rounded,
                          size: 16,
                          color: BrandColors.espressoBrown,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cafe.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: BrandColors.espressoBrown,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (cafe.address.isNotEmpty)
                              Text(
                                '${cafe.address}, ${cafe.city}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: BrandColors.mediumRoast.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],

                // Coffee details (strength & taste)
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Strength
                    if (item.strength != null)
                      _buildDetailChip(
                        icon: Icons.bolt_rounded,
                        label: _capitalize(item.strength!),
                        color: _getStrengthColor(item.strength!),
                      ),
                    // Taste profiles
                    ...item.tasteProfile
                        .take(3)
                        .map(
                          (taste) => _buildDetailChip(
                            icon: Icons.local_cafe_rounded,
                            label: _capitalize(taste),
                            color: BrandColors.caramel,
                          ),
                        ),
                    // Best time
                    if (item.bestTime.isNotEmpty)
                      _buildDetailChip(
                        icon: Icons.schedule_rounded,
                        label: _capitalize(item.bestTime.first),
                        color: BrandColors.mintGreen,
                      ),
                  ],
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
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [BrandColors.latteFoam, BrandColors.steamedMilk],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.coffee_rounded,
            size: 48,
            color: BrandColors.mocha.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 4),
          Text(
            'No image',
            style: TextStyle(
              fontSize: 12,
              color: BrandColors.mediumRoast.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Material(
      color: BrandColors.mocha,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          final cartService = context.read<CartService>();
          cartService.addToCart(recommendation.item);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${recommendation.item.name} added to cart'),
              backgroundColor: BrandColors.mocha,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: const Icon(
            Icons.add_shopping_cart_rounded,
            size: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMatchColor(int score) {
    if (score >= 7) return BrandColors.mintGreen;
    if (score >= 4) return BrandColors.caramel;
    return BrandColors.mocha;
  }

  Color _getStrengthColor(String strength) {
    switch (strength.toLowerCase()) {
      case 'strong':
        return BrandColors.espressoBrown;
      case 'medium':
        return BrandColors.mocha;
      case 'light':
        return BrandColors.caramel;
      default:
        return BrandColors.mediumRoast;
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

/// A horizontal scrollable list of coffee recommendation cards
class ChatCoffeeCardList extends StatelessWidget {
  final List<CoffeeRecommendation> recommendations;

  const ChatCoffeeCardList({super.key, required this.recommendations});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [BrandColors.mocha, BrandColors.caramel],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.recommend_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Recommended for you',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: BrandColors.deepEspresso,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: BrandColors.caramel.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${recommendations.length} items',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: BrandColors.caramel,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Scrollable cards
        SizedBox(
          height: 400,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < recommendations.length - 1 ? 12 : 0,
                ),
                child: SizedBox(
                  width: 260,
                  child: ChatCoffeeCard(recommendation: recommendations[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
