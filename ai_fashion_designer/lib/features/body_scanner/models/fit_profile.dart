import 'package:flutter/material.dart';

class Measurement {
  final String name;
  final double? value;
  final String unit;
  final bool isEstimated;
  final double confidence;

  const Measurement({
    required this.name,
    this.value,
    this.unit = 'cm',
    this.isEstimated = true,
    this.confidence = 0.0,
  });

  Measurement copyWith({
    String? name,
    double? value,
    String? unit,
    bool? isEstimated,
    double? confidence,
  }) {
    return Measurement(
      name: name ?? this.name,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      isEstimated: isEstimated ?? this.isEstimated,
      confidence: confidence ?? this.confidence,
    );
  }

  String get displayValue {
    if (value == null) return '--';
    return '${value!.toStringAsFixed(1)} $unit';
  }

  Color get confidenceColor {
    if (confidence >= 0.8) return const Color(0xFF10B981);
    if (confidence >= 0.5) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}

class FitProfile {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Measurement> measurements;
  final String recommendedTopSize;
  final String recommendedBottomSize;
  final String fitPreference;
  final List<String> recommendedFits;
  final Map<String, String> garmentPreferences;

  const FitProfile({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.measurements,
    this.recommendedTopSize = 'M',
    this.recommendedBottomSize = '32',
    this.fitPreference = 'Regular',
    this.recommendedFits = const ['Regular', 'Relaxed'],
    this.garmentPreferences = const {},
  });

  FitProfile copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Measurement>? measurements,
    String? recommendedTopSize,
    String? recommendedBottomSize,
    String? fitPreference,
    List<String>? recommendedFits,
    Map<String, String>? garmentPreferences,
  }) {
    return FitProfile(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      measurements: measurements ?? this.measurements,
      recommendedTopSize: recommendedTopSize ?? this.recommendedTopSize,
      recommendedBottomSize: recommendedBottomSize ?? this.recommendedBottomSize,
      fitPreference: fitPreference ?? this.fitPreference,
      recommendedFits: recommendedFits ?? this.recommendedFits,
      garmentPreferences: garmentPreferences ?? this.garmentPreferences,
    );
  }

  Measurement? getMeasurement(String name) {
    try {
      return measurements.firstWhere((m) => m.name == name);
    } catch (_) {
      return null;
    }
  }
}

class ScanResult {
  final bool success;
  final String? imagePath;
  final List<Offset>? poseLandmarks;
  final double poseConfidence;
  final double lightingQuality;
  final double scanQuality;
  final String? errorMessage;
  final Map<String, dynamic>? estimatedMeasurements;

  const ScanResult({
    required this.success,
    this.imagePath,
    this.poseLandmarks,
    this.poseConfidence = 0.0,
    this.lightingQuality = 0.0,
    this.scanQuality = 0.0,
    this.errorMessage,
    this.estimatedMeasurements,
  });

  ScanResult copyWith({
    bool? success,
    String? imagePath,
    List<Offset>? poseLandmarks,
    double? poseConfidence,
    double? lightingQuality,
    double? scanQuality,
    String? errorMessage,
    Map<String, dynamic>? estimatedMeasurements,
  }) {
    return ScanResult(
      success: success ?? this.success,
      imagePath: imagePath ?? this.imagePath,
      poseLandmarks: poseLandmarks ?? this.poseLandmarks,
      poseConfidence: poseConfidence ?? this.poseConfidence,
      lightingQuality: lightingQuality ?? this.lightingQuality,
      scanQuality: scanQuality ?? this.scanQuality,
      errorMessage: errorMessage ?? this.errorMessage,
      estimatedMeasurements: estimatedMeasurements ?? this.estimatedMeasurements,
    );
  }

  String get qualityLabel {
    if (scanQuality >= 0.8) return 'Excellent';
    if (scanQuality >= 0.6) return 'Good';
    if (scanQuality >= 0.4) return 'Fair';
    return 'Poor';
  }

  Color get qualityColor {
    if (scanQuality >= 0.8) return const Color(0xFF10B981);
    if (scanQuality >= 0.6) return const Color(0xFF3B82F6);
    if (scanQuality >= 0.4) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}

class OutfitRecommendation {
  final String name;
  final String description;
  final String fitType;
  final String occasion;
  final String? imageUrl;
  final List<String> availableSizes;
  final String whyItWorks;

  const OutfitRecommendation({
    required this.name,
    required this.description,
    required this.fitType,
    required this.occasion,
    this.imageUrl,
    this.availableSizes = const [],
    this.whyItWorks = '',
  });
}
