import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/style_analysis.dart';
import 'score_explanation_sheet.dart';

class StyleBreakdownCard extends StatelessWidget {
  final StyleAnalysis analysis;

  const StyleBreakdownCard({super.key, required this.analysis});

  Color _scoreColor(int score) {
    if (score >= 90) return const Color(0xFF34C759);
    if (score >= 80) return const Color(0xFF1D1D1F);
    if (score >= 70) return const Color(0xFFFF9500);
    return const Color(0xFFFF3B30);
  }

  String _factorLabel(String key) {
    const labels = {
      'personalStyle': 'Personal Style',
      'occasion': 'Occasion',
      'color': 'Color',
      'weather': 'Weather',
      'fit': 'Fit',
      'budget': 'Budget',
    };
    return labels[key] ?? key;
  }

  IconData _factorIcon(String key) {
    const icons = {
      'personalStyle': Icons.style_outlined,
      'occasion': Icons.event_outlined,
      'color': Icons.palette_outlined,
      'weather': Icons.wb_sunny_outlined,
      'fit': Icons.straighten_outlined,
      'budget': Icons.payments_outlined,
    };
    return icons[key] ?? Icons.circle;
  }

  @override
  Widget build(BuildContext context) {
    final totalScore = analysis.totalScore;
    final color = _scoreColor(totalScore);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1D1F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: totalScore / 100,
                      strokeWidth: 6,
                      backgroundColor: Colors.white.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation(color),
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$totalScore',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '/ 100',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OUTFIT SCORE',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.5),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      analysis.overallStyle,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    if (analysis.scoreReason != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        analysis.scoreReason!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (analysis.scoreBreakdown.isNotEmpty) ...[
            Divider(height: 1, color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 12),
            ...analysis.scoreBreakdown.entries.map((entry) {
              final entryColor = _scoreColor(entry.value);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(_factorIcon(entry.key), size: 14, color: Colors.white.withOpacity(0.6)),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 80,
                      child: Text(
                        _factorLabel(entry.key),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: entry.value / 100,
                          minHeight: 6,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation(entryColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${entry.value}',
                        textAlign: TextAlign.right,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: entryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => ScoreExplanationSheet.show(context, analysis),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.help_outline, size: 16, color: Colors.white.withOpacity(0.7)),
                  const SizedBox(width: 6),
                  Text(
                    'WHY THIS SCORE?',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1);
  }
}
