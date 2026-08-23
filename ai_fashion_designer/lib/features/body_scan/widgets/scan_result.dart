import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/body_scan_service.dart';

class ScanResult extends StatelessWidget {
  final BodyProfile? profile;
  final bool isLoading;

  const ScanResult({
    super.key,
    this.profile,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoading();
    }

    if (profile == null) {
      return _buildPlaceholder();
    }

    return _buildProfile();
  }

  Widget _buildLoading() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.canvasParchment,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
              const SizedBox(height: 16),
              Text(
                'Analyzing your body...',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  color: AppColors.inkMuted48,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.canvasParchment,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.straighten,
            size: 48,
            color: AppColors.inkMuted48,
          ),
          const SizedBox(height: 12),
          Text(
            'Upload a full body photo to scan',
            style: GoogleFonts.inter(
              fontSize: 17,
              color: AppColors.inkMuted48,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Body shape badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Body Shape: ${profile!.bodyShape}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Measurements
        Text(
          'Your Measurements',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 12),

        _buildMeasurementRow('Shoulder', '${profile!.shoulderWidth}"'),
        _buildMeasurementRow('Torso', '${profile!.torsoLength}"'),
        _buildMeasurementRow('Waist', '${profile!.waistSize}"'),
        _buildMeasurementRow('Hips', '${profile!.hipSize}"'),
        _buildMeasurementRow('Leg Length', '${profile!.legLength}"'),
        _buildMeasurementRow('Arm Length', '${profile!.armLength}"'),

        const SizedBox(height: 24),

        // Recommended sizes
        Text(
          'Recommended Sizes',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 12),

        ...profile!.recommendedSizes.entries.map((entry) {
          return _buildSizeRow(entry.key, entry.value);
        }),

        const SizedBox(height: 16),

        // Disclaimer
        Text(
          '* Measurements are estimates based on photo analysis. For accurate measurements, use a measuring tape.',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.inkMuted48,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildMeasurementRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 17,
              color: AppColors.ink,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeRow(String category, String size) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            category,
            style: GoogleFonts.inter(
              fontSize: 17,
              color: AppColors.ink,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              size,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
