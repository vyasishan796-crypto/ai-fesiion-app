import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chat_message.dart';

class ProductRecommendationCard extends StatefulWidget {
  final ProductCardData product;
  final String? caption;

  const ProductRecommendationCard({super.key, required this.product, this.caption});

  @override
  State<ProductRecommendationCard> createState() => _ProductRecommendationCardState();
}

class _ProductRecommendationCardState extends State<ProductRecommendationCard> {
  bool _isWishlisted = false;
  String? _selectedSize;

  @override
  void initState() {
    super.initState();
    _isWishlisted = widget.product.isWishlisted;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.brand.toUpperCase(),
                  style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF8E8E93), fontWeight: FontWeight.w600, letterSpacing: 0.5),
                ),
                const SizedBox(height: 2),
                Text(widget.product.name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1D1D1F))),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('₹${widget.product.price.toInt()}', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1D1D1F))),
                    const SizedBox(width: 8),
                    Icon(Icons.star, size: 14, color: Colors.amber.shade600),
                    const SizedBox(width: 2),
                    Text(widget.product.rating.toString(), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1D1D1F))),
                  ],
                ),
                const SizedBox(height: 10),
                _buildSizes(),
                const SizedBox(height: 12),
                _buildActions(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: const Center(
        child: Icon(Icons.shopping_bag_outlined, size: 40, color: Color(0xFFC7C7CC)),
      ),
    );
  }

  Widget _buildSizes() {
    return Row(
      children: [
        Text('Sizes:', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF8E8E93))),
        const SizedBox(width: 8),
        ...widget.product.sizes.map((size) {
          final isSelected = _selectedSize == size;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => setState(() => _selectedSize = size),
              child: Container(
                width: 30,
                height: 26,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1D1D1F) : const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(size, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : const Color(0xFF1D1D1F))),
                ),
              ),
            ),
          );
        }),
        const Spacer(),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _isWishlisted = !_isWishlisted);
          },
          child: Icon(
            _isWishlisted ? Icons.favorite : Icons.favorite_border,
            color: _isWishlisted ? const Color(0xFFEF4444) : const Color(0xFF8E8E93),
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildBtn('VIEW', Icons.open_in_new, false, () {}),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildBtn('ADD TO CART', Icons.shopping_cart_outlined, true, () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Added to cart!'), backgroundColor: Color(0xFF1D1D1F)),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBtn(String label, IconData icon, bool isPrimary, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF1D1D1F) : const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: isPrimary ? Colors.white : const Color(0xFF1D1D1F)),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: isPrimary ? Colors.white : const Color(0xFF1D1D1F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
