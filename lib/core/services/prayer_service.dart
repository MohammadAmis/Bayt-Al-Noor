import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:http/http.dart' as http;
import 'dart:convert';

class PrayerService {
  PrayerService();

  /// Fetches the user's current coordinates.
  /// Falls back to Supabase profile or Mumbai if GPS is unavailable.
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition();
  }

  /// Calculates prayer times for a given day and location.
  Future<PrayerTimes> getPrayerTimes({
    double? latitude,
    double? longitude,
    CalculationMethod method = CalculationMethod.karachi,
    Madhab madhab = Madhab.hanafi,
  }) async {
    final coordinates = Coordinates(
        latitude ?? 19.0760, longitude ?? 72.8777); // Default to Mumbai
    final params = method.getParameters();
    params.madhab = madhab;

    return PrayerTimes.today(coordinates, params);
  }

  /// Gets the city name from coordinates.
  /// Uses a web-compatible reverse geocoding API fallback for Flutter Web.
  Future<String> getCityName(double lat, double lon) async {
    if (kIsWeb) {
      return await _getCityNameWeb(lat, lon);
    }

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        return placemarks.first.locality ??
            placemarks.first.country ??
            'Current Location';
      }
    } catch (e) {
      return await _getCityNameWeb(
          lat, lon); // Fallback to web method even on mobile if geocoding fails
    }
    return 'Current Location';
  }

  /// Reverse geocodes using OpenStreetMap Nominatim API (Web-compatible).
  Future<String> _getCityNameWeb(double lat, double lon) async {
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=10');
      final response = await http.get(url, headers: {
        'User-Agent': 'BaytAlNoorApp/1.0', // Required by OSM usage policy
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        if (address != null) {
          return address['village'] ??
              address['town'] ??
              address['city'] ??
              address['suburb'] ??
              address['state'] ??
              'Current Location';
        }
      }
    } catch (e) {
      // debugPrint('Web Geocoding Error: $e');
    }
    return 'Current Location';
  }

  // -- Spiritual Boundary Calculations --

  /// Ishraq is usually 15 minutes after Sunrise.
  DateTime getIshraqTime(DateTime sunrise) {
    return sunrise.add(const Duration(minutes: 15));
  }

  /// Chast (Duha) is typically 25 minutes after Sunrise.
  DateTime getChastTime(DateTime sunrise) {
    return sunrise.add(const Duration(minutes: 25));
  }

  /// Zawal (prohibition period) starts approx 10 minutes before Dhuhr.
  DateTime getZawalTime(DateTime dhuhr) {
    return dhuhr.subtract(const Duration(minutes: 10));
  }

  /// Helper to map Supabase string preferences to Adhan enums.
  CalculationMethod parseCalculationMethod(String? method) {
    switch (method) {
      case 'KARACHI':
        return CalculationMethod.karachi;
      case 'MWL':
        return CalculationMethod.muslim_world_league;
      case 'ISNA':
        return CalculationMethod.north_america;
      case 'EGYPT':
        return CalculationMethod.egyptian;
      case 'UMM_AL_QURA':
        return CalculationMethod.umm_al_qura;
      default:
        return CalculationMethod.karachi;
    }
  }

  Madhab parseMadhab(String? madhab) {
    return (madhab == 'HANAFI') ? Madhab.hanafi : Madhab.shafi;
  }
}
