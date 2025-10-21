import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service para sa location tracking
///
/// Kini ang nag-handle sa pag-kuha ug current location sa user
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// I-check kung naka-enable ang location services
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// I-request ang location permission
  Future<bool> requestLocationPermission() async {
    try {
      // I-check ang current permission status
      var status = await Permission.location.status;

      if (status.isGranted) {
        debugPrint('✅ Location permission already granted');
        return true;
      }

      if (status.isDenied) {
        // I-request ang permission
        debugPrint('🔍 Requesting location permission...');
        status = await Permission.location.request();

        if (status.isGranted) {
          debugPrint('✅ Location permission granted');
          return true;
        }
      }

      if (status.isPermanentlyDenied) {
        debugPrint('❌ Location permission permanently denied');
        // I-open ang app settings para ma-enable manually
        await openAppSettings();
        return false;
      }

      debugPrint('⚠️ Location permission denied');
      return false;
    } catch (e) {
      debugPrint('❌ Error requesting location permission: $e');
      return false;
    }
  }

  /// Kuha ang current location sa user
  Future<Position?> getCurrentLocation() async {
    try {
      // I-check kung enabled ang location service
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('❌ Location services are disabled');
        return null;
      }

      // I-request ang permission
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        debugPrint('❌ Location permission not granted');
        return null;
      }

      // Kuha ang current position
      debugPrint('🔍 Getting current location...');
      final position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
        // ignore: deprecated_member_use
        timeLimit: const Duration(seconds: 10),
      );

      debugPrint(
        '📍 Location acquired: ${position.latitude}, ${position.longitude}',
      );
      return position;
    } catch (e) {
      debugPrint('❌ Error getting location: $e');
      return null;
    }
  }

  /// Kuha ang location with error handling ug fallback
  Future<Map<String, double?>> getLocationCoordinates() async {
    try {
      final position = await getCurrentLocation();

      if (position != null) {
        return {'latitude': position.latitude, 'longitude': position.longitude};
      }

      debugPrint('⚠️ No location available, returning null coordinates');
      return {'latitude': null, 'longitude': null};
    } catch (e) {
      debugPrint('❌ Error getting location coordinates: $e');
      return {'latitude': null, 'longitude': null};
    }
  }

  /// I-calculate ang distance between two points (in meters)
  double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}
