import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../models/models.dart';
import '../../../services/task_service.dart';
import '../../../services/category_service.dart';
import '../../../services/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../services/profile_service.dart';
import '../../../core/theme/theme_colors.dart';

class WorkerOpportunitiesScreen extends StatefulWidget {
  final String filterType; // 'category', 'distance', 'price', 'region'
  final String? categoryFilter;

  const WorkerOpportunitiesScreen({
    Key? key,
    required this.filterType,
    this.categoryFilter,
  }) : super(key: key);

  @override
  State<WorkerOpportunitiesScreen> createState() =>
      _WorkerOpportunitiesScreenState();
}

class _WorkerOpportunitiesScreenState extends State<WorkerOpportunitiesScreen> {
  // State variables
  bool _isLoading = true;
  List<TaskModel> _tasks = [];
  List<NouakchottArea> _areas = [];
  String? _errorMessage;
  String selectedSortType = 'none';
  String selectedArea = 'Toutes Zones';

  List<TaskModel> get filteredOpportunities {
    List<TaskModel> filtered = List.from(_tasks);

    // فلترة حسب الفئة
    if (widget.categoryFilter != null) {
      filtered = filtered
          .where((task) => task.serviceType
              .toLowerCase()
              .contains(widget.categoryFilter!.toLowerCase()))
          .toList();
    }

    // فلترة حسب المنطقة
    if (selectedArea != 'Toutes Zones') {
      filtered = filtered
          .where((task) => task.location.contains(selectedArea.split(' ')[0]))
          .toList();
    }

    // الترتيب
    if (selectedSortType == 'price_asc') {
      filtered.sort((a, b) => a.budget.compareTo(b.budget));
    } else if (selectedSortType == 'distance_asc') {
      filtered
          .sort((a, b) => (a.distance ?? 99.0).compareTo(b.distance ?? 99.0));
    }

    return filtered;
  }

