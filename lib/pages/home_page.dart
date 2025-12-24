import 'package:flutter/material.dart';
import '../theme/brand_colors.dart';
import '../services/cafe_service.dart';
import '../models/cafe_model.dart';
import 'menu_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: BrandColors.cream,
      child: SafeArea(
        bottom: false,
        child: StreamBuilder<List<Cafe>>(
          stream: cafeService.cafesStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: BrandColors.caramel),
              );
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No cafes found'));
            }

            final allCafes = snapshot.data!;
            // Sort by rating descending
            final sortedCafes = List<Cafe>.from(allCafes)
              ..sort((a, b) => b.avgRating.compareTo(a.avgRating));

            final popular = sortedCafes.take(5).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Popular Cafes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded,
                            color: BrandColors.caramel,
                            size: 25,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Popular cafés',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: BrandColors.espressoBrown,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,

                    child: ListView.separated(
                      padding: EdgeInsets.zero,

                      scrollDirection: Axis.horizontal,
                      itemCount: popular.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final cafe = popular[index];
                        final cardWidth =
                            MediaQuery.of(context).size.width * 0.37;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MenuPage(cafe: cafe),
                              ),
                            );
                          },
                          child: Container(
                            width: cardWidth,
                            decoration: BoxDecoration(
                              color: BrandColors.latteFoam,
                              border: Border.all(color: BrandColors.caramel),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: BrandColors.steamedMilk.withValues(
                                    alpha: 0.8,
                                  ),
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
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: BrandColors.cream,
                                    image: cafe.imageUrl != null
                                        ? DecorationImage(
                                            image: NetworkImage(cafe.imageUrl!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: cafe.imageUrl == null
                                      ? const Center(
                                          child: Icon(
                                            Icons.local_cafe_rounded,
                                            color: BrandColors.caramel,
                                            size: 32,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  cafe.name,
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
                                      cafe.avgRating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: BrandColors.mediumRoast,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Discover Cafes
                  Row(
                    children: [
                      Icon(
                        Icons.storefront_rounded,
                        color: BrandColors.caramel,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Discover cafés',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: BrandColors.espressoBrown,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Column(
                    children: sortedCafes.map((cafe) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MenuPage(cafe: cafe),
                            ),
                          );
                        },
                        child: Container(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: BrandColors.cream,
                                      image: cafe.imageUrl != null
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                cafe.imageUrl!,
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: cafe.imageUrl == null
                                        ? const Center(
                                            child: Icon(
                                              Icons.local_cafe_rounded,
                                              color: BrandColors.caramel,
                                              size: 32,
                                            ),
                                          )
                                        : null,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cafe.name,
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
                                                cafe.location,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      BrandColors.mediumRoast,
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
                                            cafe.avgRating.toStringAsFixed(1),
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
                                        'From ${cafe.startingPrice} TK',
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
                              if (cafe.tags.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: cafe.tags.map((tag) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: BrandColors.lightFoam,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
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
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
