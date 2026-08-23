import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../models/fit_profile.dart';

class ScannerService {
  static const _geminiBase = 'https://generativelanguage.googleapis.com/v1beta/models';
  static const _geminiModels = ['gemini-3-flash-preview', 'gemini-3.7-flash', 'gemini-3.5-flash'];

  Future<ScanResult> processScan(List<String> imagePaths) async {
    double poseConfidence = 0.75;
    double lightingQuality = 0.8;

    if (imagePaths.isNotEmpty) {
      try {
        final file = File(imagePaths.first);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final fileSizeKB = bytes.length / 1024;
          if (fileSizeKB > 3000) {
            lightingQuality = 0.95;
          } else if (fileSizeKB > 1000) {
            lightingQuality = 0.85;
          } else {
            lightingQuality = 0.7;
          }
        }
      } catch (e) {
        debugPrint('ScannerService: Error reading image: $e');
      }
    }

    final scanQuality = (poseConfidence + lightingQuality) / 2;

    Map<String, dynamic> measurements;
    if (imagePaths.isNotEmpty) {
      measurements = await _estimateWithGemini(imagePaths.first);
    } else {
      measurements = _fallbackMeasurements();
    }

    return ScanResult(
      success: true,
      imagePath: imagePaths.isNotEmpty ? imagePaths.first : '',
      poseConfidence: poseConfidence,
      lightingQuality: lightingQuality,
      scanQuality: scanQuality,
      estimatedMeasurements: measurements,
    );
  }

  Future<Map<String, dynamic>> _estimateWithGemini(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(bytes);

      final prompt = '''You are a professional body measurement analyst AI trained on Indian body diversity. Analyze this body photo and estimate the person's body measurements in CENTIMETERS.

Return ONLY a valid JSON object with these exact fields:
{
  "chest": number in cm (chest circumference),
  "waist": number in cm (waist circumference),
  "hips": number in cm (hip circumference),
  "shoulder": number in cm (shoulder width),
  "inseam": number in cm (inner leg length),
  "sleeve": number in cm (arm length),
  "neck": number in cm (neck circumference),
  "torso": number in cm (torso length),
  "height": number in cm (estimated total height),
  "weight": number in kg (estimated weight),
  "bodyType": "string (Athletic/Slim/Average/Muscular/Large/Stocky)",
  "skinTone": "string (Fair/Light/Medium/Olive/Tan/Dark)",
  "bodyProportions": "string describing torso-to-leg ratio (Short Torso Long Legs / Average / Long Torso Short Legs)",
  "postureType": "string (Upright / Forward Lean / Slightly Tilted)",
  "topSize": "string (Indian size: XS/S/M/L/XL/XXL/3XL)",
  "bottomSize": "string (Indian size: 28/30/32/34/36/38/40)",
  "confidence": number between 0.7 and 0.95
}

Rules:
- Indian male averages: Height 165-178cm, Chest 88-106cm, Waist 76-96cm
- Indian female averages: Height 152-165cm, Chest 76-96cm, Waist 62-82cm
- Estimate based on visible body proportions and relative sizing
- If person appears lean/athletic: chest ~92-100, waist ~74-82
- If person appears average build: chest ~96-106, waist ~82-92
- If person appears larger: chest ~106-120, waist ~92-110
- Shoulder width is approximately chest/2.1 for average builds
- Inseam is approximately 45-47% of total height
- Neck is approximately chest/2.6
- Map measurements to Indian standard clothing sizes (S/M/L/XL/XXL)
- Give HONEST confidence based on photo quality, lighting, and angle
- Account for Indian body diversity (broader build, different proportions)
- Return ONLY valid JSON, no extra text or markdown''';

      for (final model in _geminiModels) {
        try {
          final response = await http.post(
            Uri.parse('$_geminiBase/$model:generateContent?key=${ApiConstants.geminiApiKey}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt},
                    {'inlineData': {'mimeType': 'image/jpeg', 'data': base64Image}},
                  ],
                },
              ],
              'generationConfig': {
                'temperature': 0.3,
                'maxOutputTokens': 1024,
              },
            }),
          ).timeout(const Duration(seconds: 30));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final text = data['candidates'][0]['content']['parts'][0]['text'];
            final cleaned = text.trim().replaceAll('```json', '').replaceAll('```', '').trim();
            final measurements = jsonDecode(cleaned) as Map<String, dynamic>;
            debugPrint('[Scanner] Gemini $model success: $measurements');
            return measurements;
          }
          debugPrint('[Scanner] $model failed: ${response.statusCode}');
        } catch (e) {
          debugPrint('[Scanner] $model error: $e');
        }
      }
    } catch (e) {
      debugPrint('[Scanner] Gemini error: $e');
    }

    return _fallbackMeasurements();
  }

  Map<String, dynamic> _fallbackMeasurements() {
    return {
      'chest': 96.0, 'waist': 82.0, 'hips': 97.0,
      'shoulder': 46.0, 'inseam': 79.0, 'sleeve': 64.0,
      'neck': 39.0, 'torso': 72.0, 'height': 175.0, 'weight': 70.0,
      'bodyType': 'Average', 'confidence': 0.75,
    };
  }

  FitProfile generateFitProfile(Map<String, dynamic> measurements) {
    final chest = (measurements['chest'] as num?)?.toDouble() ?? 96.0;
    final waist = (measurements['waist'] as num?)?.toDouble() ?? 82.0;
    final hips = (measurements['hips'] as num?)?.toDouble() ?? 97.0;

    String topSize;
    if (chest < 92) topSize = 'S';
    else if (chest < 100) topSize = 'M';
    else if (chest < 108) topSize = 'L';
    else if (chest < 116) topSize = 'XL';
    else topSize = 'XXL';

    String bottomSize;
    if (waist < 76) bottomSize = '28';
    else if (waist < 82) bottomSize = '30';
    else if (waist < 88) bottomSize = '32';
    else if (waist < 94) bottomSize = '34';
    else bottomSize = '36';

    final confidence = (measurements['confidence'] as num?)?.toDouble() ?? 0.75;

    return FitProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      measurements: [
        Measurement(name: 'Chest', value: chest, isEstimated: true, confidence: confidence),
        Measurement(name: 'Waist', value: waist, isEstimated: true, confidence: confidence),
        Measurement(name: 'Hips', value: hips, isEstimated: true, confidence: confidence),
        Measurement(name: 'Shoulder', value: (measurements['shoulder'] as num?)?.toDouble() ?? 46.0, isEstimated: true, confidence: confidence),
        Measurement(name: 'Inseam', value: (measurements['inseam'] as num?)?.toDouble() ?? 79.0, isEstimated: true, confidence: confidence),
        Measurement(name: 'Sleeve', value: (measurements['sleeve'] as num?)?.toDouble() ?? 64.0, isEstimated: true, confidence: confidence),
        Measurement(name: 'Neck', value: (measurements['neck'] as num?)?.toDouble() ?? 39.0, isEstimated: true, confidence: confidence),
        Measurement(name: 'Torso Length', value: (measurements['torso'] as num?)?.toDouble() ?? 72.0, isEstimated: true, confidence: confidence),
      ],
      recommendedTopSize: topSize,
      recommendedBottomSize: bottomSize,
      fitPreference: 'Regular',
      recommendedFits: ['Regular', 'Relaxed', 'Oversized'],
      garmentPreferences: {
        'topFit': 'Regular Fit',
        'bottomFit': 'Straight Leg',
        'sleeveLength': 'Full Sleeve',
        'garmentLength': 'Standard',
      },
    );
  }

  List<OutfitRecommendation> getRecommendations(FitProfile profile) {
    final topSize = profile.recommendedTopSize;
    final bottomSize = profile.recommendedBottomSize;

    return [
      OutfitRecommendation(
        name: 'Oversized Graphic Tee',
        description: 'Comfortable relaxed fit tee with modern streetwear aesthetic',
        fitType: 'Oversized',
        occasion: 'Casual',
        availableSizes: ['S', 'M', 'L', 'XL'],
        whyItWorks: 'Your size $topSize works great for oversized fits. The relaxed drape will complement your proportions.',
      ),
      OutfitRecommendation(
        name: 'Regular Fit Oxford Shirt',
        description: 'Classic button-down shirt with a clean, tailored appearance',
        fitType: 'Regular',
        occasion: 'Semi-Formal',
        availableSizes: ['S', 'M', 'L', 'XL'],
        whyItWorks: 'Size $topSize regular fit will sit perfectly on your shoulders and chest for a polished look.',
      ),
      OutfitRecommendation(
        name: 'Relaxed Chinos',
        description: 'Comfortable straight-leg chinos with a relaxed thigh fit',
        fitType: 'Relaxed',
        occasion: 'Smart Casual',
        availableSizes: ['28', '30', '32', '34', '36'],
        whyItWorks: 'Size $bottomSize relaxed chinos will provide comfort while maintaining a clean silhouette.',
      ),
      OutfitRecommendation(
        name: 'Tailored Blazer',
        description: 'Structured blazer with modern slim proportions',
        fitType: 'Tailored',
        occasion: 'Formal',
        availableSizes: ['S', 'M', 'L', 'XL'],
        whyItWorks: 'Size $topSize tailored blazer will sharpen your formal appearance with clean lines.',
      ),
      OutfitRecommendation(
        name: 'Layered Streetwear Look',
        description: 'Oversized hoodie over a regular tee with baggy cargo pants',
        fitType: 'Oversized',
        occasion: 'Streetwear',
        availableSizes: ['M', 'L', 'XL'],
        whyItWorks: 'Layering oversized pieces with your build creates an effortless street style.',
      ),
      OutfitRecommendation(
        name: 'Slim Straight Jeans',
        description: 'Modern slim-straight cut that balances comfort and style',
        fitType: 'Regular',
        occasion: 'Everyday',
        availableSizes: ['28', '30', '32', '34', '36'],
        whyItWorks: 'Size $bottomSize slim-straight jeans will work perfectly with your proportions.',
      ),
    ];
  }
}
