import 'package:flutter/material.dart';
import 'api_service_new.dart';

class AuthService extends ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _isLoading = false;

  AuthService() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    await ApiService.init();
    // Try to get current user if token exists
    final result = await ApiService.getCurrentUser();
    if (result['success']) {
      _user = result['user'];
      notifyListeners();
    }
  }

  Map<String, dynamic>? get currentUser => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;

  // Get user ID as string for compatibility
  String? get currentUserId => _user?['id']?.toString();

  // Sign up
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await ApiService.signup(
      email: email,
      password: password,
      name: name,
    );

    if (result['success']) {
      _user = result['user'];
    }

    _isLoading = false;
    notifyListeners();

    return result;
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await ApiService.login(
      email: email,
      password: password,
    );

    if (result['success']) {
      _user = result['user'];
    }

    _isLoading = false;
    notifyListeners();

    return result;
  }

  // Logout
  Future<void> logout() async {
    await ApiService.logout();
    _user = null;
    notifyListeners();
  }
}
