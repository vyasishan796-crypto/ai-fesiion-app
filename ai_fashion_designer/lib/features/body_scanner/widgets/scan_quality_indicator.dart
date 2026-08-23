import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class ScanQualityIndicator extends StatelessWidget {
  final double quality;
  final String label;
  final bool showDetails;

  const ScanQualityIndicator({
    super.key,
    required this.quality,
    this.label = 'Scan Quality',
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _qualityColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _qualityIcon,
                  color: _qualityColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      _qualityLabel,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _qualityColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(quality * 100).toInt()}%',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _qualityColor,
                ),
              ),
            ],
          ),
          if (showDetails) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: quality,
                backgroundColor: AppColors.lightGrey,
                valueColor: AlwaysStoppedAnimation<Color>(_qualityColor),
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color get _qualityColor {
    if (quality >= 0.8) return const Color(0xFF10B981);
    if (quality >= 0.6) return const Color(0xFF3B82F6);
    if (quality >= 0.4) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String get _qualityLabel {
    if (quality >= 0.8) return 'Excellent';
    if (quality >= 0.6) return 'Good';
    if (quality >= 0.4) return 'Fair';
    return 'Needs Improvement';
  }

  IconData get _qualityIcon {
    if (quality >= 0.8) return Icons.check_circle;
    if (quality >= 0.6) return Icons.info_outline;
    if (quality >= 0.4) return Icons.warning_amber;
    return Icons.error_outline;
  }
}
