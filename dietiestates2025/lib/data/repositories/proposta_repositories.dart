import 'dart:convert';
import '../../data/models/proposta.dart';
import '../../services/http_service.dart';

/// Gestisce le operazioni relative alle proposte
class PropostaRepository {
  final HttpService _httpService = HttpService();

  // Invia una nuova proposta
  Future<String> inviaProposta(Proposta proposta) async {
    final response = await _httpService.sendRequest(
      'proposta',
      'POST',
      body: proposta.toJson(),
    );

    if (response.statusCode == 201) {
      return 'Proposta inviata con successo';
    } else {
      final body = jsonDecode(response.body);
      return '${body['error'] ?? 'Errore generico'}';
    }
  }

  // Recupera tutte le proposte come Map<String, dynamic>
  Future<List<Map<String, dynamic>>> getTutteLeProposte() async {
    final response = await _httpService.sendRequest('proposta', 'GET');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Errore nel caricamento delle proposte');
    }
  }

  // Recupera le proposte come Map<String, dynamic> per username
  Future<List<Map<String, dynamic>>> getPropostePerUsername(String username) async {
    final response = await _httpService.sendRequest('proposta/$username', 'GET');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Errore nel recupero delle proposte per l\'utente $username');
    }
  }

  // Recupera le proposte in base allo username dell'agente che ha fatto una controproposta
  Future<List<Map<String, dynamic>>> getPropostePerAgenteControproposta(String usernameAgente) async {
    final response = await _httpService.sendRequest('proposta/agente/$usernameAgente', 'GET');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception(
        'Errore nel recupero delle proposte per l\'agente $usernameAgente',
      );
    }
  }

  // Recupera le proposte Accettate o Rifiutate come Map<String, dynamic> per username
  Future<List<Map<String, dynamic>>> getProposteAccettateRifiutatePerUsername(String username) async {
    final response = await _httpService.sendRequest('proposta/$username/notifiche', 'GET');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      // Filtriamo le proposte per stato "Accettata" o "Rifiutata"
      final filteredData = data.where((proposta) =>
      proposta['stato_proposta'] == 'Accettata' || proposta['stato_proposta'] == 'Rifiutata').toList();

      return List<Map<String, dynamic>>.from(filteredData);
    } else {
      throw Exception('Errore nel recupero delle proposte accettate o rifiutate per l\'utente $username');
    }
  }

  // Cancella una proposta
  Future<String> cancellaProposta(int idProposta) async {
    final response = await _httpService.sendRequest('proposta/$idProposta', 'DELETE');

    if (response.statusCode == 200) {
      return 'Proposta cancellata con successo';
    } else {
      final body = jsonDecode(response.body);
      return 'Errore: ${body['error'] ?? 'Errore nella cancellazione'}';
    }
  }

  // Modifica una proposta esistente
  Future<String> aggiornaProposta({
    required int idProposta,
    required String statoProposta,
  }) async {
    final response = await _httpService.sendRequest(
      'proposta',
      'PUT',
      body: jsonEncode({
        'id_proposta': idProposta,
        'stato_proposta': statoProposta,
      }),
    );

    if (response.statusCode == 200) {
      return 'Proposta aggiornata con successo';
    } else {
      final body = jsonDecode(response.body);
      return 'Errore: ${body['error'] ?? 'Errore nell\'aggiornamento'}';
    }
  }

  // Invia una controproposta
  Future<String> inviaControproposta({
    required int idProposta,
    required String usernameAgenteControproposta,
    required double controproposta,
    required String statoControproposta,
  }) async {
    final response = await _httpService.sendRequest(
      'proposta/controproposta',
      'POST',
      body: jsonEncode({
        'id_proposta': idProposta,
        'username_agente_controproposta': usernameAgenteControproposta,
        'controproposta': controproposta,
        'stato_controproposta': statoControproposta,
      }),
    );

    if (response.statusCode == 200) {
      return 'Controproposta inviata con successo';
    } else {
      final body = jsonDecode(response.body);
      return 'Errore: ${body['error'] ?? 'Errore nell\'invio della controproposta'}';
    }
  }

  // Accetta o rifiuta una controproposta
  Future<String> aggiornaStatoControproposta({
    required int idProposta,
    required String statoControproposta,
  }) async {
    final response = await _httpService.sendRequest(
      'proposta/accettarifiutacontroproposta',
      'PUT',
      body: jsonEncode({
        'id_proposta': idProposta,
        'stato_controproposta': statoControproposta,
      }),
    );

    if (response.statusCode == 200) {
      return 'Stato controproposta aggiornato con successo';
    } else {
      final body = jsonDecode(response.body);
      return 'Errore: ${body['error'] ?? 'Errore nell\'aggiornamento dello stato controproposta'}';
    }
  }
}
