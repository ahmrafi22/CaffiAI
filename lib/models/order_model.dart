import 'package:cloud_firestore/cloud_firestore.dart';

/// Order mode - how the customer will receive their order
enum OrderMode {
  dineIn('dine_in'),
  delivery('delivery');

  final String value;
  const OrderMode(this.value);

  static OrderMode fromString(String value) {
    return OrderMode.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OrderMode.dineIn,
    );
  }
}

/// Order source - how the order was created
enum OrderSource {
  manual('manual'),
  aiChat('ai_chat');

  final String value;
  const OrderSource(this.value);

  static OrderSource fromString(String value) {
    return OrderSource.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OrderSource.manual,
    );
  }
}

/// Order status - current state of the order
enum OrderStatus {
  pending('pending'),
  accepted('accepted'),
  preparing('preparing'),
  ready('ready'),
  completed('completed'),
  cancelled('cancelled');

  final String value;
  const OrderStatus(this.value);

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OrderStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Individual item in an order
class OrderItem {
  final String id;
  final String orderId;
  final String menuItemId;
  final String menuItemName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final bool aiOrder;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.menuItemId,
    required this.menuItemName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.aiOrder = false,
  });

  factory OrderItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderItem(
      id: doc.id,
      orderId: data['orderId'] ?? '',
      menuItemId: data['menuItemId'] ?? '',
      menuItemName: data['menuItemName'] ?? '',
      quantity: (data['quantity'] ?? 1).toInt(),
      unitPrice: (data['unitPrice'] ?? 0).toDouble(),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      aiOrder: data['aiOrder'] ?? false,
    );
  }

  factory OrderItem.fromMap(String id, Map<String, dynamic> data) {
    return OrderItem(
      id: id,
      orderId: data['orderId'] ?? '',
      menuItemId: data['menuItemId'] ?? '',
      menuItemName: data['menuItemName'] ?? '',
      quantity: (data['quantity'] ?? 1).toInt(),
      unitPrice: (data['unitPrice'] ?? 0).toDouble(),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      aiOrder: data['aiOrder'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'orderId': orderId,
      'menuItemId': menuItemId,
      'menuItemName': menuItemName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'aiOrder': aiOrder,
    };
  }
}

/// Customer order model
class CustomerOrder {
  final String id;
  final String userId;
  final String cafeId;
  final String cafeName;
  final String ownerAdminId;
  final OrderMode orderMode;
  final OrderSource orderSource;
  final OrderStatus status;
  final String? specialNotes;
  final double subtotalAmount;
  final double deliveryFee;
  final double totalAmount;
  final int rewardPointsEarned;
  final String? deliveryAddress;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<OrderItem> items;

  CustomerOrder({
    required this.id,
    required this.userId,
    required this.cafeId,
    required this.cafeName,
    required this.ownerAdminId,
    required this.orderMode,
    required this.orderSource,
    required this.status,
    this.specialNotes,
    required this.subtotalAmount,
    required this.deliveryFee,
    required this.totalAmount,
    required this.rewardPointsEarned,
    this.deliveryAddress,
    this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  factory CustomerOrder.fromFirestore(
    DocumentSnapshot doc, {
    List<OrderItem> items = const [],
  }) {
    final data = doc.data() as Map<String, dynamic>;
    return CustomerOrder(
      id: doc.id,
      userId: data['userId'] ?? '',
      cafeId: data['cafeId'] ?? '',
      cafeName: data['cafeName'] ?? '',
      ownerAdminId: data['ownerAdminId'] ?? '',
      orderMode: OrderMode.fromString(data['orderMode'] ?? 'dine_in'),
      orderSource: OrderSource.fromString(data['orderSource'] ?? 'manual'),
      status: OrderStatus.fromString(data['status'] ?? 'pending'),
      specialNotes: data['specialNotes'],
      subtotalAmount: (data['subtotalAmount'] ?? 0).toDouble(),
      deliveryFee: (data['deliveryFee'] ?? 0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      rewardPointsEarned: (data['rewardPointsEarned'] ?? 0).toInt(),
      deliveryAddress: data['deliveryAddress'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      items: items,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'cafeId': cafeId,
      'cafeName': cafeName,
      'ownerAdminId': ownerAdminId,
      'orderMode': orderMode.value,
      'orderSource': orderSource.value,
      'status': status.value,
      'specialNotes': specialNotes,
      'subtotalAmount': subtotalAmount,
      'deliveryFee': deliveryFee,
      'totalAmount': totalAmount,
      'rewardPointsEarned': rewardPointsEarned,
      'deliveryAddress': deliveryAddress,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  CustomerOrder copyWith({
    String? id,
    String? userId,
    String? cafeId,
    String? cafeName,
    String? ownerAdminId,
    OrderMode? orderMode,
    OrderSource? orderSource,
    OrderStatus? status,
    String? specialNotes,
    double? subtotalAmount,
    double? deliveryFee,
    double? totalAmount,
    int? rewardPointsEarned,
    String? deliveryAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItem>? items,
  }) {
    return CustomerOrder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cafeId: cafeId ?? this.cafeId,
      cafeName: cafeName ?? this.cafeName,
      ownerAdminId: ownerAdminId ?? this.ownerAdminId,
      orderMode: orderMode ?? this.orderMode,
      orderSource: orderSource ?? this.orderSource,
      status: status ?? this.status,
      specialNotes: specialNotes ?? this.specialNotes,
      subtotalAmount: subtotalAmount ?? this.subtotalAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      totalAmount: totalAmount ?? this.totalAmount,
      rewardPointsEarned: rewardPointsEarned ?? this.rewardPointsEarned,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }
}
