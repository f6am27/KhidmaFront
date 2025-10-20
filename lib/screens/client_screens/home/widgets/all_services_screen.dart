import 'package:flutter/material.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../services/worker_search_service.dart';
import '../../../../services/category_service.dart';
import '../../../../models/service_category_model.dart';

class AllServicesScreen extends StatefulWidget {
  final Function(String) onServiceSelected;

  const AllServicesScreen({
    Key? key,
    required this.onServiceSelected,
  }) : super(key: key);

  @override
  State<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends State<AllServicesScreen> {
  final WorkerSearchService _searchService = WorkerSearchService();
  List<Map<String, dynamic>> _allServices = [];
  bool _isLoading = true;
  String? _errorMessage;

  // ✅ لا توجد بيانات ثابتة - كل شيء من Backend

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  /// ✅ جلب الخدمات من Backend
  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await categoryService.getServiceCategories();

      print('📦 Result: ${result['ok']}'); // ✅ أضف هذا
      print(
          '📦 Categories count: ${(result['categories'] as List?)?.length}'); // ✅ أضف هذا

      if (result['ok']) {
        final categories = result['categories'] as List<ServiceCategory>;

        print('✅ Loaded ${categories.length} categories'); // ✅ أضف هذا

        _allServices = categories.map((cat) {
          return {
            'icon': _getIconFromString(cat.icon ?? 'category'),
            'name': cat.name ?? 'Service',
            'category': cat.name ?? 'Service',
          };
        }).toList();

        print('✅ _allServices length: ${_allServices.length}'); // ✅ أضف هذا

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        _errorMessage = 'Erreur réseau';
        _isLoading = false;
      });
    }
  }

  /// تحويل اسم الأيقونة من Backend إلى IconData
  IconData _getIconFromString(dynamic iconData) {
    if (iconData is String) {
      // إذا كانت string، حاول إيجادها في الـ map
      switch (iconData.toLowerCase()) {
        case 'cleaning_services':
          return Icons.cleaning_services;
        case 'build':
          return Icons.build;
        case 'plumbing':
          return Icons.plumbing;
        case 'local_shipping':
          return Icons.local_shipping;
        case 'format_paint':
          return Icons.format_paint;
        case 'local_laundry_service':
          return Icons.local_laundry_service;
        case 'car_repair':
          return Icons.car_repair;
        case 'electrical_services':
          return Icons.electrical_services;
        case 'carpenter':
          return Icons.carpenter;
        case 'grass':
          return Icons.grass;
        case 'iron':
          return Icons.iron;
        case 'home_repair_service':
          return Icons.home_repair_service;
        case 'cut':
          return Icons.cut;
        case 'security':
          return Icons.security;
        case 'spa':
          return Icons.spa;
        default:
          return Icons.category;
      }
    } else if (iconData is IconData) {
      return iconData;
    }
    return Icons.category; // Default icon
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Catégories',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark
                ? ThemeColors.darkTextPrimary
                : ThemeColors.lightTextPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: ThemeColors.primaryColor,
                ),
              )
            : _errorMessage != null
                ? _buildErrorState(isDark)
                : _allServices.isEmpty
                    ? _buildEmptyState(isDark)
                    : Padding(
                        padding: EdgeInsets.all(20),
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 20,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: _allServices.length,
                          itemBuilder: (context, index) {
                            final service = _allServices[index];
                            return _buildServiceItem(
                              service['icon'],
                              service['name'],
                              service['category'],
                              isDark,
                              context,
                            );
                          },
                        ),
                      ),
      ),
    );
  }

  Widget _buildServiceItem(
    IconData icon,
    String name,
    String category,
    bool isDark,
    BuildContext context,
  ) {
    final iconColor = isDark ? Colors.white : ThemeColors.primaryColor;

    return GestureDetector(
      onTap: () {
        widget.onServiceSelected(category);
        Navigator.pop(context);
      },
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isDark ? ThemeColors.darkCardBackground : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? ThemeColors.shadowDark
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            SizedBox(height: 6),
            Expanded(
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? ThemeColors.darkTextPrimary
                      : ThemeColors.lightTextPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
            onPressed: _loadServices,
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 64,
            color: isDark ? ThemeColors.darkTextSecondary : Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Aucun service disponible',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? ThemeColors.darkTextSecondary : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // ✅ لا حاجة لـ dispose CategoryService (singleton)
    super.dispose();
  }
}
