import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/product.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/order_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/wishlist_screen.dart';
import 'screens/order_history_screen.dart';

void main() {
  runApp(const ShopEaseApp());
}

class ShopEaseApp extends StatelessWidget {
  const ShopEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => WishlistProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider()..loadOrders(),
        ),
      ],
      child: MaterialApp(
        title: 'ShopEase',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        initialRoute: '/',
        routes: {
  '/': (context) => const HomeScreen(),
  '/cart': (context) => const CartScreen(),
  '/checkout': (context) => const CheckoutScreen(),
  '/wishlist': (context) => const WishlistScreen(),
  '/orders': (context) => const OrderHistoryScreen(),
},
        onGenerateRoute: (settings) {
          if (settings.name == '/detail') {
            final product = settings.arguments as Product;

            return MaterialPageRoute(
              builder: (context) =>
                  ProductDetailScreen(product: product),
            );
          }

          return null;
        },
      ),
    );
  }
}