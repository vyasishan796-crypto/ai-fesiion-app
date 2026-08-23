class DetectedSkinTone {
  final String tone;
  final String undertone;
  final double toneConfidence;
  final double undertoneConfidence;
  final double L_median;
  final double a_median;
  final double b_median;
  final int validPixelCount;
  final double stdDev;
  final String primaryColor;
  final String secondaryColor;
  final String contrastLevel;
  final String seasonalPalette;

  DetectedSkinTone({
    required this.tone,
    required this.undertone,
    required this.toneConfidence,
    required this.undertoneConfidence,
    required this.L_median,
    required this.a_median,
    required this.b_median,
    required this.validPixelCount,
    required this.stdDev,
    required this.primaryColor,
    required this.secondaryColor,
    required this.contrastLevel,
    required this.seasonalPalette,
  });

  factory DetectedSkinTone.fromJson(Map<String, dynamic> json) {
    return DetectedSkinTone(
      tone: json['tone'] ?? 'Neutral',
      undertone: json['undertone'] ?? 'Neutral',
      toneConfidence: (json['tone_confidence'] ?? json['toneConfidence'] ?? 0.0).toDouble(),
      undertoneConfidence: (json['undertone_confidence'] ?? json['undertoneConfidence'] ?? 0.0).toDouble(),
      L_median: (json['L_median'] ?? json['l_median'] ?? 0.0).toDouble(),
      a_median: (json['a_median'] ?? 0.0).toDouble(),
      b_median: (json['b_median'] ?? 0.0).toDouble(),
      validPixelCount: json['valid_pixel_count'] ?? json['validPixelCount'] ?? 0,
      stdDev: (json['std_dev'] ?? json['stdDev'] ?? 0.0).toDouble(),
      primaryColor: json['primary_color'] ?? json['primaryColor'] ?? '#7C4DFF',
      secondaryColor: json['secondary_color'] ?? json['secondaryColor'] ?? '#FFD700',
      contrastLevel: json['contrast_level'] ?? json['contrastLevel'] ?? 'medium',
      seasonalPalette: json['seasonal_palette'] ?? json['seasonalPalette'] ?? 'Universal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tone': tone,
      'undertone': undertone,
      'tone_confidence': toneConfidence,
      'undertone_confidence': undertoneConfidence,
      'L_median': L_median,
      'a_median': a_median,
      'b_median': b_median,
      'valid_pixel_count': validPixelCount,
      'std_dev': stdDev,
      'primary_color': primaryColor,
      'secondary_color': secondaryColor,
      'contrast_level': contrastLevel,
      'seasonal_palette': seasonalPalette,
    };
  }

  @override
  String toString() {
    return 'DetectedSkinTone{tone: $tone, undertone: $undertone, confidence: ${toneConfidence + undertoneConfidence}/2}';
  }
}

class BodyProportions {
  final String silhouette;
  final double confidence;
  final double shoulderHipRatio;
  final double torsoLegRatio;
  final double upperBodyRatio;

  BodyProportions({
    required this.silhouette,
    required this.confidence,
    required this.shoulderHipRatio,
    required this.torsoLegRatio,
    required this.upperBodyRatio,
  });

