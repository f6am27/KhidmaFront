// lib/services/location_service.dart

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';
import '../core/storage/token_storage.dart';

class LocationService {
  // ════════════════════════════════════════════
  // Singleton Pattern
  // ════════════════════════════════════════════
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // ════════════════════════════════════════════
  // State Management
  // ════════════════════════════════════════════
  LatLng? _currentLocation;
  bool _isTracking = false;
  Timer? _trackingTimer;
  DateTime? _lastUpdateTime;

  // ════════════════════════════════════════════
  // Getters
  // ════════════════════════════════════════════
  LatLng? get currentLocation => _currentLocation;
  bool get isTracking => _isTracking;
  DateTime? get lastUpdateTime => _lastUpdateTime;

  /// هل الموقع حديث؟ (أقل من 6 ساعات)
  bool get isLocationFresh {
    if (_lastUpdateTime == null) return false;
    final difference = DateTime.now().difference(_lastUpdateTime!);
    return difference.inHours < 6;
  }

  /// هل الموقع قديم؟ (أكثر من 6 ساعات)
  bool get isLocationStale {
    if (_lastUpdateTime == null) return true;
    final difference = DateTime.now().difference(_lastUpdateTime!);
    return difference.inHours >= 6;
  }

  // ════════════════════════════════════════════
  // 1. طلب صلاحيات GPS
  // ════════════════════════════════════════════
  Future<bool> requestLocationPermission() async {
    try {
      // التحقق من تفعيل خدمات الموقع
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('⚠️ Location services are disabled');
        return false;
      }

      // التحقق من الصلاحيات
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
  // 2. جلب الموقع الحالي (مرة واحدة)
  // ════════════════════════════════════════════
  Future<LatLng?> getCurrentLocation() async {
    try {
      // التحقق من الصلاحيات
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        print('⚠️ No location permission');
        return await getLastSavedLocation();
      }

      print('📍 Getting current location...');

      // جلب الموقع
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      );

      _currentLocation = LatLng(position.latitude, position.longitude);
      _lastUpdateTime = DateTime.now();

      print(
          '✅ Location obtained: ${_currentLocation!.latitude}, ${_currentLocation!.longitude}');

      // حفظ الموقع محلياً
      await _saveLastLocation(_currentLocation!);

      // إرسال الموقع للـ Backend
      await _sendLocationToBackend(_currentLocation!, position.accuracy);

      return _currentLocation;
    } catch (e) {
      print('❌ Error getting location: $e');

      // في حالة الفشل، جلب آخر موقع محفوظ
      return await getLastSavedLocation();
    }
  }

  // ════════════════════════════════════════════
  // 3. بدء التتبع الدوري (للعامل فقط)
  // ════════════════════════════════════════════
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

    // جلب أول موقع فوراً
    await getCurrentLocation();

    // بدء Timer للتحديث الدوري
    _trackingTimer = Timer.periodic(interval, (timer) async {
      print('🔄 Periodic location update...');
      await getCurrentLocation();
    });
  }

  // ════════════════════════════════════════════
  // 4. إيقاف التتبع
  // ════════════════════════════════════════════
  void stopPeriodicTracking() {
    if (!_isTracking) return;

    _trackingTimer?.cancel();
    _trackingTimer = null;
    _isTracking = false;

    print('🔴 Periodic tracking stopped');
  }

  // ════════════════════════════════════════════
  // 5. حفظ آخر موقع محلياً (SharedPreferences)
  // ════════════════════════════════════════════
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

  // ════════════════════════════════════════════
  // 6. جلب آخر موقع محفوظ محلياً
  // ════════════════════════════════════════════
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

  // ════════════════════════════════════════════
  // 7. إرسال الموقع للـ Backend
  // ════════════════════════════════════════════
  Future<bool> _sendLocationToBackend(LatLng location, double accuracy) async {
    try {
      final token = await TokenStorage.readAccess();
      if (token == null) {
        print('⚠️ No auth token, cannot send location');
        return false;
      }

      final url = Uri.parse('${ApiConfig.baseUrl()}/update-location/');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'latitude': double.parse(location.latitude.toStringAsFixed(6)),
          'longitude': double.parse(location.longitude.toStringAsFixed(6)),
          'accuracy': accuracy,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Location sent to backend successfully');
        return true;
      } else {
        print('⚠️ Failed to send location: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending location to backend: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════
  // 8. تفعيل/إلغاء مشاركة الموقع (Backend)
  // ════════════════════════════════════════════
  Future<Map<String, dynamic>> toggleLocationSharing(bool enabled) async {
    try {
      final token = await TokenStorage.readAccess();
      if (token == null) {
        return {
          'ok': false,
          'error': 'No authentication token',
        };
      }

      final url = Uri.parse('${ApiConfig.baseUrl()}/toggle-location-sharing/');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'enabled': enabled,
        }),
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
    } catch (e) {
      print('❌ Error toggling location sharing: $e');
      return {
        'ok': false,
        'error': e.toString(),
      };
    }
  }

  // ════════════════════════════════════════════
  // 9. الحصول على معلومات الموقع من Backend
  // ════════════════════════════════════════════
  Future<Map<String, dynamic>> getLocationInfo() async {
    try {
      final token = await TokenStorage.readAccess();
      if (token == null) {
        return {
          'ok': false,
          'error': 'No authentication token',
        };
      }

      final url = Uri.parse('${ApiConfig.baseUrl()}/location-info/');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
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
    } catch (e) {
      print('❌ Error getting location info: $e');
      return {
        'ok': false,
        'error': e.toString(),
      };
    }
  }

  // ════════════════════════════════════════════
  // 10. تنظيف عند الخروج
  // ════════════════════════════════════════════
  void dispose() {
    stopPeriodicTracking();
  }
}

// ════════════════════════════════════════════
// Global Instance
// ════════════════════════════════════════════
final locationService = LocationService();
