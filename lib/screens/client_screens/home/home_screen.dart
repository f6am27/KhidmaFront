import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/category_selector_widget.dart';
import 'widgets/worker_card_widget.dart';
import '../../../core/theme/theme_colors.dart';
import 'widgets/all_services_screen.dart';
import '../onboarding/client_location_permission_screen.dart';
import '../../../services/worker_search_service.dart';
import '../../../services/favorite_workers_service.dart';
import '../../../models/worker_search_model.dart';
import '../../../services/category_service.dart';
import '../../../models/service_category_model.dart';
import '../../../models/nouakchott_area_model.dart';
import '../../../services/location_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientHomeScreen extends StatefulWidget {
  static const Color primaryPurple = Color(0xFF6366F1);

  @override
  _ClientHomeScreenState createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  // Services
  final WorkerSearchService _searchService = WorkerSearchService();
  final FavoriteWorkersService _favoriteService = FavoriteWorkersService();

  // Search & Filter states
  String searchQuery = '';
  bool showSearchResults = false;
  String selectedCategory = 'Toutes Catégories';
  bool isSearchActive = false;
  String ratingSort = 'none';
  String distanceSort = 'none';
  String selectedArea = 'Toutes Zones';

  // Location states
  LatLng? _clientLocation;
  bool _isLocationLoading = false;
  final LocationService _locationService = LocationService(); // ✅ جديد

  // Data from Backend
  List<String> categories = ['Toutes Catégories'];
  List<String> nouakchottAreas = ['Toutes Zones'];
  List<WorkerSearchResult> workers = [];
  List<Map<String, dynamic>> allServicesData = [];

  // Loading states
  bool _isLoadingWorkers = true;
  bool _isLoadingFilters = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        setState(() {
          isSearchActive = true;
        });
      }
    });
    _loadInitialData();

    // ✅ عند العودة للشاشة، حدّث البيانات
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshFavoriteStates();
    });
  }

  Future<void> _refreshFavoriteStates() async {
    // هذا يُعيد تحميل البيانات وتحديث isFavorite من Backend
    await _searchWorkers();
  }

  /// ✅ جلب البيانات الأولية (Categories, Areas, Top Workers)
  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadFilters(),
      _loadTopWorkers(),
    ]);
  }

  /// ✅ جلب الفلاتر (Categories + Areas)
