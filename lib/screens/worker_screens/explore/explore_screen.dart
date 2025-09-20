import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/theme_colors.dart';

class WorkerExploreScreen extends StatefulWidget {
  @override
  _WorkerExploreScreenState createState() => _WorkerExploreScreenState();
}

class _WorkerExploreScreenState extends State<WorkerExploreScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  TaskModel? _selectedTask;
  bool _showTaskDetails = false;
  bool _isLocationEnabled = false;
  LatLng? _workerLocation;
  bool _isLoadingLocation = false;
  double _maxDistance = 40.0; // كم

  // إعدادات نواكشوط
  static const LatLng _nouakchottCenter = LatLng(18.0735, -15.9582);

  final List<TaskModel> _availableTasks = [
    // المهام العاجلة
    TaskModel(
      id: '1',
      title: 'Réparation plomberie urgente',
      description:
          'Fuite d\'eau importante dans la salle de bain, intervention immédiate requise',
      location: 'Tevragh Zeina',
      price: 8500,
      clientName: 'Fatima Al-Zahra',
      timePosted: DateTime.now().subtract(Duration(minutes: 15)),
      duration: '2 heures',
      coordinates: LatLng(18.0856, -15.9785),
      category: 'Plomberie',
      isUrgent: true,
      address: 'Rue 42-156, Tevragh Zeina',
    ),
    TaskModel(
      id: '2',
      title: 'Garde d\'enfants urgente',
      description:
          'Garde de 2 enfants (3 et 6 ans) - situation d\'urgence familiale',
      location: 'Ksar',
      price: 6000,
      clientName: 'Ahmed Ould Salem',
      timePosted: DateTime.now().subtract(Duration(minutes: 30)),
      duration: '4 heures',
      coordinates: LatLng(18.0614, -15.9523),
      category: 'Garde d\'enfants',
      isUrgent: true,
      address: 'Quartier 5, Ksar',
    ),
    TaskModel(
      id: '3',
      title: 'Installation électrique urgente',
      description: 'Panne électrique totale - installation de disjoncteur',
      location: 'Dar Naim',
      price: 12000,
      clientName: 'Omar Ould Ahmed',
      timePosted: DateTime.now().subtract(Duration(minutes: 45)),
      duration: '3 heures',
      coordinates: LatLng(18.0892, -15.9234),
      category: 'Électricité',
      isUrgent: true,
      address: 'Avenue Gamal Abdel Nasser, Dar Naim',
    ),

    // المهام العادية
    TaskModel(
      id: '4',
      title: 'Nettoyage de maison',
      description: 'Nettoyage complet d\'une villa de 4 chambres avec jardin',
      location: 'Sebkha',
      price: 7500,
      clientName: 'Mariem Mint Mohamed',
      timePosted: DateTime.now().subtract(Duration(hours: 1)),
      duration: '5 heures',
      coordinates: LatLng(18.1028, -15.9467),
      category: 'Nettoyage',
      isUrgent: false,
      address: 'Cité Salam, Sebkha',
    ),
    TaskModel(
      id: '5',
      title: 'Jardinage et entretien',
      description: 'Tonte de pelouse, taille des arbustes et arrosage',
      location: 'Arafat',
      price: 4500,
      clientName: 'Hassan Ba',
      timePosted: DateTime.now().subtract(Duration(hours: 2)),
      duration: '4 heures',
      coordinates: LatLng(18.0567, -15.9712),
      category: 'Jardinage',
      isUrgent: false,
      address: 'Bloc C, Arafat',
    ),
    TaskModel(
      id: '6',
      title: 'Cours particuliers',
      description: 'Cours de mathématiques pour élève de terminale',
      location: 'Riad',
      price: 3000,
      clientName: 'Aminata Sow',
      timePosted: DateTime.now().subtract(Duration(hours: 3)),
      duration: '2 heures',
      coordinates: LatLng(18.0742, -15.9345),
      category: 'Éducation',
      isUrgent: false,
      address: 'Résidence Al-Andalus, Riad',
    ),
    TaskModel(
      id: '7',
      title: 'Livraison de courses',
      description: 'Livraison de courses alimentaires depuis le marché central',
      location: 'Centre-ville',
      price: 2000,
      clientName: 'Mohamed Vall',
      timePosted: DateTime.now().subtract(Duration(hours: 1, minutes: 30)),
      duration: '1 heure',
      coordinates: LatLng(18.0868, -15.9560),
      category: 'Livraison',
      isUrgent: false,
      address: 'Marché Central, Centre-ville',
    ),
    TaskModel(
      id: '8',
      title: 'Réparation climatisation',
      description: 'Maintenance et réparation de climatiseur défaillant',
      location: 'Teyarett',
      price: 9000,
      clientName: 'Khadija Mint Ali',
      timePosted: DateTime.now().subtract(Duration(hours: 4)),
      duration: '3 heures',
      coordinates: LatLng(18.1245, -15.9823),
      category: 'Climatisation',
      isUrgent: false,
      address: 'Zone Résidentielle, Teyarett',
    ),
    TaskModel(
      id: '9',
      title: 'Cuisine pour événement',
      description: 'Préparation de repas pour 20 personnes - fête familiale',
      location: 'Toujounine',
      price: 15000,
      clientName: 'Aicha Bint Ahmed',
      timePosted: DateTime.now().subtract(Duration(hours: 2, minutes: 15)),
      duration: '6 heures',
      coordinates: LatLng(18.0423, -15.9876),
      category: 'Cuisine',
      isUrgent: false,
      address: 'Quartier Administratif, Toujounine',
    ),
    TaskModel(
      id: '10',
      title: 'Transport de meubles',
      description: 'Déménagement d\'un appartement 2 pièces',
      location: 'El Mina',
      price: 8000,
      clientName: 'Sidi Mohamed',
      timePosted: DateTime.now().subtract(Duration(hours: 5)),
      duration: '4 heures',
      coordinates: LatLng(18.0512, -15.9234),
      category: 'Transport',
      isUrgent: false,
      address: 'Port de Pêche, El Mina',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadLocationState();
    _createMarkers();
  }

  /// تحميل حالة الموقع من الإعدادات المحفوظة
  Future<void> _loadLocationState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocationState =
          prefs.getBool('worker_location_enabled') ?? false;

      setState(() {
        _isLocationEnabled = savedLocationState;
      });

      if (_isLocationEnabled) {
        await _getCurrentLocation();
      }
    } catch (e) {
      print('Error loading location state: $e');
    }
  }

  /// الحصول على الموقع الحالي للعامل
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
          timeLimit: Duration(seconds: 120),
        );

        setState(() {
          _workerLocation = LatLng(position.latitude, position.longitude);
        });

        await _createMarkers();

        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(_workerLocation!, 14.0),
          );
        }
      }
    } catch (e) {
      print('Error getting location: $e');
      // استخدام موقع افتراضي في نواكشوط للاختبار
      setState(() {
        _workerLocation = LatLng(18.0735, -15.9582);
      });
      await _createMarkers();
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  /// إنشاء جميع المارك على الخريطة
  Future<void> _createMarkers() async {
    Set<Marker> markers = {};

    // إضافة مارك العامل إذا كان الموقع مفعل
    if (_isLocationEnabled && _workerLocation != null) {
      markers.add(
        Marker(
          markerId: MarkerId('worker_location'),
          position: _workerLocation!,
          icon: await _createCustomMarker(Colors.green),
          infoWindow: InfoWindow(
            title: 'موقعك الحالي',
            snippet: 'العامل',
          ),
        ),
      );
    }

    // إضافة مارك المهام
    for (TaskModel task in _availableTasks) {
      String distanceText = '';

      if (_isLocationEnabled && _workerLocation != null) {
        double distanceKm = Geolocator.distanceBetween(
              _workerLocation!.latitude,
              _workerLocation!.longitude,
              task.coordinates.latitude,
              task.coordinates.longitude,
            ) /
            1000;

        distanceText = ' - ${distanceKm.toStringAsFixed(1)} km';
      }

      Color markerColor = task.isUrgent ? Colors.red : Colors.lightBlue;

      markers.add(
        Marker(
          markerId: MarkerId(task.id),
          position: task.coordinates,
          icon: await _createCustomMarker(markerColor),
          infoWindow: InfoWindow(
            title: task.title,
            snippet: '${task.price} MRU$distanceText',
          ),
          onTap: () => _displayTaskCard(task),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  /// إنشاء مارك مخصص بلون محدد
  Future<BitmapDescriptor> _createCustomMarker(Color color) async {
    if (color == Colors.red) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    } else if (color == Colors.green) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    } else {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
  }

  /// الحصول على أيقونة الفئة
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
        return Icons.local_shipping;
      default:
        return Icons.work;
    }
  }

  /// عرض بطاقة تفاصيل المهمة
  void _displayTaskCard(TaskModel task) {
    setState(() {
      _selectedTask = task;
      _showTaskDetails = true;
    });
  }

  /// إخفاء بطاقة التفاصيل
  void _hideTaskCard() {
    setState(() {
      _showTaskDetails = false;
      _selectedTask = null;
    });
  }

  /// تنسيق وقت النشر
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

  /// حساب المسافة بين العامل والمهمة
  String _calculateDistance(TaskModel task) {
    if (!_isLocationEnabled || _workerLocation == null) {
      return 'Position désactivée';
    }

    double distanceKm = Geolocator.distanceBetween(
          _workerLocation!.latitude,
          _workerLocation!.longitude,
          task.coordinates.latitude,
          task.coordinates.longitude,
        ) /
        1000;

    return '${distanceKm.toStringAsFixed(1)} km';
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
        actions: [
          // مؤشر حالة الموقع
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
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              if (isDark) {
                controller.setMapStyle(_darkMapStyle);
              }
            },
            initialCameraPosition: CameraPosition(
              target: _workerLocation ?? _nouakchottCenter,
              zoom: _isLocationEnabled ? 14.0 : 12.0,
            ),
            markers: _markers,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onTap: (_) => _hideTaskCard(),
          ),

          // عداد المهام المتاحة
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? ThemeColors.darkCardBackground : Colors.white,
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
                    Icons.work_outline,
                    color: ThemeColors.primaryColor,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${_availableTasks.length} tâches disponibles',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                  ),
                ],
              ),
            ),
          ),

          // بطاقة تفاصيل المهمة في المنتصف
          if (_showTaskDetails && _selectedTask != null)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  margin: EdgeInsets.all(24),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:
                        isDark ? ThemeColors.darkCardBackground : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // رأس البطاقة
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _selectedTask!.isUrgent
                                    ? Colors.red.withOpacity(0.1)
                                    : ThemeColors.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getCategoryIcon(_selectedTask!.category),
                                color: _selectedTask!.isUrgent
                                    ? Colors.red
                                    : ThemeColors.primaryColor,
                                size: 24,
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
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'URGENT',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  SizedBox(height: 4),
                                  Text(
                                    _selectedTask!.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: _hideTaskCard,
                              icon: Icon(Icons.close, color: Colors.grey),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        // معلومات المهمة
                        _buildDetailRow(context, Icons.location_on, 'Adresse',
                            _selectedTask!.address, isDark),
                        SizedBox(height: 8),
                        _buildDetailRow(context, Icons.access_time, 'Durée',
                            _selectedTask!.duration, isDark),
                        SizedBox(height: 8),
                        _buildDetailRow(context, Icons.person, 'Client',
                            _selectedTask!.clientName, isDark),
                        SizedBox(height: 8),
                        _buildDetailRow(context, Icons.schedule, 'Publié',
                            _formatTimeAgo(_selectedTask!.timePosted), isDark),
                        if (_isLocationEnabled) ...[
                          SizedBox(height: 8),
                          _buildDetailRow(context, Icons.directions, 'Distance',
                              _calculateDistance(_selectedTask!), isDark),
                        ],

                        SizedBox(height: 16),

                        // الوصف
                        Text(
                          'Description',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? ThemeColors.darkSurface
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _selectedTask!.description,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.grey[700],
                                  height: 1.4,
                                ),
                          ),
                        ),

                        SizedBox(height: 20),

                        // السعر والأزرار
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color:
                                    ThemeColors.successColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_selectedTask!.price} MRU',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: ThemeColors.successColor,
                                ),
                              ),
                            ),
                            Spacer(),
                            ElevatedButton(
                              onPressed: () =>
                                  _showApplicationDialog(_selectedTask!),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ThemeColors.primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.send, size: 16),
                                  SizedBox(width: 8),
                                  Text('Postuler'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // أزرار التحكم
          Positioned(
            bottom: 20,
            right: 16,
            child: Column(
              children: [
                // زر تحديث الموقع
                FloatingActionButton(
                  onPressed: _isLocationEnabled ? _getCurrentLocation : null,
                  backgroundColor: _isLocationEnabled
                      ? ThemeColors.primaryColor
                      : Colors.grey,
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
                ),
                SizedBox(height: 8),
                // زر الفلاتر
                FloatingActionButton(
                  onPressed: _showFilterDialog,
                  backgroundColor: ThemeColors.primaryColor,
                  child: Icon(Icons.filter_list, color: Colors.white),
                  mini: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// بناء صف التفاصيل
  Widget _buildDetailRow(BuildContext context, IconData icon, String label,
      String value, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: ThemeColors.primaryColor,
        ),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontSize: 14,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 14,
                ),
          ),
        ),
      ],
    );
  }

  /// عرض نافذة التقدم للمهمة
  void _showApplicationDialog(TaskModel task) {
    final TextEditingController messageController = TextEditingController();
    messageController.text =
        "Je suis disponible pour cette tâche. J'ai de l'expérience dans ce domaine.";

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor:
              isDark ? ThemeColors.darkCardBackground : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Postuler pour cette tâche',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tâche: ${task.title}',
                style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey[700]),
              ),
              SizedBox(height: 16),
              TextField(
                controller: messageController,
                maxLines: 3,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ThemeColors.primaryColor),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _hideTaskCard();
                _sendApplication(task, messageController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Envoyer', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  /// إرسال طلب التقدم
  void _sendApplication(TaskModel task, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Candidature envoyée pour "${task.title}"'),
        backgroundColor: ThemeColors.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// عرض نافذة الفلاتر
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filtres'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Distance maximale: ${_maxDistance.toInt()} km'),
            Slider(
              value: _maxDistance,
              min: 5,
              max: 100,
              divisions: 19,
              label: '${_maxDistance.toInt()} km',
              onChanged: (value) {
                setState(() {
                  _maxDistance = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  // Style de carte pour le mode sombre
  static const String _darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  }
]''';
}

// Model المهام - جاهز للإنتاج
class TaskModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final int price;
  final String clientName;
  final DateTime timePosted;
  final String duration;
  final LatLng coordinates;
  final String category;
  final bool isUrgent;
  final String address;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.price,
    required this.clientName,
    required this.timePosted,
    required this.duration,
    required this.coordinates,
    required this.category,
    required this.isUrgent,
    required this.address,
  });

  /// تحويل من JSON (للربط مع API)
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      price: json['price'],
      clientName: json['clientName'],
      timePosted: DateTime.parse(json['timePosted']),
      duration: json['duration'],
      coordinates: LatLng(json['latitude'], json['longitude']),
      category: json['category'],
      isUrgent: json['isUrgent'],
      address: json['address'],
    );
  }

  /// تحويل إلى JSON (للإرسال إلى API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'price': price,
      'clientName': clientName,
      'timePosted': timePosted.toIso8601String(),
      'duration': duration,
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
      'category': category,
      'isUrgent': isUrgent,
      'address': address,
    };
  }
}
