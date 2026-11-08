import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';

class WishlistProvider extends ChangeNotifier {
  final Map<String, Product> _items = {};

  List<Product> get items => _items.values.toList();

  int get itemCount => _items.length;

  bool isWishlisted(String productId) {
    return _items.containsKey(productId);
  }

  WishlistProvider() {
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();

    final savedIds =
        prefs.getStringList('wishlist_product_ids') ?? [];

    for (final id in savedIds) {
      for (final product in sampleProducts) {
        if (product.id == id) {
          _items[id] = product;
          break;
        }
      }
    }

    notifyListeners();
  }

  Future<void> _saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      'wishlist_product_ids',
      _items.keys.toList(),
    );
  }

  void toggleWishlist(Product product) {
    if (_items.containsKey(product.id)) {
      _items.remove(product.id);
    } else {
      _items[product.id] = product;
    }

    notifyListeners();
    _saveWishlist();
  }

  void removeFromWishlist(String productId) {
    _items.remove(productId);

    notifyListeners();
    _saveWishlist();
  }
}