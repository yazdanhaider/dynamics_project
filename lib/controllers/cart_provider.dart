import 'package:flutter/material.dart';
import '../data/models/cart_item_model.dart';
import '../data/models/product_model.dart';

class CartProvider with ChangeNotifier {
  final Map<int, CartItem> _items = {};

  Map<int, CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount {
    return _items.values.fold(0.0, (sum, item) => sum + item.total);
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existingItem) => existingItem.copyWith(
          quantity: existingItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(product.id, () => CartItem.fromProduct(product));
    }
    notifyListeners();
  }

  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void updateQuantity(int productId, int quantity) {
    if (!_items.containsKey(productId)) return;
    if (quantity <= 0) {
      removeItem(productId);
    } else {
      _items.update(
        productId,
        (existingItem) => existingItem.copyWith(quantity: quantity),
      );
      notifyListeners();
    }
  }

  void incrementQuantity(int productId) {
    if (!_items.containsKey(productId)) return;
    updateQuantity(productId, _items[productId]!.quantity + 1);
  }

  void decrementQuantity(int productId) {
    if (!_items.containsKey(productId)) return;
    updateQuantity(productId, _items[productId]!.quantity - 1);
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
