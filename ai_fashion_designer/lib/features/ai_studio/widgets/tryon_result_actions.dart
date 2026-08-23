import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/models/virtual_tryon_generation.dart';
import '../../../core/models/product.dart';
import '../../../core/services/cart_service.dart';
import '../../../core/services/wishlist_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';

class TryOnResultActions extends StatelessWidget {
  final VirtualTryOnGeneration generation;
  final VoidCallback onRegenerate;
  final VoidCallback onEditPrompt;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onTryOn;
  final VoidCallback onAddToCart;
  final VoidCallback onTryAnother;

  const TryOnResultActions({
    super.key,
    required this.generation,
    required this.onRegenerate,
    required this.onEditPrompt,
    required this.onSave,
    required this.onShare,
    required this.onTryOn,
    required this.onAddToCart,
    required this.onTryAnother,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Result Image
        Container(
          width: double.infinity,
          height: 360,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withOpacity(0.15),
                offset: const Offset(0, 8),
                blurRadius: 30,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _buildResultImage(),
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

        const SizedBox(height: 20),

        // Generation info
        _buildInfoRow().animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

        const SizedBox(height: 20),

        // Action Buttons
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            _ActionButton(
              label: 'Regenerate',
              icon: Icons.refresh_rounded,
              onTap: onRegenerate,
              isPrimary: false,
            ),
            _ActionButton(
              label: 'Save Look',
              icon: Icons.bookmark_outline_rounded,
              onTap: onSave,
              isPrimary: true,
            ),
            _ActionButton(
              label: 'Share',
              icon: Icons.share_outlined,
              onTap: onShare,
              isPrimary: false,
            ),
            _ActionButton(
              label: 'View Product',
              icon: Icons.storefront_outlined,
              onTap: onTryOn,
              isPrimary: false,
            ),
            _ActionButton(
              label: 'Add to Cart',
              icon: Icons.add_shopping_cart_outlined,
              onTap: onAddToCart,
              isPrimary: true,
            ),
            _ActionButton(
              label: 'Try Another',
              icon: Icons.add_outlined,
              onTap: onTryAnother,
              isPrimary: false,
            ),
          ],
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

        const SizedBox(height: 16),

        // Products in this generation
        _buildProductTags().animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildResultImage() {
    final url = generation.resultImageUrl;

    if (url.startsWith('data:image')) {
      final base64Str = url.split(',').last;
      final bytes = base64Decode(base64Str);
      return Image.memory(bytes, fit: BoxFit.cover, width: double.infinity, height: 360);
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 360,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: AppColors.canvasParchment,
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.accentPurple,
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        color: AppColors.canvasParchment,
        child: const Icon(Icons.error_outline, color: AppColors.inkMuted48, size: 48),
      ),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _InfoChip(
          icon: Icons.timer_outlined,
          label: generation.formattedTime,
        ),
        const SizedBox(width: 12),
        _InfoChip(
          icon: Icons.auto_awesome_outlined,
          label: generation.modelUsed.toUpperCase(),
        ),
        const SizedBox(width: 12),
        _InfoChip(
          icon: Icons.auto_fix_high_outlined,
          label: 'Qwen-VL Enhanced',
        ),
      ],
    );
  }

  Widget _buildProductTags() {
    if (generation.products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Products in this look',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.inkMuted48,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: generation.products.map((product) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accentPurple.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (product.imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        product.imageUrl,
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.checkroom, size: 16),
                      ),
                    )
                  else
                    const Icon(Icons.checkroom, size: 16, color: AppColors.accentPurple),
                  const SizedBox(width: 8),
                  Text(
                    product.name,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '₹${product.price}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentPurple,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accentPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentPurple.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.accentPurple),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.accentPurple,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.accentPurple : AppColors.surfaceTile1,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isPrimary ? AppColors.accentPurple : AppColors.dividerSoft,
            width: isPrimary ? 0 : 1.5,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.accentPurple.withOpacity(0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isPrimary ? Colors.white : AppColors.ink,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick action button for the studio
class StudioActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isExpanded;

  const StudioActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.foregroundColor,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isExpanded ? 20 : 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.accentPurple,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: (backgroundColor ?? AppColors.accentPurple).withOpacity(0.3),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: foregroundColor ?? Colors.white,
            ),
            if (isExpanded) const SizedBox(width: 10),
            if (isExpanded)
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: foregroundColor ?? Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}