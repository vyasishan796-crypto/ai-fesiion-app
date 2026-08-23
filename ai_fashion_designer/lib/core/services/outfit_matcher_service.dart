import 'dart:convert';
import 'package:flutter/services.dart';
import '../../core/models/style_analysis.dart';
import '../constants/brand_images.dart';

class OutfitMatcherService {
  List<Map<String, dynamic>>? _outfits;

  Future<void> _loadOutfits() async {
    if (_outfits != null) return;
    try {
      final jsonStr = await rootBundle.loadString('assets/data/outfits.json');
      final List<dynamic> data = json.decode(jsonStr);
      _outfits = data.cast<Map<String, dynamic>>();
    } catch (e) {
      _outfits = [];
    }
  }

  Future<List<Map<String, dynamic>>> matchOutfits(
    StyleAnalysis analysis, {
    int limit = 10,
  }) async {
    await _loadOutfits();
    if (_outfits == null || _outfits!.isEmpty) return [];

    final scored = _outfits!.map((outfit) {
      final totalScore = _scoreOutfit(outfit, analysis);
      return {...outfit, '_matchScore': totalScore};
    }).toList();

    scored.sort((a, b) => (b['_matchScore'] as double).compareTo(a['_matchScore'] as double));

    return scored.take(limit).toList();
  }

  double _scoreOutfit(Map<String, dynamic> outfit, StyleAnalysis analysis) {
    double score = 0;
    score += _scoreStyle(outfit, analysis);
    score += _scoreSeason(outfit, analysis);
    score += _scoreOccasion(outfit, analysis);
    score += _scoreColors(outfit, analysis);
    return score;
  }

  double _scoreStyle(Map<String, dynamic> outfit, StyleAnalysis analysis) {
    final outfitStyle = (outfit['style'] ?? '').toString().toLowerCase();
    final analysisStyle = analysis.overallStyle.toLowerCase();
    if (analysisStyle == outfitStyle) return 30;
    if (analysisStyle.contains(outfitStyle) || outfitStyle.contains(analysisStyle)) return 20;
    if (_isStyleCompatible(analysisStyle, outfitStyle)) return 12;
    return 0;
  }

  bool _isStyleCompatible(String a, String b) {
    const compatibilities = {
      'minimal': ['classic', 'modern'],
      'classic': ['minimal', 'smart casual'],
      'streetwear': ['modern', 'casual'],
      'smart casual': ['classic', 'modern', 'minimal'],
      'modern': ['minimal', 'streetwear', 'smart casual'],
    };
    final compatList = compatibilities[a];
    return compatList?.contains(b) ?? false;
  }

  double _scoreSeason(Map<String, dynamic> outfit, StyleAnalysis analysis) {
    final outfitSeason = (outfit['season'] ?? '').toString().toLowerCase();
    if (outfitSeason == 'all season') return 15;
    final detectedSeason = _detectSeason(analysis);
    if (detectedSeason.isEmpty) return 10;
    if (detectedSeason == outfitSeason) return 25;
    return 5;
  }

  String _detectSeason(StyleAnalysis analysis) {
    final allText = '${analysis.overallStyle} ${analysis.clothing.join(" ")} ${analysis.fabric}'.toLowerCase();
    if (allText.contains('summer') || allText.contains('t-shirt') || allText.contains('shorts')) return 'summer';
    if (allText.contains('winter') || allText.contains('jacket') || allText.contains('coat')) return 'winter';
    if (allText.contains('monsoon') || allText.contains('rain')) return 'monsoon';
    return '';
  }

  double _scoreOccasion(Map<String, dynamic> outfit, StyleAnalysis analysis) {
    final outfitOccasion = (outfit['occasion'] ?? '').toString().toLowerCase();
    final analysisOccasions = analysis.occasions.map((e) => e.toLowerCase()).toList();
    if (analysisOccasions.any((o) => o == outfitOccasion)) return 25;
    if (analysisOccasions.any((o) => o.contains(outfitOccasion) || outfitOccasion.contains(o))) return 15;
    return 0;
  }

  double _scoreColors(Map<String, dynamic> outfit, StyleAnalysis analysis) {
    final outfitColors = (outfit['goodColors'] ?? '').toString().toLowerCase();
    final analysisColors = analysis.palette.map((c) => c.name.toLowerCase()).toList();
    double colorScore = 0;
    for (final color in analysisColors) {
      if (outfitColors.contains(color)) colorScore += 5;
    }
    return colorScore.clamp(0, 20).toDouble();
  }

  String getImageUrl(Map<String, dynamic> outfit, int index) {
    final top = (outfit['top'] ?? '').toString().toLowerCase();
    final bottom = (outfit['bottom'] ?? '').toString().toLowerCase();

    if (top.contains('shirt') || top.contains('polo')) {
      return BrandImages.shirtsList[index % BrandImages.shirtsList.length];
    }
    if (top.contains('t-shirt') || top.contains('tee')) {
      return BrandImages.tshirtsList[index % BrandImages.tshirtsList.length];
    }
    if (top.contains('jacket') || top.contains('hoodie')) {
      return BrandImages.jacketsList[index % BrandImages.jacketsList.length];
    }
    if (bottom.contains('jean') || bottom.contains('denim')) {
      return BrandImages.jeansList[index % BrandImages.jeansList.length];
    }
    return BrandImages.shirtsList[index % BrandImages.shirtsList.length];
  }
}
