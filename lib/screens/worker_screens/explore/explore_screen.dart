import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../models/models.dart';
import '../../../services/task_service.dart';
import '../../../services/location_service.dart';

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
  bool _isLoadingTasks = true;
  List<TaskModel> _availableTasks = [];
  double _maxDistance = 40.0;

  static const LatLng _nouakchottCenter = LatLng(18.0735, -15.9582);

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadLocationState();
    await _loadTasks();
  }

  Future<void> _loadLocationState() async {
    try {
      final lastLocation = await locationService.getLastSavedLocation();
      _isLocationEnabled = locationService.isTracking;

      if (lastLocation != null) {
        setState(() {
          _workerLocation = lastLocation;
        });
      } else if (_isLocationEnabled) {
        await _getCurrentLocation();
      }
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
            print('Task: ${task.title} → Coordinates: ${task.coordinates}');
          }

          _createMarkers();
        }
      });
    }
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

    if (_isLocationEnabled && _workerLocation != null) {
      markers.add(
        Marker(
          markerId: MarkerId('worker_location'),
          position: _workerLocation!,
          icon: await _createCustomMarker(Colors.green),
          infoWindow: InfoWindow(
            title: 'Votre position',
            snippet: 'Travailleur',
          ),
        ),
      );
    }

    for (TaskModel task in _availableTasks) {
      if (task.coordinates == null) continue;
      String distanceText = '';
      if (_isLocationEnabled && _workerLocation != null) {
        double distanceKm = task.distance ?? 0.0;
        distanceText = ' - ${distanceKm.toStringAsFixed(1)} km';
      }

      Color markerColor = task.isUrgent ? Colors.red : Colors.lightBlue;

      markers.add(
        Marker(
          markerId: MarkerId(task.id.toString()),
          position: task.coordinates ?? LatLng(18.0735, -15.9582),
          icon: await _createCustomMarker(markerColor),
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
    });
  }

  Future<BitmapDescriptor> _createCustomMarker(Color color) async {
    if (color == Colors.red) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    } else if (color == Colors.green) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    } else {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
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
        actions: [
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
                          Icons.work_outline,
                          color: ThemeColors.primaryColor,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${_availableTasks.length} tâches disponibles',
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
                        onPressed: _loadTasks,
                        backgroundColor: ThemeColors.primaryColor,
                        child: Icon(Icons.refresh, color: Colors.white),
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
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          margin: EdgeInsets.all(24),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? ThemeColors.darkCardBackground : Colors.white,
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
                        _getCategoryIcon(_selectedTask!.serviceType),
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
                                  color: isDark ? Colors.white : Colors.black,
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
                _buildDetailRow(context, Icons.location_on, 'Adresse',
                    _selectedTask!.location, isDark),
                SizedBox(height: 8),
                _buildDetailRow(context, Icons.access_time, 'Horaire',
                    _selectedTask!.preferredTime, isDark),
                SizedBox(height: 8),
                _buildDetailRow(context, Icons.schedule, 'Publié',
                    _formatTimeAgo(_selectedTask!.createdAt), isDark),
                if (_selectedTask!.distance != null) ...[
                  SizedBox(height: 8),
                  _buildDetailRow(context, Icons.directions, 'Distance',
                      _calculateDistance(_selectedTask!), isDark),
                ],
                SizedBox(height: 16),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? ThemeColors.darkSurface : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _selectedTask!.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white70 : Colors.grey[700],
                          height: 1.4,
                        ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: ThemeColors.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_selectedTask!.budget} MRU',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ThemeColors.successColor,
                        ),
                      ),
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () => _showApplicationDialog(_selectedTask!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColors.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label,
      String value, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: ThemeColors.primaryColor),
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

  void _showApplicationDialog(TaskModel task) {
    final TextEditingController messageController = TextEditingController();
    messageController.text =
        "Je suis disponible pour cette tâche et j'ai de l'expérience dans ce domaine.";

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isLoading = false;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor:
                  isDark ? ThemeColors.darkCardBackground : Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
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
                    enabled: !isLoading,
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.black),
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
                if (isLoading)
                  Center(
                      child: CircularProgressIndicator(
                          color: ThemeColors.primaryColor))
                else ...[
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text('Annuler'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _submitApplicationFromMap(
                        dialogContext,
                        task,
                        messageController.text,
                        (loading) => setState(() => isLoading = loading),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColors.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child:
                        Text('Envoyer', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ],
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
      final result = await taskService.applyToTask(
        taskId: task.id,
        message: message,
      );

      if (!mounted) return;
      setDialogState(false);

      Navigator.pop(dialogContext);
      _hideTaskCard();

      if (result['ok']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Candidature envoyée avec succès!'),
            backgroundColor: ThemeColors.successColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        await _loadTasks();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Erreur'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      setDialogState(false);
      if (mounted) {
        Navigator.pop(dialogContext);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
