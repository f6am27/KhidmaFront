import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../models/models.dart';
import '../../../services/task_service.dart';
import '../../../services/category_service.dart';
import '../../../services/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../services/profile_service.dart';
import '../../../core/theme/theme_colors.dart';
import '../../shared_screens/dialogs/success_dialog.dart';
import '../../../utils/apply_helper.dart';

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
  String? _workerCategory;
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

    _loadWorkerCategory(); // ✅ أضيفي هذا السطر
    _loadData();
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

    String? location = selectedArea != 'Toutes Zones' ? selectedArea : null;
    String? sortBy;

    if (selectedSortType == 'price_asc') {
      sortBy = 'budget_low';
    } else if (selectedSortType == 'distance_asc') {
      sortBy = 'nearest';
    }

    LatLng? workerLocation = locationService.currentLocation ??
        await locationService.getLastSavedLocation();

    // ✅ لا نرسل category للـ API، سنفلتر محلياً
    final result = await taskService.getAvailableTasks(
      location: location,
      sortBy: sortBy,
      lat: workerLocation?.latitude,
      lng: workerLocation?.longitude,
      limit: 50, // ✅ نجلب عدد أكبر لأننا سنفلتر محلياً
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['ok']) {
          List<TaskModel> allTasks = result['tasks'] as List<TaskModel>;

          // ✅ تطبيق التصفية حسب نوع الفلتر
          if (_workerCategory != null && _workerCategory!.isNotEmpty) {
            final workerCat = _workerCategory!.toLowerCase().trim();

            if (widget.filterType == 'category') {
              // ✅ فلتر "Ma catégorie": مهام التصنيف فقط (بدون غير المصنفة)
              allTasks = allTasks.where((task) {
                final taskCat = task.serviceType.toLowerCase().trim();
                return taskCat == workerCat;
              }).toList();
            } else {
              // ✅ باقي الفلاتر: مهام التصنيف + غير المصنفة
              allTasks = allTasks.where((task) {
                final taskCat = task.serviceType.toLowerCase().trim();
                return taskCat == workerCat || task.isUnclassified;
              }).toList();
            }
          }

          _tasks = allTasks;
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
        centerTitle: true, // ✅ إضافة هذا السطر
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
      offset: const Offset(0, 48), // ✅ تبدأ من تحت الزر مباشرة
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Theme.of(context).brightness == Brightness.dark
          ? ThemeColors.darkCardBackground.withOpacity(0.85)
          : Colors.white.withOpacity(0.85),
      elevation: 8,
      constraints: BoxConstraints(
        maxHeight: 300, // ✅ أقصى ارتفاع 300px فقط
        minWidth: 200, // ✅ عرض مناسب
      ),
      itemBuilder: (context) {
        return areaNames.map((areaName) {
          final isSelected = selectedArea == areaName;

          return PopupMenuItem<String>(
            value: areaName,
            height: 48, // ✅ ارتفاع ثابت لكل عنصر
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Row(
              children: [
                if (isSelected) ...[
                  Icon(
                    Icons.check_circle,
                    size: 18,
                    color: AppColors.primaryPurple,
                  ),
                  const SizedBox(width: 12),
                ] else ...[
                  const SizedBox(width: 30), // ✅ مسافة للمحاذاة
                ],
                Expanded(
                  child: Text(
                    areaName,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primaryPurple
                          : Theme.of(context).brightness == Brightness.dark
                              ? ThemeColors.darkTextPrimary
                              : ThemeColors.lightTextPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis, // ✅ قص النص الطويل
                  ),
                ),
              ],
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
    final isUnclassified = task.isUnclassified;

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
          /// ===== ROW 1 =====
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUnclassified
                      ? Colors.orange.withOpacity(0.1)
                      : AppColors.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(task.serviceType),
                  color:
                      isUnclassified ? Colors.orange : AppColors.primaryPurple,
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
                          border: Border.all(color: Colors.red, width: 2),
                        ),
                        child: const Text(
                          'URGENT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    if (isUnclassified)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange, width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.help_outline,
                                size: 12, color: Colors.orange),
                            SizedBox(width: 4),
                            Text(
                              'Non classifié',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange),
                            ),
                          ],
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
              if (task.distance != null)
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
                        const Icon(Icons.schedule,
                            size: 12, color: Colors.orange),
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

          /// ===== ROW 2 =====
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

          /// ===== ROW 3 =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  print('▶️ Opportunités Postuler pressed, task=${task.id}');
                  try {
                    _showApplicationDialog(task);
                  } catch (e, stack) {
                    print('❌ Error opening opportunities apply dialog: $e');
                    print(stack);
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.person_add, color: Colors.white, size: 14),
                      SizedBox(width: 6),
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

  void _showApplicationDialog(TaskModel task) {
    print('🟢 _showApplicationDialog (opportunities) for task: ${task.id}');

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
    print('🟢 _submitApplication ENTERED');
    setDialogState(true);

    try {
      print('📤 Sending application for task: ${task.id}');

      final result = await taskService.applyToTask(
        taskId: task.id,
        message: message,
      );

      print('📥 API Response: $result');

      if (!mounted) return;

      // ✅ أغلق Dialog التقديم
      Navigator.pop(dialogContext);

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
      if (mounted) {
        Navigator.pop(dialogContext);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
