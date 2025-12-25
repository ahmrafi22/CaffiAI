import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import '../theme/brand_colors.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.cream,
      appBar: AppBar(
        title: const Text(
          'My Orders',
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

              if (orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        size: 100,
                        color: BrandColors.steamedMilk.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'No orders yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: BrandColors.mediumRoast,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your order history will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: BrandColors.mediumRoast,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _OrderCard(order: order);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final CustomerOrder order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: BrandColors.latteFoam,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrandColors.steamedMilk),
        boxShadow: [
          BoxShadow(
            color: BrandColors.steamedMilk.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: BrandColors.lightFoam,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.cafeName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: BrandColors.deepEspresso,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(order.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: BrandColors.mediumRoast.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(order.status),
              ],
            ),
          ),

          // Order Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Type
                Row(
                  children: [
                    Icon(
                      order.orderMode == OrderMode.delivery
                          ? Icons.delivery_dining_rounded
                          : Icons.restaurant_rounded,
                      size: 18,
                      color: BrandColors.caramel,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.orderMode == OrderMode.delivery
                          ? 'Delivery'
                          : 'Dine In',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: BrandColors.deepEspresso,
                      ),
                    ),
                  ],
                ),

                if (order.deliveryAddress != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 18,
                        color: BrandColors.mediumRoast,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.deliveryAddress!,
                          style: TextStyle(
                            fontSize: 13,
                            color: BrandColors.mediumRoast.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),
                const Divider(color: BrandColors.steamedMilk),
                const SizedBox(height: 12),

                // Price Details
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: BrandColors.deepEspresso,
                      ),
                    ),
                    Text(
                      '${order.totalAmount.toStringAsFixed(0)} TK',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: BrandColors.caramel,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Reward Points
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: BrandColors.mintGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.stars_rounded,
                        size: 16,
                        color: BrandColors.caramel,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '+${order.rewardPointsEarned} points earned',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: BrandColors.deepEspresso,
                        ),
                      ),
                    ],
                  ),
                ),

                // Cancel Button (only for pending orders)
                if (order.status == OrderStatus.pending) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _showCancelDialog(context, order.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: BrandColors.warmRed,
                        side: const BorderSide(color: BrandColors.warmRed),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel Order'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case OrderStatus.pending:
        bgColor = BrandColors.caramel.withValues(alpha: 0.15);
        textColor = BrandColors.caramel;
        break;
      case OrderStatus.accepted:
        bgColor = BrandColors.mintGreen.withValues(alpha: 0.2);
        textColor = BrandColors.mocha;
        break;
      case OrderStatus.preparing:
        bgColor = BrandColors.cinnamon.withValues(alpha: 0.2);
        textColor = BrandColors.cinnamon;
        break;
      case OrderStatus.ready:
        bgColor = BrandColors.mintGreen.withValues(alpha: 0.3);
        textColor = BrandColors.deepEspresso;
        break;
      case OrderStatus.completed:
        bgColor = BrandColors.mintGreen.withValues(alpha: 0.25);
        textColor = BrandColors.mocha;
        break;
      case OrderStatus.cancelled:
        bgColor = BrandColors.warmRed.withValues(alpha: 0.15);
        textColor = BrandColors.warmRed;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today at ${_formatTime(date)}';
    } else if (diff.inDays == 1) {
      return 'Yesterday at ${_formatTime(date)}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  void _showCancelDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BrandColors.latteFoam,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Cancel Order?',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: BrandColors.deepEspresso,
          ),
        ),
        content: const Text(
          'Are you sure you want to cancel this order? Your reward points will be deducted.',
          style: TextStyle(color: BrandColors.mediumRoast),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Keep Order',
              style: TextStyle(color: BrandColors.mediumRoast),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<OrderService>().cancelOrder(orderId);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Order cancelled'),
                    backgroundColor: BrandColors.warmRed,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: BrandColors.warmRed,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BrandColors.warmRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );
  }
}
