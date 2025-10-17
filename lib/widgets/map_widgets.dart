// ignore_for_file: deprecated_member_use

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
  final bool isHighlighted;

  const MangroveMarker({
    super.key,
    required this.position,
    required this.name,
    required this.species,
    required this.speciesColor,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // Add pulsing effect for highlighted markers
          if (isHighlighted)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: speciesColor.withOpacity(0.3),
              ),
            ),
          Transform.scale(
            scale: isHighlighted ? 1.3 : 1.0,
            child: Icon(
              Icons.forest,
              color: isHighlighted ? Colors.orange[700] : speciesColor,
              size: 35,
              shadows: isHighlighted
                  ? [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.orange.withOpacity(0.8),
                      ),
                    ]
                  : null,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? Colors.orange[700]
                  : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(4),
              border: isHighlighted
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
            ),
            child: Text(
              name,
              style: TextStyle(
                fontSize: isHighlighted ? 11 : 10,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.bold,
                color: isHighlighted ? Colors.white : Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
