import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<String> generateOutfit(String prompt) async {
    _isLoading = true;
    try {
      return await _generateWithNvidiaFlux2Klein(prompt);
    } catch (e) {
      debugPrint('NVIDIA FLUX.2 Klein failed, trying HuggingFace FLUX.1-schnell: $e');
      try {
        return await _generateWithHuggingFace(prompt);
      } catch (e1) {
        debugPrint('HuggingFace failed, trying AI Horde: $e1');
        try {
          return await _generateWithAIHorde(prompt);
        } catch (e2) {
          debugPrint('AI Horde failed, falling back to Pollinations: $e2');
          try {
            return await _generateWithPollinations(prompt);
          } catch (e3) {
            debugPrint('All image generation failed: $e3');
            throw Exception('Image generation failed. Please try again.');
          }
        }
      }
    } finally {
      _isLoading = false;
    }
  }

  Future<String> generateFromPrompt(String prompt) async {
    _isLoading = true;
    try {
      return await _generateWithNvidiaFlux2Klein(prompt);
    } catch (e) {
      debugPrint('NVIDIA FLUX.2 Klein failed, trying HuggingFace FLUX.1-schnell: $e');
      try {
        return await _generateWithHuggingFace(prompt);
      } catch (e1) {
        debugPrint('HuggingFace failed, trying AI Horde: $e1');
        try {
          return await _generateWithAIHorde(prompt);
        } catch (e2) {
          debugPrint('AI Horde failed, falling back to Pollinations: $e2');
          try {
            return await _generateWithPollinations(prompt);
          } catch (e3) {
            debugPrint('All image generation failed: $e3');
            throw Exception('Image generation failed. Please try again.');
          }
        }
      }
    } finally {
      _isLoading = false;
    }
  }

  Future<String> _generateWithNvidiaFlux2Klein(String prompt) async {
    // NVIDIA API key moved to backend for security
    // This frontend method is kept for fallback compatibility
    // The main virtual try-on now uses backend API with Qwen-VL + Flux
    throw Exception('NVIDIA API moved to backend. Use VirtualTryOnService instead.');
  }

  Future<String> _generateWithHuggingFace(String prompt) async {
    final apiKey = ApiConstants.huggingFaceApiKey;
    if (apiKey.isEmpty) throw Exception('HuggingFace API key not set');

    final response = await http.post(
      Uri.parse(ApiConstants.huggingFaceInferenceUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'inputs': '$prompt, high quality fashion photography, professional lighting, studio background',
        'parameters': {
          'width': 768,
          'height': 1152,
          'num_inference_steps': 4,
          'guidance_scale': 0.0,
        },
      }),
    ).timeout(const Duration(seconds: 90));

    if (response.statusCode == 200 && response.bodyBytes.length > 1000) {
      final base64Image = base64Encode(response.bodyBytes);
      return 'data:image/png;base64,$base64Image';
    } else if (response.statusCode == 503) {
      debugPrint('HF Model loading, waiting 15s...');
      await Future.delayed(const Duration(seconds: 15));
      return await _generateWithHuggingFace(prompt);
    } else {
      throw Exception('HuggingFace error ${response.statusCode}: ${response.body.substring(0, 200)}');
    }
  }

  Future<String> _generateWithAIHorde(String prompt) async {
    final submitUrl = '${ApiConstants.aiHordeBaseUrl}/generate/async';
    final body = jsonEncode({
      'prompt': '$prompt #negative blurry, low quality, deformed, ugly',
      'params': {
        'width': 512,
        'height': 768,
        'steps': 30,
        'cfg_scale': 7.5,
        'sampler_name': 'k_euler',
      },
      'nsfw': false,
    });

    final submitResponse = await http.post(
      Uri.parse(submitUrl),
      headers: {
        'Content-Type': 'application/json',
        'apikey': ApiConstants.aiHordeApiKey,
      },
      body: body,
    ).timeout(const Duration(seconds: 30));

    if (submitResponse.statusCode != 202) {
      throw Exception('AI Horde submit failed: ${submitResponse.statusCode}');
    }

    final submitData = jsonDecode(submitResponse.body);
    final jobId = submitData['id'] as String;
    if (jobId.isEmpty) throw Exception('No job ID returned');

    final checkUrl = '${ApiConstants.aiHordeBaseUrl}/generate/check/$jobId';
    final statusUrl = '${ApiConstants.aiHordeBaseUrl}/generate/status/$jobId';

    for (int i = 0; i < 60; i++) {
      await Future.delayed(const Duration(seconds: 5));

      try {
        final checkResponse = await http.get(
          Uri.parse(checkUrl),
          headers: {'apikey': ApiConstants.aiHordeApiKey},
        ).timeout(const Duration(seconds: 15));

        if (checkResponse.statusCode == 200) {
          final checkData = jsonDecode(checkResponse.body);
          if (checkData['done'] == true) {
            final statusResponse = await http.get(
              Uri.parse(statusUrl),
              headers: {'apikey': ApiConstants.aiHordeApiKey},
            ).timeout(const Duration(seconds: 30));

            if (statusResponse.statusCode == 200) {
              final statusData = jsonDecode(statusResponse.body);
              final generations = statusData['generations'] as List?;
              if (generations != null && generations.isNotEmpty) {
                final imgUrl = generations[0]['img'] as String;
                if (imgUrl.startsWith('http')) {
                  final imgResponse = await http.get(
                    Uri.parse(imgUrl),
                  ).timeout(const Duration(seconds: 30));
                  if (imgResponse.statusCode == 200) {
                    final base64Image = base64Encode(imgResponse.bodyBytes);
                    return 'data:image/webp;base64,$base64Image';
                  }
                }
              }
            }
            throw Exception('Failed to get image from AI Horde');
          }
        }
      } catch (e) {
        if (i < 59) continue;
        rethrow;
      }
    }
    throw Exception('AI Horde timeout after 5 minutes');
  }

  Future<String> _generateWithPollinations(String prompt, {int maxRetries = 3}) async {
    final encodedPrompt = Uri.encodeComponent(prompt);
    final seed = Random().nextInt(999999);
    final url = 'https://image.pollinations.ai/prompt/$encodedPrompt?width=768&height=1152&nologo=true&seed=$seed&model=flux';

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final response = await http.get(Uri.parse(url)).timeout(
          const Duration(seconds: 60),
        );

        if (response.statusCode == 200 && response.bodyBytes.length > 1000) {
          final base64Image = base64Encode(response.bodyBytes);
          return 'data:image/jpeg;base64,$base64Image';
        } else if (response.statusCode == 429) {
          debugPrint('Rate limited. Waiting ${(attempt + 1) * 8}s...');
          await Future.delayed(Duration(seconds: (attempt + 1) * 8));
          continue;
        } else {
          debugPrint('Pollinations API Error: ${response.statusCode}');
          if (attempt < maxRetries) {
            await Future.delayed(Duration(seconds: 3 * (attempt + 1)));
            continue;
          }
          throw Exception('API returned status ${response.statusCode}');
        }
      } on Exception catch (e) {
        if (attempt < maxRetries) {
          debugPrint('Attempt ${attempt + 1} failed: $e. Retrying...');
          await Future.delayed(Duration(seconds: 3 * (attempt + 1)));
          continue;
        }
        rethrow;
      }
    }
    throw Exception('All retry attempts failed');
  }
}
