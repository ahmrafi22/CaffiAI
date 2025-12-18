import 'package:flutter/material.dart';
import '../theme/brand_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final popularCafes = [
      {'name': 'BrewLab', 'rating': 4.8, 'reviews': 324},
      {'name': 'Roast House', 'rating': 4.6, 'reviews': 189},
      {'name': 'Midnight Bean', 'rating': 4.9, 'reviews': 512},
      {'name': 'Latte Lane', 'rating': 4.7, 'reviews': 276},
    ];

    final discoverCafes = [
      {
        'name': 'Caffe Dhaka Central',
        'location': 'Banani • Dhaka',
        'tags': ['Specialty brew', 'Pour over', 'Desserts'],
        'from': 180,
        'rating': 4.7,
      },
      {
        'name': 'Riverfront Roastery',
        'location': 'Gulshan • Dhaka',
        'tags': ['Single origin', 'Cold brew', 'Bakery'],
        'from': 220,
        'rating': 4.9,
      },
      {
        'name': 'Old Town Espresso',
        'location': 'Old Dhaka',
        'tags': ['Espresso bar', 'Filter', 'Local snacks'],
        'from': 140,
        'rating': 4.5,
      },
      {
        'name': 'Gallery Café',
        'location': 'Dhanmondi • Dhaka',
        'tags': ['Art café', 'Brunch', 'Signature latte'],
        'from': 200,
        'rating': 4.6,
      },
    ];

    return Container(
      color: BrandColors.cream,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Welcome to',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: BrandColors.mediumRoast,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'caffeai',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: BrandColors.espressoBrown,
                  fontFamily: 'MochiyPopPOne',
                  fontSize: 32,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Find the perfect café for your next brew, work session, or meetup.',
                style: TextStyle(color: BrandColors.mediumRoast, height: 1.4),
              ),
              const SizedBox(height: 24),

              // Popular Cafes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Popular cafés',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: BrandColors.espressoBrown,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: BrandColors.caramel,
                    ),
                    child: const Text('See all'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 132,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: popularCafes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final cafe = popularCafes[index];
                    final rating = cafe['rating'] as double;
                    final reviews = cafe['reviews'] as int;
                    return Container(
                      width: 110,
                      decoration: BoxDecoration(
                        color: BrandColors.latteFoam,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: BrandColors.steamedMilk.withOpacity(0.8),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: BrandColors.cream,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.local_cafe_rounded,
                                color: BrandColors.caramel,
                                size: 26,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            cafe['name'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: BrandColors.deepEspresso,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: BrandColors.caramel,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: BrandColors.mediumRoast,
                                ),
                              ),
                              Text(
                                ' ($reviews)',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: BrandColors.mediumRoast,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),

              // Discover Cafes
              const Text(
                'Discover cafés',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: BrandColors.espressoBrown,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Explore new spots by vibe, location, and budget.',
                style: TextStyle(color: BrandColors.mediumRoast, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Column(
                children: discoverCafes.map((cafe) {
                  final tags = cafe['tags'] as List<String>;
                  final fromPrice = cafe['from'] as int;
                  final rating = cafe['rating'] as double;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: BrandColors.latteFoam,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: BrandColors.steamedMilk),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cafe['name'] as String,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: BrandColors.deepEspresso,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_rounded,
                                        size: 16,
                                        color: BrandColors.mocha,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          cafe['location'] as String,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: BrandColors.mediumRoast,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: BrandColors.caramel,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: BrandColors.mediumRoast,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'From $fromPrice TK',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: BrandColors.deepEspresso,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: BrandColors.lightFoam,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: BrandColors.mediumRoast,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
