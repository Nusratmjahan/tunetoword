import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  FirebaseService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get currentUser => _user;
  bool get isLoggedIn => _user != null;

  // Sign up
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user?.updateDisplayName(name);

      return {'success': true, 'user': userCredential.user};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': e.message ?? 'Signup failed'};
    }
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return {'success': true, 'user': userCredential.user};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': e.message ?? 'Login failed'};
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
