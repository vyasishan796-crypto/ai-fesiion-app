import 'package:flutter_test/flutter_test.dart';
import 'package:ai_fashion_designer/core/models/product.dart';

void main() {
  group('Product model', () {
    test('should serialize to/from map', () {
      final product = Product(
        id: 'test_001',
        name: 'Test Outfit',
        category: 'Casual',
        subcategory: 'Shirts',
        style: 'Relaxed',
        color: 'Blue',
        price: 1999,
        imageUrl: 'https://example.com/image.jpg',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        description: 'A test outfit',
        sizes: ['S', 'M', 'L'],
        rating: 4.5,
        isTrending: true,
        isRecommended: false,
        isFeatured: false,
      );

      final map = product.toMap();
      final restored = Product.fromMap(map);

      expect(restored.id, product.id);
      expect(restored.name, product.name);
      expect(restored.price, product.price);
      expect(restored.rating, product.rating);
      expect(restored.sizes, ['S', 'M', 'L']);
      expect(restored.isTrending, true);
    });

    test('should handle missing fields gracefully', () {
      final product = Product.fromMap({});
      expect(product.id, '');
      expect(product.name, '');
      expect(product.price, 0);
      expect(product.rating, 4.0);
    });

    test('should compute savings', () {
      final product = Product(
        id: 'test_002',
        name: 'Sale Item',
        category: 'Shirts',
        price: 1500,
        originalPrice: 2000,
        imageUrl: '',
      );
      expect(product.savings, 500);
    });

    test('should return allImages', () {
      final product = Product(
        id: 'test_003',
        name: 'Multi Image',
        category: 'Shirts',
        price: 1000,
        imageUrl: 'https://example.com/img.jpg',
        images: ['https://example.com/1.jpg', 'https://example.com/2.jpg'],
      );
      expect(product.allImages.length, 2);
    });

    test('should fallback to imageUrl when no images list', () {
      final product = Product(
        id: 'test_004',
        name: 'Single Image',
        category: 'Shirts',
        price: 1000,
        imageUrl: 'https://example.com/img.jpg',
      );
      expect(product.allImages.length, 1);
      expect(product.allImages.first, 'https://example.com/img.jpg');
    });

    test('should handle platform prices', () {
      final product = Product(
        id: 'test_005',
        name: 'Multi Platform',
        category: 'Shirts',
        price: 2000,
        imageUrl: '',
        originalPrice: 3000,
      );
      expect(product.bestPrice, 2000);
      expect(product.hasMultiPlatform, false);
    });

    test('should create from map with default gender', () {
      final product = Product.fromMap({
        'id': 'x',
        'name': 'Test',
        'category': 'T-Shirts',
        'price': 500,
        'imageUrl': 'img.jpg',
      });
      expect(product.gender, 'unisex');
    });
  });
}
