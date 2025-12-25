import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import '../pages/current_order_page.dart';
import '../theme/brand_colors.dart';

class CurrentOrderIconButton extends StatelessWidget {
  final Color iconColor;
  final Color badgeColor;

  const CurrentOrderIconButton({
    super.key,
    this.iconColor = BrandColors.espressoBrown,
    this.badgeColor = BrandColors.mintGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderService>(
      builder: (context, orderService, child) {
        return StreamBuilder<List<CustomerOrder>>(
          stream: orderService.getUserOrdersStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            // Filter for ongoing orders (not completed or cancelled)
            final ongoingOrders = snapshot.data!.where((order) {
              return order.status != OrderStatus.completed &&
                  order.status != OrderStatus.cancelled;
            }).toList();

            // Don't show if no ongoing orders
            if (ongoingOrders.isEmpty) {
              return const SizedBox.shrink();
            }

            return Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.receipt_long_rounded, color: iconColor),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CurrentOrderPage(),
                      ),
                    );
                  },
                  tooltip: 'Current Order',
                ),
                // Animated badge indicator
                Positioned(
                  right: 8,
                  top: 8,
                  child: _AnimatedBadge(
                    count: ongoingOrders.length,
                    color: badgeColor,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _AnimatedBadge extends StatefulWidget {
  final int count;
  final Color color;

  const _AnimatedBadge({required this.count, required this.color});

  @override
  State<_AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<_AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.5),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
        child: Center(
          child: Text(
            widget.count > 9 ? '9+' : '${widget.count}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
