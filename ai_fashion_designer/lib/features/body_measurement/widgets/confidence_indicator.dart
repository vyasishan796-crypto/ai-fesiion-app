import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class ConfidenceIndicator extends StatelessWidget {
  final double confidence;
  final bool showLabel;

  const ConfidenceIndicator({
    super.key,
    required this.confidence,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _confidenceColor,
            shape: BoxShape.circle,
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 6),
          Text(
            _confidenceLabel,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _confidenceColor,
            ),
          ),
        ],
      ],
    );
  }

  Color get _confidenceColor {
    if (confidence >= 0.8) return const Color(0xFF10B981);
    if (confidence >= 0.5) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String get _confidenceLabel {
    if (confidence >= 0.8) return 'High';
    if (confidence >= 0.5) return 'Medium';
    return 'Low';
  }
}
