import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  // إعدادات نواكشوط
  static const LatLng _nouakchottCenter = LatLng(18.0735, -15.9582);

  final List<TaskModel> _availableTasks = [
    TaskModel(
      id: '1',
      title: 'Nettoyage de maison',
      description: 'Nettoyage complet d\'une villa de 4 chambres',
      location: 'Tevragh Zeina',
      price: 5000,
      clientName: 'Fatima Al-Zahra',
      timePosted: DateTime.now().subtract(Duration(hours: 2)),
      duration: '4 heures',
      coordinates: LatLng(18.0856, -15.9785),
      category: 'Nettoyage',
      isUrgent: false,
    ),
    TaskModel(
      id: '2',
      title: 'Réparation plomberie',
      description: 'Fuite d\'eau dans la salle de bain, intervention urgente',
      location: 'Ksar',
      price: 3500,
      clientName: 'Ahmed Ould Salem',
      timePosted: DateTime.now().subtract(Duration(minutes: 30)),
      duration: '2 heures',
      coordinates: LatLng(18.0614, -15.9523),
      category: 'Plomberie',
      isUrgent: true,
    ),
    TaskModel(
      id: '3',
      title: 'Garde d\'enfants',
      description: 'Garde de 2 enfants (5 et 8 ans) pour la soirée',
      location: 'Sebkha',
      price: 2500,
      clientName: 'Mariem Mint Mohamed',
      timePosted: DateTime.now().subtract(Duration(hours: 1)),
      duration: '6 heures',
      coordinates: LatLng(18.1028, -15.9467),
      category: 'Garde d\'enfants',
      isUrgent: false,
    ),
    TaskModel(
      id: '4',
      title: 'Jardinage',
      description: 'Tonte de pelouse et taille des arbustes',
      location: 'Arafat',
      price: 4000,
      clientName: 'Hassan Ba',
      timePosted: DateTime.now().subtract(Duration(hours: 3)),
      duration: '3 heures',
      coordinates: LatLng(18.0567, -15.9712),
      category: 'Jardinage',
      isUrgent: false,
    ),
    TaskModel(
      id: '5',
      title: 'Installation électrique',
      description: 'Installation d\'un nouveau tableau électrique',
      location: 'Dar Naim',
      price: 6000,
      clientName: 'Omar Ould Ahmed',
      timePosted: DateTime.now().subtract(Duration(minutes: 45)),
      duration: '5 heures',
      coordinates: LatLng(18.0892, -15.9234),
      category: 'Électricité',
      isUrgent: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  void _createMarkers() {
    for (TaskModel task in _availableTasks) {
      _markers.add(
        Marker(
          markerId: MarkerId(task.id),
          position: task.coordinates,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: task.title,
            snippet: '${task.price} MRU - ${task.location}',
          ),
          onTap: () => _showTaskDetailSheet(task),
        ),
      );
    }
  }

  void _showTaskDetailSheet(TaskModel task) {
    setState(() {
      _selectedTask = task;
      _showTaskDetails = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTaskDetailsSheet(task),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Tâches Disponibles'),
        centerTitle: true,
        backgroundColor: isDark ? ThemeColors.darkBackground : Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;

              // تطبيق الثيم المظلم إذا كان مفعلاً
              if (isDark) {
                controller.setMapStyle(_darkMapStyle);
              }
            },
            initialCameraPosition: CameraPosition(
              target: _nouakchottCenter,
              zoom: 12.0,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
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

          // زر تحديث الموقع
          Positioned(
            bottom: 80,
            right: 16,
            child: FloatingActionButton(
              onPressed: _refreshLocation,
              backgroundColor: ThemeColors.primaryColor,
              child: Icon(Icons.my_location, color: Colors.white),
              mini: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskDetailsSheet(TaskModel task) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? ThemeColors.darkCardBackground : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // En-tête de la tâche
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        task.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                      ),
                                    ),
                                    if (task.isUrgent)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Publié ${_formatTimeAgo(task.timePosted)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.grey[600],
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: ThemeColors.successColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${task.price} MRU',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: ThemeColors.successColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      // Détails de la tâche
                      _buildDetailRow(context, Icons.location_on, 'Lieu',
                          task.location, isDark),
                      SizedBox(height: 12),
                      _buildDetailRow(context, Icons.access_time, 'Durée',
                          task.duration, isDark),
                      SizedBox(height: 12),
                      _buildDetailRow(context, Icons.person, 'Client',
                          task.clientName, isDark),
                      SizedBox(height: 12),
                      _buildDetailRow(context, Icons.category, 'Catégorie',
                          task.category, isDark),

                      SizedBox(height: 20),

                      // Description
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
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? ThemeColors.darkSurface
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          task.description,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color:
                                    isDark ? Colors.white70 : Colors.grey[700],
                                height: 1.4,
                              ),
                        ),
                      ),

                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              // Boutons d'action
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? ThemeColors.darkCardBackground : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color:
                          isDark ? ThemeColors.darkBorder : Colors.grey[200]!,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: ThemeColors.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Fermer',
                          style: TextStyle(
                            color: ThemeColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => _showApplicationDialog(task),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeColors.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Postuler',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label,
      String value, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: ThemeColors.primaryColor,
        ),
        SizedBox(width: 12),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
          ),
        ),
      ],
    );
  }

  void _showApplicationDialog(TaskModel task) {
    Navigator.pop(context); // أغلق الـ bottom sheet أولاً

    final TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor:
              isDark ? ThemeColors.darkCardBackground : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Postuler pour cette tâche',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tâche: ${task.title}',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Message optionnel:',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: messageController,
                maxLines: 3,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  hintText:
                      'Décrivez brièvement pourquoi vous êtes le bon candidat...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey[500],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
              child: Text(
                'Annuler',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _sendApplication(task, messageController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Envoyer'),
            ),
          ],
        );
      },
    );
  }

  void _sendApplication(TaskModel task, String message) {
    // هنا سيتم إرسال الطلب إلى الخادم
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Candidature envoyée avec succès pour "${task.title}"'),
        backgroundColor: ThemeColors.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    // TODO: Implémenter les filtres (catégorie, prix, distance, etc.)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filtres'),
        content: Text('Les filtres seront implémentés prochainement'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _refreshLocation() {
    // TODO: Actualiser la position et les tâches à proximité
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(_nouakchottCenter),
      );
    }
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

// Model pour les tâches
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
  });
}
