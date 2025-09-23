import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// Model class para sa mangrove location
class MangroveLocation {
  final String name;
  final String species;
  final LatLng location;
  final String province;

  MangroveLocation({
    required this.name,
    required this.species,
    required this.location,
    required this.province,
  });
}

/// Class model para sa environmental impact data
class EnvironmentalImpact {
  final String title;
  final String value;
  final String unit;
  final String description;
  final IconData icon;
  final Color color;

  EnvironmentalImpact({
    required this.title,
    required this.value,
    required this.unit,
    required this.description,
    required this.icon,
    required this.color,
  });
}
