import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';
import '../theme/brand_colors.dart';
import '../widgets/review_card.dart';

class ReviewsTab extends StatelessWidget {
  final String cafeId;

  const ReviewsTab({super.key, required this.cafeId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Review>>(
      stream: reviewService.getCafeReviews(cafeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: BrandColors.caramel),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 60,
                  color: BrandColors.warmRed,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading reviews',
                  style: TextStyle(
                    fontSize: 16,
                    color: BrandColors.mediumRoast.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          );
        }

        final reviews = snapshot.data ?? [];

        if (reviews.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  size: 80,
                  color: BrandColors.steamedMilk.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 24),
                const Text(
                  'No reviews yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: BrandColors.mediumRoast,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Be the first to review this cafe!',
                  style: TextStyle(
                    fontSize: 14,
                    color: BrandColors.mediumRoast,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Review Stats Header
            Container(
              padding: const EdgeInsets.all(16),
              color: BrandColors.lightFoam,
              child: FutureBuilder<Map<String, dynamic>>(
                future: reviewService.getCafeReviewStats(cafeId),
                builder: (context, statsSnapshot) {
                  if (!statsSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final stats = statsSnapshot.data!;
                  final avgRating = stats['averageRating'] as double;
                  final totalReviews = stats['totalReviews'] as int;
                  final distribution =
                      stats['ratingDistribution'] as Map<int, int>;

                  return Column(
                    children: [
                      Row(
                        children: [
                          // Average Rating
                          Column(
                            children: [
                              Text(
                                avgRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w700,
                                  color: BrandColors.deepEspresso,
                                ),
                              ),
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < avgRating.floor()
                                        ? Icons.star_rounded
                                        : (index < avgRating
                                              ? Icons.star_half_rounded
                                              : Icons.star_border_rounded),
                                    color: BrandColors.caramel,
                                    size: 20,
                                  );
                                }),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$totalReviews reviews',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: BrandColors.mediumRoast,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 24),
                          // Rating Distribution
                          Expanded(
                            child: Column(
                              children: List.generate(5, (index) {
                                final star = 5 - index;
                                final count = distribution[star] ?? 0;
                                final percentage = totalReviews > 0
                                    ? (count / totalReviews)
                                    : 0.0;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Text(
                                        '$star',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: BrandColors.mediumRoast,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.star_rounded,
                                        size: 12,
                                        color: BrandColors.caramel,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          child: LinearProgressIndicator(
                                            value: percentage,
                                            backgroundColor:
                                                BrandColors.steamedMilk,
                                            valueColor:
                                                const AlwaysStoppedAnimation(
                                                  BrandColors.caramel,
                                                ),
                                            minHeight: 6,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 30,
                                        child: Text(
                                          '$count',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: BrandColors.mediumRoast,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            // Reviews List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  return ReviewCard(review: reviews[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
