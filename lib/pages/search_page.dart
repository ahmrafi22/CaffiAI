import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../theme/brand_colors.dart';
import '../models/menu_item_model.dart';
import '../models/cafe_model.dart';
import '../services/cafe_service.dart';
import '../services/cart_service.dart';

enum PriceSortOrder { none, lowToHigh, highToLow }

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<MenuItem> _searchResults = [];
  Map<String, Cafe> _cafesMap = {};
  bool _isLoading = false;
  bool _hasSearched = false;
  PriceSortOrder _sortOrder = PriceSortOrder.none;

  @override
  void initState() {
    super.initState();
    _loadCafes();
  }

  Future<void> _loadCafes() async {
    final cafes = await cafeService.fetchAllOrdered();
    setState(() {
      _cafesMap = {for (var cafe in cafes) cafe.id: cafe};
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      // Fetch all available menu items
      final snapshot = await _db
          .collection('menuItems')
          .where('isAvailable', isEqualTo: true)
          .get();

      final allItems = snapshot.docs
          .map((doc) => MenuItem.fromFirestore(doc))
          .toList();

      // Filter by name or description (case-insensitive)
      final lowerQuery = query.toLowerCase();
      final filtered = allItems.where((item) {
        final nameMatch = item.name.toLowerCase().contains(lowerQuery);
        final descMatch =
            item.description?.toLowerCase().contains(lowerQuery) ?? false;
        return nameMatch || descMatch;
      }).toList();

      // Apply sorting
      _applySorting(filtered);

      setState(() {
        _searchResults = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching: $e'),
            backgroundColor: BrandColors.warmRed,
          ),
        );
      }
    }
  }

  void _applySorting(List<MenuItem> items) {
    switch (_sortOrder) {
      case PriceSortOrder.lowToHigh:
        items.sort((a, b) => a.basePrice.compareTo(b.basePrice));
        break;
      case PriceSortOrder.highToLow:
        items.sort((a, b) => b.basePrice.compareTo(a.basePrice));
        break;
      case PriceSortOrder.none:
        break;
    }
  }

  void _onSortChanged(PriceSortOrder? order) {
    if (order == null) return;
    setState(() {
      _sortOrder = order;
      _applySorting(_searchResults);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.cream,
      appBar: AppBar(
        backgroundColor: BrandColors.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: BrandColors.espressoBrown,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Search Menu',
          style: TextStyle(
            color: BrandColors.espressoBrown,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: BrandColors.latteFoam,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: BrandColors.steamedMilk),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(
                    color: BrandColors.deepEspresso,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search menu items...',
                    hintStyle: TextStyle(
                      color: BrandColors.mediumRoast.withValues(alpha: 0.6),
                      fontSize: 16,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: BrandColors.mocha,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear_rounded,
                              color: BrandColors.mocha,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                    _performSearch(value);
                  },
                  onSubmitted: _performSearch,
                ),
              ),
            ),

            // Filter Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_list_rounded,
                    color: BrandColors.mocha,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Sort by price:',
                    style: TextStyle(
                      color: BrandColors.mediumRoast,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: 'None',
                            isSelected: _sortOrder == PriceSortOrder.none,
                            onTap: () => _onSortChanged(PriceSortOrder.none),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Low to High',
                            isSelected: _sortOrder == PriceSortOrder.lowToHigh,
                            onTap: () =>
                                _onSortChanged(PriceSortOrder.lowToHigh),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'High to Low',
                            isSelected: _sortOrder == PriceSortOrder.highToLow,
                            onTap: () =>
                                _onSortChanged(PriceSortOrder.highToLow),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Results
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? BrandColors.caramel : BrandColors.latteFoam,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? BrandColors.caramel : BrandColors.steamedMilk,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : BrandColors.mediumRoast,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: BrandColors.caramel),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              size: 64,
              color: BrandColors.steamedMilk,
            ),
            const SizedBox(height: 16),
            Text(
              'Search for menu items',
              style: TextStyle(color: BrandColors.mediumRoast, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Find items by name or description',
              style: TextStyle(
                color: BrandColors.mediumRoast.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: BrandColors.steamedMilk,
            ),
            const SizedBox(height: 16),
            Text(
              'No items found',
              style: TextStyle(
                color: BrandColors.mediumRoast,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: TextStyle(
                color: BrandColors.mediumRoast.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        final cafe = _cafesMap[item.cafeId];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: BrandColors.latteFoam,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: BrandColors.steamedMilk),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item Image
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: BrandColors.cream,
                        image: item.imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(item.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: item.imageUrl == null
                          ? Center(
                              child: Icon(
                                _getCategoryIcon(item.category),
                                color: BrandColors.caramel,
                                size: 32,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),

                    // Item Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: BrandColors.deepEspresso,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Cafe Name
                          if (cafe != null)
                            Row(
                              children: [
                                const Icon(
                                  Icons.storefront_rounded,
                                  size: 14,
                                  color: BrandColors.caramel,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    cafe.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: BrandColors.caramel,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                          if (item.description != null &&
                              item.description!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              item.description!,
                              style: TextStyle(
                                fontSize: 13,
                                color: BrandColors.mediumRoast.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],

                          const SizedBox(height: 8),

                          // Price and Category
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: BrandColors.lightFoam,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  item.category,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: BrandColors.mediumRoast,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                '${item.basePrice.toStringAsFixed(0)} TK',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: BrandColors.deepEspresso,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Add to Cart Section
                const SizedBox(height: 12),
                _buildAddToCartButton(item),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'coffee':
        return Icons.coffee_rounded;
      case 'drink':
        return Icons.local_drink_rounded;
      case 'food':
        return Icons.restaurant_rounded;
      case 'dessert':
        return Icons.cake_rounded;
      default:
        return Icons.fastfood_rounded;
    }
  }

  Widget _buildAddToCartButton(MenuItem item) {
    return Consumer<CartService>(
      builder: (context, cartService, child) {
        final isInCart = cartService.isInCart(item.id);
        final quantity = cartService.getItemQuantity(item.id);

        if (isInCart && quantity > 0) {
          // Show quantity controls
          return Container(
            decoration: BoxDecoration(
              color: BrandColors.lightFoam,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: BrandColors.caramel, width: 1.5),
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
        return GestureDetector(
          onTap: () {
            cartService.addToCart(item);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${item.name} added to cart'),
                backgroundColor: BrandColors.mintGreen,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: BrandColors.caramel,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_shopping_cart_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Add to Cart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
