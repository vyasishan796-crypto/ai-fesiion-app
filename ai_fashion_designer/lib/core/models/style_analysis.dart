import 'dart:ui';

class StyleAnalysis {
  final String overallStyle;
  final double styleScore;
  final List<String> clothing;
  final List<DetectedColor> palette;
  final String fabric;
  final List<String> occasions;
  final List<String> recommendations;
  final Map<String, int> scoreBreakdown;
  final String? scoreReason;

  const StyleAnalysis({
    required this.overallStyle,
    required this.styleScore,
    required this.clothing,
    required this.palette,
    required this.fabric,
    required this.occasions,
    required this.recommendations,
    this.scoreBreakdown = const {},
    this.scoreReason,
  });

  int get totalScore {
    if (scoreBreakdown.isEmpty) return (styleScore * 10).round().clamp(0, 100);
    return scoreBreakdown.values.isEmpty
        ? (styleScore * 10).round().clamp(0, 100)
        : (scoreBreakdown.values.reduce((a, b) => a + b) / scoreBreakdown.length).round();
  }
}

class DetectedColor {
  final String name;
  final Color color;
  final double percentage;

  const DetectedColor({
    required this.name,
    required this.color,
    required this.percentage,
  });
}