// ✅ استخدم CategoryService بدلاً من WorkerSearchService

  Future<void> _loadFilters() async {
    setState(() {
      _isLoadingFilters = true;
    });

    try {
      final categoriesResult = await categoryService.getServiceCategories();
      final areasResult =
          await categoryService.getNouakchottAreas(simple: true);

      if (categoriesResult['ok'] && areasResult['ok']) {
        final cats = categoriesResult['categories'] as List<ServiceCategory>;
        final areas = areasResult['areas'] as List<NouakchottArea>;

        setState(() {
          categories = ['Toutes Catégories'] + cats.map((c) => c.name).toList();
          nouakchottAreas =
              ['Toutes Zones'] + areas.map((a) => a.name).toList();

          // ✅ مع null safety
          allServicesData = cats
              .map((cat) => {
                    'name': cat.name ?? 'Service',
                    'icon': cat.icon ?? 'category',
                    'category': cat.name ?? 'Service',
                  })
              .toList();

          _isLoadingFilters = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Échec du chargement';
          _isLoadingFilters = false;
        });
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        _errorMessage = 'Erreur réseau';
        _isLoadingFilters = false;
      });
    }
  }

  /// ✅ جلب أفضل 10 عمال
  Future<void> _loadTopWorkers() async {
    setState(() {
      _isLoadingWorkers = true;
      _errorMessage = null;
    });

    try {
      final result = await _searchService.getTopWorkers(limit: 10);

      if (result['ok']) {
        setState(() {
          workers = result['workers'] as List<WorkerSearchResult>;
          _isLoadingWorkers = false;
        });
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Échec du chargement';
          _isLoadingWorkers = false;
        });
      }
    } catch (e) {
      print('❌ Error loading workers: $e');
      setState(() {
        _errorMessage = 'Erreur réseau';
        _isLoadingWorkers = false;
      });
    }
  }

  /// ✅ البحث عن العمال مع الفلاتر
  Future<void> _searchWorkers() async {
    setState(() {
      _isLoadingWorkers = true;
      _errorMessage = null;
    });

    try {
      String? sortBy;
      if (ratingSort == 'desc') sortBy = 'rating';
      if (distanceSort == 'asc') sortBy = 'nearest';
      if (ratingSort == 'desc') sortBy = 'rating';
      if (distanceSort == 'asc') sortBy = 'nearest';

      final result = await _searchService.searchWorkers(
        category:
            selectedCategory != 'Toutes Catégories' ? selectedCategory : null,
        area: selectedArea != 'Toutes Zones' ? selectedArea : null,
        search: searchQuery.isNotEmpty ? searchQuery : null,
        sortBy: sortBy,
        clientLat: _clientLocation?.latitude,
        clientLng: _clientLocation?.longitude,
        limit: showSearchResults ? null : 10,
      );

      if (result['ok']) {
        List<WorkerSearchResult> loadedWorkers =
            result['workers'] as List<WorkerSearchResult>;

        // ✅ اطبع لتصحيح الأخطاء
        print('📊 Loaded Workers:');
        for (var worker in loadedWorkers) {
          print(
              '  - ${worker.name}: isFavorite=${worker.isFavorite}, id=${worker.id}');
        }

        setState(() {
          workers = loadedWorkers;
          _isLoadingWorkers = false;
        });
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Échec du chargement';
          _isLoadingWorkers = false;
        });
      }
    } catch (e) {
      print('❌ Error searching workers: $e');
      setState(() {
        _errorMessage = 'Erreur réseau';
        _isLoadingWorkers = false;
      });
    }
  }

  /// طلب إذن الموقع
  Future<void> _requestLocationFromGPS() async {
    final bool? userConsent =
        await ClientLocationPermissionScreen.showWhenNeeded(context);

    if (userConsent != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يجب السماح بالوصول للموقع لإظهار العمال الأقرب إليك'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _isLocationLoading = true;
    });

    try {
      final location = await _locationService.getCurrentLocation(
        sendToBackend: false,
      );

      if (location != null) {
        setState(() {
          _clientLocation = location;
          distanceSort = 'asc';
          ratingSort = 'none';
          _isLocationLoading = false;
        });

        print(
            '📍 Client Location from GPS: ${location.latitude}, ${location.longitude}');
        await _searchWorkers();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تحديد موقعك وترتيب العمال حسب المسافة'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        setState(() {
          _isLocationLoading = false;
        });
        _showLocationErrorDialog();
      }
    } catch (e) {
      print('❌ Error getting location: $e');
      setState(() {
        _isLocationLoading = false;
      });
      _showLocationErrorDialog();
    }
  }

  void _handleClosestFilter() {
    if (distanceSort == 'asc' && _clientLocation != null) {
      setState(() {
        distanceSort = 'none';
      });
      _searchWorkers();
    } else {
      _requestLocationFromGPS();
    }
  }

  void _onFilterChanged(Map<String, String> filters) {
    setState(() {
      ratingSort = filters['ratingSort']!;
      distanceSort = filters['distanceSort']!;
      selectedArea = filters['selectedArea']!;

      // ✅ أضف هذا: اجعل showSearchResults = true عند تطبيق أي فرز
      // بحيث يبقى زر Effacer Recherche ظاهر
      if (selectedCategory != 'Toutes Catégories' || searchQuery.isNotEmpty) {
        showSearchResults = true;
      }
    });

    if (distanceSort == 'asc' && _clientLocation == null) {
      _requestLocationFromGPS();
    } else {
      _searchWorkers();
    }
  }

  void _performSearch() {
    if (selectedCategory == 'Toutes Catégories' &&
        _searchController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Veuillez sélectionner une catégorie pour commencer la recherche'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      searchQuery = _searchController.text;
      showSearchResults = true;
      isSearchActive = true;
    });

    _searchWorkers();
  }

  void _resetSearch() {
    setState(() {
      showSearchResults = false;
      searchQuery = '';
      isSearchActive = false;
      selectedCategory = 'Toutes Catégories';
      _searchController.clear();
      _resetFilters();
    });
    _searchFocusNode.unfocus();
    _loadTopWorkers();
  }

  void _resetFilters() {
    setState(() {
      ratingSort = 'none';
      distanceSort = 'none';
      selectedArea = 'Toutes Zones';
      _clientLocation = null;
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
      // ✅ التصحيح: ابدأ البحث مباشرة عند اختيار فئة
      if (category != 'Toutes Catégories') {
        showSearchResults = true;
        isSearchActive = true;
      } else {
        showSearchResults = false;
        isSearchActive = false;
      }
    });

    // ✅ ابدأ البحث في كل الحالات
    _searchWorkers();
  }

  // نوافذ الحوار
  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('خدمة الموقع غير مفعلة'),
        content: Text('يرجى تفعيل خدمة الموقع من إعدادات الجهاز'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إذن الموقع مطلوب'),
        content: Text('يرجى السماح بالوصول للموقع لترتيب العمال حسب المسافة'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedForeverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إذن الموقع مرفوض نهائياً'),
        content: Text('يرجى تفعيل إذن الموقع من إعدادات التطبيق'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            child: Text('الإعدادات'),
          ),
        ],
      ),
    );
  }

  void _showLocationErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('خطأ في الموقع'),
        content: Text('حدث خطأ أثناء الحصول على موقعك. يرجى المحاولة مرة أخرى'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _showFiltersDropdown() {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (BuildContext context) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
              ),
            ),
            Positioned(
              top: 180,
              right: 20,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? ThemeColors.darkCardBackground
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? ThemeColors.darkBorder
                          : Colors.grey[200]!,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildCleanFilterItem('Note', ratingSort, () {
                        setState(() {
                          if (ratingSort == 'none') {
                            ratingSort = 'desc';
                          } else if (ratingSort == 'desc') {
                            ratingSort = 'asc';
                          } else {
                            ratingSort = 'none';
                          }
                          distanceSort = 'none';
                        });
                        Navigator.pop(context);
                        _searchWorkers();
                      }),
                      _buildDivider(),
                      _buildDistanceFilterItem(),
                      _buildDivider(),
                      _buildCleanFilterItem('Zone géographique',
                          selectedArea != 'Toutes Zones' ? 'active' : 'none',
                          () {
                        Navigator.pop(context);
                        _showAreaSelection();
                      }),
                      _buildDivider(),
                      _buildCleanFilterItem('Réinitialiser', 'reset', () {
                        _resetFilters();
                        Navigator.pop(context);
                        _searchWorkers();
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDistanceFilterItem() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color textColor;
    String suffix = '';

    if (distanceSort == 'asc') {
      textColor = ThemeColors.primaryColor;
      suffix = ' ↑';
    } else if (distanceSort == 'desc') {
      textColor = ThemeColors.primaryColor;
      suffix = ' ↓';
    } else {
      textColor =
          isDark ? ThemeColors.darkTextPrimary : ThemeColors.lightTextPrimary;
    }

    return GestureDetector(
      onTap: _isLocationLoading
          ? null
          : () {
              Navigator.pop(context);
              _handleClosestFilter();
            },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: distanceSort != 'none'
              ? ThemeColors.primaryColor.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            if (_isLocationLoading) ...[
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(ThemeColors.primaryColor),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Localisation...',
                style: TextStyle(
                  fontSize: 14,
                  color: ThemeColors.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else ...[
              Text(
                'Distance$suffix',
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                  fontWeight: distanceSort != 'none'
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCleanFilterItem(
      String title, String status, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color textColor;
    String suffix = '';

    if (status == 'reset') {
      textColor = ThemeColors.primaryColor;
    } else if (status == 'active') {
      textColor = ThemeColors.primaryColor;
    } else if (status == 'asc') {
      textColor = ThemeColors.primaryColor;
      suffix = ' ↑';
    } else if (status == 'desc') {
      textColor = ThemeColors.primaryColor;
      suffix = ' ↓';
    } else {
      textColor =
          isDark ? ThemeColors.darkTextPrimary : ThemeColors.lightTextPrimary;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: status != 'none' && status != 'reset'
              ? ThemeColors.primaryColor.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Text(
          title + suffix,
          style: TextStyle(
            fontSize: 14,
            color: textColor,
            fontWeight: status != 'none' && status != 'reset'
                ? FontWeight.w500
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: Theme.of(context).brightness == Brightness.dark
          ? ThemeColors.darkBorder
          : Colors.grey[100],
    );
  }

  void _showAreaSelection() {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor:
              isDark ? ThemeColors.darkCardBackground : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Sélectionner une zone',
            style: TextStyle(
              color: isDark
                  ? ThemeColors.darkTextPrimary
                  : ThemeColors.lightTextPrimary,
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: nouakchottAreas.length,
              itemBuilder: (context, index) {
                final area = nouakchottAreas[index];
                return ListTile(
                  title: Text(
                    area,
                    style: TextStyle(
                      color: isDark
                          ? ThemeColors.darkTextPrimary
                          : ThemeColors.lightTextPrimary,
                    ),
                  ),
                  trailing: selectedArea == area
                      ? Icon(Icons.check, color: ThemeColors.primaryColor)
                      : null,
                  onTap: () {
                    setState(() {
                      selectedArea = area;
                    });
                    Navigator.pop(context);
                    _searchWorkers();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoadingFilters
            ? Center(
                child: CircularProgressIndicator(
                  color: ThemeColors.primaryColor,
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(isDark),
                    SizedBox(height: 24),
                    SearchBarWidget(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onSearch: _performSearch,
                      onFilterTap: isSearchActive ? _showFiltersDropdown : null,
                      onSearchActiveChanged: (isActive) {
                        setState(() {
                          isSearchActive = isActive;
                        });
                      },
                      onSearchChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    if (isSearchActive)
                      CategorySelectorWidget(
                        categories: categories,
                        selectedCategory: selectedCategory,
                        onCategorySelected: _onCategorySelected,
                      ),
                    SizedBox(height: 32),
                    if (!isSearchActive) ...[
                      _buildCategoriesSection(isDark),
                      SizedBox(height: 32),
                    ],
                    _buildResultsSection(isDark),
                    SizedBox(height: 16),
                    if (_isLoadingWorkers)
                      Center(
                        child: CircularProgressIndicator(
                          color: ThemeColors.primaryColor,
                        ),
                      )
                    else if (_errorMessage != null)
                      _buildErrorState(isDark)
                    else if (workers.isEmpty)
                      _buildEmptyState(isDark)
                    else
                      ...workers
                          .map((worker) => WorkerCardWidget(
                                worker: worker,
                                onFavoriteChanged: () {
                                  // ✅ عند تغيير المفضلة، أعد تحميل البيانات
                                  _searchWorkers();
                                },
                                onPhoneCall: null,
                                onChat: () {
                                  _openChat(worker);
                                },
                              ))
                          .toList(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Center(
      child: Text(
        'Home',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isDark
              ? ThemeColors.darkTextPrimary
              : ThemeColors.lightTextPrimary,
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(bool isDark) {
    // ✅ إذا لم تُحمّل الخدمات، اعرض 4 categories افتراضية
    if (allServicesData.isEmpty) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Catégories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? ThemeColors.darkTextPrimary
                      : ThemeColors.lightTextPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => _showAllServices(context),
                child: Text(
                  'Voir tout',
                  style: TextStyle(
                    color: ThemeColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCategoryItem(Icons.cleaning_services, 'Nettoyage', isDark),
              _buildCategoryItem(Icons.build, 'Réparation', isDark),
              _buildCategoryItem(Icons.plumbing, 'Plomberie', isDark),
              _buildCategoryItem(Icons.local_shipping, 'Déménagement', isDark),
            ],
          ),
        ],
      );
    }

    // ✅ عرض أول 12 من Backend
    final displayCategories = allServicesData.take(12).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Catégories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? ThemeColors.darkTextPrimary
                    : ThemeColors.lightTextPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => _showAllServices(context),
              child: Text(
                'Voir tout',
                style: TextStyle(
                  color: ThemeColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal, // ✅ horizontal scroll
            itemCount: displayCategories.length,
            itemBuilder: (context, index) {
              final service = displayCategories[index];
              return Container(
                width: 80, // ✅ عرض ثابت لكل item
                margin: EdgeInsets.only(right: 12),
                child: _buildCategoryItem(
                  _getIconFromString(service['icon']),
                  service['name'],
                  isDark,
                ),
              );
            },
          ),
        )
      ],
    );
  }

  IconData _getIconFromString(dynamic iconData) {
    if (iconData is String) {
      switch (iconData.toLowerCase()) {
        case 'cleaning_services':
          return Icons.cleaning_services;
        case 'build':
          return Icons.build;
        case 'plumbing':
          return Icons.plumbing;
        case 'local_shipping':
          return Icons.local_shipping;
        default:
          return Icons.category;
      }
    }
    return Icons.category;
  }

  Widget _buildCategoryItem(IconData icon, String label, bool isDark) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? ThemeColors.darkCardBackground : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? ThemeColors.shadowDark
                    : Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: isDark ? ThemeColors.darkTextPrimary : Colors.grey[700],
            size: 24,
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? ThemeColors.darkTextSecondary : Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildResultsSection(bool isDark) {
    // ✅ اطبع للتصحيح
    bool shouldShowClearButton = showSearchResults ||
        selectedCategory != 'Toutes Catégories' ||
        searchQuery.isNotEmpty ||
        selectedArea != 'Toutes Zones' ||
        ratingSort != 'none' ||
        distanceSort != 'none';

    print(
        '🔍 Results Section - showSearchResults: $showSearchResults, selectedCategory: $selectedCategory, searchQuery: $searchQuery, selectedArea: $selectedArea, ratingSort: $ratingSort, distanceSort: $distanceSort');
    print('🔘 Should show clear button: $shouldShowClearButton');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          shouldShowClearButton
              ? 'Résultats de recherche'
              : 'Meilleurs Ouvriers',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark
                ? ThemeColors.darkTextPrimary
                : ThemeColors.lightTextPrimary,
          ),
        ),
        // ✅ اعرض "Effacer recherche" دائماً عند البحث أو الفرز
        if (shouldShowClearButton)
          GestureDetector(
            onTap: _resetSearch,
            child: Text(
              'Effacer recherche',
              style: TextStyle(
                color: ThemeColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          Text(
            'Voir plus',
            style: TextStyle(
              color: ThemeColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 50),
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? ThemeColors.darkTextSecondary : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              if (showSearchResults) {
                _searchWorkers();
              } else {
                _loadTopWorkers();
              }
            },
            icon: Icon(Icons.refresh),
            label: Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 50),
          Icon(
            Icons.search_off,
            size: 64,
            color: isDark ? ThemeColors.darkTextSecondary : Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Aucun résultat trouvé',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? ThemeColors.darkTextSecondary : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _openChat(WorkerSearchResult worker) {
    print('Opening chat with: ${worker.name}');
    // TODO: Implement chat functionality
  }

  void _showAllServices(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllServicesScreen(
          onServiceSelected: (String selectedCategory) {
            setState(() {
              this.selectedCategory = selectedCategory;
              showSearchResults = true;
              _searchController.text = selectedCategory;
              searchQuery = selectedCategory;
              isSearchActive = true;
            });
            _searchWorkers();
          },
        ),
      ),
    );
  }
}
