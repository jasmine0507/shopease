import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  int _quantity = 1;

  static const Color forest = Color(0xFF245B43);
  static const Color deepGreen = Color(0xFF173D2C);
  static const Color cream = Color(0xFFFAF9F5);
  static const Color softGreen = Color(0xFFEAF0E8);
  static const Color muted = Color(0xFF7B837C);
  static const Color borderColor = Color(0xFFE5EAE3);
  static const Color gold = Color(0xFFE6A23C);

  late final AnimationController _fadeController =
      AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _fadeController,
    curve: Curves.easeIn,
  );

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _increment() {
    setState(() => _quantity++);
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  void _addToCart(Product product) {
    final cart = context.read<CartProvider>();

    for (int i = 0; i < _quantity; i++) {
      cart.addToCart(product);
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 23,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$_quantity × ${product.name} added to cart',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: deepGreen,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: 'Go back',
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: deepGreen,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Product Details',
          style: TextStyle(
            color: deepGreen,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewport) {
            final isWide = viewport.maxWidth >= 760;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: viewport.maxWidth < 500 ? 16 : 28,
                vertical: 16,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1050,
                  ),
                  child: isWide
                      ? _wideLayout(product)
                      : _mobileLayout(product),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Premium product image with fallback
  Widget _productImage(
    Product product, {
    double height = 280,
  }) {
    return Container(
      height: height,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: softGreen,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: borderColor,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: deepGreen.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            bottom: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: forest.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 15,
            left: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_outlined,
                    size: 15,
                    color: forest,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Quality pick',
                    style: TextStyle(
                      color: deepGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Hero(
                tag: product.id,
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;

                    return const Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          color: forest,
                          strokeWidth: 2.5,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        product.emoji,
                        style: TextStyle(
                          fontSize: height * 0.34,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Product information
  Widget _productInfo(Product product) {
    return FadeTransition(
      opacity: _fade,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: softGreen,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              product.category,
              style: const TextStyle(
                color: forest,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            product.name,
            softWrap: true,
            style: const TextStyle(
              color: deepGreen,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 13),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 7,
            children: [
              Text(
                product.formattedPrice,
                style: const TextStyle(
                  color: forest,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4DF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: gold,
                      size: 17,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      product.rating.toString(),
                      style: const TextStyle(
                        color: deepGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${product.reviewCount} reviews',
                style: const TextStyle(
                  color: muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 23),
          const Divider(color: borderColor, height: 1),
          const SizedBox(height: 21),
          const Text(
            'About this product',
            style: TextStyle(
              color: deepGreen,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            product.description,
            softWrap: true,
            style: const TextStyle(
              color: muted,
              fontSize: 14,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 22),
          _featureRow(
            Icons.verified_user_outlined,
            'Quality-focused selection',
          ),
          const SizedBox(height: 13),
          _featureRow(
            Icons.shopping_bag_outlined,
            'Easy shopping experience',
          ),
          const SizedBox(height: 13),
          _featureRow(
            Icons.replay_rounded,
            'Simple order tracking',
          ),
        ],
      ),
    );
  }

  Widget _featureRow(IconData icon, String label) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: softGreen,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: forest,
            size: 18,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: deepGreen,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // Quantity selector
  Widget _quantitySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _quantityButton(
            icon: Icons.remove_rounded,
            onPressed: _quantity > 1 ? _decrement : null,
          ),
          SizedBox(
            width: 42,
            child: Text(
              '$_quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: deepGreen,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _quantityButton(
            icon: Icons.add_rounded,
            onPressed: _increment,
          ),
        ],
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      color: forest,
      disabledColor: const Color(0xFFCDD3CC),
      tooltip: icon == Icons.add_rounded
          ? 'Increase quantity'
          : 'Decrease quantity',
      visualDensity: VisualDensity.compact,
    );
  }

  // Add to cart button
  Widget _addToCartButton(Product product) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () => _addToCart(product),
        style: ElevatedButton.styleFrom(
          backgroundColor: forest,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 21,
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: Text(
                'Add to Cart',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '· ${widget.product.formattedPrice}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mobile layout
  Widget _mobileLayout(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _productImage(product, height: 290),
        const SizedBox(height: 25),
        _productInfo(product),
        const SizedBox(height: 26),
        const Text(
          'Select quantity',
          style: TextStyle(
            color: deepGreen,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        _quantitySelector(),
        const SizedBox(height: 18),
        _addToCartButton(product),
        const SizedBox(height: 26),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 14,
                color: muted,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'A simple and convenient shopping experience',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: muted.withOpacity(0.95),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  // Desktop and tablet layout
  Widget _wideLayout(Product product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final imageWidth = (availableWidth - 32) * 0.51;
          final detailsWidth = availableWidth - imageWidth - 32;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: imageWidth,
                child: _productImage(
                  product,
                  height: 400,
                ),
              ),
              const SizedBox(width: 32),
              SizedBox(
                width: detailsWidth,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _productInfo(product),
                      const SizedBox(height: 25),
                      const Text(
                        'Select quantity',
                        style: TextStyle(
                          color: deepGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _quantitySelector(),
                      const SizedBox(height: 19),
                      _addToCartButton(product),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}