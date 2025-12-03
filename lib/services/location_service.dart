// lib/services/location_service.dart

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import '../core/config/api_config.dart';
import 'auth_manager.dart';
import 'foreground_location_service.dart';
import '../models/models.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  LatLng? _currentLocation;
  bool _isTracking = false;
  Timer? _trackingTimer;
  DateTime? _lastUpdateTime;

  LatLng? get currentLocation => _currentLocation;
  bool get isTracking => _isTracking;
  DateTime? get lastUpdateTime => _lastUpdateTime;

  bool get isLocationFresh {
    if (_lastUpdateTime == null) return false;
    final difference = DateTime.now().difference(_lastUpdateTime!);
    return difference.inHours < 6;
  }

  bool get isLocationStale {
    if (_lastUpdateTime == null) return true;
    final difference = DateTime.now().difference(_lastUpdateTime!);
    return difference.inHours >= 6;
  }

  Future<bool> requestLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('⚠️ Location services are disabled');
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Location permission denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ Location permission permanently denied');
        return false;
      }

      print('✅ Location permission granted');
      return true;
    } catch (e) {
      print('❌ Error requesting location permission: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════
  // ✅ المُصحح: إضافة parameter للتحكم في الإرسال
  // ════════════════════════════════════════════
  Future<LatLng?> getCurrentLocation({bool sendToBackend = false}) async {
    try {
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        print('⚠️ No location permission');
        return await getLastSavedLocation();
      }

      print('📍 Getting current location...');

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      );

      _currentLocation = LatLng(position.latitude, position.longitude);
      _lastUpdateTime = DateTime.now();

      print(
          '✅ Location obtained: ${_currentLocation!.latitude}, ${_currentLocation!.longitude}');

      // دائماً احفظ محلياً
      await _saveLastLocation(_currentLocation!);

      // ✅ أرسل للـ Backend فقط إذا طُلب ذلك (للعمال فقط)
      if (sendToBackend) {
        print('📤 Sending location to backend (Worker)...');
        await _sendLocationToBackend(_currentLocation!, position.accuracy);
      } else {
        print('⏭️ Skipping backend send (Client - location only for task)');
      }

      return _currentLocation;
    } catch (e) {
      print('❌ Error getting location: $e');
      return await getLastSavedLocation();
    }
  }

  Future<void> startPeriodicTracking({
    Duration interval = const Duration(minutes: 5),
  }) async {
    if (_isTracking) {
      print('⚠️ Tracking already started');
      return;
    }

    _isTracking = true;
    print(
        '🟢 Starting periodic location tracking (every ${interval.inMinutes} min)');

    // ✅ جديد: بدء Foreground Service
    await foregroundLocationService.start();

    // تحديث أولي
    await getCurrentLocation(sendToBackend: true);

    _trackingTimer = Timer.periodic(interval, (timer) async {
      print('🔄 Periodic location update...');
      await getCurrentLocation(sendToBackend: true);
    });
  }

  void stopPeriodicTracking({bool silent = false}) {
    if (!_isTracking) {
      if (!silent) print('⚠️ Tracking already stopped');
      return;
    }

    _trackingTimer?.cancel();
    _trackingTimer = null;
    _isTracking = false;

    // إيقاف Foreground Service
    foregroundLocationService.stop();

    if (!silent) print('🔴 Periodic tracking stopped');
  }

  Future<void> _saveLastLocation(LatLng location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('last_latitude', location.latitude);
      await prefs.setDouble('last_longitude', location.longitude);
      await prefs.setString(
          'last_location_time', DateTime.now().toIso8601String());

      print('💾 Location saved locally');
    } catch (e) {
      print('❌ Error saving location: $e');
    }
  }

  Future<LatLng?> getLastSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      double? lat = prefs.getDouble('last_latitude');
      double? lng = prefs.getDouble('last_longitude');
      String? timeStr = prefs.getString('last_location_time');

      if (lat != null && lng != null) {
        _currentLocation = LatLng(lat, lng);

        if (timeStr != null) {
          _lastUpdateTime = DateTime.parse(timeStr);
        }

        print('📍 Loaded last saved location: $lat, $lng');
        return _currentLocation;
      }
    } catch (e) {
      print('❌ Error loading last location: $e');
    }

    return null;
  }

  Future<bool> _sendLocationToBackend(LatLng location, double accuracy) async {
    try {
      final response = await AuthManager.authenticatedRequest(
        method: 'POST',
        endpoint: '${ApiConfig.baseUrl()}/update-location/',
        body: {
          'latitude': double.parse(location.latitude.toStringAsFixed(6)),
          'longitude': double.parse(location.longitude.toStringAsFixed(6)),
          'accuracy': accuracy,
        },
      );

      if (response.statusCode == 200) {
        print('✅ Location sent to backend successfully');
        return true;
      } else {
        print('⚠️ Failed to send location: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } on AuthException catch (e) {
      print('❌ Auth error sending location: ${e.message}');
      if (e.needsLogin) {
        print('⚠️ User needs to login again');
      }
      return false;
    } catch (e) {
      print('❌ Error sending location to backend: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> toggleLocationSharing(bool enabled) async {
    try {
      final response = await AuthManager.authenticatedRequest(
        method: 'POST',
        endpoint: '${ApiConfig.baseUrl()}/toggle-location-sharing/',
        body: {'enabled': enabled},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Location sharing toggled: $enabled');
        return {
          'ok': true,
          'data': data['data'],
        };
      } else {
        print('⚠️ Failed to toggle location sharing: ${response.statusCode}');
        return {
          'ok': false,
          'error': 'Failed to update settings',
        };
      }
    } on AuthException catch (e) {
      print('❌ Auth error toggling location: ${e.message}');
      return {
        'ok': false,
        'error': e.needsLogin ? 'Please login again' : e.message,
        'needsLogin': e.needsLogin,
      };
    } catch (e) {
      print('❌ Error toggling location sharing: $e');
      return {
        'ok': false,
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getLocationInfo() async {
    try {
      final response = await AuthManager.authenticatedRequest(
        method: 'GET',
        endpoint: '${ApiConfig.baseUrl()}/location-info/',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'ok': true,
          'data': data['data'],
        };
      } else {
        return {
          'ok': false,
          'error': 'Failed to get location info',
        };
      }
    } on AuthException catch (e) {
      print('❌ Auth error getting location info: ${e.message}');
      return {
        'ok': false,
        'error': e.message,
        'needsLogin': e.needsLogin,
      };
    } catch (e) {
      print('❌ Error getting location info: $e');
      return {
        'ok': false,
        'error': e.toString(),
      };
    }
  }

  // ════════════════════════════════════════════════════════════
  // ✅ إدارة المواقع المحفوظة (Saved Locations)
  // ════════════════════════════════════════════════════════════

  /// الحصول على قائمة المواقع المحفوظة
  Future<Map<String, dynamic>> getSavedLocations() async {
    try {
      final response = await AuthManager.authenticatedRequest(
        method: 'GET',
        endpoint: '${ApiConfig.baseUrl()}/saved-locations/',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final locations =
            data.map((json) => SavedLocation.fromJson(json)).toList();

        print('✅ Loaded ${locations.length} saved locations');
        return {
          'ok': true,
          'locations': locations,
        };
      } else {
        print('⚠️ Failed to load saved locations: ${response.statusCode}');
        return {
          'ok': false,
          'error': 'Failed to load locations',
        };
      }
    } on AuthException catch (e) {
      print('❌ Auth error loading saved locations: ${e.message}');
      return {
        'ok': false,
        'error': e.message,
        'needsLogin': e.needsLogin,
      };
    } catch (e) {
      print('❌ Error loading saved locations: $e');
      return {
        'ok': false,
        'error': e.toString(),
      };
    }
  }

  /// حفظ موقع جديد (أو تحديث موجود)
  Future<Map<String, dynamic>> saveLocation({
    required LatLng coordinates,
    required String address,
    String? name,
    String emoji = '📍',
  }) async {
    try {
      final response = await AuthManager.authenticatedRequest(
        method: 'POST',
        endpoint: '${ApiConfig.baseUrl()}/saved-locations/create/',
        body: {
          'latitude': double.parse(coordinates.latitude.toStringAsFixed(6)),
          'longitude': double.parse(coordinates.longitude.toStringAsFixed(6)),
          'address': address,
          'name': name ?? '',
          'emoji': emoji,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Location saved: ${data['message']}');

        return {
          'ok': true,
          'created': data['created'] ?? false,
          'location': SavedLocation.fromJson(data['data']),
        };
      } else {
        print('⚠️ Failed to save location: ${response.statusCode}');
        print('Response: ${response.body}');
        return {
          'ok': false,
          'error': 'Failed to save location',
        };
      }
    } on AuthException catch (e) {
      print('❌ Auth error saving location: ${e.message}');
      return {
        'ok': false,
        'error': e.message,
        'needsLogin': e.needsLogin,
      };
    } catch (e) {
      print('❌ Error saving location: $e');
      return {
        'ok': false,
        'error': e.toString(),
      };
    }
  }

  /// تحديث اسم وإيموجي الموقع
  Future<Map<String, dynamic>> updateLocationName({
    required String locationId,
    String? name,
    String? emoji,
  }) async {
    try {
      final response = await AuthManager.authenticatedRequest(
        method: 'PATCH',
        endpoint: '${ApiConfig.baseUrl()}/saved-locations/$locationId/',
        body: {
          if (name != null) 'name': name,
          if (emoji != null) 'emoji': emoji,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Location updated successfully');

        return {
          'ok': true,
          'location': SavedLocation.fromJson(data),
        };
      } else {
        print('⚠️ Failed to update location: ${response.statusCode}');
        return {
          'ok': false,
          'error': 'Failed to update location',
        };
      }
    } on AuthException catch (e) {
      print('❌ Auth error updating location: ${e.message}');
      return {
        'ok': false,
        'error': e.message,
        'needsLogin': e.needsLogin,
      };
    } catch (e) {
      print('❌ Error updating location: $e');
      return {
        'ok': false,
        'error': e.toString(),
      };
    }
  }

  /// حذف موقع محفوظ
  Future<Map<String, dynamic>> deleteLocation(String locationId) async {
    try {
      final response = await AuthManager.authenticatedRequest(
        method: 'DELETE',
        endpoint: '${ApiConfig.baseUrl()}/saved-locations/$locationId/delete/',
      );

      if (response.statusCode == 200) {
        print('✅ Location deleted successfully');
        return {
          'ok': true,
          'message': 'Location deleted',
        };
      } else {
        print('⚠️ Failed to delete location: ${response.statusCode}');
        return {
          'ok': false,
          'error': 'Failed to delete location',
        };
      }
    } on AuthException catch (e) {
      print('❌ Auth error deleting location: ${e.message}');
      return {
        'ok': false,
        'error': e.message,
        'needsLogin': e.needsLogin,
      };
    } catch (e) {
      print('❌ Error deleting location: $e');
      return {
        'ok': false,
        'error': e.toString(),
      };
    }
  }

  void dispose() {
    // استخدم silent=true لتجنب الرسائل المكررة
    stopPeriodicTracking(silent: true);
  }
}

final locationService = LocationService();
