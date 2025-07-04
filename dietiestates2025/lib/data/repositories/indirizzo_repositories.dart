import 'dart:convert';
import '../models/Indirizzo.dart';
import '../../services/http_service.dart'; // Corretto import

class IndirizzoRepositories {
  final HttpService httpService;

  IndirizzoRepositories(this.httpService);

  // Ottenere tutti gli indirizzi
  Future<List<Indirizzo>> getIndirizzi() async {
    try {
      final response = await httpService.sendRequest("indirizzo", "GET");

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Indirizzo.fromJson(item)).toList();
      } else {
        throw Exception('Errore nel recupero degli indirizzi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Errore durante la richiesta degli indirizzi: $e');
    }
  }

  // Creare un nuovo indirizzo
  Future<void> createIndirizzo(Indirizzo indirizzo) async {
    try {
      final response = await httpService.sendRequest(
        "indirizzo",
        'POST',
        headers: {'Content-Type': 'application/json'},
        body: json.encode(indirizzo.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception('Errore nella creazione dell\'indirizzo: ${response.body}');
      }
    } catch (e) {
      throw Exception('Errore durante la richiesta di creazione indirizzo: $e');
    }
  }

  // Aggiornare un indirizzo
  Future<void> updateIndirizzo(Indirizzo indirizzo) async {
    try {
      final response = await httpService.sendRequest(
        "indirizzo/${indirizzo.idIndirizzo}",
        'PUT',
        headers: {'Content-Type': 'application/json'},
        body: json.encode(indirizzo.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Errore nell\'aggiornamento dell\'indirizzo: ${response.body}');
      }
    } catch (e) {
      throw Exception('Errore durante la richiesta di aggiornamento indirizzo: $e');
    }
  }

  // Eliminare un indirizzo
  Future<void> deleteIndirizzo(int idIndirizzo) async {
    try {
      final response = await httpService.sendRequest(
        "indirizzo/$idIndirizzo",
        'DELETE',
      );

      if (response.statusCode != 200) {
        throw Exception('Errore nell\'eliminazione dell\'indirizzo: ${response.body}');
      }
    } catch (e) {
      throw Exception('Errore durante la richiesta di eliminazione indirizzo: $e');
    }
  }

  // Ricerca di indirizzi
  Future<List<Indirizzo>> searchIndirizzi(String query) async {
    try {
      final searchUrl = 'indirizzo/ricerca?query=$query';
      final response = await httpService.sendRequest(searchUrl, 'GET');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Indirizzo.fromJson(item)).toList();
      } else {
        throw Exception('Errore nella ricerca degli indirizzi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Errore durante la richiesta di ricerca indirizzi: $e');
    }
  }
}
