import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: AppColors.charcoal.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
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
                Text(widget.product.brand, style: GoogleFonts.inter(fontSize: 11, color: AppColors.inkMuted, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(widget.product.name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('₹${widget.product.price.toInt()}', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink)),
                    const SizedBox(width: 8),
                    Icon(Icons.star, size: 14, color: Colors.amber.shade600),
                    const SizedBox(width: 2),
                    Text(widget.product.rating.toString(), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
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
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Center(
        child: Icon(Icons.shopping_bag_outlined, size: 40, color: AppColors.mediumGrey.withOpacity(0.5)),
      ),
    );
  }

  Widget _buildSizes() {
    return Row(
      children: [
        Text('Sizes:', style: GoogleFonts.inter(fontSize: 11, color: AppColors.inkMuted)),
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
                  color: isSelected ? AppColors.primary : AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                ),
                child: Center(
                  child: Text(size, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: isSelected ? AppColors.white : AppColors.ink)),
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
            color: _isWishlisted ? AppColors.error : AppColors.inkMuted,
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
          child: _buildBtn('View Product', Icons.open_in_new, false, () {}),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildBtn('Add to Cart', Icons.shopping_cart_outlined, true, () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Added to cart!'), backgroundColor: AppColors.success),
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
          color: isPrimary ? AppColors.primary : AppColors.lightGrey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: isPrimary ? AppColors.white : AppColors.inkSecondary),
            const SizedBox(width: 5),
            Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: isPrimary ? AppColors.white : AppColors.ink)),
          ],
        ),
      ),
    );
  }
}
