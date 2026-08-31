import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/cart_item.dart';
import '../../core/services/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cart = CartService();
  late final VoidCallback _cartListener;

  @override
  void initState() {
    super.initState();
    _cartListener = () => setState(() {});
    _cart.addListener(_cartListener);
  }

  @override
  void dispose() {
    _cart.removeListener(_cartListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'CART — ${_cart.totalItems}',
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 2),
        ),
        actions: [
          if (_cart.items.isNotEmpty)
            TextButton(
              onPressed: () {
                _cart.clearCart();
                setState(() {});
              },
              child: Text('CLEAR', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 1)),
            ),
        ],
      ),
      body: _cart.items.isEmpty ? _buildEmptyState() : _buildCartBody(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
            child: const Icon(Icons.shopping_bag_outlined, size: 40, color: AppColors.inkMuted48),
          ),
          const SizedBox(height: 20),
          Text('YOUR CART IS EMPTY', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Text('Add items to get started', style: GoogleFonts.inter(fontSize: 14, color: AppColors.inkMuted48)),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => context.go('/home'),
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30)),
              child: Center(child: Text('START SHOPPING', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartBody() {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            itemCount: _cart.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) => _cartItem(_cart.items[index]),
          ),
        ),
        _buildPriceSummary(),
      ],
    );
  }

  Widget _cartItem(CartItem item) {
    return Dismissible(
      key: ValueKey('${item.product.id}-${item.selectedSize}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
      ),
      onDismissed: (_) {
        _cart.removeItem(item.product.id, size: item.selectedSize);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 90,
              height: 110,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: item.product.imageUrl,
                width: 90,
                height: 110,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.grey[100]),
                errorWidget: (_, __, ___) => Container(color: Colors.grey[100], child: const Icon(Icons.image_outlined, color: AppColors.inkMuted48, size: 28)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.brand.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.inkMuted48, letterSpacing: 1)),
                  const SizedBox(height: 2),
                  Text(item.product.name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('₹${item.product.price}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.black)),
                      if (item.product.originalPrice > item.product.price) ...[
                        const SizedBox(width: 6),
                        Text('₹${item.product.originalPrice}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.inkMuted48, decoration: TextDecoration.lineThrough)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
                        child: DropdownButton<String>(
                          value: item.selectedSize,
                          underline: const SizedBox(),
                          isDense: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
                          items: item.product.sizes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              _cart.updateSize(item.product.id, val);
                              setState(() {});
                            }
                          },
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                            _qtyBtn(item.quantity > 1 ? Icons.remove_rounded : Icons.delete_outline_rounded, () {
                              if (item.quantity > 1) {
                                _cart.updateQuantity(item.product.id, item.quantity - 1, size: item.selectedSize);
                              } else {
                                _cart.removeItem(item.product.id, size: item.selectedSize);
                              }
                              setState(() {});
                            }),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('${item.quantity}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                            ),
                            _qtyBtn(Icons.add_rounded, () {
                              _cart.updateQuantity(item.product.id, item.quantity + 1, size: item.selectedSize);
                              setState(() {});
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('₹${item.totalPrice}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.black)),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 350.ms, delay: const Duration(milliseconds: 60)).slideY(begin: 0.03),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }

  Widget _buildPriceSummary() {
    final subtotal = _cart.subtotal;
    final delivery = _cart.deliveryCharges;
    final savings = _cart.totalSavings;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Column(
        children: [
          if (subtotal < 999)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_outlined, size: 16, color: Colors.black),
                  const SizedBox(width: 8),
                  Text('Add ₹${999 - subtotal} more for FREE delivery', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)),
                ],
              ),
            ),
          _priceRow('SUBTOTAL (${_cart.totalItems} ITEMS)', '₹$subtotal'),
          const SizedBox(height: 8),
          _priceRow('DELIVERY', delivery == 0 ? 'FREE' : '₹$delivery', isFree: delivery == 0),
          if (savings > 0) ...[
            const SizedBox(height: 8),
            _priceRow('SAVINGS', '-₹$savings', isGreen: true),
          ],
          const SizedBox(height: 14),
          Divider(height: 1, color: Colors.grey[200]),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 1)),
              Text('₹${_cart.grandTotal}', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black)),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: GestureDetector(
              onTap: () => context.push('/marketplace/checkout'),
              child: Container(
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30)),
                child: Center(child: Text('CHECKOUT', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 2))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isFree = false, bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.inkMuted48, letterSpacing: 0.5)),
        Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: isGreen ? AppColors.success : Colors.black)),
      ],
    );
  }
}
