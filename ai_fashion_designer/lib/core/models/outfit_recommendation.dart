import 'dart:convert';
import 'appearance_profile.dart';

class OutfitRecommendation {
  final String id;
  final String userId;
  final AppearanceAnalysis appearance;
  final Map<String, dynamic> outfitData;
  final double score;
  final Map<String, double> scores;
  final String explanation;
  final bool wardrobeUsed;
  final String occasion;
  final DateTime createdAt;

  OutfitRecommendation({
    required this.id,
    required this.userId,
    required this.appearance,
    required this.outfitData,
    required this.score,
    required this.scores,
    required this.explanation,
    required this.wardrobeUsed,
    required this.occasion,
    required this.createdAt,
  });

  factory OutfitRecommendation.fromJson(Map<String, dynamic> json) {
    // Parse the scores map
    Map<String, double> parsedScores = {};
    if (json['scores'] != null && json['scores'] is Map) {
      final scoresMap = json['scores'] as Map<dynamic, dynamic>;
      scoresMap.forEach((k, v) {
        parsedScores[k] = (v ?? 0.0).toDouble();
      });
    }

    return OutfitRecommendation(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      appearance: AppearanceAnalysis.fromJson(json['appearance'] ?? {}),
      outfitData: json['outfitData'] != null ? Map<String, dynamic>.from(json['outfitData']) : {},
      score: (json['score'] ?? 0.0).toDouble(),
      scores: parsedScores,
      explanation: json['explanation'] ?? '',
      wardrobeUsed: json['wardrobeUsed'] ?? false,
      occasion: json['occasion'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'appearance': appearance.toJson(),
      'outfitData': outfitData,
      'score': score,
      'scores': scores,
      'explanation': explanation,
      'wardrobeUsed': wardrobeUsed,
      'occasion': occasion,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'OutfitRecommendation{id: $id, score: $score, wardrobe: $wardrobeUsed}';
}