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
          print('🔍 Category name from backend: "${cat.name}"'); // ✅ أضيفي هذا
          print('🔍 Icon from backend: "${cat.icon}"'); // ✅ أضيفي هذا

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
      switch (iconData.toLowerCase()) {
        // ✅ التنظيف
        case 'cleaning_services':
          return Icons.cleaning_services;
        case 'home':
          return Icons.home;

        // ✅ الغسيل
        case 'local_laundry_service':
          return Icons.local_laundry_service;
        case 'iron':
          return Icons.iron;

        // ✅ البستنة والحيوانات
        case 'grass':
          return Icons.grass;
        case 'pets':
          return Icons.pets;

        // ✅ الرعاية والتعليم
        case 'child_care':
          return Icons.child_care;
        case 'school':
          return Icons.school;

        // ✅ السباكة والكهرباء
        case 'plumbing':
          return Icons.plumbing;
        case 'electrical_services':
          return Icons.electrical_services;
        case 'ac_unit':
          return Icons.ac_unit;

        // ✅ الإصلاحات
        case 'phone_android':
          return Icons.phone_android;
        case 'computer':
          return Icons.computer;
        case 'build':
          return Icons.build;

        // ✅ البناء والديكور
        case 'format_paint':
          return Icons.format_paint;
        case 'construction': // ❌ غير موجود
          return Icons.handyman; // ✅ البديل
        case 'carpenter':
          return Icons.carpenter;

        // ✅ النقل
        case 'delivery_dining':
          return Icons.delivery_dining;
        case 'local_shipping':
          return Icons.local_shipping;
        case 'drive_eta':
          return Icons.drive_eta;
        case 'flight':
          return Icons.flight;

        // ✅ الطعام
        case 'restaurant':
          return Icons.restaurant;
        case 'cake':
          return Icons.cake;

        // ✅ الفعاليات
        case 'celebration': // ❌ غير موجود
          return Icons.celebration_outlined; // ✅ أو event

        // ✅ التدريب
        case 'handyman':
          return Icons.handyman;

        // ✅ الجمال
        case 'content_cut':
          return Icons.content_cut;
        case 'face':
          return Icons.face;
        case 'brush':
          return Icons.brush;

        // ✅ التصوير والفيديو
        case 'photo_camera': // ❌ غير موجود
          return Icons.camera_alt; // ✅ البديل
        case 'video_call': // ❌ غير موجود
          return Icons.video_library; // ✅ البديل

        // ✅ التكنولوجيا
        case 'web':
          return Icons.web;
        case 'support': // ❌ غير موجود
          return Icons.support_agent; // ✅ البديل

        // ✅ تجريبي
        case 'test': // ❌ غير موجود
          return Icons.science; // ✅ البديل

        // ✅ افتراضي
        default:
          return Icons.work_outline;
      }
    } else if (iconData is IconData) {
      return iconData;
    }
    return Icons.work_outline;
  }

  Color _getIconColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      // 🏠 التنظيف - أزرق فاتح
      case 'nettoyage maison':
      case 'nettoyage tapis':
        return Color(0xFF4FC3F7);

      // 👔 الغسيل - أزرق داكن
      case 'blanchisserie':
        return Color(0xFF42A5F5);

      // 🌿 البستنة - أخضر
      case 'jardinage':
        return Color(0xFF66BB6A);

      // 🐾 الحيوانات - بني
      case 'soins animaux':
        return Color(0xFF8D6E63);

      // 👶 الرعاية - وردي
      case 'garde d\'enfants':
        return Color(0xFFEC407A);

      // 🎓 التعليم - بنفسجي
      case 'transport scolaire':
      case 'aide aux devoirs':
      case 'cours particuliers':
        return Color(0xFF7E57C2);

      // 🔧 السباكة - أزرق غامق
      case 'plomberie':
        return Color(0xFF1E88E5);

      // ⚡ الكهرباء - أصفر برتقالي
      case 'électricité':
        return Color(0xFFFFB300);

      // ❄️ التكييف - سماوي
      case 'climatisation':
        return Color(0xFF26C6DA);

      // 📱 الهواتف - رمادي
      case 'réparation téléphone':
        return Color(0xFF78909C);

      // 💻 الكمبيوتر - أزرق بترولي
      case 'réparation ordinateur':
      case 'formation informatique':
      case 'support informatique':
        return Color(0xFF5C6BC0);

      // 🔨 الإصلاحات - برتقالي
      case 'électroménager':
        return Color(0xFFFF7043);

      // 🎨 الدهان - وردي فاتح
      case 'peinture':
        return Color(0xFFFF6F91);

      // 🧱 البناء - بني داكن
      case 'carrelage':
      case 'plâtrerie':
        return Color(0xFF6D4C41);

      // 🪚 النجارة - بني فاتح
      case 'menuiserie':
        return Color(0xFFA1887F);

      // 🚚 التوصيل - أخضر فاتح
      case 'livraison':
        return Color(0xFF26A69A);

      // 📦 النقل - رمادي غامق
      case 'déménagement':
        return Color(0xFF546E7A);

      // 🚗 السائق - أسود مزرق
      case 'chauffeur privé':
      case 'auto-école':
        return Color(0xFF37474F);

      // ✈️ المطار - أزرق سماوي
      case 'transport aéroport':
        return Color(0xFF29B6F6);

      // 🍽️ الطعام - أحمر
      case 'traiteur':
      case 'cuisine quotidienne':
        return Color(0xFFEF5350);

      // 🎂 الحلويات - وردي غامق
      case 'pâtisserie traditionnelle':
        return Color(0xFFD81B60);

      // 🎉 الفعاليات - برتقالي ذهبي
      case 'service événements':
        return Color(0xFFFF9800);

      // 🏋️ التدريب - أحمر داكن
      case 'formation artisanale':
        return Color(0xFFE53935);

      // ✂️ الحلاقة - بنفسجي فاتح
      case 'coiffure à domicile':
        return Color(0xFF9575CD);

      // 💄 المكياج - وردي فوشيا
      case 'maquillage':
      case 'service mariée':
        return Color(0xFFE91E63);

      // 🖌️ الحناء - بني محمر
      case 'henné':
        return Color(0xFF8D6E63);

      // 📷 التصوير - رمادي فاتح
      case 'photographie':
        return Color(0xFF90A4AE);

      // 🎬 الفيديو - أحمر غامق
      case 'montage vidéo':
        return Color(0xFFC62828);

      // 🌐 المواقع - أزرق
      case 'création sites web':
        return Color(0xFF1976D2);

      // 🧪 تجريبي - أخضر نيون
      case 'test':
        return Color(0xFF00E676);

      // افتراضي - بنفسجي
      default:
        return Color(0xFF6366F1);
    }
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
    final iconColor = _getIconColor(name); // ✅ لون مخصص لكل تصنيف
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
