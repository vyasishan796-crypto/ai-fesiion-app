import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/wishlist_service.dart';
import '../../core/models/product.dart';
import '../../core/widgets/empty_state_widget.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistService _wishlistService = WishlistService();
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    await _wishlistService.loadWishlist();
    setState(() => _products = _wishlistService.wishlistedProducts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.charcoal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Wishlist', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.white)),
        centerTitle: true,
        actions: [
          if (_products.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 22, color: AppColors.white),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Clear Wishlist?', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    content: Text('Remove all items from your wishlist?', style: GoogleFonts.inter(fontSize: 14, color: AppColors.inkMuted48)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.inkMuted48))),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Clear', style: GoogleFonts.inter(color: AppColors.error, fontWeight: FontWeight.w600))),
                    ],
                  ),
                );
                if (confirm == true) {
                  await _wishlistService.clearWishlist();
                  setState(() => _products = []);
                }
              },
            ),
        ],
      ),
      body: _products.isEmpty
          ? EmptyStateWidget(
              icon: Icons.favorite_border_rounded,
              title: 'No wishlisted items',
              subtitle: 'Items you like will appear here. Tap the heart icon on any product to add it to your wishlist.',
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.62,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) => _buildWishlistCard(_products[index]),
            ),
    );
  }

  Widget _buildWishlistCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dividerSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(height: 140, color: const Color(0xFFF5F5F7)),
                  errorWidget: (_, __, ___) => Container(height: 140, color: const Color(0xFFF5F5F7), child: const Icon(Icons.checkroom, color: Color(0xFFC7C7CC))),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () async {
                    await _wishlistService.toggleWishlist(product.id);
                    setState(() => _products = _wishlistService.wishlistedProducts);
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]),
                    child: const Icon(Icons.favorite_rounded, size: 18, color: Colors.red),
                  ),
                ),
              ),
              if (product.discount > 0)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(6)),
                    child: Text('-${product.discount}%', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.brand, style: GoogleFonts.inter(fontSize: 10, color: AppColors.inkMuted48)),
                const SizedBox(height: 2),
                Text(product.name, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFBBF24)),
                    const SizedBox(width: 2),
                    Text('${product.rating}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('₹${product.price}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).scale(begin: const Offset(0.95, 0.95));
  }
}
