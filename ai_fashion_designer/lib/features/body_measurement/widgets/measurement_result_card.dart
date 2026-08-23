import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../models/body_measurement.dart';
import 'confidence_indicator.dart';

class MeasurementResultCard extends StatelessWidget {
  final BodyMeasurement measurement;
  final VoidCallback? onEdit;

  const MeasurementResultCard({
    super.key,
    required this.measurement,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                measurement.icon ?? '📏',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  measurement.name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      measurement.displayValue,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ConfidenceIndicator(confidence: measurement.confidence),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  measurement.sourceLabel,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: measurement.source == MeasurementSource.userEntered
                        ? AppColors.primary
                        : AppColors.inkMuted,
                    fontWeight: measurement.source == MeasurementSource.userEntered
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                onEdit?.call();
              },
              icon: Icon(
                Icons.edit_outlined,
                color: AppColors.inkMuted,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}
