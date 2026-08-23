import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/body_measurement.dart';
import 'measurement_engine.dart';

class BodyMeasurementService {
  static final BodyMeasurementService _instance = BodyMeasurementService._();
  factory BodyMeasurementService() => _instance;
  BodyMeasurementService._();

  FitProfile? _currentProfile;
  final MeasurementEngine engine = MeasurementEngine();

  FitProfile? get currentProfile => _currentProfile;

  Future<FitProfile> analyzePhotos({
    String? frontImagePath,
    String? sideImagePath,
    double? knownHeight,
    String gender = 'Men',
  }) async {
    final measurements = await engine.estimateMeasurements(
      frontImagePath: frontImagePath,
      sideImagePath: sideImagePath,
      knownHeight: knownHeight,
    );

    _currentProfile = engine.createFitProfile(measurements).copyWith(
      frontImagePath: frontImagePath,
      sideImagePath: sideImagePath,
      gender: gender,
    );

    await _save();
    return _currentProfile!;
  }

  Future<void> updateMeasurements(List<BodyMeasurement> measurements) async {
    if (_currentProfile == null) return;
    _currentProfile = _currentProfile!.copyWith(
      measurements: measurements,
      updatedAt: DateTime.now(),
    );
    await _save();
  }

  Future<void> _save() async {
    if (_currentProfile == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'id': _currentProfile!.id,
        'createdAt': _currentProfile!.createdAt.toIso8601String(),
        'updatedAt': _currentProfile!.updatedAt.toIso8601String(),
        'frontImagePath': _currentProfile!.frontImagePath,
        'sideImagePath': _currentProfile!.sideImagePath,
        'gender': _currentProfile!.gender,
        'measurements': _currentProfile!.measurements.map((m) => {
          'name': m.name,
          'value': m.value,
          'unit': m.unit,
          'source': m.source.index,
          'confidence': m.confidence,
          'icon': m.icon,
        }).toList(),
      };
      await prefs.setString('body_measurement_profile', jsonEncode(data));
    } catch (e) {
      debugPrint('BodyMeasurementService save error: $e');
    }
  }

  Future<bool> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('body_measurement_profile');
      if (raw == null) return false;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final measurements = (data['measurements'] as List).map((m) => BodyMeasurement(
        name: m['name'] as String,
        value: (m['value'] as num?)?.toDouble(),
        unit: m['unit'] as String? ?? 'cm',
        source: MeasurementSource.values[m['source'] as int? ?? 0],
        confidence: (m['confidence'] as num?)?.toDouble() ?? 0.8,
        icon: m['icon'] as String?,
      )).toList();
      _currentProfile = FitProfile(
        id: data['id'] as String,
        createdAt: DateTime.parse(data['createdAt'] as String),
        updatedAt: DateTime.parse(data['updatedAt'] as String),
        measurements: measurements,
        frontImagePath: data['frontImagePath'] as String?,
        sideImagePath: data['sideImagePath'] as String?,
        gender: data['gender'] as String? ?? 'Men',
      );
      return true;
    } catch (e) {
      debugPrint('BodyMeasurementService load error: $e');
      return false;
    }
  }

  Future<void> deleteAll() async {
    _currentProfile = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('body_measurement_profile');
    } catch (e) {
      debugPrint('BodyMeasurementService delete error: $e');
    }
  }
}
