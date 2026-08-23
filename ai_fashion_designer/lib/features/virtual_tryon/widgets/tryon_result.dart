import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';

class TryOnResult extends StatelessWidget {
  final String? resultImageUrl;
  final bool isLoading;
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  final VoidCallback? onTryAnother;

  const TryOnResult({
    super.key,
    this.resultImageUrl,
    this.isLoading = false,
    this.onSave,
    this.onShare,
    this.onTryAnother,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Result',
          style: GoogleFonts.inter(
            fontSize: 21,
            fontWeight: FontWeight.w600,
            color: AppColors.bodyOnDark,
            letterSpacing: 0.231,
          ),
        ),
        const SizedBox(height: 16),
        if (isLoading) _buildShimmer(),
        if (!isLoading && resultImageUrl != null) _buildResult(),
        if (!isLoading && resultImageUrl == null) _buildPlaceholder(),
      ],
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceTile2,
      highlightColor: AppColors.surfaceTile1,
      child: Container(
        width: double.infinity,
        height: 350,
        decoration: BoxDecoration(
          color: AppColors.surfaceTile2,
          borderRadius: AppRadius.sm,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checkroom,
              size: 48,
              color: AppColors.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Creating your try-on...',
              style: GoogleFonts.inter(
                fontSize: 17,
                color: AppColors.bodyMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This may take 15-30 seconds',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.bodyMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 350,
          decoration: BoxDecoration(
            borderRadius: AppRadius.sm,
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withOpacity(0.22),
                offset: const Offset(3, 5),
                blurRadius: 30,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: AppRadius.sm,
            child: CachedNetworkImage(
              imageUrl: resultImageUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.surfaceTile2,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.surfaceTile2,
                child: const Icon(
                  Icons.error_outline,
                  color: AppColors.bodyMuted,
                  size: 48,
                ),
              ),
            ),
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
          label: 'Save',
          icon: Icons.bookmark_outline,
          isPrimary: true,
          onTap: onSave,
        ),
        _buildActionButton(
          label: 'Share',
          icon: Icons.share_outlined,
          isPrimary: true,
          onTap: onShare,
        ),
        _buildActionButton(
          label: 'Try Another',
          icon: Icons.refresh,
          isPrimary: false,
          onTap: onTryAnother,
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
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.transparent,
          borderRadius: AppRadius.pill,
          border: isPrimary ? null : Border.all(color: AppColors.primary),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isPrimary ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isPrimary ? Colors.white : AppColors.primary,
                letterSpacing: -0.224,
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
        color: AppColors.surfaceTile2.withOpacity(0.3),
        borderRadius: AppRadius.sm,
        border: Border.all(
          color: AppColors.surfaceTile2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checkroom_outlined,
            size: 48,
            color: AppColors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Upload photo and select outfit to try on',
            style: GoogleFonts.inter(
              fontSize: 17,
              color: AppColors.bodyMuted,
            ),
          ),
        ],
      ),
    );
  }
}
