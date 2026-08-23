import '../data/outfit_data.dart';
import '../models/product.dart';

/// Service for resolving product IDs to canonical product data and images.
/// Ensures product-image consistency across the app.
class ProductImageService {
  ProductImageService._();

  /// Get a product by its ID from the canonical data source.
  static Product? getById(String id) {
    try {
      return OutfitData.allProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get multiple products by their IDs.
  static List<Product> getByIds(List<String> ids) {
    final idSet = ids.toSet();
    return OutfitData.allProducts.where((p) => idSet.contains(p.id)).toList();
  }

  /// Get the primary image URL for a product.
  static String getPrimaryImage(Product product) => product.imageUrl;

  /// Get all images for a product (primary + gallery).
  static List<String> getAllImages(Product product) => product.allImages;

  /// Validate that a product ID exists in the catalog.
  static bool isValidProductId(String id) {
    return OutfitData.allProducts.any((p) => p.id == id);
  }

  /// Get product details for virtual try-on (used in API requests).
  static Map<String, dynamic> getTryOnDetails(Product product) {
    return {
      'id': product.id,
      'sku': product.sku,
      'name': product.name,
      'color': product.color,
      'category': product.category,
      'material': '', // TODO: Add material field to Product model
      'brand': product.brand,
      'image_url': product.imageUrl,
    };
  }

  /// Get try-on details for multiple products.
  static List<Map<String, dynamic>> getTryOnDetailsList(List<Product> products) {
    return products.map((p) => getTryOnDetails(p)).toList();
  }

  /// Resolve product IDs to products, filtering out invalid IDs.
  static List<Product> resolveProductIds(List<String> ids) {
    return ids
        .where((id) => isValidProductId(id))
        .map((id) => getById(id)!)
        .toList();
  }

  /// Get all valid product IDs from a list.
  static List<String> getValidIds(List<String> ids) {
    return ids.where((id) => isValidProductId(id)).toList();
  }
}