import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../data/outfit_data.dart';

class WishlistService {
  static final WishlistService _instance = WishlistService._internal();
  factory WishlistService() => _instance;
  WishlistService._internal();

  static const String _storageKey = 'product_wishlist';
  List<String> _wishlistedIds = [];
  bool _isLoaded = false;

  final ValueNotifier<List<String>> wishlistNotifier = ValueNotifier([]);

  Future<void> loadWishlist() async {
    if (_isLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    _wishlistedIds = prefs.getStringList(_storageKey) ?? [];
    _isLoaded = true;
    wishlistNotifier.value = List.from(_wishlistedIds);
  }

  bool isWishlisted(String productId) => _wishlistedIds.contains(productId);

  int get count => _wishlistedIds.length;

  List<Product> get wishlistedProducts {
    return OutfitData.allProducts
        .where((p) => _wishlistedIds.contains(p.id))
        .toList();
  }

  Future<void> toggleWishlist(String productId) async {
    if (_wishlistedIds.contains(productId)) {
      _wishlistedIds.remove(productId);
    } else {
      _wishlistedIds.add(productId);
    }
    await _persist();
    wishlistNotifier.value = List.from(_wishlistedIds);
  }

  Future<void> removeFromWishlist(String productId) async {
    _wishlistedIds.remove(productId);
    await _persist();
    wishlistNotifier.value = List.from(_wishlistedIds);
  }

  Future<void> clearWishlist() async {
    _wishlistedIds = [];
    await _persist();
    wishlistNotifier.value = [];
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, _wishlistedIds);
  }
}
