class Order {
  final String id;
  final String customerName;
  final String address;
  final String phone;
  final String paymentMethod;
  final DateTime date;
  final double total;
  final int totalItems;
  final String status;
  final List<Map<String, dynamic>> products;

  const Order({
    required this.id,
    required this.customerName,
    required this.address,
    required this.phone,
    required this.paymentMethod,
    required this.date,
    required this.total,
    required this.totalItems,
    required this.status,
    required this.products,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'address': address,
      'phone': phone,
      'paymentMethod': paymentMethod,
      'date': date.toIso8601String(),
      'total': total,
      'totalItems': totalItems,
      'status': status,
      'products': products,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      customerName: json['customerName'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      paymentMethod: json['paymentMethod'] as String,
      date: DateTime.parse(json['date'] as String),
      total: (json['total'] as num).toDouble(),
      totalItems: json['totalItems'] as int,
      status: json['status'] as String,
      products: (json['products'] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
    );
  }
}