import 'ai_chat_message_model.dart';
import 'order_model.dart';

/// State of the AI chat order flow
enum ChatOrderState {
  none,
  selectingItem,
  selectingMode,
  confirmingOrder,
  processing,
  completed,
  error,
}

/// Model to track the state of an order being placed through chat
class ChatOrderData {
  final ChatOrderState state;
  final CoffeeRecommendation? selectedItem;
  final OrderMode? orderMode;
  final String? deliveryAddress;
  final String? errorMessage;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final int rewardPoints;

  const ChatOrderData({
    this.state = ChatOrderState.none,
    this.selectedItem,
    this.orderMode,
    this.deliveryAddress,
    this.errorMessage,
    this.subtotal = 0,
    this.deliveryFee = 0,
    this.total = 0,
    this.rewardPoints = 0,
  });

  bool get isActive => state != ChatOrderState.none;

  ChatOrderData copyWith({
    ChatOrderState? state,
    CoffeeRecommendation? selectedItem,
    OrderMode? orderMode,
    String? deliveryAddress,
    String? errorMessage,
    double? subtotal,
    double? deliveryFee,
    double? total,
    int? rewardPoints,
  }) {
    return ChatOrderData(
      state: state ?? this.state,
      selectedItem: selectedItem ?? this.selectedItem,
      orderMode: orderMode ?? this.orderMode,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      errorMessage: errorMessage ?? this.errorMessage,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      rewardPoints: rewardPoints ?? this.rewardPoints,
    );
  }

  static ChatOrderData initial() => const ChatOrderData();

  ChatOrderData reset() => const ChatOrderData();
}
