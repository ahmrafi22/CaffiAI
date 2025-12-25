import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../theme/brand_colors.dart';

class CheckoutPage extends StatefulWidget {
  final String cafeId;
  final String cafeName;
  final String ownerAdminId;

  const CheckoutPage({
    super.key,
    required this.cafeId,
    required this.cafeName,
    required this.ownerAdminId,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  OrderMode _selectedMode = OrderMode.dineIn;
  final _notesController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  double get _deliveryFee =>
      _selectedMode == OrderMode.delivery ? OrderService.deliveryFee : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.cream,
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: BrandColors.espressoBrown,
          ),
        ),
        backgroundColor: BrandColors.cream,
        elevation: 0,
        iconTheme: const IconThemeData(color: BrandColors.espressoBrown),
      ),
      body: Consumer<CartService>(
        builder: (context, cartService, child) {
          if (cartService.cartItems.isEmpty) {
            return const Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(fontSize: 18, color: BrandColors.mediumRoast),
              ),
            );
          }

          final subtotal = cartService.totalPrice;
          final total = subtotal + _deliveryFee;
          final rewardPoints = (subtotal * OrderService.rewardPointsMultiplier)
              .round();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cafe Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: BrandColors.latteFoam,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: BrandColors.steamedMilk),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.store_rounded,
                        color: BrandColors.caramel,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ordering from',
                              style: TextStyle(
                                fontSize: 12,
                                color: BrandColors.mediumRoast,
                              ),
                            ),
                            Text(
                              widget.cafeName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: BrandColors.deepEspresso,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Order Mode Selection
                const Text(
                  'Order Type',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: BrandColors.deepEspresso,
                  ),
                ),
                const SizedBox(height: 12),

                // Dine In Option
                _buildOrderModeOption(
                  mode: OrderMode.dineIn,
                  icon: Icons.restaurant_rounded,
                  title: 'Dine In',
                  subtitle: 'Enjoy your order at the cafe',
                  extraCharge: null,
                ),

                const SizedBox(height: 12),

                // Delivery Option
                _buildOrderModeOption(
                  mode: OrderMode.delivery,
                  icon: Icons.delivery_dining_rounded,
                  title: 'Delivery',
                  subtitle: 'Get it delivered to your location',
                  extraCharge: OrderService.deliveryFee,
                ),

                // Delivery Address (shown only for delivery)
                if (_selectedMode == OrderMode.delivery) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Delivery Address',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: BrandColors.deepEspresso,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Enter your delivery address...',
                      hintStyle: TextStyle(
                        color: BrandColors.mediumRoast.withValues(alpha: 0.6),
                      ),
                      filled: true,
                      fillColor: BrandColors.latteFoam,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: BrandColors.steamedMilk,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: BrandColors.steamedMilk,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: BrandColors.caramel,
                        ),
                      ),
                      prefixIcon: const Icon(
                        Icons.location_on_rounded,
                        color: BrandColors.caramel,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Special Notes
                const Text(
                  'Special Notes (Optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: BrandColors.deepEspresso,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Any special requests for your order...',
                    hintStyle: TextStyle(
                      color: BrandColors.mediumRoast.withValues(alpha: 0.6),
                    ),
                    filled: true,
                    fillColor: BrandColors.latteFoam,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: BrandColors.steamedMilk,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: BrandColors.steamedMilk,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: BrandColors.caramel),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Order Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: BrandColors.latteFoam,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: BrandColors.steamedMilk),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: BrandColors.deepEspresso,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Cart Items
                      ...cartService.cartItems.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.quantity}x ${item.menuItem.name}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: BrandColors.mediumRoast,
                                  ),
                                ),
                              ),
                              Text(
                                '${item.totalPrice.toStringAsFixed(0)} TK',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: BrandColors.deepEspresso,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Divider(color: BrandColors.steamedMilk),
                      const SizedBox(height: 8),

                      // Subtotal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Subtotal',
                            style: TextStyle(
                              fontSize: 15,
                              color: BrandColors.mediumRoast,
                            ),
                          ),
                          Text(
                            '${subtotal.toStringAsFixed(0)} TK',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: BrandColors.deepEspresso,
                            ),
                          ),
                        ],
                      ),

                      // Delivery Fee (if applicable)
                      if (_selectedMode == OrderMode.delivery) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Delivery Fee',
                              style: TextStyle(
                                fontSize: 15,
                                color: BrandColors.mediumRoast,
                              ),
                            ),
                            Text(
                              '${_deliveryFee.toStringAsFixed(0)} TK',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: BrandColors.caramel,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 12),
                      const Divider(color: BrandColors.steamedMilk),
                      const SizedBox(height: 12),

                      // Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: BrandColors.deepEspresso,
                            ),
                          ),
                          Text(
                            '${total.toStringAsFixed(0)} TK',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: BrandColors.caramel,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Reward Points Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: BrandColors.mintGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.stars_rounded,
                              color: BrandColors.caramel,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'You\'ll earn $rewardPoints reward points!',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: BrandColors.deepEspresso,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Place Order Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _placeOrder(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BrandColors.caramel,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: BrandColors.caramel.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Place Order',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderModeOption({
    required OrderMode mode,
    required IconData icon,
    required String title,
    required String subtitle,
    double? extraCharge,
  }) {
    final isSelected = _selectedMode == mode;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = mode;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? BrandColors.caramel.withValues(alpha: 0.1)
              : BrandColors.latteFoam,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? BrandColors.caramel : BrandColors.steamedMilk,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? BrandColors.caramel
                    : BrandColors.steamedMilk.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : BrandColors.mediumRoast,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? BrandColors.caramel
                          : BrandColors.deepEspresso,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: BrandColors.mediumRoast.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            if (extraCharge != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: BrandColors.caramel.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '+${extraCharge.toStringAsFixed(0)} TK',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: BrandColors.caramel,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: BrandColors.mintGreen.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'FREE',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: BrandColors.mocha,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context) async {
    final cartService = context.read<CartService>();
    final orderService = context.read<OrderService>();

    // Validate delivery address
    if (_selectedMode == OrderMode.delivery &&
        _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your delivery address'),
          backgroundColor: BrandColors.warmRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final order = await orderService.createOrder(
        cartItems: cartService.cartItems,
        cafeId: widget.cafeId,
        cafeName: widget.cafeName,
        ownerAdminId: widget.ownerAdminId,
        orderMode: _selectedMode,
        specialNotes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        deliveryAddress: _selectedMode == OrderMode.delivery
            ? _addressController.text.trim()
            : null,
      );

      // Clear cart after successful order
      await cartService.clearCart();

      if (!context.mounted) return;

      // Show success dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: BrandColors.latteFoam,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BrandColors.mintGreen.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: BrandColors.mintGreen,
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Order Placed!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: BrandColors.deepEspresso,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _selectedMode == OrderMode.dineIn
                    ? 'Your order has been sent to the cafe. Please wait for your order to be prepared.'
                    : 'Your order has been sent. It will be delivered to your address soon.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: BrandColors.mediumRoast,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BrandColors.caramel.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      color: BrandColors.caramel,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+${order.rewardPointsEarned} points earned!',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: BrandColors.caramel,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to cart page
                  Navigator.pop(context); // Go back to menu/home
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: BrandColors.caramel,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: ${e.toString()}'),
          backgroundColor: BrandColors.warmRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
