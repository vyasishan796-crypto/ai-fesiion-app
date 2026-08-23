import 'cart_item.dart';
import '../data/outfit_data.dart';

enum OrderStatus { confirmed, processing, shipped, outForDelivery, delivered, cancelled }

class OrderAddress {
  final String label;
  final String fullAddress;
  final String phone;

  const OrderAddress({
    required this.label,
    required this.fullAddress,
    required this.phone,
  });

  Map<String, dynamic> toMap() => {
    'label': label,
    'fullAddress': fullAddress,
    'phone': phone,
  };

  factory OrderAddress.fromMap(Map<String, dynamic> map) => OrderAddress(
    label: map['label'] ?? '',
    fullAddress: map['fullAddress'] ?? '',
    phone: map['phone'] ?? '',
  );
}

class Order {
  final String id;
  final List<CartItem> items;
  final int subtotal;
  final int deliveryCharges;
  final int grandTotal;
  final int savings;
  final OrderStatus status;
  final OrderAddress address;
  final String paymentMethod;
  final DateTime orderDate;
  final DateTime estimatedDelivery;
  final String trackingId;
  final List<OrderTimeline> timeline;

  const Order({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.deliveryCharges,
    required this.grandTotal,
    required this.savings,
    required this.status,
    required this.address,
    required this.paymentMethod,
    required this.orderDate,
    required this.estimatedDelivery,
    this.trackingId = '',
    this.timeline = const [],
  });

  String get statusText {
    switch (status) {
      case OrderStatus.confirmed: return 'Order Confirmed';
      case OrderStatus.processing: return 'Processing';
      case OrderStatus.shipped: return 'Shipped';
      case OrderStatus.outForDelivery: return 'Out for Delivery';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
    }
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'items': items.map((item) => item.toMap()).toList(),
    'subtotal': subtotal,
    'deliveryCharges': deliveryCharges,
    'grandTotal': grandTotal,
    'savings': savings,
    'status': status.index,
    'address': address.toMap(),
    'paymentMethod': paymentMethod,
    'orderDate': orderDate.toIso8601String(),
    'estimatedDelivery': estimatedDelivery.toIso8601String(),
    'trackingId': trackingId,
  };

  factory Order.fromMap(Map<String, dynamic> map) {
    final rawItems = map['items'] as List<dynamic>? ?? [];
    final items = rawItems.map((item) {
      final productId = item['productId'] ?? '';
      final product = OutfitData.allProducts.cast<dynamic>().firstWhere(
        (p) => p.id == productId,
        orElse: () => null,
      );
      if (product != null) {
        return CartItem.fromMap(item as Map<String, dynamic>, product);
      }
      return null;
    }).whereType<CartItem>().toList();

    return Order(
      id: map['id'] ?? '',
      items: items,
      subtotal: map['subtotal'] ?? 0,
      deliveryCharges: map['deliveryCharges'] ?? 0,
      grandTotal: map['grandTotal'] ?? 0,
      savings: map['savings'] ?? 0,
      status: OrderStatus.values[map['status'] ?? 0],
      address: map['address'] != null ? OrderAddress.fromMap(map['address']) : const OrderAddress(label: '', fullAddress: '', phone: ''),
      paymentMethod: map['paymentMethod'] ?? '',
      orderDate: DateTime.parse(map['orderDate'] ?? DateTime.now().toIso8601String()),
      estimatedDelivery: DateTime.parse(map['estimatedDelivery'] ?? DateTime.now().add(const Duration(days: 7)).toIso8601String()),
      trackingId: map['trackingId'] ?? '',
    );
  }
}

class OrderTimeline {
  final String status;
  final DateTime date;
  final String? detail;
  final bool isCompleted;

  const OrderTimeline({
    required this.status,
    required this.date,
    this.detail,
    this.isCompleted = false,
  });
}
