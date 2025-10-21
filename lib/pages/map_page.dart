// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'dart:async';

// Import services ug models
import '../services/user_service.dart';
import '../models/map_models.dart';
import '../widgets/map_widgets.dart';

/// Map Page - I-display ang mangrove locations
///
/// Features:
/// 1. User's scanned mangrove locations (blue markers)
/// 2. Default mangrove locations sa Caraga Region (green markers)
/// 3. Interactive markers with details
class MapPage extends StatefulWidget {
  final String? filterSpecies;

  const MapPage({super.key, this.filterSpecies});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();

  // Caraga Region center coordinates
  static const LatLng _caragaRegionCenter = LatLng(9.0, 125.5);

  // Caraga Region bounds
  static final LatLngBounds _caragaBounds = LatLngBounds(
    LatLng(8.0, 124.5),
    LatLng(10.5, 126.5),
  );

  LatLng _center = _caragaRegionCenter;

  // Markers
  final List<Marker> _markers = [];
  final List<Marker> _userScanMarkers = [];

  // Default mangrove locations
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

  // Species colors
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

  // State
  bool _isLoading = true;
  bool _showUserScans = true;
  bool _showLegend = true;
  bool _showInfoPanel = true;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _addDefaultMangroveMarkers();
    _loadUserScanLocations();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (widget.filterSpecies != null) {
        _focusOnSpecies(widget.filterSpecies!);
      } else {
        _fitMapToCaraga();
      }
    });
  }

  /// BAG-O: Load user scan locations
  Future<void> _loadUserScanLocations() async {
    try {
      final userService = context.read<UserService>();
      await userService.loadUserScans();

      final scans = userService.userScans;

      debugPrint('🗺️ Loading ${scans.length} user scan locations...');

      setState(() {
        _userScanMarkers.clear();

        for (var scan in scans) {
          if (scan['latitude'] != null && scan['longitude'] != null) {
            final scanLocation = LatLng(scan['latitude'], scan['longitude']);

            _userScanMarkers.add(
              Marker(
                point: scanLocation,
                width: 90,
                height: 90,
                child: GestureDetector(
                  onTap: () => _showUserScanDetails(scan),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue[700],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_pin_circle,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[700],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Your Scan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        }

        debugPrint('✅ Loaded ${_userScanMarkers.length} user scan markers');
      });
    } catch (e) {
      debugPrint('❌ Error loading user scan locations: $e');
    }
  }

  /// BAG-O: Show user scan details
  void _showUserScanDetails(Map<String, dynamic> scan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_pin_circle,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Scanned Mangrove',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        scan['species_name'] ?? 'Unknown Species',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Location info
            _buildScanInfoRow(
              Icons.location_on_rounded,
              'Location',
              '${scan['latitude'].toStringAsFixed(6)}, ${scan['longitude'].toStringAsFixed(6)}',
            ),

            const SizedBox(height: 12),

            // Date scanned
            _buildScanInfoRow(
              Icons.calendar_today_rounded,
              'Scanned on',
              _formatDate(scan['created_at']),
            ),

            const SizedBox(height: 12),

            // Notes
            if (scan['notes'] != null && scan['notes'].toString().isNotEmpty) ...[
              _buildScanInfoRow(Icons.notes_rounded, 'Notes', scan['notes']),
              const SizedBox(height: 12),
            ],

            // Actions
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _mapController.move(
                        LatLng(scan['latitude'], scan['longitude']),
                        16.0,
                      );
                    },
                    icon: const Icon(Icons.center_focus_strong_rounded),
                    label: const Text('Center Here'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.blue[700]!),
                      foregroundColor: Colors.blue[700],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Close'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue[700], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown date';

    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) {
        return 'Today at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } else if (diff.inDays == 1) {
        return 'Yesterday at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Unknown date';
    }
  }

  void _fitMapToCaraga() {
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: _caragaBounds,
        padding: const EdgeInsets.all(50.0),
      ),
    );
  }

  void _focusOnSpecies(String speciesName) {
    final speciesLocations = _mangroveLocations
        .where((loc) => loc.species == speciesName)
        .toList();

    if (speciesLocations.isEmpty) {
      _fitMapToCaraga();
      return;
    }

    double minLat = speciesLocations.first.location.latitude;
    double maxLat = speciesLocations.first.location.latitude;
    double minLng = speciesLocations.first.location.longitude;
    double maxLng = speciesLocations.first.location.longitude;

    for (var location in speciesLocations) {
      minLat = minLat < location.location.latitude ? minLat : location.location.latitude;
      maxLat = maxLat > location.location.latitude ? maxLat : location.location.latitude;
      minLng = minLng < location.location.longitude ? minLng : location.location.longitude;
      maxLng = maxLng > location.location.longitude ? maxLng : location.location.longitude;
    }

    final bounds = LatLngBounds(
      LatLng(minLat - 0.5, minLng - 0.5),
      LatLng(maxLat + 0.5, maxLng + 0.5),
    );

    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(80.0)),
    );
  }

  void _addDefaultMangroveMarkers() {
    for (var mangrove in _mangroveLocations) {
      final isFiltered = widget.filterSpecies != null &&
          mangrove.species == widget.filterSpecies;

      _addMangroveMarker(
        mangrove.location,
        mangrove.name,
        mangrove.species,
        mangrove.province,
        isHighlighted: isFiltered,
      );
    }
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      setState(() => _isLoading = false);
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

  void _addMangroveMarker(
    LatLng position,
    String name,
    String species,
    String? province, {
    bool isHighlighted = false,
  }) {
    setState(() {
      _markers.add(
        Marker(
          point: position,
          width: isHighlighted ? 130 : 110,
          height: isHighlighted ? 110 : 90,
          child: MangroveMarker(
            position: position,
            name: name,
            species: species,
            speciesColor: _speciesColors[species] ?? Colors.green,
            isHighlighted: isHighlighted,
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

  Future<void> _showMangroveEditDialog(
    LatLng position,
    String currentName,
    String currentSpecies,
    String currentProvince,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mangrove Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.forest, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Species', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(currentSpecies, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Province', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(currentProvince, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.pin_drop, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Coordinates', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(
                        '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _mapController.move(position, 15.0);
            },
            child: const Text('Center Map'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
              initialZoom: 8.0,
              maxZoom: 18,
              onTap: (_, _) {},
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.aigrove.app',
              ),
              MarkerLayer(markers: _markers),
              if (_showUserScans) MarkerLayer(markers: _userScanMarkers),
              const CurrentLocationLayer(),
            ],
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),

          // Legend
          if (_showLegend)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
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
                    Text(
                      'Map Legend',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.blue[700],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 10,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Your Scans',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.park,
                          color: Color(0xFF2E7D32),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Known Locations',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showUserScans = !_showUserScans;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _showUserScans
                              ? Colors.blue[700]
                              : Colors.grey.shade600,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _showUserScans
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _showUserScans
                                  ? 'Hide Scans'
                                  : 'Show Scans',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Info panel
          if (_showInfoPanel)
            Positioned(
              bottom: 30,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
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
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Colors.green[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Mangrove Locations Map',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '🔵 Blue markers = Your scanned locations',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    Text(
                      '🟢 Green markers = Known mangrove sites',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tap any marker to view details',
                      style: TextStyle(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
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
            onPressed: _loadUserScanLocations,
            heroTag: 'refreshScans',
            mini: true,
            backgroundColor: Colors.blue[700],
            tooltip: 'Refresh Your Scans',
            child: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _showLegend = !_showLegend;
              });
            },
            heroTag: 'toggleLegend',
            mini: true,
            backgroundColor: _showLegend ? Colors.green[700] : Colors.grey[600],
            tooltip: _showLegend ? 'Hide Legend' : 'Show Legend',
            child: Icon(_showLegend ? Icons.map : Icons.map_outlined),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _showInfoPanel = !_showInfoPanel;
              });
            },
            heroTag: 'toggleInfoPanel',
            mini: true,
            backgroundColor: _showInfoPanel ? Colors.green[700] : Colors.grey[600],
            tooltip: _showInfoPanel ? 'Hide Info' : 'Show Info',
            child: Icon(_showInfoPanel ? Icons.info : Icons.info_outline),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _fitMapToCaraga,
            heroTag: 'fitRegion',
            mini: true,
            backgroundColor: Colors.amber,
            tooltip: 'Fit to Caraga',
            child: const Icon(Icons.crop_free),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () async {
              final position = await Geolocator.getCurrentPosition();
              _mapController.move(
                LatLng(position.latitude, position.longitude),
                15,
              );
            },
            heroTag: 'myLocation',
            tooltip: 'My Location',
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }
}
