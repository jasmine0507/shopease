import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color forest = Color(0xFF245B43);
  static const Color darkForest = Color(0xFF173D2C);
  static const Color cream = Color(0xFFFAF9F5);
  static const Color muted = Color(0xFF858B83);

  final TextEditingController searchController = TextEditingController();

  String selectedCategory = 'All';
  String searchText = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = <String>[
      'All',
      ...sampleProducts.map((p) => p.category).toSet().toList()..sort(),
    ];

    final filteredProducts = sampleProducts.where((product) {
      final query = searchText.toLowerCase();
      final matchesSearch =
          product.name.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query);

      final matchesCategory = selectedCategory == 'All' ||
          product.category == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.shopping_bag_rounded, color: forest, size: 27),
            SizedBox(width: 9),
            Text(
              'ShopEase',
              style: TextStyle(
                color: darkForest,
                fontSize: 25,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Wishlist',
            onPressed: () => Navigator.pushNamed(context, '/wishlist'),
            icon: const Icon(Icons.favorite_border_rounded,
                color: darkForest),
          ),
          IconButton(
            tooltip: 'My Orders',
            onPressed: () => Navigator.pushNamed(context, '/orders'),
            icon: const Icon(Icons.receipt_long_outlined,
                color: darkForest),
          ),
          Consumer<CartProvider>(
            builder: (context, cart, child) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    tooltip: 'Shopping cart',
                    onPressed: () => Navigator.pushNamed(context, '/cart'),
                    icon: const Icon(Icons.shopping_cart_outlined,
                        color: darkForest, size: 25),
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 2,
                      top: 1,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 19,
                          minHeight: 19,
                        ),
                        decoration: const BoxDecoration(
                          color: forest,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GOOD THINGS,',
                      style: TextStyle(
                        color: forest,
                        fontSize: 11,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Beautifully chosen.',
                      style: TextStyle(
                        fontSize: 30,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        color: darkForest,
                        letterSpacing: -1.1,
                      ),
                    ),
                    const SizedBox(height: 9),
                    const Text(
                      'Discover products that make everyday special.',
                      style: TextStyle(
                        fontSize: 13,
                        color: muted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 23),
                    const _HeroBanner(),
                    const SizedBox(height: 23),
                    Container(
                      height: 53,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(color: const Color(0xFFE8E9E2)),
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) =>
                            setState(() => searchText = value),
                        style: const TextStyle(
                          fontSize: 14,
                          color: darkForest,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search your favourites...',
                          hintStyle: const TextStyle(
                            color: muted,
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: forest,
                          ),
                          suffixIcon: searchText.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    searchController.clear();
                                    setState(() => searchText = '');
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 27),
                    const Text(
                      'Explore categories',
                      style: TextStyle(
                        color: darkForest,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 9),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final selected = category == selectedCategory;

                          return ChoiceChip(
                            label: Text(category),
                            selected: selected,
                            showCheckmark: false,
                            onSelected: (_) => setState(
                              () => selectedCategory = category,
                            ),
                            backgroundColor: Colors.white,
                            selectedColor: forest,
                            side: BorderSide(
                              color: selected
                                  ? forest
                                  : const Color(0xFFE6E8E0),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                            labelStyle: TextStyle(
                              color: selected ? Colors.white : darkForest,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Picked for you',
                            style: TextStyle(
                              fontSize: 21,
                              color: darkForest,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        Text(
                          '${filteredProducts.length} products',
                          style: const TextStyle(color: muted, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Little details. Better everyday living.',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
            if (filteredProducts.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 55, color: muted),
                        SizedBox(height: 12),
                        Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkForest,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Try another search or category.',
                          style: TextStyle(color: muted),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.crossAxisExtent;
                    final columns = width < 650
                        ? 2
                        : width < 950
                            ? 3
                            : width < 1250
                                ? 4
                                : 5;

                    return SliverGrid(
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 13,
                        mainAxisSpacing: 15,
                        childAspectRatio: width < 380 ? 0.56 : 0.60,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = filteredProducts[index];
                          return ProductCard(
                            product: product,
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/detail',
                              arguments: product,
                            ),
                          );
                        },
                        childCount: filteredProducts.length,
                      ),
                    );
                  },
                ),
              ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_user_outlined,
                        size: 30, color: forest),
                    SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Shopping made simple',
                            style: TextStyle(
                              color: darkForest,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Explore, choose and enjoy your finds.',
                            style: TextStyle(
                              color: muted,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  static const Color forest = Color(0xFF245B43);
  static const Color darkForest = Color(0xFF173D2C);

  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [darkForest, forest],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -9,
            top: -17,
            child: Icon(
              Icons.spa_outlined,
              size: 115,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'THE EVERYDAY EDIT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.7,
                  ),
                ),
              ),
              const SizedBox(height: 17),
              const Text(
                'Find your next\nfavourite thing.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  height: 1.18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Thoughtful picks for your everyday.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F4E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Explore collection',
                      style: TextStyle(
                        color: darkForest,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: darkForest,
                      size: 15,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}