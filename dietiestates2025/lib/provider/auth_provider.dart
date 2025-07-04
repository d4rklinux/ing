import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../data/models/utente.dart';
import '../data/repositories/utente_repositories.dart';
import '../services/aut_service.dart';

import 'package:flutter/material.dart';

// Classe per gestire l'autenticazione
class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final UtenteRepositories _utenteRepo;
  Utente? _currentUser;
  bool _isLoggedIn = false;

  AuthProvider(this._authService, this._utenteRepo);

  Utente? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  // Inizializza l'autenticazione
  Future<void> initialize() async {
    _isLoggedIn = await _authService.isLoggedIn();
    if (_isLoggedIn) {
      final userData = await _authService.getUserData();
      if (userData != null) {
        _currentUser = Utente.fromJson(userData);
      }
    }
    notifyListeners();
  }

  // Effettua il login
  Future<void> login(String username, String password) async {
    try {
      final response = await _utenteRepo.login(username, password);

      final user = response['user'] as Utente;
      final token = response['token'] as String;

      await _authService.persistUserData(
        token, // Ora abbiamo il token reale
        json.encode(user.toJson()),
      );

      _currentUser = user;
      _isLoggedIn = true;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Effettua il logout
  Future<void> logout() async {
    try {
      await _utenteRepo.logout();

      await _authService.clearUserData();

      _currentUser = null;
      _isLoggedIn = false;
      notifyListeners();

    } catch (e) {
      rethrow;
    }
  }
}