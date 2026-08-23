import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../models/chat_message.dart';

class OutfitRecommendationCard extends StatelessWidget {
  final OutfitCardData outfit;
  final String? caption;
  final bool showActions;

  const OutfitRecommendationCard({
    super.key,
    required this.outfit,
    this.caption,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
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
          _buildHeader(),
          _buildComponents(),
          if (showActions) _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.08), AppColors.primary.withOpacity(0.03)],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  outfit.style,
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ),
              const Spacer(),
              Icon(Icons.auto_awesome, size: 14, color: AppColors.primary.withOpacity(0.6)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            outfit.name,
            style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.event_outlined, size: 14, color: AppColors.inkMuted),
              const SizedBox(width: 4),
              Text(
                outfit.occasion,
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.inkMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            outfit.estimatedPrice,
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildComponents() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s Included',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.inkMuted),
          ),
          const SizedBox(height: 8),
          ...outfit.components.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                Container(width: 5, height: 5, decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(item, style: GoogleFonts.inter(fontSize: 13, color: AppColors.ink)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          _buildActionChip('Regenerate', Icons.refresh, () {}),
          _buildActionChip('Modify', Icons.tune, () {}),
          _buildActionChip('Save', Icons.bookmark_outline, () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Outfit saved!'), backgroundColor: AppColors.success),
            );
          }),
          _buildActionChip('Try-On', Icons.checkroom, () {}),
          _buildActionChip('Shop', Icons.shopping_bag_outlined, () {}),
        ],
      ),
    );
  }

  Widget _buildActionChip(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.ink)),
          ],
        ),
      ),
    );
  }
}
