import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _userModel;
  bool _isLoadingUser = false;

  UserModel? get userModel => _userModel;
  bool get isLoadingUser => _isLoadingUser;


  // Difiere notifyListeners() al siguiente frame para evitar
  // "setState() called during build"
  void _safeNotify() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try { notifyListeners(); } catch (_) {}
    });
  }

  Future<void> loadUserData(String uid) async {
    _isLoadingUser = true;
    _safeNotify();

    _userModel = await _authService.getUserData(uid);

    _isLoadingUser = false;
    _safeNotify();
  }

  void clearUser() {
    _userModel = null;
    notifyListeners();
  }

  Future<User> signIn({required String email, required String password}) =>
      _authService.signIn(email: email, password: password);

  Future<User> register({
    required String name,
    required String company,
    required String email,
    required String password,
  }) =>
      _authService.register(
          name: name, company: company, email: email, password: password);

  Future<void> signOut() async {
    await _authService.signOut();
    clearUser();
  }

  Future<void> sendPasswordResetEmail(String email) =>
      _authService.sendPasswordResetEmail(email);

  Stream<User?> get authStateChanges => _authService.authStateChanges;
}