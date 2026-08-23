import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../services/cart_service.dart';

class OrderService extends ChangeNotifier {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final List<Order> _orders = [];
  final CartService _cartService = CartService();
  bool _loaded = false;

  List<Order> get orders => List.unmodifiable(_orders);

  Future<void> loadOrders() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('user_orders') ?? '[]';
      final list = jsonDecode(data) as List;
      _orders.clear();
      for (final item in list) {
        _orders.add(Order.fromMap(item));
      }
      _loaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading orders: $e');
    }
  }

  Future<void> _saveOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(_orders.map((o) => o.toMap()).toList());
      await prefs.setString('user_orders', data);
    } catch (e) {
      debugPrint('Error saving orders: $e');
    }
  }

  Future<Order> placeOrder({
    required OrderAddress address,
    required String paymentMethod,
  }) async {
    final now = DateTime.now();
    final orderId = 'ORD-${now.millisecondsSinceEpoch.toString().substring(5)}';
    final trackingId = 'TRK-${now.millisecondsSinceEpoch.toString().substring(7)}';

    final order = Order(
      id: orderId,
      items: List.from(_cartService.items),
      subtotal: _cartService.subtotal,
      deliveryCharges: _cartService.deliveryCharges,
      grandTotal: _cartService.grandTotal,
      savings: _cartService.totalSavings,
      status: OrderStatus.confirmed,
      address: address,
      paymentMethod: paymentMethod,
      orderDate: now,
      estimatedDelivery: now.add(const Duration(days: 5, hours: 12)),
      trackingId: trackingId,
      timeline: [
        OrderTimeline(
          status: 'Order Placed',
          date: now,
          detail: 'Your order has been placed successfully',
          isCompleted: true,
        ),
        OrderTimeline(
          status: 'Order Confirmed',
          date: now.add(const Duration(minutes: 5)),
          detail: 'Seller has confirmed your order',
          isCompleted: true,
        ),
        OrderTimeline(
          status: 'Processing',
          date: now.add(const Duration(hours: 2)),
        ),
        OrderTimeline(
          status: 'Shipped',
          date: now.add(const Duration(days: 1)),
        ),
        OrderTimeline(
          status: 'Out for Delivery',
          date: now.add(const Duration(days: 4)),
        ),
        OrderTimeline(
          status: 'Delivered',
          date: now.add(const Duration(days: 5, hours: 12)),
        ),
      ],
    );

    _orders.insert(0, order);
    _cartService.clearCart();
    await _saveOrders();
    notifyListeners();
    return order;
  }

  Order? getOrder(String orderId) {
    try {
      return _orders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }

  List<Order> getOrdersByStatus(OrderStatus status) {
    return _orders.where((o) => o.status == status).toList();
  }

  Future<void> cancelOrder(String orderId) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      final order = _orders[index];
      _orders[index] = Order(
        id: order.id,
        items: order.items,
        subtotal: order.subtotal,
        deliveryCharges: order.deliveryCharges,
        grandTotal: order.grandTotal,
        savings: order.savings,
        status: OrderStatus.cancelled,
        address: order.address,
        paymentMethod: order.paymentMethod,
        orderDate: order.orderDate,
        estimatedDelivery: order.estimatedDelivery,
        trackingId: order.trackingId,
        timeline: [
          ...order.timeline,
          OrderTimeline(
            status: 'Cancelled',
            date: DateTime.now(),
            detail: 'Order has been cancelled',
            isCompleted: true,
          ),
        ],
      );
      await _saveOrders();
      notifyListeners();
    }
  }
}
