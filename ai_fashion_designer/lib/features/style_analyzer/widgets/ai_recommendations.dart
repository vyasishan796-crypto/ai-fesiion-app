import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class AiRecommendations extends StatelessWidget {
  final List<String> recommendations;

  const AiRecommendations({super.key, required this.recommendations});

  static const _icons = [
    Icons.auto_awesome,
    Icons.palette,
    Icons.style,
    Icons.checkroom,
    Icons.tune,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFF7C4DFF), size: 20),
            const SizedBox(width: 8),
            Text(
              'AI Suggestions',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1D1D1F),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(recommendations.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F6FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE8E0FF)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C4DFF).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _icons[index % _icons.length],
                      size: 16,
                      color: const Color(0xFF7C4DFF),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      recommendations[index],
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF333333),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(
                  delay: Duration(milliseconds: 80 * index),
                  duration: 400.ms,
                ).slideX(begin: 0.08, duration: 400.ms),
          );
        }),
      ],
    );
  }
}
