import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final _storage = FlutterSecureStorage();
  final String _loginUrl = 'https://dummyjson.com/auth/login';
  final String _meUrl = 'https://dummyjson.com/auth/me';
  final String _refreshUrl = 'https://dummyjson.com/auth/refresh';

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(_loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _storage.write(key: 'token', value: data['token']);
      await _storage.write(key: 'refreshToken', value: data['refreshToken']);
      return data;
    } else {
      throw Exception('Failed to log in');
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final token = await _storage.read(key: 'token');
    final response = await http.get(
      Uri.parse(_meUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<void> refreshSession() async {
    final refreshToken = await _storage.read(key: 'refreshToken');
    final response = await http.post(
      Uri.parse(_refreshUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _storage.write(key: 'token', value: data['token']);
      await _storage.write(key: 'refreshToken', value: data['refreshToken']);
    } else {
      throw Exception('Failed to refresh session');
    }
  }
}
