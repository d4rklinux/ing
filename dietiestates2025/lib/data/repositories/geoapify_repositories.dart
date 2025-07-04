import '../../services/geoapify_service.dart';


class GeoapifyRepository {
  final GeoapifyService _service;

  GeoapifyRepository(this._service);

  Future<List<dynamic>> fetchNearbyPlaces({
    required String address,
    required List<String> categories,
    required int radius,
    required int limit,
  }) async {
    final result = await _service.getNearbyPlaces(
      address: address,
      categories: categories,
      radius: radius,
      limit: limit,
    );

    return result?['places'] ?? [];
  }
}
