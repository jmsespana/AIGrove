import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();

  // Butuan City coordinates
  static const LatLng _butuanCity = LatLng(8.9475, 125.5406);

  // Current map center
  LatLng _center = _butuanCity;

  // Markers for tree species
  final List<Marker> _markers = [];

  // Default mangrove locations with names
  final List<MangroveLocation> _mangroveLocations = [
    MangroveLocation(
      name: "Masao Mangrove Park",
      species: "Rhizophora mucronata",
      location: const LatLng(8.9956, 125.5272),
    ),
    MangroveLocation(
      name: "Surigao del Norte Mangroves",
      species: "Sonneratia alba",
      location: const LatLng(9.7833, 125.4167),
    ),
    MangroveLocation(
      name: "Surigao del Sur Mangroves",
      species: "Avicennia marina",
      location: const LatLng(8.5628, 126.1144),
    ),
    MangroveLocation(
      name: "Siargao Mangrove Forest",
      species: "Bruguiera gymnorrhiza",
      location: const LatLng(9.8483, 126.0458),
    ),
    MangroveLocation(
      name: "Dinagat Island Mangroves",
      species: "Xylocarpus granatum",
      location: const LatLng(10.1281, 125.6094),
    ),
    MangroveLocation(
      name: "Del Carmen Mangrove Forest",
      species: "Ceriops tagal",
      location: const LatLng(9.8617, 126.0569),
    ),
  ];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();

    // I-add ang default na mangrove locations
    _addDefaultMangroveMarkers();
  }

  // Mag-add ng default na mangrove markers
  void _addDefaultMangroveMarkers() {
    for (var mangrove in _mangroveLocations) {
      _addMangroveMarker(mangrove.location, mangrove.name, mangrove.species);
    }
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      // Kung dili ka granted ang permission, gamiton ang default location
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _center = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Add tree marker to map
  void _addTreeMarker(LatLng position, String species) {
    setState(() {
      _markers.add(
        Marker(
          point: position,
          width: 80,
          height: 80,
          child: Column(
            children: [
              const Icon(Icons.forest, color: Colors.green, size: 30),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(species, style: const TextStyle(fontSize: 10)),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Bagong method para sa pag-add ng mangrove markers
  void _addMangroveMarker(LatLng position, String name, String species) {
    setState(() {
      _markers.add(
        Marker(
          point: position,
          width: 110,
          height: 90,
          child: GestureDetector(
            onTap: () => _showMangroveEditDialog(position, name, species),
            child: Column(
              children: [
                const Icon(
                  Icons.park,
                  color: Color(0xFF2E7D32), // Forest green color
                  size: 35,
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.green.shade800, width: 1),
                  ),
                  child: Column(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        species,
                        style: TextStyle(
                          fontSize: 9,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // Dialog para sa pag-edit ng mangrove info
  Future<void> _showMangroveEditDialog(
    LatLng position,
    String currentName,
    String currentSpecies,
  ) async {
    final nameController = TextEditingController(text: currentName);
    final speciesController = TextEditingController(text: currentSpecies);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Mangrove Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Mangrove Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: speciesController,
              decoration: const InputDecoration(labelText: 'Species'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // I-update ang marker sa map
              _updateMangroveMarker(
                position,
                currentName,
                currentSpecies,
                nameController.text,
                speciesController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Update ng existing marker
  void _updateMangroveMarker(
    LatLng position,
    String oldName,
    String oldSpecies,
    String newName,
    String newSpecies,
  ) {
    setState(() {
      // I-remove ang old marker
      _markers.removeWhere((marker) {
        if (marker.point == position) {
          // Simple check kung pareho ang position
          return true;
        }
        return false;
      });

      // I-add ang updated marker
      _addMangroveMarker(position, newName, newSpecies);
    });
  }

  // Add this method to handle scanned trees
  Future<void> addScannedTree(String species, {LatLng? location}) async {
    try {
      final Position position = location == null
          ? await Geolocator.getCurrentPosition()
          : Position(
              latitude: location.latitude,
              longitude: location.longitude,
              timestamp: DateTime.now(),
              accuracy: 0,
              altitude: 0,
              altitudeAccuracy: 0,
              heading: 0,
              headingAccuracy: 0,
              speed: 0,
              speedAccuracy: 0,
            );

      final newPosition = LatLng(position.latitude, position.longitude);
      _addTreeMarker(newPosition, species);

      // Animate map to new marker
      _mapController.move(newPosition, 15);
    } catch (e) {
      debugPrint('Error adding scanned tree: $e');
    }
  }

  // Bagong method para sa pag-add ng custom mangrove location
  void _addCustomMangroveLocation() async {
    // Kuha muna ng current position para default location ng bagong mangrove
    try {
      final position = await Geolocator.getCurrentPosition();
      final location = LatLng(position.latitude, position.longitude);

      final nameController = TextEditingController(text: "New Mangrove Site");
      final speciesController = TextEditingController(text: "Unknown Species");

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add New Mangrove Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Location Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: speciesController,
                decoration: const InputDecoration(
                  labelText: 'Mangrove Species',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addMangroveMarker(
                  location,
                  nameController.text,
                  speciesController.text,
                );
                _mapController.move(location, 15);
                Navigator.pop(context);
              },
              child: const Text('Add Location'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Error creating custom mangrove location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center, // Updated from center to initialCenter
              initialZoom: 15.0, // Updated from zoom to initialZoom
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.aigrove.app',
              ),
              MarkerLayer(markers: _markers),
              // I-add ang current location marker
              CurrentLocationLayer(),
            ],
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),

          // Legend for mangroves
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mangrove Species',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.park, color: Color(0xFF2E7D32), size: 16),
                      SizedBox(width: 4),
                      Text('Mangrove Location', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _addCustomMangroveLocation,
            heroTag: 'addMangrove',
            mini: true,
            child: const Icon(Icons.add_location),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () async {
              final position = await Geolocator.getCurrentPosition();
              final userLocation = LatLng(
                position.latitude,
                position.longitude,
              );
              _mapController.move(userLocation, 15);
            },
            heroTag: 'myLocation',
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }
}

// Model class para sa mangrove location
class MangroveLocation {
  final String name;
  final String species;
  final LatLng location;

  MangroveLocation({
    required this.name,
    required this.species,
    required this.location,
  });
}

// Simple implementation of a current location layer
class CurrentLocationLayer extends StatelessWidget {
  const CurrentLocationLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Position>(
      stream: Geolocator.getPositionStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        final position = snapshot.data!;
        return MarkerLayer(
          markers: [
            Marker(
              point: LatLng(position.latitude, position.longitude),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.blue.withOpacity(0.7),
                  shape: BoxShape.circle,
                  border: Border.all(width: 2, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
