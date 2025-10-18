import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../core/theme/theme_colors.dart';
import 'dart:math';
import '../../../services/category_service.dart';
import '../../../models/models.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({Key? key}) : super(key: key);

  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String _currentAddress = 'Recherche de votre position...';
  bool _isLoadingLocation = true;
  bool _isLoadingAddress = false;

  // نواكشوط كموقع افتراضي
  static const LatLng _nouakchottCenter = LatLng(18.0735, -15.9582);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isLoadingLocation = true;
        _currentAddress = 'Recherche de votre position...';
      });

      // التحقق من الأذونات
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        _showPermissionDeniedDialog();
        return;
      }

      // الحصول على الموقع الحالي
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      );

      final LatLng currentLocation =
          LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedLocation = currentLocation;
        _isLoadingLocation = false;
      });

      // تحريك الكاميرا للموقع الحالي
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(currentLocation, 16.0),
        );
      }

      // الحصول على العنوان مع timeout
      await _getAddressFromLatLng(currentLocation);
    } catch (e) {
      print('❌ Error getting location: $e');
      // في حالة الفشل، استخدام نواكشوط كموقع افتراضي
      setState(() {
        _selectedLocation = _nouakchottCenter;
        _isLoadingLocation = false;
        _currentAddress = 'Nouakchott, Mauritanie';
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_nouakchottCenter, 13.0),
        );
      }
    }
  }

  Future<void> _getAddressFromLatLng(LatLng location) async {
    try {
      setState(() => _isLoadingAddress = true);

      // ✅ محاولة Geocoding أولاً
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      ).timeout(
        Duration(seconds: 5),
        onTimeout: () {
          print('⚠️ Geocoding timeout, using nearest area');
          return [];
        },
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '';

        if (place.street != null && place.street!.isNotEmpty) {
          address += '${place.street}, ';
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          address += '${place.subLocality}, ';
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          address += place.locality!;
        } else {
          address += 'Nouakchott';
        }

        setState(() {
          _currentAddress =
              address.isNotEmpty ? address : 'Nouakchott, Mauritanie';
          _isLoadingAddress = false;
        });
      } else {
        // ✅ إذا فشل Geocoding، احسب أقرب منطقة
        await _getNearestArea(location);
      }
    } catch (e) {
      print('❌ Error getting address: $e');
      // ✅ في حالة الخطأ، احسب أقرب منطقة
      await _getNearestArea(location);
    }
  }

// ✅ دالة جديدة: حساب أقرب منطقة
  Future<void> _getNearestArea(LatLng location) async {
    try {
      // استيراد المناطق من categoryService
      final result = await categoryService.getNouakchottAreas(simple: true);

      if (result['ok']) {
        final areas = result['areas'] as List<NouakchottArea>;
        // ✅ أضف هذا للتحقق
        print('📍 Total areas loaded: ${areas.length}');
        for (var area in areas) {
          print(
              'Area: ${area.name} - Lat: ${area.latitude}, Lng: ${area.longitude}');
        }

        if (areas.isEmpty) {
          setState(() {
            _currentAddress = 'Nouakchott, Mauritanie';
            _isLoadingAddress = false;
          });
          return;
        }

        // حساب أقرب منطقة
        String nearestArea = 'Nouakchott';
        double minDistance = double.infinity;

        for (var area in areas) {
          // ✅ استخدم latitude و longitude مباشرة
          if (area.latitude != null && area.longitude != null) {
            // حساب المسافة باستخدام صيغة Haversine
            double distance = _calculateDistance(
              location.latitude,
              location.longitude,
              area.latitude!,
              area.longitude!,
            );

            if (distance < minDistance) {
              minDistance = distance;
              nearestArea = area.name;
            }
          }
        }

        setState(() {
          _currentAddress = '$nearestArea, Nouakchott';
          _isLoadingAddress = false;
        });

        print(
            '✅ Nearest area: $nearestArea (${minDistance.toStringAsFixed(2)} km)');
      } else {
        setState(() {
          _currentAddress = 'Nouakchott, Mauritanie';
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      print('❌ Error finding nearest area: $e');
      setState(() {
        _currentAddress = 'Nouakchott, Mauritanie';
        _isLoadingAddress = false;
      });
    }
  }

// ✅ دالة حساب المسافة (Haversine Formula)
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // نصف قطر الأرض بالكيلومتر

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    _getAddressFromLatLng(location);
  }

  void _onMyLocationButtonPressed() {
    _getCurrentLocation();
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission requise'),
        content: Text(
          'L\'accès à la localisation est nécessaire pour sélectionner votre position. '
          'Veuillez activer la localisation dans les paramètres.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, null);
            },
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            child: Text('Paramètres'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? ThemeColors.darkBackground : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child:
                Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
          ),
          onPressed: () => Navigator.pop(context, null),
        ),
        title: Text(
          'Choisir la position',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ════════════════════════════════════════════
          // ✅ Google Map - الحل النهائي المضمون
          // ════════════════════════════════════════════
          GoogleMap(
            onMapCreated: (GoogleMapController controller) async {
              _mapController = controller;

              // انتظار 500ms
              await Future.delayed(Duration(milliseconds: 500));

              // الانتقال للموقع
              if (_selectedLocation != null) {
                controller.animateCamera(
                  CameraUpdate.newLatLngZoom(_selectedLocation!, 15.0),
                );
              }
            },

            initialCameraPosition: CameraPosition(
              target: _nouakchottCenter,
              zoom: 13.0, // ← zoom أوسع
            ),

            onTap: _onMapTap,

            markers: _selectedLocation != null
                ? {
                    Marker(
                      markerId: MarkerId('selected_location'),
                      position: _selectedLocation!,
                      draggable: true,
                      onDragEnd: (LatLng newPosition) {
                        setState(() {
                          _selectedLocation = newPosition;
                        });
                        _getAddressFromLatLng(newPosition);
                      },
                    ),
                  }
                : {},

            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,

            // ✅ هذه أهم نقطة!
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: false, // ← false لتسهيل التحكم
          ),

          // Loading overlay
          if (_isLoadingLocation)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation(ThemeColors.primaryColor),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Localisation en cours...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Address card at top
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: ThemeColors.primaryColor,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Position sélectionnée',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  _isLoadingAddress
                      ? Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                    ThemeColors.primaryColor),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Recherche de l\'adresse...'),
                          ],
                        )
                      : Text(
                          _currentAddress,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                ],
              ),
            ),
          ),

          // My location button
          Positioned(
            bottom: 180,
            right: 16,
            child: FloatingActionButton(
              onPressed: _onMyLocationButtonPressed,
              backgroundColor: ThemeColors.primaryColor,
              child: _isLoadingLocation
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Icon(Icons.my_location, color: Colors.white),
              mini: true,
              heroTag: 'myLocationBtn',
            ),
          ),

          // Instructions
          Positioned(
            bottom: 120,
            left: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Appuyez sur la carte ou faites glisser le marqueur pour ajuster',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confirm button
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _selectedLocation != null ? _confirmLocation : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Confirmer cette position',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      // تقريب الإحداثيات إلى 7 منازل عشرية
      double roundedLatitude =
          double.parse(_selectedLocation!.latitude.toStringAsFixed(7));
      double roundedLongitude =
          double.parse(_selectedLocation!.longitude.toStringAsFixed(7));

      print(
          '✅ Original: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}');
      print('✅ Rounded: $roundedLatitude, $roundedLongitude');

      // إرجاع البيانات
      Navigator.pop(context, {
        'coordinates': LatLng(roundedLatitude, roundedLongitude),
        'address': _currentAddress,
      });
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
