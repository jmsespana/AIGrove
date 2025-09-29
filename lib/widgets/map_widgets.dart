import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Simple implementation of a current location layer
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

/// Custom marker for mangrove locations
class MangroveMarker extends StatelessWidget {
  final LatLng position;
  final String name;
  final String species;
  final Color speciesColor;
  final VoidCallback onTap;

  const MangroveMarker({
    super.key,
    required this.position,
    required this.name,
    required this.species,
    required this.speciesColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(Icons.forest, color: speciesColor, size: 35),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              name,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
