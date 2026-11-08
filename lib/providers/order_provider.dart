import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/order.dart';
import 'cart_provider.dart';

class OrderProvider extends ChangeNotifier {
  static const String _storageKey = 'shopease_order_history';

  final List<Order> _orders = [];
  bool _isLoaded = false;

  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoaded => _isLoaded;

  Future<void> loadOrders() async {
    if (_isLoaded) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_storageKey);

      if (saved != null) {
        final decoded = jsonDecode(saved) as List;

        _orders
          ..clear()
          ..addAll(
            decoded.map(
              (item) => Order.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            ),
          );

        _orders.sort((a, b) => b.date.compareTo(a.date));
      }
    } catch (e) {
      debugPrint('Loading orders failed: $e');
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> placeOrder({
    required String customerName,
    required String address,
    required String phone,
    required String paymentMethod,
    required CartProvider cart,
  }) async {
    if (!_isLoaded) await loadOrders();

    if (cart.items.isEmpty) {
      throw StateError('Your cart is empty.');
    }

    final now = DateTime.now();
    final items = cart.items.values.toList();

    final order = Order(
      id: 'SE${now.millisecondsSinceEpoch}',
      customerName: customerName,
      address: address,
      phone: phone,
      paymentMethod: paymentMethod,
      date: now,
      total: cart.totalPrice,
      totalItems: cart.itemCount,
      status: 'Placed',
      products: items.map((item) => <String, dynamic>{
        'id': item.product.id,
        'name': item.product.name,
        'price': item.product.price,
        'quantity': item.quantity,
        'imageUrl': item.product.imageUrl,
        'emoji': item.product.emoji,
      }).toList(),
    );

    _orders.insert(0, order);

    try {
      await _saveOrders();
    } catch (_) {
      _orders.remove(order);
      rethrow;
    }

    notifyListeners();
  }

  Future<void> _saveOrders() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _storageKey,
      jsonEncode(_orders.map((order) => order.toJson()).toList()),
    );
  }

  Future<void> clearOrderHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    _orders.clear();
    notifyListeners();
  }
}