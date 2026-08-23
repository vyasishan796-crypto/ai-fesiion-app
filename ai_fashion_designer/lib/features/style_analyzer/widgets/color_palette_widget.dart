import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/style_analysis.dart';

class ColorPaletteWidget extends StatelessWidget {
  final List<DetectedColor> colors;

  const ColorPaletteWidget({super.key, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color Palette',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1D1D1F),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(colors.length, (index) {
            final c = colors[index];
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  children: [
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: c.color,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: c.color == const Color(0xFFFFFFFF)
                              ? Colors.grey.shade200
                              : Colors.transparent,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: c.color.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      c.name,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1D1D1F),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '${c.percentage.round()}%',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(
                  delay: Duration(milliseconds: 80 * index),
                  duration: 350.ms,
                ).slideY(begin: 0.15, duration: 350.ms);
          }),
        ),
      ],
    );
  }
}
