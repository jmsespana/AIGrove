// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:math' as math;

// Import the extracted models and widgets
import '../models/map_models.dart';
import '../widgets/map_widgets.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();

  // Caraga Region center coordinates
  static const LatLng _caragaRegionCenter = LatLng(9.0, 125.5);

  // Caraga Region bounds for focusing the map
  static final LatLngBounds _caragaBounds = LatLngBounds(
    LatLng(8.0, 124.5), // Southwest corner
    LatLng(10.5, 126.5), // Northeast corner
  );

  // Current map center
  LatLng _center = _caragaRegionCenter;

  // Markers for tree species
  final List<Marker> _markers = [];

  // Heat map indicators for species distribution
  final List<Marker> _distributionMarkers = [];

  // Environmental impact markers
  final List<Marker> _environmentalImpactMarkers = [];

  // Species count by province for distribution analysis
  final Map<String, Map<String, int>> _speciesDistribution = {
    'Agusan del Norte': {
      'Rhizophora mucronata': 120,
      'Sonneratia alba': 85,
      'Avicennia marina': 95,
    },
    'Agusan del Sur': {
      // Limited mangroves in Agusan del Sur
    },
    'Surigao del Norte': {
      'Rhizophora mucronata': 230,
      'Sonneratia alba': 195,
      'Avicennia marina': 180,
      'Bruguiera gymnorrhiza': 145,
      'Xylocarpus granatum': 90,
    },
    'Surigao del Sur': {
      'Rhizophora mucronata': 175,
      'Sonneratia alba': 140,
      'Avicennia marina': 110,
      'Bruguiera gymnorrhiza': 95,
    },
    'Dinagat Islands': {
      'Rhizophora mucronata': 205,
      'Sonneratia alba': 170,
      'Avicennia marina': 155,
      'Xylocarpus granatum': 120,
      'Ceriops tagal': 100,
    },
  };

  // Default mangrove locations with names
  final List<MangroveLocation> _mangroveLocations = [
    MangroveLocation(
      name: "Masao Mangrove Park",
      species: "Rhizophora mucronata",
      location: const LatLng(8.9956, 125.5272),
      province: "Agusan del Norte",
    ),
    MangroveLocation(
      name: "Surigao del Norte Mangroves",
      species: "Sonneratia alba",
      location: const LatLng(9.7833, 125.4167),
      province: "Surigao del Norte",
    ),
    MangroveLocation(
      name: "Surigao del Sur Mangroves",
      species: "Avicennia marina",
      location: const LatLng(8.5628, 126.1144),
      province: "Surigao del Sur",
    ),
    MangroveLocation(
      name: "Siargao Mangrove Forest",
      species: "Bruguiera gymnorrhiza",
      location: const LatLng(9.8483, 126.0458),
      province: "Surigao del Norte",
    ),
    MangroveLocation(
      name: "Dinagat Island Mangroves",
      species: "Xylocarpus granatum",
      location: const LatLng(10.1281, 125.6094),
      province: "Dinagat Islands",
    ),
    MangroveLocation(
      name: "Del Carmen Mangrove Forest",
      species: "Ceriops tagal",
      location: const LatLng(9.8617, 126.0569),
      province: "Surigao del Norte",
    ),
    MangroveLocation(
      name: "Hinatuan Mangrove Park",
      species: "Rhizophora stylosa",
      location: const LatLng(8.3667, 126.3333),
      province: "Surigao del Sur",
    ),
    MangroveLocation(
      name: "Tubay Mangrove Forest",
      species: "Avicennia officinalis",
      location: const LatLng(9.1833, 125.5333),
      province: "Agusan del Norte",
    ),
    MangroveLocation(
      name: "San Jose Mangroves",
      species: "Lumnitzera racemosa",
      location: const LatLng(9.8117, 125.6508),
      province: "Dinagat Islands",
    ),
  ];

  // Species color mapping for visualization
  final Map<String, Color> _speciesColors = {
    'Rhizophora mucronata': Colors.green.shade700,
    'Sonneratia alba': Colors.teal.shade600,
    'Avicennia marina': Colors.lightGreen.shade700,
    'Bruguiera gymnorrhiza': Colors.lime.shade800,
    'Xylocarpus granatum': Colors.cyan.shade800,
    'Ceriops tagal': Colors.indigo.shade400,
    'Rhizophora stylosa': Colors.amber.shade700,
    'Avicennia officinalis': Colors.deepOrange.shade400,
    'Lumnitzera racemosa': Colors.purple.shade400,
  };

  // State variables
  bool _isLoading = true;
  bool _showDistribution = false;
  bool _showEnvironmentalImpact = false;
  Timer? _distributionUpdateTimer;
  String _selectedProvince = 'All Provinces';
  String _selectedSpecies = 'All Species';

  // Environmental impact data (from the dashboard)
  final Map<String, EnvironmentalImpact> _environmentalImpactData = {
    'Carbon Capture': EnvironmentalImpact(
      title: 'Carbon Capture',
      value: '25.3',
      unit: 'tons/hectare',
      description: 'Annual carbon sequestration',
      icon: Icons.co2,
      color: Colors.teal,
    ),
    'Coastal Protection': EnvironmentalImpact(
      title: 'Coastal Protection',
      value: '70%',
      unit: 'wave energy',
      description: 'Reduction in coastal erosion',
      icon: Icons.waves,
      color: Colors.blue,
    ),
    'Biodiversity': EnvironmentalImpact(
      title: 'Biodiversity',
      value: '1,300+',
      unit: 'species',
      description: 'Supported by mangrove ecosystems',
      icon: Icons.pets,
      color: Colors.amber,
    ),
    'Marine Expansion': EnvironmentalImpact(
      title: 'Marine Expansion',
      value: '12.5',
      unit: 'km²/year',
      description: 'Potential growth zones',
      icon: Icons.water,
      color: Colors.indigo,
    ),
  };

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();

    // I-add ang default na mangrove locations
    _addDefaultMangroveMarkers();

    // Generate initial species distribution
    _generateSpeciesDistributionMarkers();

    // Generate environmental impact markers
    _generateEnvironmentalImpactMarkers();

    // Setup timer for periodic updates (every 30 seconds)
    _distributionUpdateTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _updateSpeciesDistribution(),
    );

    // Center the map on the Caraga region with appropriate zoom
    Future.delayed(const Duration(milliseconds: 500), () {
      _fitMapToCaraga();
    });
  }

  @override
  void dispose() {
    _distributionUpdateTimer?.cancel();
    super.dispose();
  }

  // Center and zoom map to show the entire Caraga region
  void _fitMapToCaraga() {
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: _caragaBounds,
        padding: const EdgeInsets.all(50.0),
      ),
    );
  }

  // Generate markers to visualize species distribution
  void _generateSpeciesDistributionMarkers() {
    setState(() {
      _distributionMarkers.clear();

      // Para sa kada province sa Caraga
      _speciesDistribution.forEach((province, speciesData) {
        // Skip kung walay mangroves ang province
        if (speciesData.isEmpty) return;

        // Filter by selected province if applicable
        if (_selectedProvince != 'All Provinces' &&
            province != _selectedProvince) {
          return;
        }

        // Get coordinates for this province
        final LatLng provinceCenter = _getProvinceCenterCoordinates(province);

        // Generate multiple markers around the province center
        speciesData.forEach((species, count) {
          // Filter by selected species if applicable
          if (_selectedSpecies != 'All Species' &&
              species != _selectedSpecies) {
            return;
          }

          // Determine number of markers based on count
          final int numMarkers = (count / 20).round().clamp(1, 15);

          // Generate markers around province center
          for (int i = 0; i < numMarkers; i++) {
            // Random offset to distribute markers
            final double latOffset = (math.Random().nextDouble() - 0.5) * 0.3;
            final double lngOffset = (math.Random().nextDouble() - 0.5) * 0.3;

            final markerPosition = LatLng(
              provinceCenter.latitude + latOffset,
              provinceCenter.longitude + lngOffset,
            );

            // Create the distribution marker
            _distributionMarkers.add(
              Marker(
                point: markerPosition,
                child: GestureDetector(
                  onTap: () =>
                      _showSpeciesDistributionInfo(province, species, count),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color:
                          _speciesColors[species]?.withOpacity(0.7) ??
                          Colors.green.withOpacity(0.7),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ),
            );
          }
        });
      });
    });
  }

  // Generate markers to visualize environmental impact
  void _generateEnvironmentalImpactMarkers() {
    setState(() {
      _environmentalImpactMarkers.clear();

      // I-add ang mga markers para sa environmental impact
      _speciesDistribution.forEach((province, _) {
        // Filter by selected province if applicable
        if (_selectedProvince != 'All Provinces' &&
            province != _selectedProvince) {
          return;
        }

        // Get coordinates for this province
        final LatLng provinceCenter = _getProvinceCenterCoordinates(province);

        // Add environmental impact markers for each province
        _environmentalImpactData.forEach((impactType, impactData) {
          // Random offset to distribute markers
          final double latOffset = (math.Random().nextDouble() - 0.5) * 0.2;
          final double lngOffset = (math.Random().nextDouble() - 0.5) * 0.2;

          final markerPosition = LatLng(
            provinceCenter.latitude + latOffset,
            provinceCenter.longitude + lngOffset,
          );

          // Create the environmental impact marker
          _environmentalImpactMarkers.add(
            Marker(
              point: markerPosition,
              child: GestureDetector(
                onTap: () => _showEnvironmentalImpactInfo(province, impactData),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: impactData.color.withOpacity(0.8),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(impactData.icon, color: Colors.white, size: 20),
                ),
              ),
            ),
          );
        });
      });
    });
  }

  @override
  void didUpdateWidget(covariant MapPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Regenerate markers if the selected province or species changes
    if (_selectedProvince != _selectedProvince ||
        _selectedSpecies != _selectedSpecies) {
      _generateSpeciesDistributionMarkers();
      _generateEnvironmentalImpactMarkers();
    }
  }

  // Simulate real-time updates to species distribution
  void _updateSpeciesDistribution() {
    // Randomly update some species counts to simulate real-time changes
    _speciesDistribution.forEach((province, speciesData) {
      speciesData.forEach((species, count) {
        // Random change between -5 and +10
        final change = math.Random().nextInt(16) - 5;

        // Update count ensuring it doesn't go below 0
        final newCount = (count + change).clamp(0, 500);
        _speciesDistribution[province]?[species] = newCount;
      });
    });

    // Regenerate distribution markers with updated data
    if (_showDistribution) {
      _generateSpeciesDistributionMarkers();
    }
  }

  // Get approximate center coordinates for each province in Caraga
  LatLng _getProvinceCenterCoordinates(String province) {
    switch (province) {
      case 'Agusan del Norte':
        return const LatLng(9.1167, 125.5333);
      case 'Agusan del Sur':
        return const LatLng(8.5167, 125.7000);
      case 'Surigao del Norte':
        return const LatLng(9.7833, 125.4833);
      case 'Surigao del Sur':
        return const LatLng(8.5983, 126.0144);
      case 'Dinagat Islands':
        return const LatLng(10.1281, 125.6094);
      default:
        return _caragaRegionCenter;
    }
  }

  // Show dialog with species distribution information
  void _showSpeciesDistributionInfo(
    String province,
    String species,
    int count,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$species Distribution'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Province: $province'),
            const SizedBox(height: 8),
            Text('Species: $species'),
            const SizedBox(height: 8),
            Text('Estimated count: $count trees'),
            const SizedBox(height: 16),
            const Text(
              'This data is updated in real-time based on field surveys and satellite imagery analysis.',
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Show dialog with environmental impact information
  void _showEnvironmentalImpactInfo(
    String province,
    EnvironmentalImpact impact,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(impact.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(impact.icon, color: impact.color),
                const SizedBox(width: 8),
                Text(
                  '${impact.value} ${impact.unit}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Province: $province'),
            const SizedBox(height: 8),
            Text(impact.description),
            const SizedBox(height: 16),
            const Text(
              'Mangroves play a crucial role in environmental conservation and provide numerous ecosystem services.',
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Mag-add ng default na mangrove markers
  void _addDefaultMangroveMarkers() {
    for (var mangrove in _mangroveLocations) {
      _addMangroveMarker(
        mangrove.location,
        mangrove.name,
        mangrove.species,
        mangrove.province,
      );
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
              Icon(
                Icons.forest,
                color: _speciesColors[species] ?? Colors.green,
                size: 30,
              ),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(species, style: const TextStyle(fontSize: 10)),
              ),
            ],
          ),
        ),
      );

      // Update species distribution data based on current location
      // Find which province this position belongs to
      String? province = _determineProvince(position);
      if (province != null) {
        // Update distribution data
        final currentCount = _speciesDistribution[province]?[species] ?? 0;
        if (_speciesDistribution.containsKey(province)) {
          _speciesDistribution[province]?[species] = currentCount + 1;
        } else {
          _speciesDistribution[province] = {species: 1};
        }

        // Update distribution visualization if it's enabled
        if (_showDistribution) {
          _generateSpeciesDistributionMarkers();
        }
      }
    });
  }

  // Simple method to determine which province a location belongs to
  String? _determineProvince(LatLng position) {
    // Simplified province boundary check based on coordinates
    final lat = position.latitude;
    final lng = position.longitude;

    if (lat > 8.9 && lat < 9.5 && lng > 125.3 && lng < 125.7) {
      return 'Agusan del Norte';
    } else if (lat > 8.0 && lat < 9.0 && lng > 125.5 && lng < 126.0) {
      return 'Agusan del Sur';
    } else if (lat > 9.5 && lat < 10.2 && lng > 125.0 && lng < 126.2) {
      return 'Surigao del Norte';
    } else if (lat > 8.0 && lat < 9.5 && lng > 125.7 && lng < 126.5) {
      return 'Surigao del Sur';
    } else if (lat > 9.9 && lat < 10.6 && lng > 125.4 && lng < 125.8) {
      return 'Dinagat Islands';
    }

    return null;
  }

  // Bagong method para sa pag-add ng mangrove markers
  void _addMangroveMarker(
    LatLng position,
    String name,
    String species, [
    String? province,
  ]) {
    setState(() {
      _markers.add(
        Marker(
          point: position,
          width: 110,
          height: 90,
          child: MangroveMarker(
            position: position,
            name: name,
            species: species,
            speciesColor: _speciesColors[species] ?? Colors.green,
            onTap: () => _showMangroveEditDialog(
              position,
              name,
              species,
              province ?? 'Unknown',
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
    String currentProvince,
  ) async {
    final nameController = TextEditingController(text: currentName);
    final speciesController = TextEditingController(text: currentSpecies);
    String selectedProvince = currentProvince;

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
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedProvince,
              decoration: const InputDecoration(
                labelText: 'Province',
                border: OutlineInputBorder(),
              ),
              items:
                  [
                    'Agusan del Norte',
                    'Agusan del Sur',
                    'Surigao del Norte',
                    'Surigao del Sur',
                    'Dinagat Islands',
                    'Unknown',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (value) {
                selectedProvince = value!;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  color: _speciesColors[currentSpecies] ?? Colors.green,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Species color will update automatically',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],
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
                selectedProvince,
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
    String province,
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
      _addMangroveMarker(position, newName, newSpecies, province);

      // Update distribution data if species changed
      if (oldSpecies != newSpecies && province != 'Unknown') {
        // Decrease old species count
        final oldCount = _speciesDistribution[province]?[oldSpecies] ?? 0;
        if (oldCount > 0) {
          _speciesDistribution[province]?[oldSpecies] = oldCount - 1;
        }

        // Increase new species count
        final newCount = _speciesDistribution[province]?[newSpecies] ?? 0;
        if (_speciesDistribution.containsKey(province)) {
          _speciesDistribution[province]?[newSpecies] = newCount + 1;
        } else {
          _speciesDistribution[province] = {newSpecies: 1};
        }

        // Update distribution visualization if enabled
        if (_showDistribution) {
          _generateSpeciesDistributionMarkers();
        }
      }
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
    try {
      final position = await Geolocator.getCurrentPosition();
      final location = LatLng(position.latitude, position.longitude);

      final nameController = TextEditingController(text: "New Mangrove Site");
      final speciesController = TextEditingController(text: "Unknown Species");
      String selectedProvince = _determineProvince(location) ?? 'Unknown';

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
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedProvince,
                decoration: const InputDecoration(
                  labelText: 'Province',
                  border: OutlineInputBorder(),
                ),
                items:
                    [
                      'Agusan del Norte',
                      'Agusan del Sur',
                      'Surigao del Norte',
                      'Surigao del Sur',
                      'Dinagat Islands',
                      'Unknown',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (value) {
                  selectedProvince = value!;
                },
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
                  selectedProvince,
                );

                // Update species distribution data
                if (selectedProvince != 'Unknown') {
                  final species = speciesController.text;
                  final currentCount =
                      _speciesDistribution[selectedProvince]?[species] ?? 0;

                  if (_speciesDistribution.containsKey(selectedProvince)) {
                    _speciesDistribution[selectedProvince]?[species] =
                        currentCount + 1;
                  } else {
                    _speciesDistribution[selectedProvince] = {species: 1};
                  }

                  if (_showDistribution) {
                    _generateSpeciesDistributionMarkers();
                  }
                }

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
              initialCenter: _center,
              initialZoom: 8.0, // Lower zoom to show more of the region
              maxZoom: 18,
              onTap: (_, __) {
                // Hide any open tooltips or info windows when map is tapped
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.aigrove.app',
              ),
              // Show distribution markers if enabled
              if (_showDistribution) MarkerLayer(markers: _distributionMarkers),
              // Show environmental impact markers if enabled
              if (_showEnvironmentalImpact)
                MarkerLayer(markers: _environmentalImpactMarkers),
              // Show regular markers
              MarkerLayer(markers: _markers),
              // I-add ang current location marker
              const CurrentLocationLayer(),
            ],
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),

          // Province selector
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Caraga Region Mangroves',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _selectedProvince,
                    isDense: true,
                    underline: Container(height: 1, color: Colors.green),
                    dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    items:
                        <String>[
                          'All Provinces',
                          'Agusan del Norte',
                          'Surigao del Norte',
                          'Surigao del Sur',
                          'Dinagat Islands',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedProvince = newValue!;

                        // Update visualization if enabled
                        if (_showDistribution) {
                          _generateSpeciesDistributionMarkers();
                        }

                        // Move map to province if specific province selected
                        if (_selectedProvince != 'All Provinces') {
                          _mapController.move(
                            _getProvinceCenterCoordinates(_selectedProvince),
                            9.0,
                          );
                        } else {
                          _fitMapToCaraga();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 4),
                  DropdownButton<String>(
                    value: _selectedSpecies,
                    isDense: true,
                    underline: Container(height: 1, color: Colors.green),
                    dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    items:
                        <String>[
                          'All Species',
                          ...{..._speciesColors.keys},
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSpecies = newValue!;

                        // Update visualization if enabled
                        if (_showDistribution) {
                          _generateSpeciesDistributionMarkers();
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // Legend for mangroves
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).scaffoldBackgroundColor.withOpacity(0.95),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mangrove Species',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.park,
                        color: const Color(0xFF2E7D32),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Mangrove Location',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                  if (_showDistribution) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Species Distribution',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ..._speciesColors.entries.take(5).map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: entry.value,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 8),
                  // Toggle switch for distribution view
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showDistribution = !_showDistribution;
                        if (_showDistribution) {
                          _generateSpeciesDistributionMarkers();
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _showDistribution
                            ? Colors.green
                            : Colors.grey.shade600,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _showDistribution
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _showDistribution
                                ? 'Hide Distribution'
                                : 'Show Distribution',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Toggle switch for environmental impact view
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showEnvironmentalImpact = !_showEnvironmentalImpact;
                        if (_showEnvironmentalImpact) {
                          _generateEnvironmentalImpactMarkers();
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _showEnvironmentalImpact
                            ? Colors.teal
                            : Colors.grey.shade600,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _showEnvironmentalImpact
                                ? Icons.eco
                                : Icons.eco_outlined,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _showEnvironmentalImpact
                                ? 'Hide Impact Data'
                                : 'Show Impact Data',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Show environmental impact legend if enabled
                  if (_showEnvironmentalImpact) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Environmental Impact',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ..._environmentalImpactData.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Icon(
                              entry.value.icon,
                              color: entry.value.color,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),

          // Info panel at bottom to show real-time data
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Real-time Species Distribution',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedProvince == 'All Provinces'
                          ? 'Viewing mangrove data across the Caraga Region'
                          : 'Viewing mangrove data for $_selectedProvince',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedSpecies == 'All Species'
                          ? 'All mangrove species are displayed'
                          : 'Filtered to show only $_selectedSpecies',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap on distribution indicators to view detailed species information',
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
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
            onPressed: _fitMapToCaraga,
            heroTag: 'showRegion',
            mini: true,
            backgroundColor: Colors.amber,
            child: const Icon(Icons.crop_free),
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
