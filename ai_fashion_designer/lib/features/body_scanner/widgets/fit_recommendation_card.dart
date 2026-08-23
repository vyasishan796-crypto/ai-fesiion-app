import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../models/fit_profile.dart';

class FitRecommendationCard extends StatelessWidget {
  final OutfitRecommendation recommendation;
  final VoidCallback? onTryOn;

  const FitRecommendationCard({
    super.key,
    required this.recommendation,
    this.onTryOn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getFitColor(recommendation.fitType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getFitIcon(recommendation.fitType),
                  color: _getFitColor(recommendation.fitType),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.name,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      recommendation.fitType,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _getFitColor(recommendation.fitType),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            recommendation.description,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.inkSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              recommendation.whyItWorks,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.inkSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: recommendation.availableSizes.map((size) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  size,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.inkSecondary,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                onTryOn?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Try This Fit',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getFitColor(String fit) {
    switch (fit) {
      case 'Oversized': return const Color(0xFF7C4DFF);
      case 'Relaxed': return const Color(0xFF10B981);
      case 'Regular': return const Color(0xFF3B82F6);
      case 'Tailored': return const Color(0xFFF59E0B);
      default: return AppColors.primary;
    }
  }

  IconData _getFitIcon(String fit) {
    switch (fit) {
      case 'Oversized': return Icons.checkroom;
      case 'Relaxed': return Icons.weekend;
      case 'Regular': return Icons.straighten;
      case 'Tailored': return Icons.content_cut;
      default: return Icons.checkroom;
    }
  }
}
