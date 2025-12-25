import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import 'firebase_service.dart';

class OrderService extends ChangeNotifier {
  final _fb = firebase;

  // Delivery fee constant
  static const double deliveryFee = 50.0;

  // Reward points multiplier (15% of order subtotal)
  static const double rewardPointsMultiplier = 0.15;

  // Get orders collection
  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _fb.firestore.collection('orders');

  // Get order items collection for a specific order
  CollectionReference<Map<String, dynamic>> _orderItemsCollection(
    String orderId,
  ) => _ordersCollection.doc(orderId).collection('items');

  /// Calculate reward points based on subtotal
  int calculateRewardPoints(double subtotal) {
    return (subtotal * rewardPointsMultiplier).round();
  }

  /// Create a new order (manual order)
  Future<CustomerOrder> createOrder({
    required List<CartItem> cartItems,
    required String cafeId,
    required String cafeName,
    required String ownerAdminId,
    required OrderMode orderMode,
    String? specialNotes,
    String? deliveryAddress,
  }) async {
    final user = _fb.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to create an order');
    }

    // Validate cart items
    if (cartItems.isEmpty) {
      throw Exception('Cart is empty');
    }

    // Validate delivery address if delivery mode
    if (orderMode == OrderMode.delivery &&
        (deliveryAddress == null || deliveryAddress.trim().isEmpty)) {
      throw Exception('Delivery address is required for delivery orders');
    }

    // Calculate totals
    final subtotal = cartItems.fold<double>(
      0,
      (total, item) => total + item.totalPrice,
    );
    final fee = orderMode == OrderMode.delivery ? deliveryFee : 0.0;
    final finalTotal = subtotal + fee;
    final rewardPoints = calculateRewardPoints(subtotal);

    // Create order document
    final orderRef = _ordersCollection.doc();
    final orderId = orderRef.id;

    final order = CustomerOrder(
      id: orderId,
      userId: user.uid,
      cafeId: cafeId,
      cafeName: cafeName,
      ownerAdminId: ownerAdminId,
      orderMode: orderMode,
      orderSource: OrderSource.manual,
      status: OrderStatus.pending,
      specialNotes: specialNotes,
      subtotalAmount: subtotal,
      deliveryFee: fee,
      totalAmount: finalTotal,
      rewardPointsEarned: rewardPoints,
      deliveryAddress: deliveryAddress,
    );

    // Use batch write for atomicity
    final batch = _fb.firestore.batch();

    // Set order document
    batch.set(orderRef, order.toFirestore());

    // Add order items as subcollection
    for (final cartItem in cartItems) {
      final itemRef = _orderItemsCollection(orderId).doc();
      final orderItem = OrderItem(
        id: itemRef.id,
        orderId: orderId,
        menuItemId: cartItem.menuItem.id,
        menuItemName: cartItem.menuItem.name,
        quantity: cartItem.quantity,
        unitPrice: cartItem.menuItem.basePrice,
        totalPrice: cartItem.totalPrice,
        aiOrder: false,
      );
      batch.set(itemRef, orderItem.toFirestore());
    }

    // Update user's reward points
    final userRef = _fb.usersCollection.doc(user.uid);
    batch.update(userRef, {
      'rewardPoints': FieldValue.increment(rewardPoints),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Commit the batch
    await batch.commit();

    debugPrint('Order created: $orderId with $rewardPoints reward points');

    return order;
  }

  /// Get user's orders stream
  Stream<List<CustomerOrder>> getUserOrdersStream() {
    final user = _fb.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _ordersCollection
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return CustomerOrder.fromFirestore(doc);
          }).toList();
        });
  }

  /// Get a single order with its items
  Future<CustomerOrder?> getOrderWithItems(String orderId) async {
    final orderDoc = await _ordersCollection.doc(orderId).get();
    if (!orderDoc.exists) return null;

    final itemsSnapshot = await _orderItemsCollection(orderId).get();
    final items = itemsSnapshot.docs.map((doc) {
      return OrderItem.fromFirestore(doc);
    }).toList();

    return CustomerOrder.fromFirestore(orderDoc, items: items);
  }

  /// Get orders for a cafe (for cafe admin app)
  Stream<List<CustomerOrder>> getCafeOrdersStream(String cafeId) {
    return _ordersCollection
        .where('cafeId', isEqualTo: cafeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return CustomerOrder.fromFirestore(doc);
          }).toList();
        });
  }

  /// Get orders by owner admin ID (for cafe admin app)
  Stream<List<CustomerOrder>> getOwnerOrdersStream(String ownerAdminId) {
    return _ordersCollection
        .where('ownerAdminId', isEqualTo: ownerAdminId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return CustomerOrder.fromFirestore(doc);
          }).toList();
        });
  }

  /// Update order status (primarily for cafe admin app)
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await _ordersCollection.doc(orderId).update({
      'status': newStatus.value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    notifyListeners();
  }

  /// Cancel an order (only if pending)
  Future<void> cancelOrder(String orderId) async {
    final orderDoc = await _ordersCollection.doc(orderId).get();
    if (!orderDoc.exists) {
      throw Exception('Order not found');
    }

    final order = CustomerOrder.fromFirestore(orderDoc);
    if (order.status != OrderStatus.pending) {
      throw Exception('Can only cancel pending orders');
    }

    final user = _fb.currentUser;
    if (user == null || user.uid != order.userId) {
      throw Exception('Not authorized to cancel this order');
    }

    // Use batch to cancel order and deduct reward points
    final batch = _fb.firestore.batch();

    batch.update(_ordersCollection.doc(orderId), {
      'status': OrderStatus.cancelled.value,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Deduct reward points that were earned
    batch.update(_fb.usersCollection.doc(user.uid), {
      'rewardPoints': FieldValue.increment(-order.rewardPointsEarned),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    notifyListeners();
  }
}
