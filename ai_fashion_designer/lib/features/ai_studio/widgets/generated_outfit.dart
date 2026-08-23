import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class GeneratedOutfit extends StatelessWidget {
  final String? imageUrl;
  final bool isLoading;
  final VoidCallback? onRegenerate;
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  final VoidCallback? onTryOn;

  const GeneratedOutfit({
    super.key,
    this.imageUrl,
    this.isLoading = false,
    this.onRegenerate,
    this.onSave,
    this.onShare,
    this.onTryOn,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLoading) _buildShimmer(),
        if (!isLoading && imageUrl != null) _buildResult(),
        if (!isLoading && imageUrl == null) _buildPlaceholder(),
      ],
    );
  }

  Widget _buildShimmer() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 28,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Creating your outfit...',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'AI is generating your image (~30 sec)',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.inkMuted,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withOpacity(0.1),
                offset: const Offset(0, 4),
                blurRadius: 20,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: _buildImage(),
          ),
        ),
        const SizedBox(height: 16),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildActionButton(
          label: 'Regenerate',
          icon: Icons.refresh,
          isPrimary: false,
          onTap: onRegenerate,
        ),
        _buildActionButton(
          label: 'Save',
          icon: Icons.bookmark_outline,
          isPrimary: true,
          onTap: onSave,
        ),
        _buildActionButton(
          label: 'Share',
          icon: Icons.share_outlined,
          isPrimary: false,
          onTap: onShare,
        ),
        _buildActionButton(
          label: 'Try On',
          icon: Icons.checkroom,
          isPrimary: false,
          onTap: onTryOn,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.lightGrey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isPrimary ? AppColors.white : AppColors.inkSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isPrimary ? AppColors.white : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_outlined,
              size: 24,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Select options and tap Generate',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl!.startsWith('data:image')) {
      final base64Str = imageUrl!.split(',').last;
      final bytes = base64Decode(base64Str);
      return Image.memory(bytes, fit: BoxFit.cover, width: double.infinity, height: 300);
    }
    if (imageUrl!.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 300,
        placeholder: (context, url) => Container(
          color: AppColors.lightGrey,
          child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppColors.lightGrey,
          child: const Icon(Icons.error_outline, color: AppColors.mediumGrey, size: 48),
        ),
      );
    }
    return Container(
      color: AppColors.lightGrey,
      child: const Icon(Icons.checkroom_outlined, color: AppColors.mediumGrey, size: 48),
    );
  }
}
