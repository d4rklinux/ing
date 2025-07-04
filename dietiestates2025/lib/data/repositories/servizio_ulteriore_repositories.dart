import 'dart:convert';
import '../../services/http_service.dart';


class ServizioUlterioreRepositories {
  final HttpService _httpService;

  ServizioUlterioreRepositories(this._httpService);

  //Ottenere tutte i servizi Ulteriori
  Future<List<dynamic>> getAllServizioUlteriore() async {
    try {
      final response = await _httpService.sendRequest("servizio", "GET");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Errore nel recupero dei servizi_ulteriori: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Errore nella richiesta dei servizi: $e');
    }
  }

}