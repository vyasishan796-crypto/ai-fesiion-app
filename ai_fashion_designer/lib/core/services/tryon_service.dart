import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class TryOnResult {
  final String? imageUrl;
  final String source;
  final String? error;
  final String? styleTips;
  final String? colorPalette;
  final String? pairsWellWith;

  const TryOnResult({
    this.imageUrl,
    required this.source,
    this.error,
    this.styleTips,
    this.colorPalette,
    this.pairsWellWith,
  });
}

class TryOnService {
  static final TryOnService _instance = TryOnService._internal();
  factory TryOnService() => _instance;
  TryOnService._internal();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<TryOnResult> tryOn({
    required File personImage,
    required String garmentImageUrl,
    String? garmentName,
    String? garmentColor,
    String? garmentStyle,
  }) async {
    _isLoading = true;

    try {
      final result = await _tryKolors(personImage, garmentImageUrl);
      if (result != null) {
        return TryOnResult(
          imageUrl: result,
          source: 'Kolors Virtual Try-On',
          styleTips: _generateStyleTips(garmentName, garmentColor, garmentStyle),
          colorPalette: _generateColorPalette(garmentColor),
          pairsWellWith: _generatePairsWith(garmentStyle),
        );
      }

      final pollinationsResult = await _tryPollinationsImproved(
        garmentImageUrl, garmentName, garmentColor, garmentStyle,
      );
      if (pollinationsResult != null) {
        return TryOnResult(
          imageUrl: pollinationsResult,
          source: 'AI Style Preview',
          styleTips: _generateStyleTips(garmentName, garmentColor, garmentStyle),
          colorPalette: _generateColorPalette(garmentColor),
          pairsWellWith: _generatePairsWith(garmentStyle),
        );
      }

      return TryOnResult(
        imageUrl: garmentImageUrl,
        source: 'Style Preview',
        error: 'Virtual try-on unavailable. Showing garment preview.',
        styleTips: _generateStyleTips(garmentName, garmentColor, garmentStyle),
        colorPalette: _generateColorPalette(garmentColor),
        pairsWellWith: _generatePairsWith(garmentStyle),
      );
    } catch (e) {
      debugPrint('Try-on error: $e');
      return TryOnResult(
        imageUrl: garmentImageUrl,
        source: 'Style Preview',
        error: 'Error: ${e.toString()}',
        styleTips: _generateStyleTips(garmentName, garmentColor, garmentStyle),
        colorPalette: _generateColorPalette(garmentColor),
        pairsWellWith: _generatePairsWith(garmentStyle),
      );
    } finally {
      _isLoading = false;
    }
  }

  Future<String?> _tryKolors(File personImage, String garmentImageUrl) async {
    try {
      final personBytes = await personImage.readAsBytes();
      if (personBytes.length > 5 * 1024 * 1024) {
        debugPrint('Image too large for Kolors, skipping');
        return null;
      }
      final personBase64 = base64Encode(personBytes);

      final response = await http.post(
        Uri.parse(ApiConstants.kolorsTryOnSubmit),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data': [
            'data:image/jpeg;base64,$personBase64',
            garmentImageUrl,
          ],
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final eventId = body['event_id'];
        if (eventId != null) {
          return await _pollKolorsResult(eventId);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Kolors API error: $e');
      return null;
    }
  }

  Future<String?> _pollKolorsResult(String eventId) async {
    final url = '${ApiConstants.kolorsTryOnSubmit}/$eventId';
    int attempts = 0;
    const maxAttempts = 15;

    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 2));
      attempts++;

      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {'Accept': 'text/event-stream'},
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final lines = response.body.split('\n');
          for (final line in lines) {
            if (line.startsWith('data:')) {
              final data = jsonDecode(line.substring(5).trim());
              if (data['data'] != null && data['data'].isNotEmpty) {
                final result = data['data'][0];
                if (result is Map && result['url'] != null) {
                  return result['url'];
                }
                if (result is String && result.startsWith('http')) {
                  return result;
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Kolors poll attempt $attempts error: $e');
      }
    }
    return null;
  }

  Future<String?> _tryPollinationsImproved(
    String garmentImageUrl,
    String? garmentName,
    String? garmentColor,
    String? garmentStyle,
  ) async {
    try {
      final name = garmentName ?? 'fashion outfit';
      final color = garmentColor ?? '';
      final style = garmentStyle ?? 'casual';

      final prompt = Uri.encodeComponent(
        'professional fashion photography, Indian model wearing $name, '
        '${color.isNotEmpty ? "$color color, " : ""}'
        '$style style, full body shot, standing pose, '
        'studio lighting, white background, sharp focus, '
        'high quality fashion editorial, magazine photo, '
        'photorealistic, 8k quality',
      );
      final seed = DateTime.now().millisecondsSinceEpoch % 10000;
      final url = 'https://image.pollinations.ai/prompt/$prompt'
          '?width=768&height=1024&nologo=true&seed=$seed&model=flux';

      final response = await http.head(Uri.parse(url)).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return url;
      }
      return null;
    } catch (e) {
      debugPrint('Pollinations improved error: $e');
      return null;
    }
  }

