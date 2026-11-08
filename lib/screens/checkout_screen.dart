import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../widgets/custom_widgets.dart';
import '../providers/order_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  String _paymentMethod = 'Cash on Delivery';
  bool _placingOrder = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

 Future<void> _placeOrder() async {
  if (_placingOrder) return;

  final cart = context.read<CartProvider>();
  final orderProvider = context.read<OrderProvider>();

  if (cart.items.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your cart is empty. Add a product first.'),
      ),
    );
    return;
  }

  if (!(_formKey.currentState?.validate() ?? false)) {
    return;
  }

  final orderTotal = cart.totalPrice;
  final totalItems = cart.itemCount;
  final customerName = _nameController.text.trim();

  setState(() => _placingOrder = true);

  try {
    await Future.delayed(const Duration(seconds: 1));

    await orderProvider.placeOrder(
      customerName: customerName,
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      paymentMethod: _paymentMethod,
      cart: cart,
    );

    if (!mounted) return;

    cart.clearCart();

    setState(() => _placingOrder = false);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF24734D),
                size: 70,
              ),
              const SizedBox(height: 14),
              const Text(
                'Order placed successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Thank you, $customerName!',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _summaryRow('Items', '$totalItems'),
              const SizedBox(height: 8),
              _summaryRow(
                'Order total',
                '₹${orderTotal.toStringAsFixed(0)}',
              ),
              const SizedBox(height: 8),
              _summaryRow('Payment', _paymentMethod),
              const SizedBox(height: 12),
              const Text(
                'Demo order only. No real payment was processed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).popUntil(
                    (route) => route.isFirst,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF24734D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                child: const Text('Back to Shop'),
              ),
            ),
          ],
        );
      },
    );
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Could not save order: $error'),
      ),
    );
  } finally {
    if (mounted) {
      setState(() => _placingOrder = false);
    }
  }
}

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.black54),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items.values.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF24734D),
        foregroundColor: Colors.white,
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      size: 70,
                      color: Color(0xFF24734D),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Continue Shopping'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Delivery Details',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().length < 3) {
                          return 'Enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    CustomTextField(
                      controller: _addressController,
                      label: 'Shipping Address',
                      icon: Icons.home_outlined,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Address is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    CustomTextField(
                      controller: _phoneController,
                      label: '10-digit Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        final digits =
                            value?.replaceAll(RegExp(r'\D'), '') ?? '';

                        if (!RegExp(r'^[6-9]\d{9}$').hasMatch(digits)) {
                          return 'Enter a valid Indian mobile number';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 26),
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFE1E8E2),
                        ),
                      ),
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            value: 'Cash on Delivery',
                            groupValue: _paymentMethod,
                            activeColor: const Color(0xFF24734D),
                            title: const Text('Cash on Delivery'),
                            secondary: const Icon(
                              Icons.local_shipping_outlined,
                            ),
                            onChanged: _placingOrder
                                ? null
                                : (value) {
                                    if (value != null) {
                                      setState(() {
                                        _paymentMethod = value;
                                      });
                                    }
                                  },
                          ),
                          const Divider(height: 1),
                          RadioListTile<String>(
                            value: 'Demo Online Payment',
                            groupValue: _paymentMethod,
                            activeColor: const Color(0xFF24734D),
                            title: const Text('Demo Online Payment'),
                            subtitle: const Text(
                              'No actual payment will be charged',
                            ),
                            secondary: const Icon(
                              Icons.account_balance_wallet_outlined,
                            ),
                            onChanged: _placingOrder
                                ? null
                                : (value) {
                                    if (value != null) {
                                      setState(() {
                                        _paymentMethod = value;
                                      });
                                    }
                                  },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE1E8E2),
                        ),
                      ),
                      child: Column(
                        children: [
                          ...items.map((item) {
                            final lineTotal =
                                item.product.price * item.quantity;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.product.name} × ${item.quantity}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '₹${lineTotal.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const Divider(),
                          const SizedBox(height: 8),
                          _summaryRow(
                            'Total items',
                            '${cart.itemCount}',
                          ),
                          const SizedBox(height: 12),
                          _summaryRow(
                            'Order total',
                            '₹${cart.totalPrice.toStringAsFixed(0)}',
                          ),
                          const SizedBox(height: 8),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Shipping charges are not included in this demo.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    if (_placingOrder)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            color: Color(0xFF24734D),
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 52,
                        child: CustomButton(
                          label: 'Place Demo Order',
                          icon: Icons.check_circle_outline,
                          onPressed: _placeOrder,
                        ),
                      ),
                    const SizedBox(height: 12),
                    const Text(
                      'Demo checkout only. Real orders and payments are not processed.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}