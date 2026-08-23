import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/product.dart';
import '../utils/product_validator.dart';

class OutfitData {
  OutfitData._();

  static List<Product> _allProducts = [];
  static bool _loaded = false;

  static Future<void> loadProducts() async {
    if (_loaded) return;
    try {
      final jsonStr = await rootBundle.loadString('assets/data/products.json');
      final data = jsonDecode(jsonStr);
      final list = data['products'] as List;
      _allProducts = list.map((p) => Product.fromMap(p as Map<String, dynamic>)).toList();
      _loaded = true;
      if (kDebugMode) {
        ProductValidator.validateAllProducts();
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
      _allProducts = [];
      _loaded = true;
    }
  }

  static List<Product> get allProducts => _allProducts;

  static List<Product> get trending => _allProducts.where((p) => p.isTrending).toList();
  static List<Product> get recommended => _allProducts.where((p) => p.isRecommended).toList();
  static List<Product> get featured => _allProducts.where((p) => p.isFeatured).toList();
  static List<Product> get newArrivals => _allProducts.where((p) => p.isNewArrival).toList();
  static List<Product> get onSale => _allProducts.where((p) => p.isOnSale || p.discount > 0).toList();

  static List<Product> get menProducts => _allProducts.where((p) => p.gender == 'men').toList();
  static List<Product> get womenProducts => _allProducts.where((p) => p.gender == 'women').toList();

  static List<Product> byCategory(String category) => _allProducts.where((p) => p.category == category).toList();
  static List<Product> byGender(String gender) => _allProducts.where((p) => p.gender == gender).toList();
  static List<Product> byBrand(String brand) => _allProducts.where((p) => p.brand == brand).toList();
  static Product? byId(String id) {
    try {
      return _allProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<String> get categories => ['T-Shirts', 'Shirts', 'Jackets', 'Jeans', 'Sneakers', 'Formals', 'Cargo', 'Tops', 'Dresses', 'Kurtis', 'Bags', 'Heels', 'Accessories', 'Trousers', 'Hoodies', 'Joggers', 'Shorts', 'Blazers', 'Sports Wear', 'Watches', 'Sunglasses'];

  static List<String> get brands => _allProducts.map((p) => p.brand).toSet().toList()..sort();
}
