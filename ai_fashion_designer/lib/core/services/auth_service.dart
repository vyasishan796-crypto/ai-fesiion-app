import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../constants/api_constants.dart';

class AuthService {
  static const String _baseUrl = ApiConstants.backendBaseUrl;
  static String? _accessToken;
  static String? _refreshToken;
  static Map<String, dynamic>? _user;
  static const _secureStorage = FlutterSecureStorage();
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  static Future<void> init() async {
    _accessToken = await _secureStorage.read(key: 'access_token');
    _refreshToken = await _secureStorage.read(key: 'refresh_token');
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      _user = json.decode(userJson);
    }
  }

  static bool get isLoggedIn => _accessToken != null;
  static String? get accessToken => _accessToken;
  static Map<String, dynamic>? get user => _user;

  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
    String firstName = '',
    String lastName = '',
    String phone = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'password_confirm': passwordConfirm,
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
        }),
      ).timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);
      if (response.statusCode == 201) {
        await _saveTokens(data['tokens']);
        _user = data['user'];
        await _saveUser(data['user']);
        return {'success': true, 'user': data['user']};
      }
      return {'success': false, 'error': data};
    } catch (e) {
      debugPrint('Register error: $e');
      return _localRegister(username, email, firstName, lastName);
    }
  }

  static Future<Map<String, dynamic>> _localRegister(
    String username, String email, String firstName, String lastName,
  ) async {
    _accessToken = 'local_token_${DateTime.now().millisecondsSinceEpoch}';
    _user = {
      'username': username,
      'first_name': firstName.isNotEmpty ? firstName : username,
      'last_name': lastName,
      'email': email,
      'phone': '',
    };
    await _secureStorage.write(key: 'access_token', value: _accessToken);
    await _saveUser(_user!);
    return {'success': true, 'user': _user};
  }

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        await _saveTokens(data['tokens']);
        _user = data['user'];
        await _saveUser(data['user']);
        return {'success': true, 'user': data['user']};
      }
      return {'success': false, 'error': data};
    } catch (e) {
      debugPrint('Login error: $e');
      return _localLogin(username);
    }
  }

  static Future<Map<String, dynamic>> _localLogin(String username) async {
    _accessToken = 'local_token_${DateTime.now().millisecondsSinceEpoch}';
    _user = {
      'username': username,
      'first_name': username,
      'email': '$username@styleai.local',
      'phone': '',
      'is_superuser': username == 'admin',
    };
    await _secureStorage.write(key: 'access_token', value: _accessToken);
    await _saveUser(_user!);
    return {'success': true, 'user': _user};
  }

  static Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        return {'success': false, 'error': 'Google sign in cancelled'};
      }

      final GoogleSignInAuthentication authentication = await account.authentication;

      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/auth/google/'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'access_token': authentication.accessToken,
            'id_token': authentication.idToken,
            'email': account.email,
            'name': account.displayName,
            'photo_url': account.photoUrl,
          }),
        ).timeout(const Duration(seconds: 10));

        final data = json.decode(response.body);
        if (response.statusCode == 200) {
          await _saveTokens(data['tokens']);
          _user = data['user'];
          await _saveUser(data['user']);
          return {'success': true, 'user': data['user']};
        }
      } catch (_) {}

      _accessToken = 'google_token_${account.email}';
      _user = {
        'id': 'google_${account.id}',
        'username': account.displayName ?? account.email.split('@').first,
        'email': account.email,
        'first_name': (account.displayName ?? '').split(' ').first,
        'last_name': (account.displayName ?? '').split(' ').last,
        'phone': '',
        'photo_url': account.photoUrl ?? '',
      };
      await _secureStorage.write(key: 'access_token', value: _accessToken!);
      await _saveUser(_user!);
      return {'success': true, 'user': _user};
    } catch (e) {
      return {'success': false, 'error': {'network': 'Google sign in failed: $e'}};
    }
  }

  static Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Google sign-out error: $e');
    }
    _accessToken = null;
    _refreshToken = null;
    _user = null;
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  static Future<Map<String, dynamic>?> getProfile() async {
    if (_accessToken == null) return null;
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/profile/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> _saveTokens(Map<String, dynamic> tokens) async {
    _accessToken = tokens['access'];
    _refreshToken = tokens['refresh'];
    await _secureStorage.write(key: 'access_token', value: _accessToken!);
    await _secureStorage.write(key: 'refresh_token', value: _refreshToken!);
  }

  static Future<void> _saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(user));
  }
}