  String _generateStyleTips(String? name, String? color, String? style) {
    final tips = <String>[];

    if (style != null) {
      switch (style.toLowerCase()) {
        case 'formal':
          tips.add('Pair with oxford shoes and a leather belt for a polished look.');
          tips.add('Add a classic watch to complete the outfit.');
          break;
        case 'casual':
          tips.add('Roll up the sleeves for a relaxed vibe.');
          tips.add('White sneakers go perfectly with this.');
          break;
        case 'streetwear':
          tips.add('Layer with an oversized jacket for extra style points.');
          tips.add('Chunky sneakers complete the streetwear look.');
          break;
        case 'sporty':
          tips.add('Match with athletic shoes and a sports watch.');
          tips.add('Keep accessories minimal for a clean athletic look.');
          break;
        case 'ethnic':
          tips.add('Pair with juttis or kolhapuris for an authentic touch.');
          tips.add('Add oxidized jewelry for a boho-ethnic fusion.');
          break;
        default:
          tips.add('This piece is versatile — dress it up or down.');
          tips.add('Confidence is the best accessory!');
      }
    } else {
      tips.add('This piece works for multiple occasions.');
      tips.add('Mix and match with your existing wardrobe.');
    }

    return tips.join(' | ');
  }

  String _generateColorPalette(String? color) {
    if (color == null || color.isEmpty) return 'Navy, White, Grey, Black';

    switch (color.toLowerCase()) {
      case 'black':
        return 'White, Red, Gold, Silver';
      case 'white':
        return 'Navy, Black, Denim Blue, Pastels';
      case 'blue':
        return 'White, Cream, Tan, Grey';
      case 'navy':
        return 'White, Camel, Burgundy, Light Blue';
      case 'red':
        return 'Black, White, Denim, Gold';
      case 'green':
        return 'White, Beige, Brown, Gold';
      case 'grey':
        return 'Black, White, Pink, Blue';
      case 'beige':
        return 'Brown, Navy, White, Olive';
      default:
        return 'White, Black, Navy, Grey';
    }
  }

  String _generatePairsWith(String? style) {
    if (style == null) return 'Jeans, Chinos, Sneakers';

    switch (style.toLowerCase()) {
      case 'formal':
        return 'Dress shoes, Leather belt, Blazer, Watch';
      case 'casual':
        return 'Sneakers, Denim jacket, Crossbody bag';
      case 'streetwear':
        return 'Chunky sneakers, Cap, Backpack, Chain necklace';
      case 'sporty':
        return 'Running shoes, Sports watch, Gym bag';
      case 'ethnic':
        return 'Juttis, Clutch, Oxidized jewelry, Dupatta';
      case 'classic':
        return 'Loafers, Belt, Sunglasses, Tote bag';
      default:
        return 'Sneakers, Watch, Belt, Sunglasses';
    }
  }
}
