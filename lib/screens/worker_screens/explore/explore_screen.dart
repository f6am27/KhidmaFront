import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../models/models.dart';
import '../../../models/task_model.dart';
import '../../../services/task_service.dart';
import '../../../services/location_service.dart';
import '../../shared_screens/dialogs/success_dialog.dart';
import '../../shared_screens/messages/chat_screen.dart';
import '../../../services/chat_service.dart';
import '../../../utils/apply_helper.dart';
import '../../../services/profile_service.dart';

class WorkerExploreScreen extends StatefulWidget {
  @override
  _WorkerExploreScreenState createState() => _WorkerExploreScreenState();
}

class _WorkerExploreScreenState extends State<WorkerExploreScreen>
    with WidgetsBindingObserver {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  TaskModel? _selectedTask;
  bool _showTaskDetails = false;
  bool _isLocationEnabled = false;
  LatLng? _workerLocation;
  bool _isLoadingLocation = false;
  bool _isLoadingTasks = true;
  List<TaskModel> _availableTasks = [];
  double _maxDistance = 40.0;
  String? _workerCategory;
  bool _filterByCategory = false;

  static const LatLng _nouakchottCenter = LatLng(18.0735, -15.9582);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('🔄 App resumed - reloading location state');
      _loadLocationState();
    }
  }

  @override
  void didUpdateWidget(WorkerExploreScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadLocationState();
  }

  Future<void> _initialize() async {
    await _loadLocationState();
    await _loadWorkerCategory();
    await _loadTasks();
  }

  Future<void> _loadWorkerCategory() async {
    try {
      // جلب فئة العامل من الملف الشخصي
      final result = await profileService.getWorkerProfile();
      if (result['ok']) {
        final workerProfile = result['workerProfile'] as WorkerProfile;
        _workerCategory = workerProfile.serviceCategory;
        print('🔎 Worker category loaded: $_workerCategory');
      }
    } catch (e) {
      print('❌ Error loading worker category: $e');
    }
  }

  Future<void> _loadLocationState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLocationEnabled = prefs.getBool('worker_location_enabled') ?? false;

      print('🔍 Location enabled from prefs: $_isLocationEnabled');

      final lastLocation = await locationService.getLastSavedLocation();

      if (lastLocation != null) {
        setState(() {
          _workerLocation = lastLocation;
        });
        print('📍 Worker location loaded: $_workerLocation');
        await _createMarkers();
      } else if (_isLocationEnabled) {
        await _getCurrentLocation();
      }
      await _createMarkers();
    } catch (e) {
      print('Error loading location state: $e');
    }
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoadingTasks = true);

    final result = await taskService.getAvailableTasks(
      sortBy: 'latest',
      lat: _workerLocation?.latitude,
      lng: _workerLocation?.longitude,
    );

    if (mounted) {
      setState(() {
        _isLoadingTasks = false;
        if (result['ok']) {
          _availableTasks = result['tasks'] as List<TaskModel>;

          print('📡 Raw API Response: ${result}');
          print('📍 Total tasks: ${_availableTasks.length}');
          for (var task in _availableTasks) {
            print(
                'Task: ${task.title} → Category: ${task.serviceType} → Coordinates: ${task.coordinates}');
          }

          _createMarkers();
        }
      });
    }
  }

  List<TaskModel> get _filteredTasks {
    // ✅ أولاً: فلترة المهام التي تحتوي على إحداثيات فقط
    List<TaskModel> tasksWithCoordinates =
        _availableTasks.where((task) => task.coordinates != null).toList();

    // ✅ إذا لا يوجد تصنيف للعامل، عرض كل المهام
    if (_workerCategory == null || _workerCategory!.isEmpty) {
      return tasksWithCoordinates;
    }

    final workerCat = _workerCategory!.toLowerCase().trim();

    // ✅ إذا كانت الفلترة مفعّلة: مهام تصنيف العامل فقط
    if (_filterByCategory) {
      return tasksWithCoordinates.where((task) {
        final taskCat = task.serviceType.toLowerCase().trim();
        return taskCat == workerCat;
      }).toList();
    }

    // ✅ بدون فلترة: مهام تصنيف العامل + المهام غير المصنفة
    return tasksWithCoordinates.where((task) {
      final taskCat = task.serviceType.toLowerCase().trim();
      // عرض مهام تصنيف العامل أو المهام غير المصنفة
      return taskCat == workerCat || task.isUnclassified;
    }).toList();
  }

  Future<void> _onRefresh() async {
    print('🔄 Refreshing...');
    await _loadLocationState();
    await _loadTasks();
    print(
        '✅ Refresh completed - Location: $_isLocationEnabled, Worker at: $_workerLocation');
  }

  Future<void> _getCurrentLocation() async {
    if (!_isLocationEnabled) return;

    setState(() => _isLoadingLocation = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission != LocationPermission.deniedForever) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        );

        setState(() {
          _workerLocation = LatLng(position.latitude, position.longitude);
        });

        await _loadTasks();

        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(_workerLocation!, 14.0),
          );
        }
      }
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _workerLocation = _nouakchottCenter;
      });
      await _loadTasks();
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _createMarkers() async {
    Set<Marker> markers = {};
    Set<Circle> circles = {};

    if (_isLocationEnabled && _workerLocation != null) {
      print('✅ Adding worker marker at: $_workerLocation');

      markers.add(
        Marker(
          markerId: MarkerId('worker_location'),
          position: _workerLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: '📍 Votre position',
            snippet: 'Vous êtes ici',
          ),
          zIndex: 1000,
          consumeTapEvents: false,
        ),
      );

      circles.add(
        Circle(
          circleId: CircleId('worker_accuracy'),
          center: _workerLocation!,
          radius: 100,
          fillColor: Colors.blue.withOpacity(0.15),
          strokeColor: Colors.blue.withOpacity(0.5),
          strokeWidth: 2,
        ),
      );
    } else {
      print(
          '⚠️ Worker location NOT added - Enabled: $_isLocationEnabled, Location: $_workerLocation');
    }

    for (TaskModel task in _filteredTasks) {
      if (task.coordinates == null) continue;

      String distanceText = '';
      if (_isLocationEnabled && _workerLocation != null) {
        double distanceKm = task.distance ?? 0.0;
        distanceText = ' - ${distanceKm.toStringAsFixed(1)} km';
      }

      BitmapDescriptor markerIcon;
      if (task.isUrgent) {
        markerIcon =
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      } else {
        markerIcon =
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      }

      markers.add(
        Marker(
          markerId: MarkerId(task.id.toString()),
          position: task.coordinates!,
          icon: markerIcon,
          infoWindow: InfoWindow(
            title: task.title,
            snippet: '${task.budget} MRU$distanceText',
          ),
          onTap: () => _displayTaskCard(task),
        ),
      );
    }

    setState(() {
      _markers = markers;
      _circles = circles;
    });

    print('📍 Total markers: ${markers.length}, Circles: ${circles.length}');
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'plomberie':
        return Icons.plumbing;
      case 'électricité':
        return Icons.electrical_services;
      case 'nettoyage':
        return Icons.cleaning_services;
      case 'jardinage':
        return Icons.grass;
      case 'garde d\'enfants':
        return Icons.child_care;
      case 'éducation':
        return Icons.school;
      case 'livraison':
        return Icons.delivery_dining;
      case 'climatisation':
        return Icons.ac_unit;
      case 'cuisine':
        return Icons.restaurant;
      case 'transport':
      case 'déménagement':
        return Icons.local_shipping;
      default:
        return Icons.work;
    }
  }

  void _displayTaskCard(TaskModel task) {
    setState(() {
      _selectedTask = task;
      _showTaskDetails = true;
    });
  }

  void _hideTaskCard() {
    setState(() {
      _showTaskDetails = false;
      _selectedTask = null;
    });
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return 'il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'il y a ${difference.inHours}h';
    } else {
      return 'il y a ${difference.inDays} jours';
    }
  }

  String _calculateDistance(TaskModel task) {
    if (task.distance != null) {
      return '${task.distance!.toStringAsFixed(1)} km';
    }
    return 'Position désactivée';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Explorer les tâches'),
        centerTitle: true,
        backgroundColor: isDark ? ThemeColors.darkBackground : Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        actions: [
          // ✅ زر الفلترة حسب الفئة
          if (_workerCategory != null && _workerCategory!.isNotEmpty)
            if (_workerCategory != null && _workerCategory!.isNotEmpty)
              Container(
                margin: EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _filterByCategory = !_filterByCategory;
                      _createMarkers(); // إعادة إنشاء العلامات
                    });
                  },
                  icon: Icon(
                    _filterByCategory
                        ? Icons.filter_alt
                        : Icons.filter_alt_outlined,
                    color: _filterByCategory
                        ? ThemeColors.primaryColor
                        : (isDark ? Colors.white70 : Colors.black54),
                  ),
                  tooltip: _filterByCategory
                      ? 'Afficher ma catégorie + non classifiées'
                      : 'Filtrer par ma catégorie seulement',
                ),
              ),

          // الزر الأصلي للموقع
          Container(
            margin: EdgeInsets.only(right: 16),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isLocationEnabled
                  ? ThemeColors.successColor.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isLocationEnabled ? Icons.location_on : Icons.location_off,
                  size: 16,
                  color: _isLocationEnabled
                      ? ThemeColors.successColor
                      : Colors.orange,
                ),
                SizedBox(width: 4),
                Text(
                  _isLocationEnabled ? 'Activé' : 'Désactivé',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isLocationEnabled
                        ? ThemeColors.successColor
                        : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoadingTasks
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) async {
                    _mapController = controller;
                    await Future.delayed(Duration(milliseconds: 500));
                    if (_workerLocation != null) {
                      controller.animateCamera(
                        CameraUpdate.newLatLngZoom(_workerLocation!, 15.0),
                      );
                    }
                  },
                  initialCameraPosition: CameraPosition(
                    target: _nouakchottCenter,
                    zoom: 13.0,
                  ),
                  markers: _markers,
                  circles: _circles,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  onTap: (_) => _hideTaskCard(),
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  tiltGesturesEnabled: false,
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? ThemeColors.darkCardBackground
                          : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment,
                          color: ThemeColors.primaryColor,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${_filteredTasks.length} tâches disponibles',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_showTaskDetails && _selectedTask != null)
                  _buildTaskDetailsCard(isDark),
                Positioned(
                  bottom: 20,
                  right: 16,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        onPressed:
                            _isLocationEnabled ? _getCurrentLocation : null,
                        backgroundColor: _isLocationEnabled
                            ? ThemeColors.primaryColor
                            : Colors.grey,
                        child: _isLoadingLocation
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Icon(Icons.my_location, color: Colors.white),
                        mini: true,
                      ),
                      SizedBox(height: 8),
                      FloatingActionButton(
                        onPressed: _isLoadingLocation ? null : _onRefresh,
                        backgroundColor: ThemeColors.primaryColor,
                        child: _isLoadingLocation
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Icon(Icons.refresh, color: Colors.white),
                        mini: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTaskDetailsCard(bool isDark) {
    return GestureDetector(
      onTap: _hideTaskCard,
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 50),
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7),
              decoration: BoxDecoration(
                color: isDark ? ThemeColors.darkCardBackground : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    offset: Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _selectedTask!.isUrgent
                            ? [Colors.red.withOpacity(0.8), Colors.red]
                            : [
                                ThemeColors.primaryColor.withOpacity(0.8),
                                ThemeColors.primaryColor
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getCategoryIcon(_selectedTask!.serviceType),
                            color: _selectedTask!.isUrgent
                                ? Colors.red
                                : ThemeColors.primaryColor,
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_selectedTask!.isUrgent)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    'URGENT',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              SizedBox(height: 4),
                              Text(
                                _selectedTask!.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _hideTaskCard,
                          icon: Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoCard(Icons.location_on, 'Adresse',
                              _selectedTask!.location, isDark),
                          SizedBox(height: 12),
                          _buildInfoCard(Icons.access_time, 'Horaire',
                              _selectedTask!.preferredTime, isDark),
                          SizedBox(height: 12),
                          _buildInfoCard(Icons.schedule, 'Publié',
                              _formatTimeAgo(_selectedTask!.createdAt), isDark),
                          if (_selectedTask!.distance != null) ...[
                            SizedBox(height: 12),
                            _buildInfoCard(Icons.directions, 'Distance',
                                _calculateDistance(_selectedTask!), isDark),
                          ],
                          SizedBox(height: 20),
                          Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? ThemeColors.darkSurface
                                  : Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? Colors.grey[800]!
                                    : Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _selectedTask!.description,
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    isDark ? Colors.white70 : Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  ThemeColors.successColor.withOpacity(0.1),
                                  ThemeColors.successColor.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    ThemeColors.successColor.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.payments,
                                    color: ThemeColors.successColor, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  '${_selectedTask!.budget} MRU',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeColors.successColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Actions
                  Container(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                    decoration: BoxDecoration(
                      color: isDark ? ThemeColors.darkSurface : Colors.grey[50],
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              onPressed: () {
                                print(
                                    '▶️ Postuler button pressed, selectedTask=$_selectedTask');

                                if (_selectedTask == null) {
                                  print(
                                      '⚠️ Postuler pressed but _selectedTask is null');
                                  return;
                                }

                                try {
                                  _showApplicationDialog(_selectedTask!);
                                } catch (e, stack) {
                                  print(
                                      '❌ Error in _showApplicationDialog: $e');
                                  print(stack);
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle, size: 18),
                                  SizedBox(width: 6),
                                  Text('Postuler'),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      IconData icon, String label, String value, bool isDark) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.darkSurface : Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ThemeColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: ThemeColors.primaryColor),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showApplicationDialog(TaskModel task) {
    print('🟢 _showApplicationDialog called for task: ${task.id}');

    final TextEditingController messageController = TextEditingController();
    messageController.text = "Bonjour, je suis disponible pour cette mission.";

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (dialogContext) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeColors.primaryColor.withOpacity(0.3),
                      blurRadius: 30,
                      offset: Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 24),
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: ThemeColors.primaryColor.withOpacity(0.2),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/kh.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Postuler',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1.5,
                          ),
                        ),
                        child: TextField(
                          controller: messageController,
                          maxLines: 3,
                          enabled: !isLoading,
                          style: TextStyle(fontSize: 13, height: 1.4),
                          decoration: InputDecoration(
                            hintText: 'Votre message...',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(14),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: isLoading
                          ? Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: SizedBox(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation(
                                      ThemeColors.primaryColor),
                                ),
                              ),
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext),
                                    style: OutlinedButton.styleFrom(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 14),
                                      side: BorderSide(
                                        color: Colors.grey[300]!,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Annuler',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _submitApplicationFromMap(
                                        dialogContext,
                                        task,
                                        messageController.text,
                                        (loading) =>
                                            setState(() => isLoading = loading),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ThemeColors.primaryColor,
                                      elevation: 0,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Envoyer',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitApplicationFromMap(
    BuildContext dialogContext,
    TaskModel task,
    String message,
    Function(bool) setDialogState,
  ) async {
    setDialogState(true);

    try {
      print('🟢 _submitApplicationFromMap ENTERED');
      print('📤 Sending application from map for task: ${task.id}');

      final result = await taskService.applyToTask(
        taskId: task.id,
        message: message,
      );

      print('📥 API Response: $result');

      // ✅ إغلاق dialog التقديم
      if (Navigator.canPop(dialogContext)) {
        Navigator.pop(dialogContext);
      }

      // ⏱️ انتظار صغير للتأكد من إغلاق Dialog
      await Future.delayed(Duration(milliseconds: 100));

      if (!mounted) return;

      // 🎯 عرض النتيجة مع معالجة Soft Lock
      print('⚠️ About to call handleApplyResult');

      handleApplyResult(
        context,
        result,
        onSuccessDone: () {
          _loadTasks();
          _hideTaskCard();
        },
      );
    } catch (e) {
      print('❌ Error: $e');

      if (Navigator.canPop(dialogContext)) {
        Navigator.pop(dialogContext);
      }

      if (mounted) {
        _hideTaskCard();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _contactClient(TaskModel task) async {
    // _hideTaskCard();

    print('══════════════════════════════════');
    print('📋 Task Details:');
    print('   Task ID: ${task.id}');
    print('   Task Title: ${task.title}');
    print('   Client ID: ${task.clientId}');
    print('   Client ID Type: ${task.clientId.runtimeType}');
    print('══════════════════════════════════');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    print('📤 Calling chatService.startConversation(${task.clientId})');

    final result = await chatService.startConversation(task.clientId);

    print('📥 Chat Service Response:');
    print('   Full result: $result');
    print('   Success: ${result['ok']}');
    print('   Conversation ID: ${result['conversation_id']}');
    print('   Error: ${result['error']}');
    print('   Status Code: ${result['status']}');

    // ✅ إضافة Debug جديد
    print('🔍 DEBUG - Checking result:');
    print('   result type: ${result.runtimeType}');
    print('   result keys: ${result.keys}');
    print('   conversation_id value: ${result['conversation_id']}');
    print('   conversation_id type: ${result['conversation_id']?.runtimeType}');
    print('   conversation_id == null? ${result['conversation_id'] == null}');
    print('   conversation_id != null? ${result['conversation_id'] != null}');
    print('══════════════════════════════════');

    if (!mounted) {
      print('⚠️ Widget not mounted - returning');
      return;
    }

    Navigator.pop(context);
    print('✅ Dialog closed');

    if (result['conversation_id'] != null) {
      print('✅ Entering navigation block...');
      print('   Mounted: $mounted');
      print('   Context: $context');

      if (!mounted) {
        print('⚠️ Widget not mounted after check - returning');
        return;
      }

      print('🚀 About to push ChatScreen...');

      try {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              print('🏗️ Building ChatScreen...');
              return ChatScreen(
                conversationId: result['conversation_id'],
                contactName: 'Client',
                contactId: task.clientId,
                isOnline: false,
                profileImageUrl: null,
              );
            },
          ),
        );
        print('✅ Navigation completed');
      } catch (e) {
        print('❌ Navigation error: $e');
      }
    } else {
      print('❌ conversation_id is null - showing error');

      final errorMessage = (result['error'] ?? '').toString().toLowerCase();
      final statusCode = result['status'];

      String displayMessage;

      if (statusCode == 403 ||
          errorMessage.contains('block') ||
          errorMessage.contains('bloqué') ||
          errorMessage.contains('forbidden')) {
        displayMessage =
            'Vous ne pouvez pas discuter avec un utilisateur bloqué';
      } else {
        displayMessage =
            result['error'] ?? 'Erreur lors du démarrage de la conversation';
      }

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text('Erreur', style: TextStyle(fontSize: 18)),
            ],
          ),
          content:
              Text(displayMessage, style: TextStyle(fontSize: 15, height: 1.5)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK',
                  style:
                      TextStyle(fontSize: 16, color: ThemeColors.primaryColor)),
            ),
          ],
        ),
      );
    }

    // ✅✅✅ لا تضيفي شيئاً هنا!
    // سيتم إغلاق الـ card من الـ OutlinedButton نفسه!
  }
}
