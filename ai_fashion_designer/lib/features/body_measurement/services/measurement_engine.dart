import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../models/body_measurement.dart';

class MeasurementEngine {
  static const _geminiBase = 'https://generativelanguage.googleapis.com/v1beta/models';
  static const _geminiModels = ['gemini-3-flash-preview', 'gemini-3.7-flash', 'gemini-3.5-flash'];

  Future<Map<String, dynamic>> estimateMeasurements({
    String? frontImagePath,
    String? sideImagePath,
    double? knownHeight,
  }) async {
    if (frontImagePath == null) {
      return _fallbackMeasurements(knownHeight);
    }

    try {
      final frontBytes = await File(frontImagePath).readAsBytes();
      final frontBase64 = base64Encode(frontBytes);

      String? sideBase64;
      if (sideImagePath != null) {
        final sideBytes = await File(sideImagePath).readAsBytes();
        sideBase64 = base64Encode(sideBytes);
      }

      final prompt = '''You are a professional body measurement analyst AI trained on Indian body diversity. Analyze this body photo and estimate the person's measurements in CENTIMETERS.

${knownHeight != null ? "The person's known height is $knownHeight cm. Use this as a reference for scaling all other measurements proportionally." : "Estimate the person's height based on proportions. Indian male average: 165-178cm, Indian female average: 152-165cm."}

Return ONLY a valid JSON object with these fields:
{
  "height": number in cm,
  "shoulder": number in cm (shoulder width across back),
  "chest": number in cm (chest circumference at widest point),
  "waist": number in cm (waist circumference at narrowest point),
  "hip": number in cm (hip circumference at widest point),
  "inseam": number in cm (inner leg length from crotch to ankle),
  "armLength": number in cm (shoulder to wrist),
  "sleeveLength": number in cm (shoulder to wrist for sleeve),
  "torsoLength": number in cm (shoulder to waist),
  "legLength": number in cm (waist to ankle),
  "skinTone": "string (Fair/Light/Medium/Olive/Tan/Dark)",
  "bodyProportions": "string (Short Torso Long Legs / Average / Long Torso Short Legs)",
  "topSize": "string (Indian brand size: XS/S/M/L/XL/XXL/3XL based on chest)",
  "bottomSize": "string (Indian brand waist size: 28/30/32/34/36/38/40)",
  "fitType": "string (Slim Fit / Regular Fit / Relaxed Fit / Oversized — best recommendation for body type)",
  "confidence": {
    "height": number 0-1,
    "shoulder": number 0-1,
    "chest": number 0-1,
    "waist": number 0-1,
    "hip": number 0-1,
    "inseam": number 0-1,
    "armLength": number 0-1,
    "sleeveLength": number 0-1,
    "torsoLength": number 0-1,
    "legLength": number 0-1
  }
}

Rules:
- Estimate measurements based on visible body proportions
- Front view gives: shoulder, chest, waist, hip, arm length, torso length
- Side view gives: better chest/hip depth, posture assessment
- Inseam is approximately 45-48% of total height for average males
- Indian male averages: Chest 88-106cm, Waist 76-96cm, Shoulder 42-50cm
- Indian female averages: Chest 76-96cm, Waist 62-82cm, Shoulder 36-44cm
- Map chest measurement to Indian clothing sizes: S(88-94), M(94-100), L(100-106), XL(106-112), XXL(112-118)
- Map waist to Indian bottom sizes: 28(71-74), 30(76-79), 32(81-84), 34(86-89), 36(91-94)
- Recommend fit type based on build (athletic→Slim Fit, average→Regular, larger→Relaxed)
- Give honest confidence scores based on photo quality, lighting, and angle
- Account for Indian body diversity in proportions
- Return ONLY valid JSON, no extra text''';

      final parts = <Map<String, dynamic>>[
        {'text': prompt},
        {
          'inlineData': {
            'mimeType': 'image/jpeg',
            'data': frontBase64,
          },
        },
      ];

      if (sideBase64 != null) {
        parts.add({
          'inlineData': {
            'mimeType': 'image/jpeg',
            'data': sideBase64,
          },
        });
      }

      final payload = jsonEncode({
        'contents': [{'parts': parts}],
        'generationConfig': {
          'temperature': 0.3,
          'maxOutputTokens': 1024,
        },
      });

      for (final model in _geminiModels) {
        try {
          final response = await http.post(
            Uri.parse('$_geminiBase/$model:generateContent?key=$ApiConstants.geminiApiKey'),
            headers: {'Content-Type': 'application/json'},
            body: payload,
          ).timeout(const Duration(seconds: 30));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final text = data['candidates'][0]['content']['parts'][0]['text'];
            return _parseResponse(text, knownHeight);
          }
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      // Fall through to fallback
    }

    return _fallbackMeasurements(knownHeight);
  }

  Map<String, dynamic> _parseResponse(String text, double? knownHeight) {
    try {
      String jsonStr = text.trim();
      if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr.replaceFirst(RegExp(r'^```\w*\n?'), '').replaceFirst(RegExp(r'\n?```$'), '');
      }
      final map = jsonDecode(jsonStr);

      final measurements = <String, dynamic>{
        'height': (map['height'] as num?)?.toDouble() ?? (knownHeight ?? 175.0),
        'shoulder': (map['shoulder'] as num?)?.toDouble() ?? 44.0,
        'chest': (map['chest'] as num?)?.toDouble() ?? 96.0,
        'waist': (map['waist'] as num?)?.toDouble() ?? 82.0,
        'hip': (map['hip'] as num?)?.toDouble() ?? 95.0,
        'inseam': (map['inseam'] as num?)?.toDouble() ?? 78.0,
        'armLength': (map['armLength'] as num?)?.toDouble() ?? 64.0,
        'sleeveLength': (map['sleeveLength'] as num?)?.toDouble() ?? 62.0,
        'torsoLength': (map['torsoLength'] as num?)?.toDouble() ?? 70.0,
        'legLength': (map['legLength'] as num?)?.toDouble() ?? 96.0,
      };

      final conf = map['confidence'] as Map<String, dynamic>?;
      measurements['confidence'] = {
        'height': (conf?['height'] as num?)?.toDouble() ?? 0.85,
        'shoulder': (conf?['shoulder'] as num?)?.toDouble() ?? 0.80,
        'chest': (conf?['chest'] as num?)?.toDouble() ?? 0.82,
        'waist': (conf?['waist'] as num?)?.toDouble() ?? 0.80,
        'hip': (conf?['hip'] as num?)?.toDouble() ?? 0.78,
        'inseam': (conf?['inseam'] as num?)?.toDouble() ?? 0.75,
        'armLength': (conf?['armLength'] as num?)?.toDouble() ?? 0.73,
        'sleeveLength': (conf?['sleeveLength'] as num?)?.toDouble() ?? 0.74,
        'torsoLength': (conf?['torsoLength'] as num?)?.toDouble() ?? 0.76,
        'legLength': (conf?['legLength'] as num?)?.toDouble() ?? 0.77,
      };

      return measurements;
    } catch (e) {
      return _fallbackMeasurements(knownHeight);
    }
  }

