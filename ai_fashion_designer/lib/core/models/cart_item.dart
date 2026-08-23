import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;
  String selectedSize;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.selectedSize = '',
  }) {
    if (selectedSize.isEmpty && product.sizes.isNotEmpty) {
      selectedSize = product.sizes.first;
    }
  }

  int get totalPrice => product.price * quantity;
  int get totalSavings => (product.originalPrice > product.price)
      ? (product.originalPrice - product.price) * quantity
      : 0;

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'quantity': quantity,
      'selectedSize': selectedSize,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map, Product product) {
    return CartItem(
      product: product,
      quantity: map['quantity'] ?? 1,
      selectedSize: map['selectedSize'] ?? (product.sizes.isNotEmpty ? product.sizes.first : ''),
    );
  }
}
