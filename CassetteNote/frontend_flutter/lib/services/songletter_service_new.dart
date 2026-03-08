import 'dart:io';
import 'api_service_new.dart';

class SongLetterServiceNew {
  // Upload photo to backend
  static Future<Map<String, dynamic>> uploadPhoto({
    required File photoFile,
  }) async {
    return await ApiService.uploadPhoto(photoFile);
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
    return await ApiService.createSongLetter(
      songLink: songLink,
      letter: letter,
      password: password,
      receiverEmail: receiverEmail,
      colorTheme: colorTheme,
      emotionTag: emotionTag,
      photoUrl: photoUrl,
    );
  }

  // Get song letter by code with password verification
  static Future<Map<String, dynamic>> getSongLetterByCode({
    required String code,
    required String password,
  }) async {
    return await ApiService.accessSongLetter(
      code: code,
      password: password,
    );
  }

  // Get all song letters sent by the current user
  static Future<Map<String, dynamic>> getSentLetters() async {
    return await ApiService.getSentLetters();
  }
}
