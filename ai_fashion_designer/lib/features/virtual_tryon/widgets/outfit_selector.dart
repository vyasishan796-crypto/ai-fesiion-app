import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/data/outfit_data.dart';
import '../../../core/models/outfit.dart';
import '../../../core/models/product.dart';
import '../../../core/theme/app_colors.dart';

class OutfitSelector extends StatelessWidget {
  final String? selectedOutfitId;
  final String? selectedProductId;
  final ValueChanged<Outfit> onOutfitSelected;
  final ValueChanged<Product>? onProductSelected;
  final bool showProducts;
  final String? categoryFilter;

  const OutfitSelector({
    super.key,
    this.selectedOutfitId,
    this.selectedProductId,
    required this.onOutfitSelected,
    this.onProductSelected,
    this.showProducts = true,
    this.categoryFilter,
  });

  static List<Outfit> get curatedOutfits {
    final allProducts = OutfitData.allProducts;
    return [
      _buildOutfit(
        id: 'outfit_summer_casual',
        name: 'Summer Casual',
        products: [
          ...allProducts.where((p) => p.category == 'T-Shirts' && p.color.toLowerCase().contains('white')).take(1),
          ...allProducts.where((p) => p.category == 'Jeans').take(1),
          ...allProducts.where((p) => p.category == 'Sneakers').take(1),
        ],
      ),
      _buildOutfit(
        id: 'outfit_urban_streetwear',
        name: 'Urban Streetwear',
        products: [
          ...allProducts.where((p) => p.category == 'T-Shirts' && p.color.toLowerCase().contains('black')).take(1),
          ...allProducts.where((p) => p.category == 'Jackets').take(1),
          ...allProducts.where((p) => p.category == 'Jeans').take(1),
          ...allProducts.where((p) => p.category == 'Sneakers').take(1),
        ],
      ),
      _buildOutfit(
        id: 'outfit_office_formal',
        name: 'Office Formal',
        products: [
          ...allProducts.where((p) => p.category == 'Shirts').take(1),
          ...allProducts.where((p) => p.category == 'Formals').take(1),
          ...allProducts.where((p) => p.category == 'Sneakers').take(1),
        ],
      ),
      _buildOutfit(
        id: 'outfit_street_style',
        name: 'Street Style',
        products: [
          ...allProducts.where((p) => p.category == 'T-Shirts' && p.color.toLowerCase().contains('grey')).take(1),
          ...allProducts.where((p) => p.category == 'Jackets').take(1),
          ...allProducts.where((p) => p.category == 'Jeans').take(1),
        ],
      ),
      _buildOutfit(
        id: 'outfit_indian_ethnic',
        name: 'Indian Ethnic',
        products: [
          ...allProducts.where((p) => p.category == 'Kurtis').take(1),
          ...allProducts.where((p) => p.category == 'Kurtas').take(1),
          ...allProducts.where((p) => p.category == 'Heels').take(1),
        ],
      ),
      _buildOutfit(
        id: 'outfit_weekend_vibes',
        name: 'Weekend Vibes',
        products: [
          ...allProducts.where((p) => p.category == 'Tops' && p.color.toLowerCase().contains('white')).take(1),
          ...allProducts.where((p) => p.category == 'Shorts').take(1),
          ...allProducts.where((p) => p.category == 'Sneakers').take(1),
        ],
      ),
    ];
  }

  static Outfit _buildOutfit({required String id, required String name, required List<Product> products}) {
    return Outfit(id: id, name: name, products: products, style: _inferStyle(products), occasion: _inferOccasion(products), createdAt: DateTime.now());
  }

  static String _inferStyle(List<Product> products) {
    final categories = products.map((p) => p.category.toLowerCase()).toSet();
    if (categories.contains('kurtis') || categories.contains('kurtas')) return 'ethnic';
    if (categories.contains('formals') || categories.contains('shirts')) return 'formal';
    if (categories.contains('jackets')) return 'streetwear';
    return 'casual';
  }

  static String _inferOccasion(List<Product> products) {
    final categories = products.map((p) => p.category.toLowerCase()).toSet();
    if (categories.contains('kurtis') || categories.contains('kurtas')) return 'festive';
    if (categories.contains('formals') || categories.contains('shirts')) return 'office';
    return 'daily';
  }

  @override
  Widget build(BuildContext context) {
    final outfits = curatedOutfits;
    final products = showProducts ? (categoryFilter != null ? OutfitData.byCategory(categoryFilter!) : OutfitData.allProducts.take(20).toList()) : <Product>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (outfits.isNotEmpty) ...[
          Text('Complete Outfits', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink, letterSpacing: -0.224)),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: outfits.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final outfit = outfits[index];
                final isSelected = outfit.id == selectedOutfitId;
                return _buildOutfitCard(context, outfit, isSelected, index);
              },
            ),
          ),
          if (products.isNotEmpty) const SizedBox(height: 24),
        ],
        if (showProducts && products.isNotEmpty) ...[
          Text(categoryFilter != null ? '$categoryFilter' : 'Or Pick Individual Items', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink, letterSpacing: -0.224)),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = products[index];
                final isSelected = product.id == selectedProductId;
                return _buildProductCard(context, product, isSelected, index);
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOutfitCard(BuildContext context, Outfit outfit, bool isSelected, int index) {
    final primaryImage = outfit.primaryImage;
    return GestureDetector(
      onTap: () => onOutfitSelected(outfit),
      child: Container(
        width: 160,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: isSelected ? AppColors.accentPurple : AppColors.dividerSoft, width: isSelected ? 2.5 : 1)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (primaryImage != null)
              CachedNetworkImage(
                imageUrl: primaryImage,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.canvasParchment, child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentPurple))),
                errorWidget: (_, __, ___) => Container(color: AppColors.canvasParchment, child: const Icon(Icons.checkroom_rounded, color: AppColors.inkMuted48, size: 32)),
              )
            else
              Container(color: AppColors.canvasParchment),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(8)),
                child: Text('${outfit.products.length} items', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.85)])),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(outfit.name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text('${outfit.products.length} items • ${outfit.style?.capitalize() ?? 'Style'}', style: GoogleFonts.inter(fontSize: 10, color: Colors.white70)),
                  ],
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(width: 24, height: 24, decoration: const BoxDecoration(color: AppColors.accentPurple, shape: BoxShape.circle), child: const Icon(Icons.check, size: 14, color: Colors.white)),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.1);
  }

  Widget _buildProductCard(BuildContext context, Product product, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => onProductSelected?.call(product),
      child: Container(
        width: 140,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: isSelected ? AppColors.accentPurple : AppColors.dividerSoft, width: isSelected ? 2.5 : 1)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: product.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: AppColors.canvasParchment, child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentPurple))),
              errorWidget: (_, __, ___) => Container(color: AppColors.canvasParchment, child: const Icon(Icons.checkroom_rounded, color: AppColors.inkMuted48, size: 32)),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.7)])),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(product.name, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(product.brand, style: GoogleFonts.inter(fontSize: 9, color: Colors.white70)),
                  ],
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(width: 24, height: 24, decoration: const BoxDecoration(color: AppColors.accentPurple, shape: BoxShape.circle), child: const Icon(Icons.check, size: 14, color: Colors.white)),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (30 * index).ms).slideY(begin: 0.1);
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
