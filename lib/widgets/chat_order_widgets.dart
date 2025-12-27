import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../services/ai_chat_state_service.dart';
import '../services/location_service.dart';
import '../theme/brand_colors.dart';

/// Widget for selecting order mode (Dine-in or Delivery) in chat
class ChatOrderModeSelector extends StatelessWidget {
  const ChatOrderModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AIChatStateService>(
      builder: (context, chatService, child) {
        final orderData = chatService.chatOrderData;
        final item = orderData.selectedItem;

        if (item == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, BrandColors.latteFoam],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: BrandColors.mocha.withValues(alpha: 0.15),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with item info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [BrandColors.mocha, BrandColors.caramel],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order: ${item.item.name}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: BrandColors.deepEspresso,
                          ),
                        ),
                        Text(
                          '${item.item.basePrice.toStringAsFixed(0)} TK',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: BrandColors.caramel,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Cancel button
                  IconButton(
                    onPressed: () => chatService.cancelChatOrder(),
                    icon: const Icon(Icons.close_rounded),
                    color: BrandColors.mediumRoast,
                    tooltip: 'Cancel order',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Question
              const Text(
                'How would you like to receive your order?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: BrandColors.espressoBrown,
                ),
              ),

              const SizedBox(height: 12),

              // Order mode options
              Row(
                children: [
                  Expanded(
                    child: _OrderModeCard(
                      icon: Icons.restaurant_rounded,
                      title: 'Dine In',
                      subtitle: 'Enjoy at café',
                      isSelected: false,
                      onTap: () =>
                          chatService.selectOrderMode(OrderMode.dineIn),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _OrderModeCard(
                      icon: Icons.delivery_dining_rounded,
                      title: 'Delivery',
                      subtitle: '+50 TK fee',
                      isSelected: false,
                      onTap: () =>
                          chatService.selectOrderMode(OrderMode.delivery),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OrderModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _OrderModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? BrandColors.mocha : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? BrandColors.mocha
                  : BrandColors.mocha.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected ? Colors.white : BrandColors.mocha,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : BrandColors.deepEspresso,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected
                      ? Colors.white70
                      : BrandColors.mediumRoast.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget for order confirmation with summary
class ChatOrderConfirmation extends StatefulWidget {
  const ChatOrderConfirmation({super.key});

  @override
  State<ChatOrderConfirmation> createState() => _ChatOrderConfirmationState();
}

class _ChatOrderConfirmationState extends State<ChatOrderConfirmation> {
  final TextEditingController _addressController = TextEditingController();
  bool _isFetchingLocation = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation(AIChatStateService chatService) async {
    setState(() {
      _isFetchingLocation = true;
    });

    try {
      final address = await LocationService.getCurrentLocationAddress();
      if (address != null && mounted) {
        _addressController.text = address;
        chatService.updateDeliveryAddress(address);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Unable to get location. Please enter manually.',
            ),
            backgroundColor: BrandColors.caramel,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AIChatStateService>(
      builder: (context, chatService, child) {
        final orderData = chatService.chatOrderData;
        final item = orderData.selectedItem;
        final isDelivery = orderData.orderMode == OrderMode.delivery;

        if (item == null) return const SizedBox.shrink();

        // Pre-fill address if available
        if (orderData.deliveryAddress != null &&
            _addressController.text.isEmpty) {
          _addressController.text = orderData.deliveryAddress!;
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, BrandColors.latteFoam],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: BrandColors.mocha.withValues(alpha: 0.15),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [BrandColors.mocha, BrandColors.caramel],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // AI badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 14,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'AI Order',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item details
                    Row(
                      children: [
                        // Image
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: BrandColors.latteFoam,
                          ),
                          child: item.item.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    item.item.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            _buildPlaceholder(),
                                  ),
                                )
                              : _buildPlaceholder(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.item.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: BrandColors.deepEspresso,
                                ),
                              ),
                              if (item.cafe != null)
                                Text(
                                  item.cafe!.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: BrandColors.mediumRoast.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isDelivery
                                      ? BrandColors.caramel.withValues(
                                          alpha: 0.15,
                                        )
                                      : BrandColors.mintGreen.withValues(
                                          alpha: 0.15,
                                        ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isDelivery
                                          ? Icons.delivery_dining_rounded
                                          : Icons.restaurant_rounded,
                                      size: 14,
                                      color: isDelivery
                                          ? BrandColors.caramel
                                          : BrandColors.mintGreen,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isDelivery ? 'Delivery' : 'Dine In',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDelivery
                                            ? BrandColors.caramel
                                            : BrandColors.mintGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Delivery address input
                    if (isDelivery) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: BrandColors.lightFoam,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: BrandColors.mocha.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 18,
                                  color: BrandColors.caramel,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Delivery Address',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: BrandColors.espressoBrown,
                                  ),
                                ),
                                const Spacer(),
                                // Get location button
                                TextButton.icon(
                                  onPressed: _isFetchingLocation
                                      ? null
                                      : () => _fetchLocation(chatService),
                                  icon: _isFetchingLocation
                                      ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: BrandColors.mocha,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.my_location_rounded,
                                          size: 16,
                                        ),
                                  label: Text(
                                    _isFetchingLocation
                                        ? 'Getting...'
                                        : 'Use current',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: BrandColors.mocha,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _addressController,
                              onChanged: chatService.updateDeliveryAddress,
                              decoration: InputDecoration(
                                hintText: 'Enter your delivery address',
                                hintStyle: TextStyle(
                                  color: BrandColors.mediumRoast.withValues(
                                    alpha: 0.5,
                                  ),
                                  fontSize: 13,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: BrandColors.mocha.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: BrandColors.mocha.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: BrandColors.mocha,
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                isDense: true,
                              ),
                              style: const TextStyle(fontSize: 13),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Price breakdown
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: BrandColors.lightFoam,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildPriceRow(
                            'Subtotal',
                            '${orderData.subtotal.toStringAsFixed(0)} TK',
                          ),
                          if (isDelivery) ...[
                            const SizedBox(height: 6),
                            _buildPriceRow(
                              'Delivery Fee',
                              '+${orderData.deliveryFee.toStringAsFixed(0)} TK',
                              color: BrandColors.caramel,
                            ),
                          ],
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(height: 1),
                          ),
                          _buildPriceRow(
                            'Total',
                            '${orderData.total.toStringAsFixed(0)} TK',
                            isBold: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Reward points badge
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            BrandColors.mintGreen.withValues(alpha: 0.15),
                            BrandColors.mintGreen.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: BrandColors.mintGreen.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: BrandColors.mintGreen,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.stars_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Reward Points',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: BrandColors.mediumRoast,
                                  ),
                                ),
                                Text(
                                  "You'll earn ${orderData.rewardPoints} points!",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: BrandColors.mintGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        // Cancel button
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => chatService.cancelChatOrder(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: BrandColors.mediumRoast,
                              side: const BorderSide(
                                color: BrandColors.mediumRoast,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Confirm button
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed:
                                (isDelivery &&
                                    (_addressController.text.trim().isEmpty))
                                ? null
                                : () => chatService.confirmChatOrder(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: BrandColors.mocha,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: BrandColors.mocha
                                  .withValues(alpha: 0.5),
                              disabledForegroundColor: Colors.white.withValues(
                                alpha: 0.7,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_rounded, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Confirm Order',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
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
      },
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.coffee_rounded,
        size: 28,
        color: BrandColors.mocha.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: color ?? BrandColors.espressoBrown,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: color ?? BrandColors.deepEspresso,
          ),
        ),
      ],
    );
  }
}

/// Widget shown while order is being processed
class ChatOrderProcessing extends StatelessWidget {
  const ChatOrderProcessing({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: BrandColors.mocha.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(BrandColors.mocha),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Placing your order...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: BrandColors.deepEspresso,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Please wait while we process your AI order',
            style: TextStyle(
              fontSize: 13,
              color: BrandColors.mediumRoast.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
