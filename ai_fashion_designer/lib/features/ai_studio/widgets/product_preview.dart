import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/outfit.dart';
import '../../../core/models/product.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';

class ProductPreview extends StatelessWidget {
  final Outfit outfit;
  final VoidCallback onChange;

  const ProductPreview({
    super.key,
    required this.outfit,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.canvasParchment,
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.dividerSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.checkroom_outlined, size: 14, color: AppColors.accentPurple),
                    const SizedBox(width: 6),
                    Text(
                      outfit.products.length == 1 ? 'Product Selected' : 'Outfit Selected',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentPurple,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onChange,
                icon: const Icon(Icons.swap_horiz, size: 16),
                label: Text('Change', style: GoogleFonts.inter(fontSize: 13)),
                style: TextButton.styleFrom(foregroundColor: AppColors.accentPurple),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Product images
          if (outfit.products.length == 1)
            _buildSingleProduct(outfit.products.first)
          else
            _buildOutfitProducts(),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildSingleProduct(Product product) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.dividerSoft),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: product.imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              color: AppColors.canvasParchment,
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentPurple)),
            ),
            errorWidget: (_, __, ___) => Container(
              color: AppColors.canvasParchment,
              child: const Icon(Icons.checkroom_rounded, color: AppColors.inkMuted48, size: 48),
            ),
          ),
          // Gradient overlay with product info
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.brand,
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${product.price.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.accentPurple),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitProducts() {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: outfit.products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = outfit.products[index];
              return Container(
                width: 130,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.md,
                  border: Border.all(color: AppColors.dividerSoft),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppColors.canvasParchment),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.canvasParchment,
                        child: const Icon(Icons.checkroom_rounded, color: AppColors.inkMuted48, size: 32),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              product.brand,
                              style: GoogleFonts.inter(fontSize: 9, color: Colors.white70),
                            ),
                            Text(
                              product.name,
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (index * 80).ms).slideX(begin: 0.1);
            },
          ),
        ),
        if (outfit.products.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '+${outfit.products.length - 5} more items',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.inkMuted48),
            ),
          ),
      ],
    );
  }
}