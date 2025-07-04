import 'dart:convert';
import '../../services/http_service.dart';


class RuoloRepositories {
  final HttpService _httpService;

  RuoloRepositories(this._httpService);

  //Ottenere tutti i ruoli
  Future<List<dynamic>> getAllRuolo() async {
    try {
      final response = await _httpService.sendRequest("ruolo", "GET");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Errore nel recupero dei ruoli: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Errore nella richiesta dei ruoli: $e');
    }
  }

}