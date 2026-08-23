import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../models/body_measurement.dart';

class SizeRecommendationCard extends StatelessWidget {
  final SizeRecommendation recommendation;

  const SizeRecommendationCard({super.key, required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                recommendation.recommendedSize,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.category,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  recommendation.bestMatch ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.inkSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (recommendation.confidence != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getConfidenceColor(recommendation.confidence!).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                recommendation.confidence!,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _getConfidenceColor(recommendation.confidence!),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(String confidence) {
    switch (confidence) {
      case 'High': return const Color(0xFF10B981);
      case 'Medium': return const Color(0xFFF59E0B);
      default: return const Color(0xFFEF4444);
    }
  }
}
