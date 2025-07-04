import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../data/repositories/geoapify_repositories.dart';
import '../services/geoapify_service.dart';

class MapPage extends StatefulWidget {
  final double lat;
  final double lon;
  final String locationName;

  const MapPage({
    super.key,
    required this.lat,
    required this.lon,
    required this.locationName,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final MapController _mapController;
  final GeoapifyRepository _geoapifyRepository = GeoapifyRepository(GeoapifyService());
  List<dynamic> _nearbyPlaces = [];
  bool _isLoading = false;
  bool _showLegend = false;
  bool _showParks = true;
  bool _showSchools = true;
  bool _showBusStops = true;
  bool _showAttractions = true;
  bool _showTransport = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNearbyPlaces());
  }

  //Carica i posti di interesse vicini alla posizione
  Future<void> _loadNearbyPlaces() async {
    setState(() => _isLoading = true);
    try {
      final places = await _geoapifyRepository.fetchNearbyPlaces(
        address: widget.locationName,
        categories: [
          'education', 'building.transportation', 'tourism',
          'public_transport', 'leisure.park'
        ],
        radius: 2000,
        limit: 20,
      );
      if (mounted) {
        setState(() => _nearbyPlaces = places);
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Errore'),
              content: Text('Impossibile caricare i luoghi: ${e.toString()}'),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  //Filtro per mostrare solo i posti di interesse
  bool _shouldShowPlace(Map<String, dynamic> place) {
    List<String> categories = List<String>.from(place['categories'] ?? []);
    if (_showParks && categories.any((c) => c.contains('leisure.park'))) {
      return true;
    }
    if (_showSchools && categories.any((c) => c.contains('education'))) {
      return true;
    }
    if (_showBusStops && categories.any((c) => c.contains('public_transport'))) {
      return true;
    }
    if (_showAttractions && categories.any((c) => c.contains('tourism'))) {
      return true;
    }
    if (_showTransport && categories.any((c) => c.contains('building.transportation'))) {
      return true;
    }
    return false;
  }

  //Crea il layer per i posti di interesse
  MarkerLayer _buildNearbyPlacesLayer() {
    return MarkerLayer(
      markers: _nearbyPlaces
          .where((place) => _shouldShowPlace(place))
          .map((entry) {
        final place = entry;
        final lat = place['lat'] as double;
        final lon = place['lon'] as double;
        final name = place['name'] ?? 'Luogo';
        final categories = place['categories']?.join(', ') ?? '';

        return Marker(
          point: LatLng(lat, lon),
          width: 40,
          height: 40,
          child: Tooltip(
            message: '$name\n${categories.replaceAll(',', '\n')}',
            child: Icon(
              _getIconForCategories(place['categories'] ?? []),
              color: _getMarkerColorForCategories(place['categories'] ?? []),
              size: 40,
            ),
          ),
        );
      }).toList(),
    );
  }

  //Icone per i posti di interesse
  IconData _getIconForCategories(List<dynamic> categories) {
    if (categories.any((c) => c.toString().contains('education'))) {
      return Icons.school;
    }
    if (categories.any((c) => c.toString().contains('building.transportation'))) {
      return Icons.train; // Ferrovia/tram
    }
    if (categories.any((c) => c.toString().contains('public_transport'))) {
      return Icons.train; // Ferrovia/tram
    }
    if (categories.any((c) => c.toString().contains('tourism'))) {
      return Icons.attractions;
    }
    if (categories.any((c) => c.toString().contains('leisure.park'))) {
      return Icons.park;
    }
    return Icons.pin_drop;
  }

  //Colore per i posti di interesse
  Color _getMarkerColorForCategories(List<dynamic> categories) {
    if (categories.any((c) => c.toString().contains('education'))) {
      return Colors.pink;
    }
    if (categories.any((c) => c.toString().contains('building.transportation'))) {
      return Colors.red; // Ferrovia/tram in rosso
    }
    if (categories.any((c) => c.toString().contains('public_transport'))) {
      return Colors.blue;
    }
    if (categories.any((c) => c.toString().contains('tourism'))) {
      return Colors.orange;
    }
    if (categories.any((c) => c.toString().contains('leisure.park'))) {
      return Colors.green;
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildMap(),
          _buildZoomControls(),
          _buildLegendButton(),
          if (_isLoading) _buildLoadingIndicator(),
          if (_showLegend) _buildLegend(),
        ],
      ),
    );
  }

  //Creazione dell'appbar
  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: _buildAppBarTitle(),
      backgroundColor: const Color(0xFF0079BB),
    );
  }

  //Creazione del titolo dell'appbar
  Widget _buildAppBarTitle() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Mappa',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (widget.locationName.isNotEmpty)
        Text(
          widget.locationName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  //Creazione della mappa
  Widget _buildMap() {
    return FlutterMap(
      key: ValueKey(_nearbyPlaces.length),
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(widget.lat, widget.lon),
        initialZoom: 15.0,
        minZoom: 3,
        maxZoom: 18,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: 'com.example.app',
        ),
        _buildNearbyPlacesLayer(),
        _buildMarkerLayer(),
      ],
    );
  }

  //Creazione del marker
  MarkerLayer _buildMarkerLayer() {
    return MarkerLayer(
      markers: [
        Marker(
          point: LatLng(widget.lat, widget.lon),
          width: 50,
          height: 50,
          child: const Icon(
            Icons.location_pin,
            color: Colors.red,
            size: 50,
          ),
        ),
      ],
    );
  }

  Widget _buildZoomControls() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        children: [
          _buildZoomInButton(),
          const SizedBox(height: 10),
          _buildZoomOutButton(),
        ],
      ),
    );
  }

  //Creazione dei pulsanti di zoom
  Widget _buildZoomInButton() {
    return FloatingActionButton(
      heroTag: "zoom_in",
      onPressed: () =>
          _mapController.move(
            _mapController.camera.center,
            _mapController.camera.zoom + 1,
          ),
      mini: true,
      backgroundColor: Colors.white,
      child: const Icon(Icons.zoom_in, color: Colors.black),
    );
  }

  //Creazione dei pulsanti di zoom
  Widget _buildZoomOutButton() {
    return FloatingActionButton(
      heroTag: "zoom_out",
      onPressed: () =>
          _mapController.move(
            _mapController.camera.center,
            _mapController.camera.zoom - 1,
          ),
      mini: true,
      backgroundColor: Colors.white,
      child: const Icon(Icons.zoom_out, color: Colors.black),
    );
  }

  //Creazione dell'indicatore di caricamento
  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.blue,
        strokeWidth: 4,
      ),
    );
  }

  //Creazione della legenda
  Widget _buildLegendButton() {
    return Positioned(
      top: 20,
      left: 20,
      child: FloatingActionButton(
        onPressed: () {
          setState(() {
            _showLegend = !_showLegend;
          });
        },
        backgroundColor: Colors.white,
        child: Icon(
          Icons.info_outline,
          color: _showLegend ? Colors.orange : Colors
              .blue,
        ),
      ),
    );
  }

  //Creazione della legenda
  Widget _buildLegend() {
    return Positioned(
      top: 90,
      left: 20,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem(Icons.school, 'Scuole', _showSchools, (value) {
                setState(() {
                  _showSchools = value;
                });
                _loadNearbyPlaces();
              }),
              _buildLegendItem(Icons.park, 'Parchi', _showParks, (value) {
                setState(() {
                  _showParks = value;
                });
                _loadNearbyPlaces();
              }),
              _buildLegendItem(
                  Icons.directions_bus, 'Fermate Bus', _showBusStops, (value) {
                setState(() {
                  _showBusStops = value;
                });
                _loadNearbyPlaces();
              }),
              _buildLegendItem(
                  Icons.train, 'Trasporti Pubblici', _showTransport, (value) {
                setState(() {
                  _showTransport = value;
                });
                _loadNearbyPlaces();
              }),
              _buildLegendItem(
                  Icons.attractions, 'Attrazioni', _showAttractions, (value) {
                setState(() {
                  _showAttractions = value;
                });
                _loadNearbyPlaces();
              }),

            ],
          ),
        ),
      ),
    );
  }

  //Creazione della legenda
  Widget _buildLegendItem(IconData icon, String label, bool value,
      ValueChanged<bool> onChanged) {
    Color iconColor;
    if (icon == Icons.school) {
      iconColor = Colors.pink;
    } else if (icon == Icons.park) {
      iconColor = Colors.green;
    } else if (icon == Icons.directions_bus) {
      iconColor = Colors.blue;
    } else if (icon == Icons.attractions) {
      iconColor = Colors.orange;
    } else if (icon == Icons.train) {
      iconColor = Colors.red;
    } else {
      iconColor = Colors.black;
    }
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor,
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.orange,
          inactiveThumbColor: Colors.blue,
        ),
        Text(
          label,
          style: TextStyle(
            color: iconColor,
          ),
        ),
      ],
    );
  }

}
