import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/models/outfit_dataset.dart';

class OutfitCard extends StatelessWidget {
  final OutfitDataset outfit;
  final bool isSaved;
  final bool showSaveButton;
  final bool showShareButton;
  final bool showGenerateButton;
  final VoidCallback? onTap;
  final VoidCallback? onGenerateImage;
  final VoidCallback? onToggleSave;
  final VoidCallback? onShare;
  final String? savedImageUrl;

  const OutfitCard({
    super.key,
    required this.outfit,
    this.isSaved = false,
    this.showSaveButton = true,
    this.showShareButton = true,
    this.showGenerateButton = true,
    this.onTap,
    this.onGenerateImage,
    this.onToggleSave,
    this.onShare,
    this.savedImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (savedImageUrl != null && savedImageUrl!.isNotEmpty)
            _buildSavedImage(),
          if (savedImageUrl == null || savedImageUrl!.isEmpty)
            _buildOutfitItems(),
          const SizedBox(height: 12),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _getOccasionColor(outfit.occasion).withOpacity(0.1),
            borderRadius: AppRadius.pill,
          ),
          child: Text(
            outfit.occasion,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getOccasionColor(outfit.occasion),
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (outfit.style != null && outfit.style!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.canvasParchment,
              borderRadius: AppRadius.pill,
            ),
            child: Text(
              outfit.style!,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.inkMuted48,
              ),
            ),
          ),
        const Spacer(),
        if (outfit.score != null)
          Row(
            children: [
              Icon(Icons.star, size: 14, color: AppColors.primary),
              const SizedBox(width: 2),
              Text(
                '${outfit.score}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSavedImage() {
    return ClipRRect(
      borderRadius: AppRadius.sm,
      child: Image.network(
        savedImageUrl!,
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: double.infinity,
          height: 200,
          color: AppColors.canvasParchment,
          child: const Icon(Icons.broken_image, color: AppColors.inkMuted48),
        ),
      ),
    );
  }

  Widget _buildOutfitItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (outfit.top != null)
          _buildItem('Top', outfit.top!, Icons.checkroom, Colors.blue),
        if (outfit.bottom != null)
          _buildItem('Bottom', outfit.bottom!, Icons.straighten, Colors.brown),
        if (outfit.shoes != null)
          _buildItem('Shoes', outfit.shoes!, Icons.directions_walk, Colors.green),
        if (outfit.layer != null && outfit.layer != 'None')
          _buildItem('Layer', outfit.layer!, Icons.layers, Colors.purple),
        if (outfit.accessory != null && outfit.accessory != 'None')
          _buildItem('Accessory', outfit.accessory!, Icons.watch, Colors.orange),
      ],
    );
  }

  Widget _buildItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color.withOpacity(0.7)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.inkMuted48,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.ink,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        if (outfit.budget != null && outfit.budget!.isNotEmpty)
          Text(
            '₹${outfit.budget}',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.ink,
            ),
          ),
        if (outfit.season != null && outfit.season!.isNotEmpty) ...[
          const SizedBox(width: 12),
          Icon(Icons.wb_sunny_outlined, size: 14, color: AppColors.inkMuted48),
          const SizedBox(width: 4),
          Text(
            outfit.season!,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.inkMuted48,
            ),
          ),
        ],
        const Spacer(),
        if (showSaveButton) ...[
          _buildActionButton(
            icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: isSaved ? AppColors.primary : AppColors.inkMuted,
            onTap: onToggleSave,
          ),
          const SizedBox(width: 8),
        ],
        if (showShareButton) ...[
          _buildActionButton(
            icon: Icons.share_outlined,
            color: AppColors.inkMuted,
            onTap: onShare,
          ),
          const SizedBox(width: 8),
        ],
        if (showGenerateButton)
          GestureDetector(
            onTap: onGenerateImage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.pill,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'AI Image',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Color _getOccasionColor(String occasion) {
    switch (occasion) {
      case 'College':
        return const Color(0xFF2196F3);
      case 'Office':
        return const Color(0xFF607D8B);
      case 'Party':
        return const Color(0xFF9C27B0);
      case 'Travel':
        return const Color(0xFF4CAF50);
      case 'Relax':
        return const Color(0xFFFF9800);
      default:
        return AppColors.primary;
    }
  }
}
