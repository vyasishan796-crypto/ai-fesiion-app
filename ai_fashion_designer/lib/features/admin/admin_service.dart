import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/services/auth_service.dart';

class AdminService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  String get _baseUrl => '${ApiConstants.backendBaseUrl}/admin';

  Future<Map<String, String>> _headers() async {
    final token = AuthService.accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty && !token.startsWith('local_token_')) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>?> getStats() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/stats/'),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      debugPrint('[Admin] Stats error: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('[Admin] Stats error: $e');
      return null;
    }
  }

  Future<List<dynamic>> getProducts({String search = ''}) async {
    try {
      final url = search.isNotEmpty ? '$_baseUrl/products/?q=$search' : '$_baseUrl/products/';
      final response = await http.get(
        Uri.parse(url),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint('[Admin] Products error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> createProduct(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/products/'),
        headers: await _headers(),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('[Admin] Create product error: $e');
      return null;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/products/$id/'),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 15));
      return response.statusCode == 204;
    } catch (e) {
      debugPrint('[Admin] Delete product error: $e');
      return false;
    }
  }

  Future<List<dynamic>> getOrders({String status = ''}) async {
    try {
      final url = status.isNotEmpty ? '$_baseUrl/orders/?status=$status' : '$_baseUrl/orders/';
      final response = await http.get(
        Uri.parse(url),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint('[Admin] Orders error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> updateOrderStatus(int orderId, String newStatus) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/orders/$orderId/status/'),
        headers: await _headers(),
        body: jsonEncode({'status': newStatus}),
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('[Admin] Update order error: $e');
      return null;
    }
  }

  Future<List<dynamic>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/'),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint('[Admin] Users error: $e');
      return [];
    }
  }
}
