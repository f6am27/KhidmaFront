import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/colors.dart';
import '../../../services/location_service.dart';

enum UserType { worker, client }

class LocationPermissionBaseScreen extends StatefulWidget {
  final UserType userType;
  final String title;
  final String subtitle;
  final String primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onLocationGranted;
  final VoidCallback? onLocationDenied;
  final VoidCallback? onManualEntry;

  const LocationPermissionBaseScreen({
    Key? key,
    required this.userType,
    required this.title,
    required this.subtitle,
    required this.primaryButtonText,
    this.secondaryButtonText,
    this.onLocationGranted,
    this.onLocationDenied,
    this.onManualEntry,
  }) : super(key: key);

  @override
  State<LocationPermissionBaseScreen> createState() =>
      _LocationPermissionBaseScreenState();
}

class _LocationPermissionBaseScreenState
    extends State<LocationPermissionBaseScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  // ✅ متغيرات جديدة لتخزين الموقع
  LatLng? _currentLocation;
  bool _locationGranted = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _pulseController.repeat(reverse: true);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                const Spacer(flex: 2),
                _buildLocationIcon(),
                const Spacer(flex: 1),

                // العنوان
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // الوصف
                Text(
                  widget.subtitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(flex: 2),
                _buildActionButtons(),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationIcon() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // الدوائر النبضية
              ...List.generate(3, (index) {
                final delay = index * 0.3;
                final animation =
                    Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                  parent: _pulseController,
                  curve: Interval(delay, 1.0, curve: Curves.easeOut),
                ));

                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Container(
                      width: 120 + (80 * animation.value),
                      height: 120 + (80 * animation.value),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryPurple
                              .withOpacity(0.3 * (1 - animation.value)),
                          width: 2,
                        ),
                      ),
                    );
                  },
                );
              }),

              // الخلفية الرئيسية
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryPurple.withOpacity(0.1),
                  border: Border.all(
                    color: AppColors.primaryPurple.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),

              // أيقونة الموقع
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryPurple,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.location_on, color: Colors.white, size: 28),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // الزر الأساسي
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handlePrimaryAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.my_location, size: 20),
                const SizedBox(width: 8),
                Text(
                  widget.primaryButtonText,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),

        // الزر الثانوي (إذا كان موجوداً)
        if (widget.secondaryButtonText != null) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _handleSecondaryAction,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                widget.secondaryButtonText!,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ════════════════════════════════════════════
  // ✅ المُصحح: معالجة منفصلة للعميل والعامل
  // ════════════════════════════════════════════
  void _handlePrimaryAction() async {
    _showLoadingDialog();

    try {
      // 1. طلب صلاحيات GPS حقيقية
      bool hasPermission = await locationService.requestLocationPermission();

      if (!hasPermission) {
        Navigator.pop(context); // إغلاق loading dialog
        widget.onLocationDenied?.call();
        _showErrorMessage('Permission refusée');
        return;
      }

      // 2. جلب الموقع الحالي
      // ✅ للعميل: لا ترسل للـ Backend (sendToBackend: false)
      // ✅ للعامل: أرسل للـ Backend (sendToBackend: true)
      final bool shouldSendToBackend = (widget.userType == UserType.worker);

      final location = await locationService.getCurrentLocation(
        sendToBackend: shouldSendToBackend,
      );

      if (location == null) {
        Navigator.pop(context);
        widget.onLocationDenied?.call();
        _showErrorMessage('Impossible d\'obtenir la position');
        return;
      }

      // 3. حفظ الموقع والحالة
      setState(() {
        _currentLocation = location;
        _locationGranted = true;
      });

      await _saveLocationPermissionState(true);

      // 4. إغلاق dialog والإعلام
      Navigator.pop(context); // إغلاق loading dialog
      widget.onLocationGranted?.call();
      _showSuccessMessage();
    } catch (e) {
      print('❌ Error in location permission: $e');
      Navigator.pop(context);
      widget.onLocationDenied?.call();
      _showErrorMessage('Erreur: ${e.toString()}');
    }
  }

  void _handleSecondaryAction() async {
    await _saveLocationPermissionState(false);
    widget.onManualEntry?.call();
  }

  Future<void> _saveLocationPermissionState(bool granted) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = widget.userType == UserType.worker ? 'worker' : 'client';

    await prefs.setBool('${prefix}_location_permission_requested', true);
    await prefs.setBool('${prefix}_location_enabled', granted);
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.primaryPurple)),
              const SizedBox(height: 16),
              Text('Demande d\'autorisation...',
                  style: TextStyle(fontSize: 16, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text('Position activée avec succès!'),
          ],
        ),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
