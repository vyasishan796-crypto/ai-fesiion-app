class PriceData {
  final String platform;
  final int price;
  final String? productUrl;
  final double? rating;
  final int? reviewCount;
  final String? shippingInfo;
  final String? deliveryDate;

  const PriceData({
    required this.platform,
    required this.price,
    this.productUrl,
    this.rating,
    this.reviewCount,
    this.shippingInfo,
    this.deliveryDate,
  });

  factory PriceData.fromJson(Map<String, dynamic> json) {
    return PriceData(
      platform: json['platform'] as String? ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      productUrl: json['productUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'] as int?,
      shippingInfo: json['shippingInfo'] as String?,
      deliveryDate: json['deliveryDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'platform': platform,
    'price': price,
    'productUrl': productUrl,
    'rating': rating,
    'reviewCount': reviewCount,
    'shippingInfo': shippingInfo,
    'deliveryDate': deliveryDate,
  };
}
