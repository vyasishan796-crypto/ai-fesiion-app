import 'product.dart';

/// Represents a fashion outfit composed of multiple products.
class Outfit {
  final String id;
  final String name;
  final List<Product> products;
  final String? occasion;
  final String? style;
  final DateTime createdAt;

  Outfit({
    required this.id,
    required this.name,
    required this.products,
    this.occasion,
    this.style,
    required this.createdAt,
  });

  factory Outfit.create({
    required String name,
    required List<Product> products,
    String? occasion,
    String? style,
  }) {
    return Outfit(
      id: 'outfit_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      products: products,
      occasion: occasion,
      style: style,
      createdAt: DateTime.now(),
    );
  }

  /// Get product IDs for API requests.
  List<String> get productIds => products.map((p) => p.id).toList();

  /// Get total price of outfit.
  int get totalPrice => products.fold(0, (sum, p) => sum + p.price);

  /// Get all unique categories in outfit.
  List<String> get categories => products.map((p) => p.category).toSet().toList();

  /// Get all unique brands in outfit.
  List<String> get brands => products.map((p) => p.brand).toSet().toList();

  /// Get primary image (first product).
  String? get primaryImage => products.isNotEmpty ? products.first.imageUrl : null;

  /// Get all product images.
  List<String> get allImages => products.expand((p) => p.allImages).toList();

  /// Get product details for try-on API.
  List<Map<String, dynamic>> get tryOnDetails {
    return products.map((p) => {
      'id': p.id,
      'sku': p.sku,
      'name': p.name,
      'color': p.color,
      'category': p.category,
      'material': '', // TODO: Add material field
      'brand': p.brand,
      'image_url': p.imageUrl,
    }).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'product_ids': productIds,
      'occasion': occasion,
      'style': style,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Outfit.fromJson(Map<String, dynamic> json, List<Product> products) {
    return Outfit(
      id: json['id'] as String,
      name: json['name'] as String,
      products: products,
      occasion: json['occasion'] as String?,
      style: json['style'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Outfit && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Outfit(id: $id, name: $name, products: ${products.length})';
}