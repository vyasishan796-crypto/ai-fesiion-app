import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class OutfitPersonalization extends StatelessWidget {
  const OutfitPersonalization({super.key});

  @override
  Widget build(BuildContext context) {
    final outfits = [
      {'name': 'College Look', 'icon': Icons.school, 'color': AppColors.primary},
      {'name': 'Formal Look', 'icon': Icons.business, 'color': AppColors.charcoal},
      {'name': 'Streetwear Look', 'icon': Icons.location_city, 'color': AppColors.accent},
      {'name': 'Wedding Look', 'icon': Icons.celebration, 'color': const Color(0xFFF59E0B)},
      {'name': 'Travel Look', 'icon': Icons.flight, 'color': AppColors.success},
      {'name': 'Casual Look', 'icon': Icons.weekend, 'color': const Color(0xFF6366F1)},
    ];

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.charcoal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'AI Outfit Personalization',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildHeader(),
            const SizedBox(height: 28),
            _buildOutfitGrid(context, outfits),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Outfits For Me',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Based on your fit profile, we recommend these outfit styles.',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: AppColors.inkSecondary,
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildOutfitGrid(BuildContext context, List<Map<String, dynamic>> outfits) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.0,
      ),
      itemCount: outfits.length,
      itemBuilder: (context, index) {
        final outfit = outfits[index];
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${outfit['name']} added to your style profile!', style: GoogleFonts.inter()),
                backgroundColor: AppColors.charcoal,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                action: SnackBarAction(label: 'View Outfits', textColor: AppColors.accentPurple, onPressed: () => context.push('/browse-outfits')),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (outfit['color'] as Color).withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (outfit['color'] as Color).withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: (outfit['color'] as Color).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    outfit['icon'] as IconData,
                    color: outfit['color'] as Color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  outfit['name'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 100 + index * 80)),
        );
      },
    );
  }
}
