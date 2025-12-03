import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/colors.dart';
import '../../../models/models.dart';
import '../../../services/task_service.dart';
import '../../../services/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'worker_opportunities_screen.dart';
import '../../../services/auth_manager.dart';
import '../../../core/config/api_config.dart';
import '../../../core/theme/theme_colors.dart';
import '../../shared_screens/dialogs/success_dialog.dart';
import '../../../utils/apply_helper.dart';
import '../../../services/profile_service.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({Key? key}) : super(key: key);

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen>
    with WidgetsBindingObserver {
  // ← تم الإضافة
  bool _isLocationEnabled = false;
  String _currentLocation = "Nouakchott";
  String _currentCountry = "Mauritanie";
  bool _isLocationLoading = false;
  bool _isLoadingTasks = true;
  List<TaskModel> _tasks = [];
  LatLng? _workerLocation;
  String? _workerCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setWorkerOnline();
    _loadLocationState();
    _checkAndStartTracking();
    _loadWorkerCategory(); // ✅ أضيفي هذا السطر
    _loadTasks();
  }

  void _loadLocationState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocationState =
          prefs.getBool('worker_location_enabled') ?? false;

      setState(() {
        _isLocationEnabled = savedLocationState;
      });
    } catch (e) {
      print('Error loading location state: $e');
    }
  }

  Future<void> _checkAndStartTracking() async {
    if (_isLocationEnabled) {
      print('🟢 Switch is ON → Starting tracking...');
      _workerLocation = await locationService.getCurrentLocation(
        sendToBackend: true,
      );

      if (_workerLocation != null) {
        setState(() {
          _currentLocation = "Position GPS active";
        });

        await locationService.startPeriodicTracking(
          interval: Duration(minutes: 5),
        );

        print('✅ Tracking started successfully');
      } else {
        print('⚠️ Could not get location, using last saved');
        final lastLocation = await locationService.getLastSavedLocation();
        if (lastLocation != null) {
          setState(() {
            _workerLocation = lastLocation;
            _currentLocation = "Position GPS active";
          });
        }
      }
    } else {
      print('🔴 Switch is OFF → Loading last location only');
      final lastLocation = await locationService.getLastSavedLocation();
      if (lastLocation != null) {
        setState(() {
          _workerLocation = lastLocation;
          _currentLocation = "Dernière position connue";
        });
      }
    }
  }

  Future<void> _loadWorkerCategory() async {
    try {
      final result = await profileService.getWorkerProfile();
      if (result['ok']) {
        final workerProfile = result['workerProfile'] as WorkerProfile;
        setState(() {
          _workerCategory = workerProfile.serviceCategory;
        });
        print('🔎 Worker category loaded: $_workerCategory');
      }
    } catch (e) {
      print('❌ Error loading worker category: $e');
    }
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoadingTasks = true);

    LatLng? workerLocation = locationService.currentLocation ??
        await locationService.getLastSavedLocation();

    final result = await taskService.getAvailableTasks(
      sortBy: 'latest',
      lat: workerLocation?.latitude,
      lng: workerLocation?.longitude,
    );

    if (mounted) {
      setState(() {
        _isLoadingTasks = false;
        if (result['ok']) {
          List<TaskModel> allTasks = result['tasks'] as List<TaskModel>;

          // ✅ تصفية المهام: مهام التصنيف + غير المصنفة
          if (_workerCategory != null && _workerCategory!.isNotEmpty) {
            final workerCat = _workerCategory!.toLowerCase().trim();
            allTasks = allTasks.where((task) {
              final taskCat = task.serviceType.toLowerCase().trim();
              // عرض مهام تصنيف العامل أو المهام غير المصنفة
              return taskCat == workerCat || task.isUnclassified;
            }).toList();
          }

          _tasks = allTasks.take(4).toList();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    ThemeColors.primaryColor,
                    ThemeColors.primaryColor.withOpacity(0.8),
                    ThemeColors.darkBackground,
                  ]
                : [
                    ThemeColors.primaryColor,
                    ThemeColors.primaryColor.withOpacity(0.8),
                    ThemeColors.lightBackground,
                  ],
            stops: const [0.0, 0.3, 0.6],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildModernLocationHeader(),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        _buildWelcomeCard(),
                        const SizedBox(height: 24),
                        _buildQuickActions(),
                        const SizedBox(height: 24),
                        _buildOpportunitiesSection(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernLocationHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Position',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: _isLocationEnabled
                              ? AppColors.green
                              : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _isLocationLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _isLocationEnabled
                                          ? "Position GPS active" // ← نص ثابت دائماً
                                          : 'Désactivée',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    // ✅ حذف الأيقونة البرتقالية تماماً
                                  ],
                                ),
                                if (_isLocationEnabled)
                                  Text(
                                    _currentCountry,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                              ],
                            ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white.withOpacity(0.7),
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Switch(
                  value: _isLocationEnabled,
                  onChanged: _toggleLocation,
                  activeColor: Colors.white,
                  activeTrackColor: AppColors.green.withOpacity(0.8),
                  inactiveThumbColor: Colors.white.withOpacity(0.7),
                  inactiveTrackColor: Colors.white.withOpacity(0.2),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _showSearchOptions,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.white.withOpacity(0.8),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Rechercher des opportunités...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.tune,
                      color: Colors.white.withOpacity(0.9),
                      size: 16,
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

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Spécial pour vous',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Nouvelles missions\ndisponibles',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Jusqu\'à 15 000 MRU aujourd\'hui',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.work_outline,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? ThemeColors.darkTextPrimary
                : ThemeColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.explore,
                title: 'Explorer',
                subtitle: 'Trouver missions',
                color: AppColors.cyan,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.assignment,
                title: 'Mes Tâches',
                subtitle: 'Gérer missions',
                color: AppColors.orange,
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? ThemeColors.darkCardBackground
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark
                    ? ThemeColors.darkTextPrimary
                    : ThemeColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).brightness == Brightness.dark
                    ? ThemeColors.darkTextSecondary
                    : ThemeColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpportunitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Opportunités près de vous',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? ThemeColors.darkTextPrimary
                    : ThemeColors.lightTextPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkerOpportunitiesScreen(
                      filterType: 'all',
                    ),
                  ),
                ).then((_) => _loadTasks());
              },
              child: Text(
                'Voir tout',
                style: TextStyle(
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _isLoadingTasks
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: CircularProgressIndicator(
                    color: AppColors.primaryPurple,
                  ),
                ),
              )
            : _tasks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.work_off,
                              size: 48, color: AppColors.mediumGray),
                          const SizedBox(height: 12),
                          Text(
                            'Aucune opportunité disponible',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) =>
                        _buildOpportunityCard(_tasks[index]),
                  ),
      ],
    );
  }

  Widget _buildOpportunityCard(TaskModel task) {
    final isUrgent = task.isUrgent;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? ThemeColors.darkCardBackground
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isUrgent ? Border.all(color: Colors.red, width: 2.5) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(task.serviceType),
                  color: AppColors.primaryPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isUrgent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          'URGENT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? ThemeColors.darkTextPrimary
                            : ThemeColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (task.distance != null) // ✅ فقط إذا كان هناك مسافة حقيقية
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!locationService.isLocationFresh) ...[
                        Icon(Icons.schedule, size: 12, color: Colors.orange),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        '${task.distance!.toStringAsFixed(1)} km',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? ThemeColors.darkTextSecondary
                      : ThemeColors.lightTextSecondary),
              const SizedBox(width: 4),
              Expanded(
                // ✅ أضف Expanded
                child: Text(
                  task.location,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? ThemeColors.darkTextSecondary
                        : ThemeColors.lightTextSecondary,
                  ),
                  overflow: TextOverflow.ellipsis, // ✅ قص النص الطويل
                  maxLines: 1, // ✅ سطر واحد فقط
                ),
              ),
              const SizedBox(width: 8), // ✅ استبدل Spacer بمسافة ثابتة
              Text(
                task.preferredTime,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? ThemeColors.darkTextSecondary
                      : ThemeColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _showApplicationDialog(task),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_add, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Postuler',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                '${task.budget} MRU',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String serviceType) {
    if (serviceType.toLowerCase() == "non classifié" ||
        serviceType.toLowerCase() == "non classifie") {
      return Icons.help_outline; // ✅ علامة استفهام برتقالية
    }
    switch (serviceType.toLowerCase()) {
      case 'nettoyage':
      case 'nettoyage maison':
      case 'nettoyage tapis':
        return Icons.cleaning_services;
      case 'plomberie':
        return Icons.plumbing;
      case 'jardinage':
        return Icons.grass;
      case 'garde d\'enfants':
        return Icons.child_care;
      case 'électricité':
        return Icons.electrical_services;
      case 'peinture':
        return Icons.format_paint;
      case 'déménagement':
        return Icons.local_shipping;
      case 'livraison':
        return Icons.delivery_dining;
      case 'cuisine':
      case 'cuisine quotidienne':
        return Icons.restaurant;
      case 'climatisation':
        return Icons.ac_unit;
      default:
        return Icons.work_outline;
    }
  }

  void _showApplicationDialog(TaskModel task) {
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
                      color: AppColors.primaryPurple.withOpacity(0.3),
                      blurRadius: 30,
                      offset: Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🎯 Logo التطبيق
                    SizedBox(height: 24),
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryPurple.withOpacity(0.2),
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

                    // 📝 Title فقط
                    Text(
                      'Postuler',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),

                    SizedBox(height: 16),

                    // 💬 Message Field
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

                    // 🔘 Buttons - نفس الحجم
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
                                    AppColors.primaryPurple,
                                  ),
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
                                      _submitApplication(
                                        dialogContext,
                                        task,
                                        messageController.text,
                                        (loading) =>
                                            setState(() => isLoading = loading),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryPurple,
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

  Future<void> _submitApplication(
    BuildContext dialogContext,
    TaskModel task,
    String message,
    Function(bool) setDialogState,
  ) async {
    setDialogState(true);

    try {
      print('📤 Sending application for task: ${task.id}');

      final result = await taskService.applyToTask(
        taskId: task.id,
        message: message,
      );

      print('📥 API Response: $result');

      // ✅ أغلق Dialog باستخدام dialogContext
      if (Navigator.canPop(dialogContext)) {
        Navigator.of(dialogContext).pop();
      }

      if (!mounted) return;

      // ✅ انتظر قليلاً
      await Future.delayed(Duration(milliseconds: 150));

      // ✅ استخدام الدالة الموحدة - سطر واحد فقط!
      handleApplyResult(
        context,
        result,
        onSuccessDone: () {
          _loadTasks();
        },
      );
    } catch (e) {
      print('❌ Error: $e');

      if (Navigator.canPop(dialogContext)) {
        Navigator.of(dialogContext).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleLocation(bool value) async {
    setState(() => _isLocationLoading = true);

    try {
      if (value) {
        // ═══════════════════════════════════
        // ✅ تفعيل الموقع
        // ═══════════════════════════════════

        // 1. طلب صلاحيات GPS
        bool hasPermission = await locationService.requestLocationPermission();

        if (!hasPermission) {
          setState(() => _isLocationLoading = false);
          _showErrorSnackBar('Permission refusée');
          return;
        }

        // 2. جلب الموقع الحالي مع إرسال للـ Backend
        LatLng? location = await locationService.getCurrentLocation(
          sendToBackend: true, // ← مهم!
        );

        if (location == null) {
          setState(() => _isLocationLoading = false);
          _showErrorSnackBar('Impossible d\'obtenir la position');
          return;
        }

        // 3. تفعيل المشاركة في Backend (يُحدّث is_online أيضاً)
        final toggleResult = await locationService.toggleLocationSharing(true);

        if (!toggleResult['ok']) {
          setState(() => _isLocationLoading = false);
          _showErrorSnackBar('Erreur Backend');
          return;
        }

        // 4. بدء التتبع الدوري (كل 5 دقائق)
        await locationService.startPeriodicTracking(
          interval: Duration(minutes: 5),
        );

        // 5. حفظ الحالة محلياً
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('worker_location_enabled', true);

        setState(() {
          _isLocationEnabled = true;
          _workerLocation = location;
          _currentLocation = "Position GPS active"; // ← نص ثابت دائماً
          _isLocationLoading = false;
        });

        _showSuccessSnackBar('Position activée avec succès!');

        // 6. إعادة تحميل المهام بالموقع الجديد
        _loadTasks();
      } else {
        // ═══════════════════════════════════
        // ❌ إلغاء الموقع
        // ═══════════════════════════════════

        // 1. إيقاف التتبع الدوري فوراً
        locationService.stopPeriodicTracking();

        // 2. إلغاء المشاركة في Backend (يُحدّث is_online = false)
        await locationService.toggleLocationSharing(false);

        // 3. حفظ الحالة محلياً
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('worker_location_enabled', false);

        setState(() {
          _isLocationEnabled = false;
          _currentLocation = "Désactivée"; // ← نص واضح
          _isLocationLoading = false;
        });

        _showSuccessSnackBar('Position désactivée');
      }
    } catch (e) {
      print('❌ Error toggling location: $e');
      setState(() => _isLocationLoading = false);
      _showErrorSnackBar('Erreur');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSearchOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // ✅ مهم جداً
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height *
            0.60, // ✅ ارتفاع ثابت 60% من الشاشة
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? ThemeColors.darkCardBackground
              : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min, // ✅ اتركيه min
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trier les missions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? ThemeColors.darkTextPrimary
                        : ThemeColors.lightTextPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: AppColors.mediumGray),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              // ✅ مهم: يجعل المحتوى يأخذ المساحة المتبقية
              child: SingleChildScrollView(
                // ✅ للتمرير إذا كان المحتوى طويلاً
                child: Column(
                  children: [
                    _buildSearchOption(
                      icon: Icons.work_outline,
                      title: 'Ma catégorie',
                      subtitle: 'Missions dans votre domaine',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkerOpportunitiesScreen(
                              filterType: 'category',
                              categoryFilter: null,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildSearchOption(
                      icon: Icons.location_on_outlined,
                      title: 'Plus proches',
                      subtitle: 'Triées par distance croissante',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkerOpportunitiesScreen(
                                filterType: 'distance'),
                          ),
                        );
                      },
                    ),
                    _buildSearchOption(
                      icon: Icons.attach_money,
                      title: 'Prix croissant',
                      subtitle: 'Du moins cher au plus cher',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                WorkerOpportunitiesScreen(filterType: 'price'),
                          ),
                        );
                      },
                    ),
                    _buildSearchOption(
                      icon: Icons.map_outlined,
                      title: 'Par région',
                      subtitle: 'Groupées par zones',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                WorkerOpportunitiesScreen(filterType: 'region'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? ThemeColors.darkCardBackground.withOpacity(0.5)
              : Colors.grey[100]!,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primaryPurple, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? ThemeColors.darkTextPrimary
                          : ThemeColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? ThemeColors.darkTextSecondary
                          : ThemeColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 14, color: AppColors.mediumGray),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    print('📱 App state: $state');

    if (state == AppLifecycleState.paused) {
      // ✅ التطبيق في الخلفية - لا شيء (التتبع مستمر)
      print('⏸️ App paused → Tracking continues');
    } else if (state == AppLifecycleState.detached) {
      // ✅ التطبيق سيُغلق
      print('🔴 App detached → Setting offline');
      _handleAppClosing();
    }
  }

// ✅ دالة مشتركة
  Future<void> _handleAppClosing() async {
    print('🔴 Setting worker offline');

    if (_isLocationEnabled) {
      // 1. أوقف التتبع المحلي فقط
      locationService.stopPeriodicTracking();

      // 2. تحقق من وجود Token قبل استدعاء Backend
      final isAuthenticated = await AuthManager.isAuthenticated();
      if (isAuthenticated) {
        // فقط إذا كان مسجل دخول، أرسل للـ Backend
        await locationService.toggleLocationSharing(false);
      } else {
        print('⏭️ Skipping backend call - user logged out');
      }
    }
  }

  Future<void> _setWorkerOnline() async {
    try {
      final response = await AuthManager.authenticatedRequest(
        method: 'POST',
        endpoint: '${ApiConfig.baseUrl()}/set-online/',
        body: {'is_online': true},
      );

      if (response.statusCode == 200) {
        print('✅ Worker set to online');
      } else {
        print('⚠️ Failed to set online: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error setting online: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // ✅ استدعاء async function
    _handleAppClosing();

    super.dispose();
  }
}
