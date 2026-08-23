import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../data/outfit_data.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _items = [];
  bool _loaded = false;

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  int get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);
  int get totalSavings => _items.fold(0, (sum, item) => sum + item.totalSavings);
  int get deliveryCharges => subtotal >= 999 ? 0 : 49;
  int get grandTotal => subtotal + deliveryCharges;

  bool get isEmpty => _items.isEmpty;

  Future<void> loadCart() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('cart_items') ?? '[]';
      final list = jsonDecode(data) as List;
      _items.clear();
      for (final item in list) {
        final productId = item['productId'] ?? '';
        final product = _findProduct(productId);
        if (product != null) {
          _items.add(CartItem.fromMap(item, product));
        }
      }
      _loaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  Product? _findProduct(String id) {
    try {
      final all = [...OutfitData.allProducts];
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(_items.map((item) => item.toMap()).toList());
      await prefs.setString('cart_items', data);
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  void addItem(Product product, {String size = '', int quantity = 1}) {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id && item.selectedSize == size,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(
        product: product,
        quantity: quantity,
        selectedSize: size.isNotEmpty ? size : (product.sizes.isNotEmpty ? product.sizes.first : ''),
      ));
    }
    _saveCart();
    notifyListeners();
  }

  void removeItem(String productId, {String size = ''}) {
    _items.removeWhere(
      (item) => item.product.id == productId && item.selectedSize == size,
    );
    _saveCart();
    notifyListeners();
  }

  void updateQuantity(String productId, int newQuantity, {String size = ''}) {
    if (newQuantity <= 0) {
      removeItem(productId, size: size);
      return;
    }
    final index = _items.indexWhere(
      (item) => item.product.id == productId && item.selectedSize == size,
    );
    if (index >= 0) {
      _items[index].quantity = newQuantity;
      _saveCart();
      notifyListeners();
    }
  }

  void updateSize(String productId, String newSize) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final item = _items[index];
      final duplicateIndex = _items.indexWhere(
        (i) => i.product.id == productId && i.selectedSize == newSize,
      );
      if (duplicateIndex >= 0 && duplicateIndex != index) {
        _items[duplicateIndex].quantity += item.quantity;
        _items.removeAt(index);
      } else {
        item.selectedSize = newSize;
      }
      _saveCart();
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }

  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  int getItemQuantity(String productId) {
    final item = _items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(product: Product(id: '', name: '', category: '', price: 0, imageUrl: '')),
    );
    return item.quantity;
  }
}