  @override
  void initState() {
    super.initState();

    // تطبيق الفرز الأولي حسب نوع الفلتر
    switch (widget.filterType) {
      case 'distance':
        selectedSortType = 'distance_asc';
        break;
      case 'price':
        selectedSortType = 'price_asc';
        break;
    }

    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadAreas(),
      _loadTasks(),
    ]);
  }

  Future<void> _loadAreas() async {
    final result = await categoryService.getNouakchottAreas(simple: true);
    if (result['ok'] && mounted) {
      setState(() {
        _areas = result['areas'] as List<NouakchottArea>;
      });
    }
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // ✅ جلب فئة العامل إذا كان الفلتر حسب الفئة
    String? category = widget.categoryFilter;
    if (category == null && widget.filterType == 'category') {
      try {
        final result = await profileService.getWorkerProfile();
        if (result['ok']) {
          final workerProfile = result['workerProfile'] as WorkerProfile;
          category = workerProfile.serviceCategory;
          print('✅ Worker category loaded: $category');
        }
      } catch (e) {
        print('❌ Error loading worker category: $e');
      }
    }

    String? location = selectedArea != 'Toutes Zones' ? selectedArea : null;
    String? sortBy;

    if (selectedSortType == 'price_asc') {
      sortBy = 'budget_low';
    } else if (selectedSortType == 'distance_asc') {
      sortBy = 'nearest';
    }

    // ← جلب موقع العامل
    LatLng? workerLocation = locationService.currentLocation ??
        await locationService.getLastSavedLocation();

    final result = await taskService.getAvailableTasks(
      category: category,
      location: location,
      sortBy: sortBy,
      lat: workerLocation?.latitude, // ← جديد
      lng: workerLocation?.longitude, // ← جديد
      limit: 10, // ← جديد
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['ok']) {
          _tasks = result['tasks'] as List<TaskModel>;
        } else {
          _errorMessage = result['error'];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).brightness == Brightness.dark
                ? ThemeColors.darkTextPrimary
                : ThemeColors.lightTextPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _getScreenTitle(),
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? ThemeColors.darkTextPrimary
                : ThemeColors.lightTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.tune,
              color: Theme.of(context).brightness == Brightness.dark
                  ? ThemeColors.darkTextPrimary
                  : ThemeColors.lightTextPrimary,
            ),
            onPressed: _showAdvancedFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // ← أضف Banner هنا
          if (!locationService.isLocationFresh &&
              locationService.currentLocation != null)
            _buildLocationWarningBanner(),

          // شريط الفلاتر السريعة
          _buildQuickFilters(),

          // عدد النتائج
          _buildResultsCount(),

          // قائمة النتائج
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryPurple,
                    ),
                  )
                : _errorMessage != null
                    ? _buildErrorState()
                    : filteredOpportunities.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _loadTasks,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredOpportunities.length,
                              itemBuilder: (context, index) =>
                                  _buildOpportunityCard(
                                      filteredOpportunities[index]),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  String _getScreenTitle() {
    switch (widget.filterType) {
      case 'category':
        return 'Ma catégorie';
      case 'distance':
        return 'Plus proches';
      case 'price':
        return 'Prix croissant';
      case 'region':
        return 'Par région';
      default:
        return 'Opportunités';
    }
  }

  Widget _buildQuickFilters() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              'Plus proche',
              selectedSortType == 'distance_asc',
              () {
                setState(() {
                  selectedSortType = selectedSortType == 'distance_asc'
                      ? 'none'
                      : 'distance_asc';
                });
                _loadTasks();
              },
              icon: Icons.near_me,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Prix croissant',
              selectedSortType == 'price_asc',
              () {
                setState(() {
                  selectedSortType =
                      selectedSortType == 'price_asc' ? 'none' : 'price_asc';
                });
                _loadTasks();
              },
              icon: Icons.attach_money,
            ),
            const SizedBox(width: 8),
            _buildAreaFilter(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isActive, VoidCallback onTap,
      {IconData? icon}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryPurple
              : Theme.of(context).brightness == Brightness.dark
                  ? ThemeColors.darkCardBackground
                  : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppColors.primaryPurple
                : Theme.of(context).brightness == Brightness.dark
                    ? ThemeColors.darkCardBackground.withOpacity(0.5)
                    : Colors.grey[100]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isActive
                    ? Colors.white
                    : Theme.of(context).brightness == Brightness.dark
                        ? ThemeColors.darkTextSecondary
                        : ThemeColors.lightTextSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : Theme.of(context).brightness == Brightness.dark
                        ? ThemeColors.darkTextPrimary
                        : ThemeColors.lightTextPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaFilter() {
    List<String> areaNames = [
      'Toutes Zones',
      ..._areas.map((a) => a.name).toList()
    ];

    return PopupMenuButton<String>(
      onSelected: (value) {
        setState(() => selectedArea = value);
        _loadTasks();
      },
      itemBuilder: (context) {
        return areaNames.map((areaName) {
          return PopupMenuItem<String>(
            value: areaName,
            child: Container(
              color: Theme.of(context).brightness == Brightness.dark
                  ? ThemeColors.darkCardBackground
                  : Colors.white,
              child: Row(
                children: [
                  if (selectedArea == areaName) ...[
                    Icon(Icons.check, size: 16, color: AppColors.primaryPurple),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    areaName,
                    style: TextStyle(
                      color: selectedArea == areaName
                          ? AppColors.primaryPurple
                          : Theme.of(context).brightness == Brightness.dark
                              ? ThemeColors.darkTextPrimary
                              : ThemeColors.lightTextPrimary,
                      fontWeight: selectedArea == areaName
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selectedArea != 'Toutes Zones'
              ? AppColors.primaryPurple
              : Theme.of(context).brightness == Brightness.dark
                  ? ThemeColors.darkCardBackground
                  : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selectedArea != 'Toutes Zones'
                ? AppColors.primaryPurple
                : Theme.of(context).brightness == Brightness.dark
                    ? ThemeColors.darkCardBackground.withOpacity(0.5)
                    : Colors.grey[100]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: selectedArea != 'Toutes Zones'
                  ? Colors.white
                  : Theme.of(context).brightness == Brightness.dark
                      ? ThemeColors.darkTextSecondary
                      : ThemeColors.lightTextSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              'Zone',
              style: TextStyle(
                color: selectedArea != 'Toutes Zones'
                    ? Colors.white
                    : Theme.of(context).brightness == Brightness.dark
                        ? ThemeColors.darkTextPrimary
                        : ThemeColors.lightTextPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: selectedArea != 'Toutes Zones'
                  ? Colors.white
                  : Theme.of(context).brightness == Brightness.dark
                      ? ThemeColors.darkTextSecondary
                      : ThemeColors.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCount() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${filteredOpportunities.length} opportunités trouvées',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? ThemeColors.darkTextPrimary
                  : ThemeColors.lightTextPrimary,
            ),
          ),
          if (selectedSortType != 'none' || selectedArea != 'Toutes Zones')
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedSortType = 'none';
                  selectedArea = 'Toutes Zones';
                });
                _loadTasks();
              },
              child: Text(
                'Effacer filtres',
                style: TextStyle(
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark
                    ? ThemeColors.darkTextPrimary
                    : ThemeColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Une erreur est survenue',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadTasks,
              icon: Icon(Icons.refresh),
              label: Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
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
        border: isUrgent
            ? Border.all(color: AppColors.orange.withOpacity(0.3), width: 1)
            : null,
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
                          color: AppColors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'URGENT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.orange,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? ThemeColors.darkTextPrimary
                            : ThemeColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!locationService.isLocationFresh &&
                        task.distance != null) ...[
                      Icon(Icons.schedule, size: 12, color: Colors.orange),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      '${task.distance?.toStringAsFixed(1) ?? '?'} km',
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
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Theme.of(context).brightness == Brightness.dark
                    ? ThemeColors.darkTextSecondary
                    : ThemeColors.lightTextSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                task.location,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? ThemeColors.darkTextSecondary
                      : ThemeColors.lightTextSecondary,
                ),
              ),
              const Spacer(),
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
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showApplicationDialog(task),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_add, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? ThemeColors.darkCardBackground.withOpacity(0.5)
                          : Colors.grey[100]!,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline,
                      color: AppColors.primaryPurple,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
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
    switch (serviceType.toLowerCase()) {
      case 'nettoyage':
      case 'nettoyage maison':
      case 'nettoyage tapis':
        return Icons.cleaning_services;
      case 'blanchisserie':
        return Icons.local_laundry_service;
      case 'plomberie':
        return Icons.plumbing;
      case 'électricité':
        return Icons.electrical_services;
      case 'jardinage':
        return Icons.grass;
      case 'garde d\'enfants':
        return Icons.child_care;
      case 'transport scolaire':
        return Icons.school_outlined;
      case 'aide aux devoirs':
        return Icons.school;
      case 'peinture':
        return Icons.format_paint;
      case 'déménagement':
        return Icons.local_shipping;
      case 'réparation':
      case 'réparation téléphone':
      case 'réparation ordinateur':
        return Icons.build;
      case 'cuisine':
      case 'cuisine quotidienne':
      case 'traiteur':
        return Icons.restaurant;
      case 'soins animaux':
        return Icons.pets;
      case 'climatisation':
        return Icons.ac_unit;
      case 'livraison':
        return Icons.delivery_dining;
      default:
        return Icons.work_outline;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.mediumGray,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune opportunité trouvée',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).brightness == Brightness.dark
                  ? ThemeColors.darkTextSecondary
                  : ThemeColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos filtres',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? ThemeColors.darkTextSecondary
                  : ThemeColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtres avancés',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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
            const SizedBox(height: 24),
            Text(
              'Trier par',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark
                    ? ThemeColors.darkTextPrimary
                    : ThemeColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildAdvancedOption('Prix croissant', 'price_asc'),
            _buildAdvancedOption('Distance croissante', 'distance_asc'),
            _buildAdvancedOption('Urgent en premier', 'urgent'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _loadTasks();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Appliquer',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedOption(String title, String value) {
    final isSelected = selectedSortType == value;

    return GestureDetector(
      onTap: () => setState(() {
        selectedSortType = isSelected ? 'none' : value;
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryPurple.withOpacity(0.1)
              : Theme.of(context).brightness == Brightness.dark
                  ? ThemeColors.darkCardBackground.withOpacity(0.5)
                  : Colors.grey[100]!,
          borderRadius: BorderRadius.circular(12),
          border:
              isSelected ? Border.all(color: AppColors.primaryPurple) : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color:
                  isSelected ? AppColors.primaryPurple : AppColors.mediumGray,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? AppColors.primaryPurple
                    : Theme.of(context).brightness == Brightness.dark
                        ? ThemeColors.darkTextPrimary
                        : ThemeColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showApplicationDialog(TaskModel task) {
    final TextEditingController messageController = TextEditingController();
    messageController.text =
        "Je suis disponible pour cette tâche et j'ai de l'expérience dans ce domaine.";

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (dialogContext) {
        bool isLoading = false; // حالة Loading

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? ThemeColors.darkCardBackground
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.person_add,
                              color: AppColors.primaryPurple, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Postuler pour la mission',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? ThemeColors.darkTextPrimary
                                  : ThemeColors.lightTextPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(task.title,
                        style: TextStyle(
                            fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(height: 20),

                    // TextField
                    TextField(
                      controller: messageController,
                      maxLines: 4,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'Message optionnel...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Buttons
                    if (isLoading)
                      CircularProgressIndicator(color: AppColors.primaryPurple)
                    else
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: Text('Annuler'),
                            ),
                          ),
                          const SizedBox(width: 12),
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
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text('Envoyer',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
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
    setDialogState(true); // أظهر Loading في Dialog

    try {
      print('📤 Sending application for task: ${task.id}');

      final result = await taskService.applyToTask(
        taskId: task.id,
        message: message,
      );

      print('📥 API Response: $result');

      if (!mounted) return;

      Navigator.pop(dialogContext); // أغلق Dialog

      if (result['ok']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Candidature envoyée avec succès!'),
            backgroundColor: AppColors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        _loadTasks();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Erreur'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      print('❌ Error: $e');
      if (mounted) {
        Navigator.pop(dialogContext);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildLocationWarningBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Position obsolète. Activez votre position pour des distances précises.',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).brightness == Brightness.dark
                    ? ThemeColors.darkTextPrimary
                    : ThemeColors.lightTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
