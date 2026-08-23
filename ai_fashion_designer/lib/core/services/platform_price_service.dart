import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/price_data.dart';

class PlatformPriceService {
  static final PlatformPriceService _instance = PlatformPriceService._internal();
  factory PlatformPriceService() => _instance;
  PlatformPriceService._internal();

  Map<String, List<PriceData>> _cache = {};

  static const Map<String, double> _brandTiers = {
    'Roadster': 0.8,
    'HRX': 0.85,
    'US Polo': 0.9,
    'H&M': 1.0,
    'Allen Solly': 1.1,
    'W': 1.0,
    'Puma': 1.2,
    'Levis': 1.3,
    'FabIndia': 1.2,
    'Nike': 1.5,
    'Adidas': 1.4,
    'Zara': 1.6,
    'Tommy Hilfiger': 1.7,
    'Mango': 1.4,
    'Marks & Spencer': 1.3,
    'Ray-Ban': 2.0,
    'Fossil': 1.8,
    'Wildcraft': 0.9,
    'Safari': 0.7,
    'Lino Perros': 1.1,
  };

  static const Map<String, double> _platformStrategy = {
    'Amazon': 0.95,
    'Meesho': 0.88,
    'Flipkart': 0.97,
    'Myntra': 1.02,
    'Ajio': 1.05,
    'TataCliq': 1.08,
  };

  static const Map<String, double> _platformRatings = {
    'Amazon': 4.3,
    'Flipkart': 4.2,
    'Myntra': 4.4,
    'Ajio': 4.1,
    'Meesho': 3.9,
    'TataCliq': 4.2,
  };

  Future<List<PriceData>> getPrices(String productName, String brand, int basePrice) async {
    final cacheKey = '${brand.toLowerCase()}_$productName'.replaceAll(' ', '_');

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    await _loadFromCache();
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final prices = _buildBrandAwarePrices(productName, brand, basePrice);
    _cache[cacheKey] = prices;
    await _saveToCache();
    return prices;
  }

  Future<void> _loadFromCache() async {
    if (_cache.isNotEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString('platform_prices_v2');
    if (cachedJson != null) {
      try {
        final data = jsonDecode(cachedJson) as Map<String, dynamic>;
        _cache = data.map((key, value) {
          final list = (value as List).cast<Map<String, dynamic>>();
          return MapEntry(key, list.map((p) => PriceData.fromJson(p)).toList());
        });
      } catch (e) {
        debugPrint('Error loading price cache: $e');
      }
    }
  }

  Future<void> _saveToCache() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _cache.map((key, value) =>
        MapEntry(key, value.map((p) => p.toJson()).toList()));
    await prefs.setString('platform_prices_v2', jsonEncode(data));
  }

  List<PriceData> _buildBrandAwarePrices(String productName, String brand, int basePrice) {
    final brandTier = _brandTiers[brand] ?? 1.0;
    final seed = productName.hashCode;
    final platforms = ['Amazon', 'Flipkart', 'Myntra', 'Ajio', 'Meesho', 'TataCliq'];

    return platforms.asMap().entries.map((entry) {
      final i = entry.key;
      final platform = entry.value;
      final strategy = _platformStrategy[platform]!;
      final variation = ((seed + i * 13) % 7) - 3;
      final price = (basePrice * brandTier * strategy + variation).round().clamp(
        (basePrice * brandTier * 0.85).round(),
        (basePrice * brandTier * 1.15).round(),
      );
      final baseRating = _platformRatings[platform]!;
      final rating = (baseRating + ((seed + i * 3) % 5) * 0.1).clamp(3.7, 4.8);
      final reviews = 500 + (i * 800) + (seed.abs() % 8000);
      final deliveryDays = i < 2 ? 'Tomorrow' : i < 4 ? '2 days' : '3-5 days';

      return PriceData(
        platform: platform,
        price: price,
        productUrl: _getSearchUrl(platform, '$brand $productName'),
        rating: double.parse(rating.toStringAsFixed(1)),
        reviewCount: reviews,
        shippingInfo: price > 499 ? 'Free delivery' : '₹49 delivery',
        deliveryDate: deliveryDays,
      );
    }).toList();
  }

  String _getSearchUrl(String platform, String query) {
    final encoded = Uri.encodeComponent(query);
    switch (platform) {
      case 'Amazon':
        return 'https://www.amazon.in/s?k=$encoded';
      case 'Flipkart':
        return 'https://www.flipkart.com/search?q=$encoded';
      case 'Meesho':
        return 'https://www.meesho.com/search?q=$encoded';
      case 'Ajio':
        return 'https://www.ajio.com/search/?text=$encoded';
      case 'Myntra':
        return 'https://www.myntra.com/$encoded';
      case 'TataCliq':
        return 'https://www.tatacliq.com/search/?searchCategory=all&text=$encoded';
      default:
        return 'https://www.google.com/search?q=$encoded';
    }
  }
}
