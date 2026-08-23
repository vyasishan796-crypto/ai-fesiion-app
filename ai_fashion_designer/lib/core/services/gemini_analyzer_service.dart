import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/style_analysis.dart';
import 'auth_service.dart';

class GeminiAnalyzerService {
  static final GeminiAnalyzerService _instance = GeminiAnalyzerService._();
  factory GeminiAnalyzerService() => _instance;
  GeminiAnalyzerService._();

  static String get _base => ApiConstants.backendBaseUrl;

  Map<String, String> get _authHeaders {
    final token = AuthService.accessToken;
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty && !token.startsWith('local_token_')) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<StyleAnalysis> analyzeImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final mime = imageFile.path.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';

    http.Response resp;
    try {
      resp = await http.post(
        Uri.parse('$_base/style-analyze/'),
        headers: _authHeaders,
        body: jsonEncode({'image_base64': 'data:$mime;base64,$base64Image', 'mime': mime}),
      ).timeout(const Duration(seconds: 35));
    } catch (e) {
      final isConn = e.toString().contains('SocketException') || e.toString().contains('Connection refused') || e.toString().contains('Failed host');
      throw Exception(isConn ? 'Backend not reachable at $_base — run: python manage.py runserver 0.0.0.0:8000 (same WiFi)' : 'Network error: $e');
    }

    if (resp.statusCode == 200) {
      final map = jsonDecode(resp.body);
      debugPrint('[StyleAnalyze] Backend response received');
      return _mapToAnalysis(map);
    }
    debugPrint('[StyleAnalyze] Backend failed ${resp.statusCode}: ${resp.body}');
    throw Exception('Style analysis failed (${resp.statusCode}): ${resp.body}');
  }

  StyleAnalysis _mapToAnalysis(Map<String, dynamic> map) {
    Map<String, int> scoreBreakdown = {};
    if (map['scoreBreakdown'] != null) {
      final sb = map['scoreBreakdown'] as Map<String, dynamic>;
      scoreBreakdown = {
        'personalStyle': (sb['personalStyle'] as num?)?.toInt() ?? 85,
        'occasion': (sb['occasion'] as num?)?.toInt() ?? 85,
        'color': (sb['color'] as num?)?.toInt() ?? 85,
        'weather': (sb['weather'] as num?)?.toInt() ?? 85,
        'fit': (sb['fit'] as num?)?.toInt() ?? 85,
        'budget': (sb['budget'] as num?)?.toInt() ?? 85,
      };
    } else {
      final s = ((map['styleScore'] as num?)?.toDouble() ?? 7.5) * 10;
      scoreBreakdown = {
        'personalStyle': s.round().clamp(60, 100),
        'occasion': s.round().clamp(60, 100),
        'color': s.round().clamp(60, 100),
        'weather': s.round().clamp(60, 100),
        'fit': s.round().clamp(60, 100),
        'budget': s.round().clamp(60, 100),
      };
    }
    return StyleAnalysis(
      overallStyle: map['overallStyle'] ?? 'Casual',
      styleScore: (map['styleScore'] as num?)?.toDouble() ?? 7.5,
      clothing: List<String>.from(map['clothing'] ?? []),
      palette: (map['dominantColors'] as List?)?.map((c) => DetectedColor(name: c['name'] ?? '', color: _hexToColor(c['hex'] ?? '#888888'), percentage: (c['percentage'] as num?)?.toDouble() ?? 25.0)).toList() ?? [],
      fabric: map['fabric'] ?? 'Cotton',
      occasions: List<String>.from(map['occasions'] ?? ['Casual']),
      recommendations: List<String>.from(map['recommendations'] ?? []),
      scoreBreakdown: scoreBreakdown,
      scoreReason: map['scoreReason'] as String?,
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  Future<String> askQuestion(StyleAnalysis analysis, String question) async {
    final payload = {
      'analysis': {
        'overallStyle': analysis.overallStyle,
        'clothing': analysis.clothing,
        'dominantColors': analysis.palette.map((c) => {'name': c.name}).toList(),
        'fabric': analysis.fabric,
        'occasions': analysis.occasions,
        'styleScore': analysis.styleScore,
        'scoreBreakdown': analysis.scoreBreakdown,
      },
      'question': question,
    };

    try {
      final resp = await http.post(
        Uri.parse('$_base/style-analyze/ask/'),
        headers: _authHeaders,
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 30));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        return data['answer'] ?? 'Sorry, could not process.';
      }
      throw Exception('Ask failed: ${resp.body}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error while asking question: $e');
    }
  }
}
