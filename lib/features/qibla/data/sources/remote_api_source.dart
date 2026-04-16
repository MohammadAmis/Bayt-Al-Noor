import 'dart:convert';
import 'dart:io';
import 'dart:math'; // Added
import 'dart:async'; // Added for TimeoutException
import 'package:http/http.dart' as http;
import '../../../../core/utils/location_service.dart';

/// Remote API data source for Qibla calculation via external service
class RemoteApiSource {
  static const String _baseUrl = 'https://api.aladhan.com/v1';
  static const Duration _timeout = Duration(seconds: 10);
  
  final http.Client _httpClient;
  final bool _isEnabled;

  RemoteApiSource({
    http.Client? httpClient,
    bool isEnabled = true,
  })  : _httpClient = httpClient ?? http.Client(),
        _isEnabled = isEnabled;

  Future<RemoteQiblaResponse> calculateQibla({
    required double latitude,
    required double longitude,
  }) async {
    if (!_isEnabled) {
      throw RemoteDataSourceException('Remote API is disabled');
    }

    try {
      final uri = Uri.parse('$_baseUrl/qibla').replace(queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      });

      final response = await _httpClient.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return RemoteQiblaResponse.fromJson(jsonData);
      } else if (response.statusCode == 400) {
        throw RemoteDataSourceException('Invalid coordinates provided');
      } else if (response.statusCode == 429) {
        throw RemoteDataSourceException('API rate limit exceeded');
      } else {
        throw RemoteDataSourceException(
          'API error: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } on SocketException {
      throw RemoteDataSourceException('No internet connection');
    } on TimeoutException {
      throw RemoteDataSourceException('Request timed out');
    } on FormatException {
      throw RemoteDataSourceException('Invalid API response format');
    } catch (error) {
      throw RemoteDataSourceException('Remote API error: $error');
    }
  }

  Future<PrayerTimesResponse> getPrayerTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
    String? method,
  }) async {
    if (!_isEnabled) {
      throw RemoteDataSourceException('Remote API is disabled');
    }

    try {
      final uri = Uri.parse('$_baseUrl/timings/${date.day}-${date.month}-${date.year}')
          .replace(queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        if (method != null) 'method': method,
      });

      final response = await _httpClient.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return PrayerTimesResponse.fromJson(jsonData);
      } else {
        throw RemoteDataSourceException(
          'Prayer times API error: ${response.statusCode}',
        );
      }
    } catch (error) {
      throw RemoteDataSourceException('Failed to fetch prayer times: $error');
    }
  }

  Future<LocationInfo> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/hijri').replace(queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'date': DateTime.now().toString().split(' ')[0],
      });

      final response = await _httpClient.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return LocationInfo.fromJson(jsonData['data']['meta']?['timezone'] ?? {});
      }
      return LocationInfo.unknown;
    } catch (_) {
      return LocationInfo.unknown;
    }
  }

  void dispose() {
    _httpClient.close();
  }
}

class RemoteQiblaResponse {
  final double direction;
  final String directionString;
  final double distance;
  final LocationData coordinates;

  RemoteQiblaResponse({
    required this.direction,
    required this.directionString,
    required this.distance,
    required this.coordinates,
  });

  factory RemoteQiblaResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return RemoteQiblaResponse(
      direction: (data['qibla'] as num).toDouble(),
      directionString: _getCardinalDirection((data['qibla'] as num).toDouble()),
      distance: _calculateDistanceToKaaba(
        (data['latitude'] as num).toDouble(),
        (data['longitude'] as num).toDouble(),
      ),
      coordinates: LocationData(
        latitude: (data['latitude'] as num).toDouble(),
        longitude: (data['longitude'] as num).toDouble(),
      ),
    );
  }

  static String _getCardinalDirection(double degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((degrees + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  static double _calculateDistanceToKaaba(double lat, double lon) {
    const kaabaLat = 21.422524;
    const kaabaLon = 39.826189;
    const earthRadius = 6371;

    final dLat = _toRad(kaabaLat - lat);
    final dLon = _toRad(kaabaLon - lon);
    
    final a = sin(dLat/2) * sin(dLat/2) +
              cos(_toRad(lat)) * cos(_toRad(kaabaLat)) *
              sin(dLon/2) * sin(dLon/2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1-a));
    return earthRadius * c;
  }

  static double _toRad(double deg) => deg * pi / 180;
}

class PrayerTimesResponse {
  final DateTime date;
  final Map<String, String> timings;
  final String timezone;
  final String method;

  PrayerTimesResponse({
    required this.date,
    required this.timings,
    required this.timezone,
    required this.method,
  });

  factory PrayerTimesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final timings = (data['timings'] as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, value.toString()));

    return PrayerTimesResponse(
      date: DateTime.parse(data['date']['readable'] as String),
      timings: timings,
      timezone: data['meta']['timezone'] as String,
      method: data['meta']['method']['name'] as String,
    );
  }
}

class LocationInfo {
  final String? city;
  final String? country;
  final String? timezone;

  const LocationInfo({this.city, this.country, this.timezone});

  static const unknown = LocationInfo();

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      timezone: json['timezone'] as String?,
    );
  }

  String get formatted {
    if (city != null && country != null) return '$city, $country';
    if (city != null) return city!;
    if (country != null) return country!;
    return 'Unknown Location';
  }
}

class RemoteDataSourceException implements Exception {
  final String message;
  final dynamic error;

  RemoteDataSourceException(this.message, [this.error]);

  @override
  String toString() => 'RemoteDataSourceException: $message';
}