import 'price_data.dart';

class Product {
  final String id;
  final String sku;
  final String name;
  final String category;
  final String subcategory;
  final String style;
  final String color;
  final int price;
  final int originalPrice;
  final int discount;
  final String imageUrl;
  final List<String> images;
  final String thumbnailUrl;
  final String description;
  final List<String> sizes;
  final double rating;
  final int reviewCount;
  final String brand;
  final String gender;
  final String deliveryInfo;
  final String buyUrl;
  final bool isTrending;
  final bool isRecommended;
  final bool isFeatured;
  final bool isNewArrival;
  final bool isOnSale;
  final List<String> tags;
  final List<PriceData> platformPrices;

  const Product({
    required this.id,
    this.sku = '',
    required this.name,
    required this.category,
    this.subcategory = '',
    this.style = '',
    this.color = '',
    required this.price,
    this.originalPrice = 0,
    this.discount = 0,
    required this.imageUrl,
    this.images = const [],
    this.thumbnailUrl = '',
    this.description = '',
    this.sizes = const [],
    this.rating = 4.0,
    this.reviewCount = 0,
    this.brand = '',
    this.gender = 'unisex',
    this.deliveryInfo = 'Free delivery',
    this.buyUrl = '',
    this.isTrending = false,
    this.isRecommended = false,
    this.isFeatured = false,
    this.isNewArrival = false,
    this.isOnSale = false,
    this.tags = const [],
    this.platformPrices = const [],
  });

  List<String> get allImages {
    if (images.isNotEmpty) return images;
    if (imageUrl.isNotEmpty) return [imageUrl];
    return [];
  }

  int get savings => originalPrice > price ? originalPrice - price : 0;

  int get bestPrice => platformPrices.isNotEmpty
      ? (platformPrices.map((p) => p.price).reduce((a, b) => a < b ? a : b))
      : price;

  int get bestSavings => platformPrices.isNotEmpty && originalPrice > 0
      ? originalPrice - bestPrice
      : savings;

  bool get hasMultiPlatform => platformPrices.length > 1;

  PriceData? get cheapestPlatform => platformPrices.isNotEmpty
      ? (platformPrices.reduce((a, b) => a.price < b.price ? a : b))
      : null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'category': category,
      'subcategory': subcategory,
      'style': style,
      'color': color,
      'price': price,
      'originalPrice': originalPrice,
      'discount': discount,
      'imageUrl': imageUrl,
      'images': images,
      'thumbnailUrl': thumbnailUrl,
      'description': description,
      'sizes': sizes,
      'rating': rating,
      'reviewCount': reviewCount,
      'brand': brand,
      'gender': gender,
      'deliveryInfo': deliveryInfo,
      'buyUrl': buyUrl,
      'isTrending': isTrending,
      'isRecommended': isRecommended,
      'isFeatured': isFeatured,
      'isNewArrival': isNewArrival,
      'isOnSale': isOnSale,
      'tags': tags,
      'platformPrices': platformPrices.map((p) => p.toJson()).toList(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      sku: map['sku'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      subcategory: map['subcategory'] ?? '',
      style: map['style'] ?? '',
      color: map['color'] ?? '',
      price: map['price'] ?? 0,
      originalPrice: map['originalPrice'] ?? 0,
      discount: map['discount'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      thumbnailUrl: map['thumbnailUrl'] ?? map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      sizes: List<String>.from(map['sizes'] ?? []),
      rating: (map['rating'] as num?)?.toDouble() ?? 4.0,
      reviewCount: map['reviewCount'] ?? 0,
      brand: map['brand'] ?? '',
      gender: map['gender'] ?? 'unisex',
      deliveryInfo: map['deliveryInfo'] ?? 'Free delivery',
      buyUrl: map['buyUrl'] ?? '',
      isTrending: map['isTrending'] ?? false,
      isRecommended: map['isRecommended'] ?? false,
      isFeatured: map['isFeatured'] ?? false,
      isNewArrival: map['isNewArrival'] ?? false,
      isOnSale: map['isOnSale'] ?? false,
      tags: List<String>.from(map['tags'] ?? []),
      platformPrices: (map['platformPrices'] as List<dynamic>?)
          ?.map((p) => PriceData.fromJson(p as Map<String, dynamic>))
          .toList() ??
          const [],
    );
  }
}
