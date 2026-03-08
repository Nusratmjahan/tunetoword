import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Change this to your backend URL
  static const String baseUrl = 'http://localhost:3000/api';

  // Create song letter
  static Future<Map<String, dynamic>> createSongLetter({
    required String senderId,
    required String songLink,
    required String letter,
    required String password,
    String? receiverEmail,
    String? colorTheme,
    String? emotionTag,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/songletter/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sender_id': senderId,
          'receiver_email': receiverEmail,
          'song_link': songLink,
          'letter': letter,
          'password': password,
          'color_theme': colorTheme ?? 'amber-deep',
          'emotion_tag': emotionTag ?? 'nostalgia',
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode} - ${response.body}'
        };
      }
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains('SocketException') ||
          errorMsg.contains('Connection refused') ||
          errorMsg.contains('Failed host lookup')) {
        errorMsg =
            'Cannot connect to backend server. Make sure the Node.js backend is running at $baseUrl';
      }
      return {'success': false, 'error': errorMsg};
    }
  }

  // Get song letter by code
  static Future<Map<String, dynamic>> getSongLetter({
    required String code,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/songletter/$code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'password': password}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get sent letters
  static Future<Map<String, dynamic>> getSentLetters(String senderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/songletter/sent/$senderId'),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Create reply
  static Future<Map<String, dynamic>> createReply({
    required String songLetterId,
    required String senderId,
    required String message,
    String? songLink,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reply/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'song_letter_id': songLetterId,
          'sender_id': senderId,
          'message': message,
          'song_link': songLink,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get replies
  static Future<Map<String, dynamic>> getReplies(String songLetterId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reply/$songLetterId'),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
