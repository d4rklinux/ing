import 'dart:convert';

import '../../services/http_service.dart';
import '../models/visita.dart';


class VisitaRepositories {
  final HttpService _httpService;

  VisitaRepositories(this._httpService);

  //Ottenere tutte le visite
  Future<List<dynamic>> getAllVisita() async {
    try {
      final response = await _httpService.sendRequest("visita", "GET");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Errore nel recupero delle visite: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Errore nella richiesta delle visite: $e');
    }
  }


  // Metodo per creare una nuova visita
  Future<String> createVisita(Visita visita) async {
    final response = await _httpService.sendRequest(
      'visita',
      'POST',
      body: visita.toJson(),
    );

    if (response.statusCode == 201) {
      return 'Visita creata con successo';
    } else {
      final body = jsonDecode(response.body);
      return 'Errore: ${body['error'] ?? 'Errore generico'}';
    }
  }

  // Metodo per approvare o rifiutare una visita da parte dell'agente
  Future<String> approvaVisita({
    required int idVisita,
    required String statoApprovazioneAgente, // 'confermata' o 'rifiutata'
    required String usernameAgenteApprovazione,
  }) async {
    try {
      final response = await _httpService.sendRequest(
        'visita/approvazione',
        'POST',
        body: {
          'id_visita': idVisita,
          'stato_approvazione_agente': statoApprovazioneAgente,
          'username_agente_approvazione': usernameAgenteApprovazione,
        },
      );

      if (response.statusCode == 200) {
        return 'Visita $statoApprovazioneAgente con successo';
      } else {
        final body = jsonDecode(response.body);
        return 'Errore: ${body['error'] ?? 'Errore generico'}';
      }
    } catch (e) {
      return 'Errore durante l\'approvazione della visita: $e';
    }
  }

  // Ottenere tutte le visite completate
  Future<List<dynamic>> getVisiteCompletate() async {
    try {
      final response = await _httpService.sendRequest("visita/completate", "GET");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Errore nel recupero delle visite completate: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Errore nella richiesta delle visite completate: $e');
    }
  }

  // Recupera le visite Completate o Annullate come Map<String, dynamic> per username
  Future<List<Map<String, dynamic>>> getVisiteCompletateAnnullatePerUsername(String username) async {
    final response = await _httpService.sendRequest('visita/$username/notifiche', 'GET');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      // Filtriamo le visite per stato "Completata" o "Annullata"
      final filteredData = data.where((visita) =>
      visita['stato_visita'] == 'Completata' || visita['stato_visita'] == 'Annullata').toList();

      return List<Map<String, dynamic>>.from(filteredData);
    } else {
      throw Exception('Errore nel recupero delle visite completate o annullate per l\'utente $username');
    }
  }

  // Ottenere tutte le visite di un utente specifico
  Future<List<dynamic>> getVisiteByUsername(String username) async {
    try {
      final response = await _httpService.sendRequest("visita/$username", "GET");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Errore nel recupero delle visite per l\'utente $username: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Errore nella richiesta delle visite per l\'utente: $e');
    }
  }

}

