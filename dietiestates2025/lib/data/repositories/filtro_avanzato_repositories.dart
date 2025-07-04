import 'dart:convert';
import '../../services/http_service.dart';


class FiltroAvanzatoRepositories {
  final HttpService _httpService;

  FiltroAvanzatoRepositories(this._httpService);

  //Ottenere tutti i Filtri Avanzati
  Future<List<dynamic>> getAllFiltroAvanzato() async {
    try {
      final response = await _httpService.sendRequest("filtro", "GET");

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