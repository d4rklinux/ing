import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'aut_service.dart';

class RecentSearchesService {
  final String _baseKey = 'recent_searches';

  Future<String?> _getUsername() async {
    final userData = await AuthService().getUserData();
    return userData?['username_utente'];
  }

  // Salva un immobile (oggetto) come JSON stringa
  Future<void> saveSearch(Map<String, dynamic> immobile) async {
    final prefs = await SharedPreferences.getInstance();
    final username = await _getUsername();
    if (username == null) return;
    final key = '$_baseKey$username';
    final searchesJsonList = prefs.getStringList(key) ?? [];

    // Serializza immobile in JSON
    final newSearchJson = jsonEncode(immobile);
    // Se già presente, rimuovi la vecchia occorrenza
    searchesJsonList.removeWhere((jsonItem) => jsonItem == newSearchJson);
    // Inserisci l'elemento in testa
    searchesJsonList.insert(0, newSearchJson);

    // Mantieni massimo 3 elementi
    if (searchesJsonList.length > 5) {
      searchesJsonList.removeLast();
    }

    await prefs.setStringList(key, searchesJsonList);
  }

  // Recupera la lista di immobile deserializzati
  Future<List<Map<String, dynamic>>> getSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final username = await _getUsername();
    if (username == null) return [];

    final key = '$_baseKey$username';
    final searchesJsonList = prefs.getStringList(key) ?? [];

    // Decodifica ogni JSON in Map
    return searchesJsonList.map((jsonStr) => jsonDecode(jsonStr) as Map<String, dynamic>).toList();
  }

  // Rimuove tutte le ricerche dell'utente
  Future<void> clearAllSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final username = await _getUsername();
    if (username == null) return;

    final key = '$_baseKey$username';
    await prefs.remove(key);
  }
}