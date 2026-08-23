import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StyleProfile {
  final String bodyType;
  final String skinTone;
  final List<String> preferredStyles;
  final List<String> preferredColors;
  final List<String> avoidColors;
  final List<String> occasions;
  final double minBudget;
  final double maxBudget;
  final List<String> preferredBrands;
  final List<String> preferredFabrics;
  final String gender;
  final int age;
  final String climate;

  const StyleProfile({
    this.bodyType = '',
    this.skinTone = '',
    this.preferredStyles = const [],
    this.preferredColors = const [],
    this.avoidColors = const [],
    this.occasions = const [],
    this.minBudget = 500,
    this.maxBudget = 5000,
    this.preferredBrands = const [],
    this.preferredFabrics = const [],
    this.gender = 'male',
    this.age = 22,
    this.climate = 'tropical',
  });

  StyleProfile copyWith({
    String? bodyType,
    String? skinTone,
    List<String>? preferredStyles,
    List<String>? preferredColors,
    List<String>? avoidColors,
    List<String>? occasions,
    double? minBudget,
    double? maxBudget,
    List<String>? preferredBrands,
    List<String>? preferredFabrics,
    String? gender,
    int? age,
    String? climate,
  }) {
    return StyleProfile(
      bodyType: bodyType ?? this.bodyType,
      skinTone: skinTone ?? this.skinTone,
      preferredStyles: preferredStyles ?? this.preferredStyles,
      preferredColors: preferredColors ?? this.preferredColors,
      avoidColors: avoidColors ?? this.avoidColors,
      occasions: occasions ?? this.occasions,
      minBudget: minBudget ?? this.minBudget,
      maxBudget: maxBudget ?? this.maxBudget,
      preferredBrands: preferredBrands ?? this.preferredBrands,
      preferredFabrics: preferredFabrics ?? this.preferredFabrics,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      climate: climate ?? this.climate,
    );
  }

  Map<String, dynamic> toMap() => {
    'bodyType': bodyType, 'skinTone': skinTone,
    'preferredStyles': preferredStyles, 'preferredColors': preferredColors,
    'avoidColors': avoidColors, 'occasions': occasions,
    'minBudget': minBudget, 'maxBudget': maxBudget,
    'preferredBrands': preferredBrands, 'preferredFabrics': preferredFabrics,
    'gender': gender, 'age': age, 'climate': climate,
  };

  factory StyleProfile.fromMap(Map<String, dynamic> m) => StyleProfile(
    bodyType: m['bodyType'] ?? '', skinTone: m['skinTone'] ?? '',
    preferredStyles: List<String>.from(m['preferredStyles'] ?? []),
    preferredColors: List<String>.from(m['preferredColors'] ?? []),
    avoidColors: List<String>.from(m['avoidColors'] ?? []),
    occasions: List<String>.from(m['occasions'] ?? []),
    minBudget: (m['minBudget'] ?? 500).toDouble(),
    maxBudget: (m['maxBudget'] ?? 5000).toDouble(),
    preferredBrands: List<String>.from(m['preferredBrands'] ?? []),
    preferredFabrics: List<String>.from(m['preferredFabrics'] ?? []),
    gender: m['gender'] ?? 'male', age: m['age'] ?? 22,
    climate: m['climate'] ?? 'tropical',
  );

  String toContextString() {
    final parts = <String>[];
    if (bodyType.isNotEmpty) parts.add('Body type: $bodyType');
    if (skinTone.isNotEmpty) parts.add('Skin tone: $skinTone');
    if (preferredStyles.isNotEmpty) parts.add('Styles: ${preferredStyles.join(", ")}');
    if (preferredColors.isNotEmpty) parts.add('Likes colors: ${preferredColors.join(", ")}');
    if (avoidColors.isNotEmpty) parts.add('Avoids colors: ${avoidColors.join(", ")}');
    if (preferredBrands.isNotEmpty) parts.add('Brands: ${preferredBrands.join(", ")}');
    if (preferredFabrics.isNotEmpty) parts.add('Fabrics: ${preferredFabrics.join(", ")}');
    parts.add('Budget: ₹${minBudget.toInt()} - ₹${maxBudget.toInt()}');
    parts.add('Gender: $gender, Age: $age');
    if (occasions.isNotEmpty) parts.add('Occasions: ${occasions.join(", ")}');
    parts.add('Climate: $climate');
    return parts.join('\n');
  }

  bool get isOnboarded => bodyType.isNotEmpty || preferredStyles.isNotEmpty;
}

class StyleProfileService {
  static final StyleProfileService _instance = StyleProfileService._();
  factory StyleProfileService() => _instance;
  StyleProfileService._();

  StyleProfile _profile = const StyleProfile();
  StyleProfile get profile => _profile;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('style_profile');
      if (json != null) {
        _profile = StyleProfile.fromMap(jsonDecode(json));
      }
    } catch (e) {
      debugPrint('[StyleProfile] Load error: $e');
    }
  }

  Future<void> updateProfile(StyleProfile newProfile) async {
    _profile = newProfile;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('style_profile', jsonEncode(_profile.toMap()));
    } catch (e) {
      debugPrint('[StyleProfile] Save error: $e');
    }
  }

  Future<void> updateFromQuiz(Map<String, dynamic> answers) async {
    _profile = _profile.copyWith(
      bodyType: answers['bodyType'] ?? _profile.bodyType,
      skinTone: answers['skinTone'] ?? _profile.skinTone,
      preferredStyles: answers['styles'] != null
          ? List<String>.from(answers['styles']) : _profile.preferredStyles,
      preferredColors: answers['colors'] != null
          ? List<String>.from(answers['colors']) : _profile.preferredColors,
      occasions: answers['occasions'] != null
          ? List<String>.from(answers['occasions']) : _profile.occasions,
      gender: answers['gender'] ?? _profile.gender,
      age: answers['age'] ?? _profile.age,
      preferredBrands: answers['brands'] != null
          ? List<String>.from(answers['brands']) : _profile.preferredBrands,
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('style_profile', jsonEncode(_profile.toMap()));
    } catch (e) {
      debugPrint('[StyleProfile] Save error: $e');
    }
  }
}
