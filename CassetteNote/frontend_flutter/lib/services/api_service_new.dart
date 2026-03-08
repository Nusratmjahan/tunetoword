import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ==================== CONFIGURATION ====================
  // Change this to switch between development and production
  static const bool isProduction = false;

  // Development URL (your local machine)
  static const String devUrl = 'http://192.168.0.110:8000/api';

  // Production URL (update this when you deploy to server)
  // Examples:
  // - DigitalOcean: 'https://cassettenote.com/api'
  // - Heroku: 'https://your-app-name.herokuapp.com/api'
  // - AWS: 'https://api.cassettenote.com/api'
  static const String prodUrl = 'https://your-production-domain.com/api';

  // Automatically select URL based on environment
  static String get baseUrl => isProduction ? prodUrl : devUrl;

  static String? _token;

  // Initialize by loading stored token
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  // Save token to storage
  static Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Clear token
  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Get authorization headers
  static Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // ==================== AUTH ENDPOINTS ====================

  static Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: _getHeaders(includeAuth: false),
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save token
        await _saveToken(data['access_token']);
        return {
          'success': true,
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'error': data['detail'] ?? 'Signup failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _getHeaders(includeAuth: false),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save token
        await _saveToken(data['access_token']);
        return {
          'success': true,
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'error': data['detail'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': data,
        };
      } else {
        return {
          'success': false,
          'error': data['detail'] ?? 'Failed to get user info',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  static Future<void> logout() async {
    await clearToken();
  }

  // ==================== PHOTO ENDPOINTS ====================

  static Future<Map<String, dynamic>> uploadPhoto(File photoFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/photos/upload'),
      );

      // Add authorization header
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          photoFile.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'url': data['data']['url'],
        };
      } else {
        return {
          'success': false,
          'error': data['detail'] ?? 'Photo upload failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // ==================== SONG LETTER ENDPOINTS ====================

  static Future<Map<String, dynamic>> createSongLetter({
    required String songLink,
    required String letter,
    required String password,
    String? receiverEmail,
    String? colorTheme,
    String? emotionTag,
    String? photoUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/songletters/create'),
        headers: _getHeaders(),
        body: jsonEncode({
          'song_link': songLink,
          'letter': letter,
          'password': password,
          'receiver_email': receiverEmail,
          'color_theme': colorTheme ?? 'amber-deep',
          'emotion_tag': emotionTag ?? 'nostalgia',
          'photo_url': photoUrl,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        return {
          'success': false,
          'error': data['detail'] ?? 'Failed to create song letter',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> accessSongLetter({
    required String code,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/songletters/access'),
        headers: _getHeaders(includeAuth: false),
        body: jsonEncode({
          'code': code,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        return {
          'success': false,
          'error': data['detail'] ?? 'Failed to access song letter',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getSentLetters() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/songletters/sent'),
        headers: _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        return {
          'success': false,
          'error': data['detail'] ?? 'Failed to get sent letters',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }
}
