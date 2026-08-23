import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../models/product.dart';
import '../models/virtual_tryon_generation.dart';
import 'auth_service.dart';
import 'product_image_service.dart';

class VirtualTryOnService {
  VirtualTryOnService._();
  static final VirtualTryOnService _instance = VirtualTryOnService._();
  factory VirtualTryOnService() => _instance;
  static const String _storageKey = 'virtual_tryon_history';

  String get _authToken {
    final token = AuthService.accessToken;
    if (token != null && token.isNotEmpty && !token.startsWith('local_token_')) {
      return token;
    }
    return '';
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken.isNotEmpty) 'Authorization': 'Bearer $_authToken',
  };

  Future<VirtualTryOnGeneration> generate({
    required File userImage,
    required List<Product> products,
    required String userPrompt,
    String? outfitId,
    int? seed,
  }) async {
    try {
      final imageBytes = await userImage.readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64Encode(imageBytes)}';
      final productIds = products.map((p) => p.id).toList();
      final requestBody = {
        'user_image_base64': base64Image,
        'product_ids': productIds,
        'user_prompt': userPrompt,
        if (outfitId != null && outfitId.isNotEmpty) 'outfit_id': outfitId,
        if (seed != null) 'seed': seed,
      };
      final uri = Uri.parse(ApiConstants.virtualTryOnEndpoint);
      final response = await http.post(uri, headers: _headers, body: jsonEncode(requestBody)).timeout(const Duration(seconds: 120));
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final pIds = List<String>.from(data['product_ids']);
        final prods = ProductImageService.getByIds(pIds);
        return VirtualTryOnGeneration.fromJson(data, products: prods);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Generation failed: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Virtual try-on timed out. Please try again.');
    } on http.ClientException catch (e) {
      final isConn = e.message.contains('SocketException') || e.message.contains('Connection refused');
      throw Exception(isConn ? 'Backend not reachable. Ensure server is running.' : 'Network error: ${e.message}');
    }
  }

  Future<List<VirtualTryOnGeneration>> getHistory({int limit = 50}) async {
    try {
      final uri = Uri.parse('${ApiConstants.virtualTryOnHistoryEndpoint}?limit=$limit');
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) {
          final pIds = List<String>.from(json['product_ids']);
          final prods = ProductImageService.getByIds(pIds);
          return VirtualTryOnGeneration.fromJson(json, products: prods);
        }).toList();
      } else {
        throw Exception('Failed to fetch history: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timed out.');
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<VirtualTryOnGeneration?> getGeneration(int id) async {
    try {
      final uri = Uri.parse('${ApiConstants.virtualTryOnEndpoint}$id/');
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final pIds = List<String>.from(data['product_ids']);
        final prods = ProductImageService.getByIds(pIds);
        return VirtualTryOnGeneration.fromJson(data, products: prods);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to fetch generation: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timed out.');
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<void> saveToLocalHistory(VirtualTryOnGeneration generation) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_storageKey) ?? [];
    final entry = jsonEncode({'id': generation.id, 'result_image_url': generation.resultImageUrl, 'user_prompt': generation.userPrompt, 'product_ids': generation.productIds, 'created_at': generation.createdAt.toIso8601String()});
    history.insert(0, entry);
    if (history.length > 50) history.removeRange(50, history.length);
    await prefs.setStringList(_storageKey, history);
  }

  Future<List<Map<String, dynamic>>> getLocalHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_storageKey) ?? [];
    return history.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }
}
