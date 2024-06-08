import 'package:flutter/material.dart';
import '/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _user;

  Map<String, dynamic>? get user => _user;

  Future<void> login(String username, String password) async {
    _user = await _authService.login(username, password);
    notifyListeners();
  }

  Future<void> loadCurrentUser() async {
    _user = await _authService.getCurrentUser();
    notifyListeners();
  }

  Future<void> refreshSession() async {
    await _authService.refreshSession();
    await loadCurrentUser();
  }
}
