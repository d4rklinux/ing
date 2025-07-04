import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _keyToken = 'auth_token';
  static const _keyUserData = 'user_data'; // Per salvare i dati dell'utente
  static const _keyIsLoggedIn = 'is_logged_in';

  Future<void> persistUserData(String token, String userJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUserData, userJson);
    print('JWT Token: $token');
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_keyUserData);
    return userJson != null ? json.decode(userJson) : null;
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserData);
    await prefs.setBool(_keyIsLoggedIn, false);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }
}