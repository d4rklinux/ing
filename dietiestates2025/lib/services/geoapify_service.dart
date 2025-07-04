import 'dart:convert';
import 'package:http/http.dart' as http;
import 'http_service.dart';

class GeoapifyService {
  final HttpService _httpService = HttpService();

  // Metodo per ottenere le coordinate
  Future<Map<String, double>?> getCoordinatesFromAddress(String address) async {
    final String backendUrl = '${_httpService.getApiBaseUrl()}/geoapify/get-coordinates';
    final response = await http.get(Uri.parse('$backendUrl?address=${Uri.encodeComponent(address)}'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'lat': data['lat'].toDouble(),
        'lon': data['lon'].toDouble()
      };
    }
    return null;
  }

  // Metodo per ottenere i luoghi vicini
  Future<Map<String, dynamic>?> getNearbyPlaces({
    required String address,
    List<String> categories = const [],
    int radius = 5000,
    int limit = 20
  }) async {
    final String backendUrl = '${_httpService.getApiBaseUrl()}/geoapify/get-nearby-places';

    final uri = Uri.parse(backendUrl).replace(
        queryParameters: {
          'address': address,
          if (categories.isNotEmpty) 'categories': categories.join(','),
          'radius': radius.toString(),
          'limit': limit.toString()
        }
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }
}