  factory BodyProportions.fromJson(Map<String, dynamic> json) {
    return BodyProportions(
      silhouette: json['silhouette'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      shoulderHipRatio: (json['shoulder_hip_ratio'] ?? json['shoulderHipRatio'] ?? 1.0).toDouble(),
      torsoLegRatio: (json['torso_leg_ratio'] ?? json['torsoLegRatio'] ?? 1.0).toDouble(),
      upperBodyRatio: (json['upper_body_ratio'] ?? json['upperBodyRatio'] ?? 1.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'silhouette': silhouette,
      'confidence': confidence,
      'shoulder_hip_ratio': shoulderHipRatio,
      'torso_leg_ratio': torsoLegRatio,
      'upper_body_ratio': upperBodyRatio,
    };
  }

  @override
  String toString() {
    return 'BodyProportions{silhouette: $silhouette, ratio: ${shoulderHipRatio.toStringAsFixed(2)}';
  }
}

class ColorProfile {
  final String primaryColor;
  final String secondaryColor;
  final String accentColor;
  final String contrastLevel;
  final String seasonalPalette;

  ColorProfile({
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.contrastLevel,
    required this.seasonalPalette,
  });

  factory ColorProfile.fromJson(Map<String, dynamic> json) {
    return ColorProfile(
      primaryColor: json['primary_color'] ?? json['primaryColor'] ?? '#7C4DFF',
      secondaryColor: json['secondary_color'] ?? json['secondaryColor'] ?? '#FFD700',
      accentColor: json['accent_color'] ?? json['accentColor'] ?? '#7C4DFF',
      contrastLevel: json['contrast_level'] ?? json['contrastLevel'] ?? 'medium',
      seasonalPalette: json['seasonal_palette'] ?? json['seasonalPalette'] ?? 'Universal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary_color': primaryColor,
      'secondary_color': secondaryColor,
      'accent_color': accentColor,
      'contrast_level': contrastLevel,
      'seasonal_palette': seasonalPalette,
    };
  }

  @override
  String toString() => 'ColorProfile{primary: $primaryColor, seasonal: $seasonalPalette}';
}

class AppearanceAnalysis {
  final String id;
  final DetectedSkinTone skin;
  final BodyProportions body;
  final ColorProfile colorProfile;
  final String version;
  final double overallConfidence;
  final DateTime createdAt;
  final String occasion;

  AppearanceAnalysis({
    required this.id,
    required this.skin,
    required this.body,
    required this.colorProfile,
    required this.version,
    required this.overallConfidence,
    required this.createdAt,
    required this.occasion,
  });

  factory AppearanceAnalysis.fromJson(Map<String, dynamic> json) {
    final skinJson = json['skin'] is Map<String, dynamic> ? json['skin'] as Map<String, dynamic> : <String, dynamic>{};
    final bodyJson = json['body'] is Map<String, dynamic> ? json['body'] as Map<String, dynamic> : <String, dynamic>{};
    final colorJson = json['color_profile'] is Map<String, dynamic>
        ? json['color_profile'] as Map<String, dynamic>
        : (json['colorProfile'] is Map<String, dynamic> ? json['colorProfile'] as Map<String, dynamic> : <String, dynamic>{});

    final appearanceData = json['appearance'] is Map<String, dynamic> ? json['appearance'] as Map<String, dynamic> : json;

    final rawId = json['analysis_id'] ?? json['id'] ?? appearanceData['id'] ?? '';
    final rawVersion = json['version'] ?? appearanceData['version'] ?? 'appearance_v1';
    final rawConfidence = json['overall_confidence'] ?? json['overallConfidence'] ?? appearanceData['overall_confidence'] ?? 0.0;
    final rawOccasion = json['occasion'] ?? '';
    final rawCreatedAt = json['created_at'] ?? json['createdAt'] ?? appearanceData['created_at'] ?? DateTime.now().toIso8601String();

    return AppearanceAnalysis(
      id: rawId.toString(),
      skin: DetectedSkinTone.fromJson(skinJson),
      body: BodyProportions.fromJson(bodyJson),
      colorProfile: ColorProfile.fromJson(colorJson),
      version: rawVersion.toString(),
      overallConfidence: rawConfidence is double ? rawConfidence : double.tryParse(rawConfidence.toString()) ?? 0.0,
      createdAt: rawCreatedAt is DateTime ? rawCreatedAt : DateTime.tryParse(rawCreatedAt.toString()) ?? DateTime.now(),
      occasion: rawOccasion.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'analysis_id': id,
      'skin': skin.toJson(),
      'body': body.toJson(),
      'color_profile': colorProfile.toJson(),
      'version': version,
      'overall_confidence': overallConfidence,
      'created_at': createdAt.toIso8601String(),
      'occasion': occasion,
    };
  }

  @override
  String toString() =>
      'AppearanceAnalysis{v${version}, conf:${overallConfidence.toStringAsFixed(2)}}';
}
