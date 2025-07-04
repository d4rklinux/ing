import 'dart:convert';
import '../../services/http_service.dart';

class ImmobileRepositories {
  final HttpService _httpService;

  ImmobileRepositories(this._httpService);

  // Funzione per ottenere tutti gli immobili
  Future<List<dynamic>> getImmobili() async {
    try {
      final response = await _httpService.sendRequest("immobile", "GET");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Errore nel recupero degli immobili: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Errore nella richiesta degli immobili: $e');
    }
  }

  // Funzione per ottenere un immobile specifico tramite ID
  Future<Map<String, dynamic>> getImmobileById(int id) async {
    try {
      final response = await _httpService.sendRequest("immobile/$id", "GET"); // Usa l'ID nel percorso

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Errore nel recupero del dettaglio immobile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Errore nella richiesta dell\'immobile: $e');
    }
  }

  // Funzione per cercare gli immobili con query
  Future<List<dynamic>> searchImmobili(String query) async {
    try {
      final response = await _httpService.sendRequest("immobile/ricerca?query=$query", "GET"
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Errore nella ricerca degli immobili: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Errore nella richiesta di ricerca immobili: $e');
    }
  }

  // Funzione per inserire un immobile
  Future<Map<String, dynamic>> insertImmobile(Map<String, dynamic> immobileData) async {
    try {
      final response = await _httpService.sendRequest(
          "immobile", "POST", body: immobileData,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {// 201 indica che la risorsa è stata creata
        return json.decode(response.body);
      } else {
        throw Exception('Errore nell\'inserimento dell\'immobile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Errore nella richiesta di inserimento immobile: $e');
    }
  }


}