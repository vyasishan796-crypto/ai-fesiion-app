import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/appearance_profile.dart';
import '../models/outfit_recommendation.dart';
import '../constants/api_constants.dart';
import 'auth_service.dart';

class AppearanceService {
  static final AppearanceService _instance = AppearanceService._internal();
  factory AppearanceService() => _instance;
  AppearanceService._internal();

  static const String _base = ApiConstants.backendBaseUrl;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

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

  Future<AppearanceAnalysis> analyzeAppearance(File imageFile, {String occasion = ''}) async {
    _isLoading = true;
    try {
      final uri = Uri.parse('$_base/appearance/analyze/');

      final request = http.MultipartRequest('POST', uri);
      final token = AuthService.accessToken;
      if (token != null && token.isNotEmpty && !token.startsWith('local_token_')) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.fields['occasion'] = occasion;
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      final response = await request.send().timeout(const Duration(seconds: 60));
      final responseData = await http.Response.fromStream(response);

      _isLoading = false;

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(responseData.body);
        return AppearanceAnalysis.fromJson(json);
      } else {
        String errorMessage = 'Unknown error';
        try {
          final Map<String, dynamic> errorJson = jsonDecode(responseData.body);
          errorMessage = errorJson['error'] ?? errorJson['message'] ?? errorJson.toString();
        } catch (_) {
          errorMessage = responseData.body;
        }
        throw Exception('Appearance analysis failed: $errorMessage (${response.statusCode})');
      }
    } on TimeoutException {
      _isLoading = false;
      throw Exception('Appearance analysis timed out. Please try again with a smaller image.');
    } on http.ClientException catch (e) {
      _isLoading = false;
      final isConn = e.message.contains('SocketException') ||
          e.message.contains('Connection refused') ||
          e.message.contains('Failed host');
      throw Exception(isConn
          ? 'Backend not reachable. Ensure Django server is running at $_base'
          : 'Network error: ${e.message}');
    } catch (e) {
      _isLoading = false;
      rethrow;
    }
  }

  Future<AppearanceAnalysis> getAppearanceAnalysis(String analysisId) async {
    _isLoading = true;
    try {
      final uri = Uri.parse('$_base/appearance/$analysisId/');
      final response = await http.get(uri, headers: _authHeaders).timeout(const Duration(seconds: 30));

      _isLoading = false;

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return AppearanceAnalysis.fromJson(json);
      } else {
        throw Exception('Failed to retrieve appearance analysis: ${response.statusCode}');
      }
    } on TimeoutException {
      _isLoading = false;
      throw Exception('Request timed out.');
    } on http.ClientException catch (e) {
      _isLoading = false;
      rethrow;
    } catch (e) {
      _isLoading = false;
      rethrow;
    }
  }

  Future<List<OutfitRecommendation>> generateOutfitRecommendations({
    required AppearanceAnalysis appearance,
    String occasion = '',
  }) async {
    _isLoading = true;
    try {
      final uri = Uri.parse('$_base/outfits/recommend/');

      final request = http.MultipartRequest('POST', uri);
      final token = AuthService.accessToken;
      if (token != null && token.isNotEmpty && !token.startsWith('local_token_')) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.fields['occasion'] = occasion;
      request.fields['appearance_data'] = jsonEncode(appearance.toJson());

      final response = await request.send().timeout(const Duration(seconds: 45));
      final responseData = await http.Response.fromStream(response);

      _isLoading = false;

      if (response.statusCode == 201 || response.statusCode == 200) {
        final body = jsonDecode(responseData.body);
        final List<dynamic> jsonList = body is List ? body : (body['recommendations'] ?? []);
        return jsonList.map((json) => OutfitRecommendation.fromJson(json)).toList();
      } else {
        String errorMessage = 'Unknown error';
        try {
          final Map<String, dynamic> errorJson = jsonDecode(responseData.body);
          errorMessage = errorJson['error'] ?? errorJson['message'] ?? errorJson.toString();
        } catch (_) {
          errorMessage = responseData.body;
        }
        throw Exception('Outfit generation failed: $errorMessage (${response.statusCode})');
      }
    } on TimeoutException {
      _isLoading = false;
      throw Exception('Outfit generation timed out. Please try again.');
    } on http.ClientException catch (e) {
      _isLoading = false;
      rethrow;
    } catch (e) {
      _isLoading = false;
      rethrow;
    }
  }
}
