import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ImageGenerationService {
  static final ImageGenerationService _instance = ImageGenerationService._internal();
  factory ImageGenerationService() => _instance;
  ImageGenerationService._internal();

  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;

  /// Generate image using HuggingFace FLUX.1-schnell
  /// Falls back to Pollinations if HF key not set
  Future<Uint8List?> generateImage({
    required String prompt,
    int width = 512,
    int height = 512,
    int numInferenceSteps = 4,
  }) async {
    if (_isGenerating) return null;
    _isGenerating = true;

    try {
      // Try HuggingFace first if key is available
      if (ApiConstants.huggingFaceApiKey.isNotEmpty) {
        final result = await _generateWithHuggingFace(
          prompt: prompt,
          width: width,
          height: height,
          steps: numInferenceSteps,
        );
        if (result != null) return result;
      }

      // Fallback to Pollinations (free, no key needed)
      return await _generateWithPollinations(prompt: prompt, width: width, height: height);
    } catch (e) {
      debugPrint('Image generation error: $e');
      return null;
    } finally {
      _isGenerating = false;
    }
  }

  /// HuggingFace Inference API - FLUX.1-schnell
  Future<Uint8List?> _generateWithHuggingFace({
    required String prompt,
    required int width,
    required int height,
    required int steps,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.huggingFaceInferenceUrl),
        headers: {
          'Authorization': 'Bearer ${ApiConstants.huggingFaceApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputs': prompt,
          'parameters': {
            'width': width,
            'height': height,
            'num_inference_steps': steps,
            'guidance_scale': 0.0,
          },
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else if (response.statusCode == 503) {
        // Model is loading, retry after delay
        final modelInfo = jsonDecode(response.body);
        debugPrint('HF Model loading: $modelInfo');
        await Future.delayed(const Duration(seconds: 10));
        return await _generateWithHuggingFace(
          prompt: prompt,
          width: width,
          height: height,
          steps: steps,
        );
      } else {
        debugPrint('HF Error ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('HF API error: $e');
      return null;
    }
  }

  /// Pollinations - Free, no API key needed
  /// Returns image bytes from URL
  Future<Uint8List?> _generateWithPollinations({
    required String prompt,
    required int width,
    required int height,
  }) async {
    try {
      final encodedPrompt = Uri.encodeComponent(prompt);
      final url = '${ApiConstants.pollinationsBaseUrl}/$encodedPrompt?width=$width&height=$height&nologo=true&seed=${DateTime.now().millisecondsSinceEpoch}';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'image/*'},
      ).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      }
      debugPrint('Pollinations error: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Pollinations API error: $e');
      return null;
    }
  }

  /// Generate fashion-specific prompt
  String generateFashionPrompt({
    required String item,
    required String style,
    String color = '',
    String occasion = '',
    String gender = 'unisex',
  }) {
    final parts = <String>[
      'Professional fashion product photography',
      item,
      if (style.isNotEmpty) style,
      if (color.isNotEmpty) color,
      if (occasion.isNotEmpty) 'for $occasion',
      if (gender != 'unisex') gender == 'men' ? 'menswear' : 'womenswear',
      'studio lighting, white background, high resolution, editorial fashion photo',
    ];
    return parts.join(', ');
  }

  /// Generate outfit visualization prompt
  String generateOutfitPrompt({
    required String top,
    required String bottom,
    required String shoes,
    String? layer,
  }) {
    final parts = <String>[
      'Full body fashion photo of a model wearing',
      top,
      'paired with $bottom',
      'and $shoes',
      if (layer != null) 'layered with $layer',
      'professional fashion photography, studio lighting, editorial style, high resolution',
    ];
    return parts.join(', ');
  }
}
