import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item_model.dart';

class MenuService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of menu items for a specific cafe
  Stream<List<MenuItem>> menuItemsStream(String cafeId) {
    return _db
        .collection('menuItems')
        .where('cafeId', isEqualTo: cafeId)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MenuItem.fromFirestore(doc))
              .toList();
        });
  }

  // Get menu items by category for a specific cafe
  Stream<List<MenuItem>> menuItemsByCategoryStream(
    String cafeId,
    String category,
  ) {
    return _db
        .collection('menuItems')
        .where('cafeId', isEqualTo: cafeId)
        .where('category', isEqualTo: category)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MenuItem.fromFirestore(doc))
              .toList();
        });
  }

  // Get a single menu item
  Future<MenuItem?> getMenuItem(String itemId) async {
    final doc = await _db.collection('menuItems').doc(itemId).get();
    if (doc.exists) {
      return MenuItem.fromFirestore(doc);
    }
    return null;
  }

  // Add a new menu item (for admin use)
  Future<String> addMenuItem(MenuItem item) async {
    final docRef = await _db.collection('menuItems').add(item.toFirestore());
    return docRef.id;
  }

  // Update menu item
  Future<void> updateMenuItem(String itemId, Map<String, dynamic> data) async {
    await _db.collection('menuItems').doc(itemId).update(data);
  }

  // Delete menu item
  Future<void> deleteMenuItem(String itemId) async {
    await _db.collection('menuItems').doc(itemId).delete();
  }
}

// Global instance
final menuService = MenuService();
