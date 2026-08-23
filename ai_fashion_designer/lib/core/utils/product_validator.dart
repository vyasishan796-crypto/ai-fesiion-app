import 'package:flutter/foundation.dart';
import '../data/outfit_data.dart';

class ProductValidator {
  ProductValidator._();

  static void validateAllProducts() {
    if (!kDebugMode) return;

    final products = OutfitData.allProducts;
    final ids = <String>{};
    final skus = <String>{};
    int errors = 0;

    for (final p in products) {
      if (p.id.isEmpty) {
        debugPrint('PRODUCT ERROR: Empty product ID for "${p.name}"');
        errors++;
      }
      if (!ids.add(p.id)) {
        debugPrint('PRODUCT ERROR: Duplicate ID "${p.id}" for "${p.name}"');
        errors++;
      }
      if (p.sku.isEmpty) {
        debugPrint('PRODUCT WARNING: Missing SKU for ${p.id} "${p.name}"');
      } else if (!skus.add(p.sku)) {
        debugPrint('PRODUCT ERROR: Duplicate SKU "${p.sku}" for "${p.name}"');
        errors++;
      }
      if (p.name.isEmpty) {
        debugPrint('PRODUCT ERROR: Empty name for ID "${p.id}"');
        errors++;
      }
      if (p.imageUrl.isEmpty && p.images.isEmpty) {
        debugPrint('PRODUCT ERROR: No image for ${p.id} "${p.name}"');
        errors++;
      }
      if (p.price <= 0) {
        debugPrint('PRODUCT WARNING: Invalid price ${p.price} for ${p.id} "${p.name}"');
      }
    }

    if (errors == 0) {
      debugPrint('PRODUCT VALIDATION: All ${products.length} products passed validation');
    } else {
      debugPrint('PRODUCT VALIDATION: $errors errors found in ${products.length} products');
    }
  }
}