  Map<String, dynamic> _fallbackMeasurements(double? knownHeight) {
    final h = knownHeight ?? 175.0;
    final scale = h / 175.0;
    return {
      'height': h,
      'shoulder': 44.0 * scale,
      'chest': 96.0 * scale,
      'waist': 82.0 * scale,
      'hip': 95.0 * scale,
      'inseam': 78.0 * scale,
      'armLength': 64.0 * scale,
      'sleeveLength': 62.0 * scale,
      'torsoLength': 70.0 * scale,
      'legLength': 96.0 * scale,
      'confidence': {
        'height': 0.70,
        'shoulder': 0.65,
        'chest': 0.65,
        'waist': 0.65,
        'hip': 0.60,
        'inseam': 0.55,
        'armLength': 0.55,
        'sleeveLength': 0.55,
        'torsoLength': 0.55,
        'legLength': 0.55,
      },
    };
  }

  FitProfile createFitProfile(Map<String, dynamic> measurements) {
    final conf = measurements['confidence'] as Map<String, dynamic>? ?? {};
    return FitProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      measurements: [
        BodyMeasurement(name: 'Height', value: measurements['height'] as double?, confidence: conf['height'] as double? ?? 0.85, icon: '📏'),
        BodyMeasurement(name: 'Shoulder', value: measurements['shoulder'] as double?, confidence: conf['shoulder'] as double? ?? 0.80, icon: '👔'),
        BodyMeasurement(name: 'Chest', value: measurements['chest'] as double?, confidence: conf['chest'] as double? ?? 0.82, icon: '👕'),
        BodyMeasurement(name: 'Waist', value: measurements['waist'] as double?, confidence: conf['waist'] as double? ?? 0.80, icon: '📐'),
        BodyMeasurement(name: 'Hip', value: measurements['hip'] as double?, confidence: conf['hip'] as double? ?? 0.78, icon: '👖'),
        BodyMeasurement(name: 'Inseam', value: measurements['inseam'] as double?, confidence: conf['inseam'] as double? ?? 0.75, icon: '🦵'),
        BodyMeasurement(name: 'Arm Length', value: measurements['armLength'] as double?, confidence: conf['armLength'] as double? ?? 0.73, icon: '💪'),
        BodyMeasurement(name: 'Sleeve Length', value: measurements['sleeveLength'] as double?, confidence: conf['sleeveLength'] as double? ?? 0.74, icon: '🧥'),
        BodyMeasurement(name: 'Torso Length', value: measurements['torsoLength'] as double?, confidence: conf['torsoLength'] as double? ?? 0.76, icon: '📏'),
        BodyMeasurement(name: 'Leg Length', value: measurements['legLength'] as double?, confidence: conf['legLength'] as double? ?? 0.77, icon: '🦵'),
      ],
    );
  }

  FitProfile createDemoProfile() {
    return createFitProfile({
      'height': 175.0,
      'shoulder': 44.0,
      'chest': 96.0,
      'waist': 82.0,
      'hip': 95.0,
      'inseam': 78.0,
      'armLength': 64.0,
      'sleeveLength': 62.0,
      'torsoLength': 70.0,
      'legLength': 96.0,
    });
  }
}
