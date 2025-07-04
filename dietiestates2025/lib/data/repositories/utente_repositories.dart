import 'dart:convert';

import '../../services/http_service.dart';
import '../models/utente.dart';

class UtenteRepositories {
  final HttpService _httpService;

  UtenteRepositories(this._httpService);

  // Metodo per effettuare il login
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _httpService.sendRequest(
        'utente/login',
        'POST',
        body: {'username_utente': username, 'password': password},
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Estrai il token dal cookie (se presente)
        final token = response.headers['set-cookie']
            ?.split(';')
            .firstWhere((part) => part.trim().startsWith('auth_token='))
            .split('=')
            .last;

        if (token == null) {
          throw Exception('Token non ricevuto dal server');
        }

        return {
          'user': Utente.fromJson(responseData), // Mappa i campi come nel tuo modello
          'token': token,
        };
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Metodo per cambiare la password
  Future<void> changePassword({
    required String username,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _httpService.sendRequest(
        'utente/change-password',
        'POST',
        body: {
          'username_utente': username,
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        },
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? 'Errore nel cambio password';
        throw Exception(message);
      }
    } catch (e) {
      throw Exception('Errore durante il cambio password: $e');
    }
  }

  // Metodo per effettuare il logout
  Future<void> logout() async {
    try {
      await _httpService.sendRequest('utente/logout', 'POST');
      await _httpService.clearAuthData(); // Usa il nuovo metodo pubblico
    } catch (e) {
      rethrow;
    }
  }

  // Ottenere tutti gli utenti
  Future<List<Utente>> getAllUtenti() async {
    try {
      final response = await _httpService.sendRequest('utente', 'GET');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Utente.fromJson(json)).toList();
      } else {
        throw Exception('Errore durante il recupero degli utenti');
      }
    } catch (e) {
      throw Exception('Errore: $e');
    }
  }

  // Ottenere un utente specifico
  Future<Utente> getUtenteByUsername(String username) async {
    try {
      final response = await _httpService.sendRequest('utente/$username', 'GET');
      if (response.statusCode == 200) {
        return Utente.fromJson(json.decode(response.body));
      } else {
        throw Exception('Utente non trovato');
      }
    } catch (e) {
      throw Exception('Errore: $e');
    }
  }

  // Registrare un nuovo utente
  Future<void> createUtente(Utente utente) async {
    try {
      final response = await _httpService.sendRequest(
        'utente',
        'POST',
        body: utente.toJson(),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 201) {
        throw Exception('Errore: ${response.body}');
      }
    } catch (e) {
      throw Exception('Errore nella registrazione: $e');
    }
  }


  // Aggiornare un utente
  Future<void> updateUtente(String username, Utente utente) async {
    try {
      final response = await _httpService.sendRequest(
        'utente/$username',
        'PUT',
        body: utente.toJson(),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Errore durante l\'aggiornamento dell\'utente');
      }
    } catch (e) {
      throw Exception('Errore: $e');
    }
  }

  // Eliminare un utente
  Future<void> deleteUtente(String username) async {
    try {
      final response = await _httpService.sendRequest('utente/$username', 'DELETE');
      if (response.statusCode != 200) {
        throw Exception('Errore durante l\'eliminazione dell\'utente');
      }
    } catch (e) {
      throw Exception('Errore: $e');
    }
  }
}