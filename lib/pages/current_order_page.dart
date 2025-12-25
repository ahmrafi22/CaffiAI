import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import '../theme/brand_colors.dart';

class CurrentOrderPage extends StatelessWidget {
  const CurrentOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.cream,
      appBar: AppBar(
        title: const Text(
          'Current Order',
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
      body: Consumer<OrderService>(
        builder: (context, orderService, child) {
          return StreamBuilder<List<CustomerOrder>>(
            stream: orderService.getUserOrdersStream(),
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
                        'Error loading orders',
                        style: TextStyle(
                          fontSize: 16,
                          color: BrandColors.mediumRoast.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final orders = snapshot.data ?? [];

              // Filter for ongoing orders (not completed or cancelled)
              final ongoingOrders = orders.where((order) {
                return order.status != OrderStatus.completed &&
                    order.status != OrderStatus.cancelled;
              }).toList();

              if (ongoingOrders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 100,
                        color: BrandColors.mintGreen.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'No active orders',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: BrandColors.mediumRoast,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'All your orders have been completed!',
                        style: TextStyle(
                          fontSize: 14,
                          color: BrandColors.mediumRoast,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BrandColors.caramel,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: ongoingOrders.length,
                itemBuilder: (context, index) {
                  final order = ongoingOrders[index];
                  return _CurrentOrderCard(order: order);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _CurrentOrderCard extends StatelessWidget {
  final CustomerOrder order;

  const _CurrentOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: BrandColors.latteFoam,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BrandColors.steamedMilk),
        boxShadow: [
          BoxShadow(
            color: BrandColors.steamedMilk.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Banner
          _buildStatusBanner(),

          // Cafe Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: BrandColors.caramel.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    order.orderMode == OrderMode.delivery
                        ? Icons.delivery_dining_rounded
                        : Icons.restaurant_rounded,
                    color: BrandColors.caramel,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.cafeName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: BrandColors.deepEspresso,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            order.orderMode == OrderMode.delivery
                                ? Icons.delivery_dining_rounded
                                : Icons.restaurant_rounded,
                            size: 14,
                            color: BrandColors.mediumRoast,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order.orderMode == OrderMode.delivery
                                ? 'Delivery Order'
                                : 'Dine In Order',
                            style: TextStyle(
                              fontSize: 13,
                              color: BrandColors.mediumRoast.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(order.status),
              ],
            ),
          ),

          // Ready Message
          if (order.status == OrderStatus.ready) _buildReadyMessage(),

          // Delivery Address (if delivery)
          if (order.orderMode == OrderMode.delivery &&
              order.deliveryAddress != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BrandColors.lightFoam,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: BrandColors.steamedMilk),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 20,
                      color: BrandColors.caramel,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Delivery Address',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: BrandColors.mediumRoast,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            order.deliveryAddress!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: BrandColors.deepEspresso,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: BrandColors.steamedMilk),
          ),

          // Order Items Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.shopping_bag_rounded,
                      size: 20,
                      color: BrandColors.caramel,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Order Items',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: BrandColors.deepEspresso,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _OrderItemsList(orderId: order.id),
              ],
            ),
          ),

          // Special Notes
          if (order.specialNotes != null && order.specialNotes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BrandColors.steamedMilk.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.note_rounded,
                      size: 18,
                      color: BrandColors.mediumRoast,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Special Notes',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: BrandColors.mediumRoast,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            order.specialNotes!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: BrandColors.deepEspresso,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Price Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: BrandColors.lightFoam,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Subtotal',
                      style: TextStyle(
                        fontSize: 14,
                        color: BrandColors.mediumRoast,
                      ),
                    ),
                    Text(
                      '${order.subtotalAmount.toStringAsFixed(0)} TK',
                      style: const TextStyle(
                        fontSize: 14,
                        color: BrandColors.deepEspresso,
                      ),
                    ),
                  ],
                ),
                if (order.deliveryFee > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Delivery Fee',
                        style: TextStyle(
                          fontSize: 14,
                          color: BrandColors.mediumRoast,
                        ),
                      ),
                      Text(
                        '${order.deliveryFee.toStringAsFixed(0)} TK',
                        style: const TextStyle(
                          fontSize: 14,
                          color: BrandColors.caramel,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                const Divider(color: BrandColors.steamedMilk),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: BrandColors.deepEspresso,
                      ),
                    ),
                    Text(
                      '${order.totalAmount.toStringAsFixed(0)} TK',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: BrandColors.caramel,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      size: 16,
                      color: BrandColors.mintGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${order.rewardPointsEarned} points earned',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: BrandColors.mintGreen,
                      ),
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

  Widget _buildStatusBanner() {
    Color bannerColor;
    IconData bannerIcon;
    String bannerText;

    switch (order.status) {
      case OrderStatus.pending:
        bannerColor = BrandColors.warmRed;
        bannerIcon = Icons.hourglass_top_rounded;
        bannerText = 'Waiting for confirmation...';
        break;
      case OrderStatus.accepted:
        bannerColor = BrandColors.caramel;
        bannerIcon = Icons.thumb_up_alt_rounded;
        bannerText = 'Order accepted! Preparing soon...';
        break;
      case OrderStatus.preparing:
        bannerColor = BrandColors.mocha;
        bannerIcon = Icons.local_cafe_rounded;
        bannerText = 'Your order is being prepared ☕';
        break;
      case OrderStatus.ready:
        bannerColor = BrandColors.mintGreen;
        bannerIcon = Icons.check_circle_rounded;
        bannerText = 'Your order is ready! 🎉';
        break;
      default:
        bannerColor = BrandColors.mediumRoast;
        bannerIcon = Icons.info_rounded;
        bannerText = 'Processing...';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(bannerIcon, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              bannerText,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyMessage() {
    final isDineIn = order.orderMode == OrderMode.dineIn;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDineIn
              ? [
                  BrandColors.mintGreen,
                  BrandColors.mintGreen.withValues(alpha: 0.8),
                ]
              : [
                  BrandColors.caramel,
                  BrandColors.caramel.withValues(alpha: 0.8),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: (isDineIn ? BrandColors.mintGreen : BrandColors.caramel)
                .withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDineIn
                  ? Icons.restaurant_rounded
                  : Icons.local_shipping_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDineIn ? '🍽️ Please come and dine in!' : '🚚 On the way!',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isDineIn
                      ? 'Your order is ready at the counter. Enjoy your meal!'
                      : 'Your order will be delivered soon. Please be patient!',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color chipColor;
    Color textColor;

    switch (status) {
      case OrderStatus.pending:
        chipColor = BrandColors.warmRed.withValues(alpha: 0.15);
        textColor = BrandColors.warmRed;
        break;
      case OrderStatus.accepted:
        chipColor = BrandColors.caramel.withValues(alpha: 0.15);
        textColor = BrandColors.caramel;
        break;
      case OrderStatus.preparing:
        chipColor = BrandColors.mocha.withValues(alpha: 0.15);
        textColor = BrandColors.mocha;
        break;
      case OrderStatus.ready:
        chipColor = BrandColors.mintGreen.withValues(alpha: 0.15);
        textColor = BrandColors.mintGreen;
        break;
      default:
        chipColor = BrandColors.mediumRoast.withValues(alpha: 0.15);
        textColor = BrandColors.mediumRoast;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

// Widget to fetch and display order items
class _OrderItemsList extends StatelessWidget {
  final String orderId;

  const _OrderItemsList({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderService>(
      builder: (context, orderService, child) {
        return FutureBuilder<CustomerOrder?>(
          future: orderService.getOrderWithItems(orderId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                    color: BrandColors.caramel,
                    strokeWidth: 2,
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'No items found',
                  style: TextStyle(
                    color: BrandColors.mediumRoast,
                    fontSize: 14,
                  ),
                ),
              );
            }

            final items = snapshot.data!.items;

            return Column(
              children: items.map((item) => _buildItemRow(item)).toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildItemRow(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BrandColors.lightFoam,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: BrandColors.steamedMilk),
      ),
      child: Row(
        children: [
          // Quantity Badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: BrandColors.caramel.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${item.quantity}x',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: BrandColors.caramel,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Item Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.menuItemName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: BrandColors.deepEspresso,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.unitPrice.toStringAsFixed(0)} TK each',
                  style: TextStyle(
                    fontSize: 12,
                    color: BrandColors.mediumRoast.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          // Total Price
          Text(
            '${item.totalPrice.toStringAsFixed(0)} TK',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: BrandColors.caramel,
            ),
          ),
        ],
      ),
    );
  }
}
