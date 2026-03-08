import 'dart:io';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class SongLetterService {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Generate unique code (8 characters, alphanumeric, no confusing chars)
  static String _generateCode() {
    const chars = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
    final random = Random.secure();
    return List.generate(8, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  // Hash password using SHA-256
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Verify password
  static bool _verifyPassword(String password, String hash) {
    return _hashPassword(password) == hash;
  }

  // Create song letter
  static Future<Map<String, dynamic>> createSongLetter({
    required String senderId,
    required String songLink,
    required String letter,
    required String password,
    String? receiverEmail,
    String? colorTheme,
    String? emotionTag,
    String? photoUrl,
  }) async {
    try {
      // Generate unique code
      String code;
      bool codeExists = true;

      // Keep generating until we get a unique code
      do {
        code = _generateCode();
        final snapshot = await _database
            .ref('songLetters')
            .orderByChild('code')
            .equalTo(code)
            .once();
        codeExists = snapshot.snapshot.value != null;
      } while (codeExists);

      // Hash password
      final passwordHash = _hashPassword(password);

      final songLetterData = {
        'code': code,
        'sender_id': senderId,
        'receiver_email': receiverEmail,
        'song_link': songLink,
        'letter': letter,
        'password_hash': passwordHash,
        'color_theme': colorTheme ?? 'amber-deep',
        'emotion_tag': emotionTag ?? 'nostalgia',
        'photo_url': photoUrl,
        'created_at': ServerValue.timestamp,
      };

      // Save to Realtime Database
      final newRef = _database.ref('songLetters').push();
      await newRef.set(songLetterData);

      return {
        'success': true,
        'message': 'Song letter created successfully',
        'data': {
          'id': newRef.key,
          'code': code,
          'link': '/memory/$code',
        },
      };
    } catch (error) {
      return {
        'success': false,
        'error': 'Failed to create song letter: $error',
      };
    }
  }

  // Get song letter by code with password verification
  static Future<Map<String, dynamic>> getSongLetterByCode({
    required String code,
    required String password,
  }) async {
    try {
      final snapshot = await _database
          .ref('songLetters')
          .orderByChild('code')
          .equalTo(code)
          .once();

      if (snapshot.snapshot.value == null) {
        return {
          'success': false,
          'error': 'Song letter not found',
        };
      }

      // Get the first (and should be only) result
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      final entry = data.entries.first;
      final letterId = entry.key as String;
      final letterData = Map<String, dynamic>.from(entry.value as Map);

      // Verify password
      final passwordHash = letterData['password_hash'] as String;
      if (!_verifyPassword(password, passwordHash)) {
        return {
          'success': false,
          'error': 'Invalid password',
        };
      }

      // Remove password hash from response
      letterData.remove('password_hash');

      return {
        'success': true,
        'data': {
          'id': letterId,
          ...letterData,
        },
      };
    } catch (error) {
      return {
        'success': false,
        'error': 'Failed to get song letter: $error',
      };
    }
  }

  // Get all song letters sent by a user
  static Future<Map<String, dynamic>> getSentLetters(String senderId) async {
    try {
      final snapshot = await _database
          .ref('songLetters')
          .orderByChild('sender_id')
          .equalTo(senderId)
          .once();

      final letters = <Map<String, dynamic>>[];

      if (snapshot.snapshot.value != null) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          final letterData = Map<String, dynamic>.from(value as Map);
          letterData.remove('password_hash'); // Don't return password hash
          letters.add({
            'id': key,
            ...letterData,
          });
        });

        // Sort by created_at descending (most recent first)
        letters.sort((a, b) {
          final aTime = a['created_at'] ?? 0;
          final bTime = b['created_at'] ?? 0;
          return (bTime as int).compareTo(aTime as int);
        });
      }

      return {
        'success': true,
        'data': letters,
      };
    } catch (error) {
      return {
        'success': false,
        'error': 'Failed to get sent letters: $error',
      };
    }
  }

  // Upload photo to Firebase Storage
  static Future<Map<String, dynamic>> uploadPhoto({
    required File photoFile,
    required String userId,
  }) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$userId.jpg';
      final storageRef = _storage.ref().child('song_letter_photos/$fileName');

      // Upload file
      final uploadTask = await storageRef.putFile(photoFile);

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return {
        'success': true,
        'photo_url': downloadUrl,
      };
    } catch (error) {
      return {
        'success': false,
        'error': 'Failed to upload photo: $error',
      };
    }
  }

  // Delete song letter
  static Future<Map<String, dynamic>> deleteSongLetter(String letterId) async {
    try {
      await _database.ref('songLetters/$letterId').remove();
      return {
        'success': true,
        'message': 'Song letter deleted successfully',
      };
    } catch (error) {
      return {
        'success': false,
        'error': 'Failed to delete song letter: $error',
      };
    }
  }

  // Get replies for a song letter
  static Future<Map<String, dynamic>> getReplies(String songLetterId) async {
    try {
      final snapshot = await _database
          .ref('replies')
          .orderByChild('song_letter_id')
          .equalTo(songLetterId)
          .once();

      final replies = <Map<String, dynamic>>[];

      if (snapshot.snapshot.value != null) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          final replyData = Map<String, dynamic>.from(value as Map);
          replies.add({
            'id': key,
            ...replyData,
          });
        });

        // Sort by created_at ascending (oldest first)
        replies.sort((a, b) {
          final aTime = a['created_at'] ?? 0;
          final bTime = b['created_at'] ?? 0;
          return (aTime as int).compareTo(bTime as int);
        });
      }

      return {
        'success': true,
        'data': replies,
      };
    } catch (error) {
      return {
        'success': false,
        'error': 'Failed to get replies: $error',
      };
    }
  }

  // Create a reply to a song letter
  static Future<Map<String, dynamic>> createReply({
    required String songLetterId,
    required String senderId,
    required String message,
  }) async {
    try {
      final replyData = {
        'song_letter_id': songLetterId,
        'sender_id': senderId,
        'message': message,
        'created_at': ServerValue.timestamp,
      };

      final newRef = _database.ref('replies').push();
      await newRef.set(replyData);

      return {
        'success': true,
        'message': 'Reply created successfully',
        'data': {
          'id': newRef.key,
        },
      };
    } catch (error) {
      return {
        'success': false,
        'error': 'Failed to create reply: $error',
      };
    }
  }
}
