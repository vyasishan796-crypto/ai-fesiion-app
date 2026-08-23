import 'package:flutter/material.dart';

enum MeasurementSource { aiEstimated, userEntered }

class BodyMeasurement {
  final String name;
  final double? value;
  final String unit;
  final MeasurementSource source;
  final double confidence;
  final String? icon;

  const BodyMeasurement({
    required this.name,
    this.value,
    this.unit = 'cm',
    this.source = MeasurementSource.aiEstimated,
    this.confidence = 0.0,
    this.icon,
  });

  BodyMeasurement copyWith({
    String? name,
    double? value,
    String? unit,
    MeasurementSource? source,
    double? confidence,
    String? icon,
  }) {
    return BodyMeasurement(
      name: name ?? this.name,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      source: source ?? this.source,
      confidence: confidence ?? this.confidence,
      icon: icon ?? this.icon,
    );
  }

  String get displayValue {
    if (value == null) return '--';
    return '${value!.toStringAsFixed(1)}';
  }

  String get sourceLabel {
    switch (source) {
      case MeasurementSource.aiEstimated:
        return 'AI Estimated';
      case MeasurementSource.userEntered:
        return 'User Entered';
    }
  }

  Color get confidenceColor {
    if (confidence >= 0.8) return const Color(0xFF10B981);
    if (confidence >= 0.5) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  bool get isHighConfidence => confidence >= 0.8;
}

class FitProfile {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<BodyMeasurement> measurements;
  final String? frontImagePath;
  final String? sideImagePath;
  final bool hasCalibration;
  final double? knownHeight;
  final Map<String, String> sizeRecommendations;
  final String gender;

  const FitProfile({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.measurements,
    this.frontImagePath,
    this.sideImagePath,
    this.hasCalibration = false,
    this.knownHeight,
    this.sizeRecommendations = const {},
    this.gender = 'Men',
  });

  FitProfile copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<BodyMeasurement>? measurements,
    String? frontImagePath,
    String? sideImagePath,
    bool? hasCalibration,
    double? knownHeight,
    Map<String, String>? sizeRecommendations,
    String? gender,
  }) {
    return FitProfile(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      measurements: measurements ?? this.measurements,
      frontImagePath: frontImagePath ?? this.frontImagePath,
      sideImagePath: sideImagePath ?? this.sideImagePath,
      hasCalibration: hasCalibration ?? this.hasCalibration,
      knownHeight: knownHeight ?? this.knownHeight,
      sizeRecommendations: sizeRecommendations ?? this.sizeRecommendations,
      gender: gender ?? this.gender,
    );
  }

  BodyMeasurement? getMeasurement(String name) {
    try {
      return measurements.firstWhere((m) => m.name == name);
    } catch (_) {
      return null;
    }
  }

  String get topSize {
    final chest = getMeasurement('Chest');
    if (chest?.value == null) return 'M';
    final c = chest!.value!;
    if (c < 88) return 'XS';
    if (c < 96) return 'S';
    if (c < 104) return 'M';
    if (c < 112) return 'L';
    if (c < 120) return 'XL';
    return 'XXL';
  }

  String get bottomSize {
    final waist = getMeasurement('Waist');
    if (waist?.value == null) return '32';
    final w = waist!.value!;
    if (w < 72) return '28';
    if (w < 78) return '30';
    if (w < 84) return '32';
    if (w < 90) return '34';
    if (w < 96) return '36';
    return '38';
  }
}

class ImageQualityResult {
  final bool isFullBodyVisible;
  final bool isHeadVisible;
  final bool isFeetVisible;
  final bool isLightingGood;
  final bool isSharpnessGood;
  final bool isAngleGood;
  final bool isPersonSeparated;
  final bool isPoseVisible;
  final bool hasOcclusion;
  final double overallScore;
  final String? errorMessage;

  const ImageQualityResult({
    this.isFullBodyVisible = false,
    this.isHeadVisible = false,
    this.isFeetVisible = false,
    this.isLightingGood = false,
    this.isSharpnessGood = false,
    this.isAngleGood = false,
    this.isPersonSeparated = false,
    this.isPoseVisible = false,
    this.hasOcclusion = false,
    this.overallScore = 0.0,
    this.errorMessage,
  });

  bool get isAcceptable => overallScore >= 0.6 && isFullBodyVisible;

  List<String> get issues {
    final list = <String>[];
    if (!isFullBodyVisible) list.add('Full body not visible');
    if (!isHeadVisible) list.add('Head not visible');
    if (!isFeetVisible) list.add('Feet not visible');
    if (!isLightingGood) list.add('Poor lighting');
    if (!isSharpnessGood) list.add('Image too blurry');
    if (!isAngleGood) list.add('Camera angle not optimal');
    if (hasOcclusion) list.add('Body partially obstructed');
    return list;
  }
}

class PoseLandmark {
  final String name;
  final Offset position;
  final double confidence;

  const PoseLandmark({
    required this.name,
    required this.position,
    this.confidence = 0.0,
  });
}

class SizeRecommendation {
  final String category;
  final String recommendedSize;
  final double matchScore;
  final String? bestMatch;
  final String? confidence;

  const SizeRecommendation({
    required this.category,
    required this.recommendedSize,
    this.matchScore = 0.0,
    this.bestMatch,
    this.confidence,
  });
}

class OutfitSuggestion {
  final String name;
  final String description;
  final String occasion;
  final String fitType;
  final List<String> items;
  final String? imageUrl;

  const OutfitSuggestion({
    required this.name,
    required this.description,
    required this.occasion,
    required this.fitType,
    required this.items,
    this.imageUrl,
  });
}
