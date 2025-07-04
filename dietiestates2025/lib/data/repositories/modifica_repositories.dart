import 'dart:convert';
import '../../services/http_service.dart';


class ModificaRepositories {
  final HttpService _httpService;

  ModificaRepositories(this._httpService);

  //Ottenere tutte le modifiche effettuate
  Future<List<dynamic>> getAllModifica() async {
    try {
      final response = await _httpService.sendRequest("modifica", "GET");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Errore nel recupero dei filtri avanzati: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Errore nella richiesta dei filtri: $e');
    }
  }

}