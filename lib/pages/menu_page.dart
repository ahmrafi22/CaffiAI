import 'package:flutter/material.dart';
import '../models/cafe_model.dart';
import '../models/menu_item_model.dart';
import '../services/menu_service.dart';
import '../theme/brand_colors.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/category_filter_chip.dart';

class MenuPage extends StatefulWidget {
  final Cafe cafe;

  const MenuPage({super.key, required this.cafe});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String? _selectedCategory;

  final List<String> _categories = ['coffee', 'drink', 'food', 'dessert'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.cream,
      body: CustomScrollView(
        slivers: [
          // App Bar with Cafe Image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: BrandColors.espressoBrown,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.cafe.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              background: widget.cafe.imageUrl != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(widget.cafe.imageUrl!, fit: BoxFit.cover),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      color: BrandColors.espressoBrown,
                      child: const Center(
                        child: Icon(
                          Icons.local_cafe_rounded,
                          size: 80,
                          color: BrandColors.cream,
                        ),
                      ),
                    ),
            ),
          ),

          // Cafe Details
          SliverToBoxAdapter(
            child: Container(
              color: BrandColors.latteFoam,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 18,
                        color: BrandColors.mocha,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.cafe.location,
                          style: const TextStyle(
                            fontSize: 14,
                            color: BrandColors.mediumRoast,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: BrandColors.caramel,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.cafe.avgRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: BrandColors.deepEspresso,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'From ${widget.cafe.startingPrice} TK',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: BrandColors.deepEspresso,
                        ),
                      ),
                    ],
                  ),
                  if (widget.cafe.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.cafe.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: BrandColors.lightFoam,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 12,
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
          ),

          // Category Filters
          SliverToBoxAdapter(
            child: Container(
              color: BrandColors.cream,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: BrandColors.espressoBrown,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        CategoryFilterChip(
                          label: 'All',
                          isSelected: _selectedCategory == null,
                          onTap: () {
                            setState(() {
                              _selectedCategory = null;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ..._categories.map((category) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CategoryFilterChip(
                              label: _capitalize(category),
                              isSelected: _selectedCategory == category,
                              onTap: () {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu Items List
          StreamBuilder<List<MenuItem>>(
            stream: menuService.menuItemsStream(widget.cafe.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: BrandColors.caramel,
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(child: Text('Error: ${snapshot.error}')),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 64,
                          color: BrandColors.steamedMilk,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No menu items available',
                          style: TextStyle(
                            fontSize: 16,
                            color: BrandColors.mediumRoast,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              var menuItems = snapshot.data!;

              // Filter by category if selected
              if (_selectedCategory != null) {
                menuItems = menuItems
                    .where((item) => item.category == _selectedCategory)
                    .toList();
              }

              if (menuItems.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No items in this category',
                      style: TextStyle(
                        fontSize: 16,
                        color: BrandColors.mediumRoast,
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = menuItems[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MenuItemCard(item: item),
                    );
                  }, childCount: menuItems.length),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
