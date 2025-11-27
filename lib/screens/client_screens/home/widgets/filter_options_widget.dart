import 'package:flutter/material.dart';
import '../../../../core/theme/theme_colors.dart';

class FilterOptionsWidget extends StatelessWidget {
  final String priceSort;
  final String ratingSort;
  final String distanceSort;
  final String selectedArea;
  final List<String> nouakchottAreas;
  final Function(Map<String, String>) onFilterChanged;
  final bool isLocationLoading;
  final bool hasClientLocation;

  const FilterOptionsWidget({
    Key? key,
    required this.priceSort,
    required this.ratingSort,
    required this.distanceSort,
    required this.selectedArea,
    required this.nouakchottAreas,
    required this.onFilterChanged,
    this.isLocationLoading = false,
    this.hasClientLocation = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterButton(
            context,
            'Trier par',
            Icons.filter_list,
            () => _showSortBottomSheet(context),
            isActive: priceSort != 'none' ||
                ratingSort != 'none' ||
                distanceSort != 'none',
          ),
          SizedBox(width: 12),
          _buildFilterButton(
            context,
            'Prix',
            Icons.attach_money,
            () => _handlePriceFilter(),
            isActive: priceSort != 'none',
            showArrow: priceSort != 'none',
            isAscending: priceSort == 'asc',
          ),
          SizedBox(width: 12),
          _buildClosestChip(context),
          SizedBox(width: 12),
          _buildAreaDropdownChip(context),
          SizedBox(width: 12),
          _buildFilterButton(
            context,
            'Plus répandu',
            Icons.trending_up,
            () => _handleRatingFilter(),
            isActive: ratingSort != 'none',
          ),
        ],
      ),
    );
  }

  /// بناء فلتر "الأقرب لي" مع معالجة طلب الموقع
  Widget _buildClosestChip(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isActive = distanceSort == 'asc';

    return GestureDetector(
      onTap: isLocationLoading
          ? null
          : () {
              if (isActive && hasClientLocation) {
                // إذا كان مفعل ولدينا موقع، قم بإلغائه
                Map<String, String> newFilters = {
                  'priceSort': 'none',
                  'ratingSort': 'none',
                  'distanceSort': 'none',
                  'selectedArea': selectedArea,
                };
                onFilterChanged(newFilters);
              } else {
                // إذا لم يكن مفعل أو لا يوجد موقع، فعّله (سيطلب الموقع في HomeScreen)
                Map<String, String> newFilters = {
                  'priceSort': 'none',
                  'ratingSort': 'none',
                  'distanceSort': 'asc',
                  'selectedArea': selectedArea,
                };
                onFilterChanged(newFilters);
              }
            },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? ThemeColors.primaryColor
              : (isDark ? ThemeColors.darkCardBackground : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? ThemeColors.primaryColor
                : (isDark ? ThemeColors.darkBorder : Colors.grey[300]!),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? ThemeColors.shadowDark
                  : Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLocationLoading) ...[
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(
                    isActive ? Colors.white : ThemeColors.primaryColor,
                  ),
                ),
              ),
              SizedBox(width: 6),
              Text(
                'Localisation...',
                style: TextStyle(
                  color: isActive
                      ? Colors.white
                      : (isDark
                          ? ThemeColors.darkTextPrimary
                          : Colors.grey[700]),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ] else ...[
              Icon(
                hasClientLocation ? Icons.near_me : Icons.location_searching,
                size: 16,
                color: isActive
                    ? Colors.white
                    : (isDark
                        ? ThemeColors.darkTextSecondary
                        : Colors.grey[600]),
              ),
              SizedBox(width: 6),
              Text(
                'Le plus proche',
                style: TextStyle(
                  color: isActive
                      ? Colors.white
                      : (isDark
                          ? ThemeColors.darkTextPrimary
                          : Colors.grey[700]),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAreaDropdownChip(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isActive = selectedArea != 'Toutes Zones';

    return GestureDetector(
      onTap: () => _showAreaBottomSheet(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? ThemeColors.primaryColor
              : (isDark ? ThemeColors.darkCardBackground : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? ThemeColors.primaryColor
                : (isDark ? ThemeColors.darkBorder : Colors.grey[300]!),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? ThemeColors.shadowDark
                  : Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: isActive
                  ? Colors.white
                  : (isDark ? ThemeColors.darkTextSecondary : Colors.grey[600]),
            ),
            SizedBox(width: 6),
            Text(
              isActive ? selectedArea : 'Zone',
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : (isDark ? ThemeColors.darkTextPrimary : Colors.grey[700]),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: isActive
                  ? Colors.white
                  : (isDark ? ThemeColors.darkTextSecondary : Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

// ✅ دالة جديدة لعرض قائمة المناطق
  void _showAreaBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? ThemeColors.darkCardBackground : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ مقبض السحب
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // ✅ العنوان
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sélectionner une zone',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? ThemeColors.darkTextPrimary
                          : ThemeColors.lightTextPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // ✅ قائمة المناطق
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: nouakchottAreas.length,
                  itemBuilder: (context, index) {
                    final area = nouakchottAreas[index];
                    final isSelected = area == selectedArea;

                    return GestureDetector(
                      onTap: () {
                        Map<String, String> newFilters = {
                          'priceSort': priceSort,
                          'ratingSort': ratingSort,
                          'distanceSort': distanceSort,
                          'selectedArea': area,
                        };
                        onFilterChanged(newFilters);
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 8),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? ThemeColors.primaryColor.withOpacity(0.1)
                              : (isDark
                                  ? ThemeColors.darkSurface
                                  : Colors.grey[50]),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? ThemeColors.primaryColor
                                : (isDark
                                    ? Colors.grey[800]!
                                    : Colors.grey[200]!),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 20,
                              color: isSelected
                                  ? ThemeColors.primaryColor
                                  : (isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600]),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                area,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? ThemeColors.primaryColor
                                      : (isDark
                                          ? ThemeColors.darkTextPrimary
                                          : ThemeColors.lightTextPrimary),
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: ThemeColors.primaryColor,
                                size: 22,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap, {
    bool isActive = false,
    bool showArrow = false,
    bool isAscending = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? ThemeColors.primaryColor
              : (isDark ? ThemeColors.darkCardBackground : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? ThemeColors.primaryColor
                : (isDark ? ThemeColors.darkBorder : Colors.grey[300]!),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? ThemeColors.shadowDark
                  : Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive
                  ? Colors.white
                  : (isDark ? ThemeColors.darkTextSecondary : Colors.grey[600]),
            ),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : (isDark ? ThemeColors.darkTextPrimary : Colors.grey[700]),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            if (showArrow) ...[
              SizedBox(width: 4),
              Icon(
                isAscending
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                size: 16,
                color: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handlePriceFilter() {
    String newPriceSort;
    if (priceSort == 'none') {
      newPriceSort = 'asc';
    } else if (priceSort == 'asc') {
      newPriceSort = 'desc';
    } else {
      newPriceSort = 'none';
    }

    Map<String, String> newFilters = {
      'priceSort': newPriceSort,
      'ratingSort': newPriceSort != 'none' ? 'none' : ratingSort,
      'distanceSort': newPriceSort != 'none' ? 'none' : distanceSort,
      'selectedArea': selectedArea,
    };
    onFilterChanged(newFilters);
  }

  void _handleRatingFilter() {
    String newRatingSort = ratingSort == 'none' ? 'desc' : 'none';

    Map<String, String> newFilters = {
      'priceSort': newRatingSort != 'none' ? 'none' : priceSort,
      'ratingSort': newRatingSort,
      'distanceSort': newRatingSort != 'none' ? 'none' : distanceSort,
      'selectedArea': selectedArea,
    };
    onFilterChanged(newFilters);
  }

  void _showSortBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? ThemeColors.darkCardBackground : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ مقبض السحب
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // ✅ العنوان
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trier par',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? ThemeColors.darkTextPrimary
                          : ThemeColors.lightTextPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // ✅ الخيارات
              _buildModernSortOption(
                context,
                'Prix croissant',
                Icons.arrow_upward,
                priceSort == 'asc',
                () {
                  Map<String, String> filters = {
                    'priceSort': 'asc',
                    'ratingSort': 'none',
                    'distanceSort': 'none',
                    'selectedArea': selectedArea,
                  };
                  onFilterChanged(filters);
                  Navigator.pop(context);
                },
              ),
              _buildModernSortOption(
                context,
                'Prix décroissant',
                Icons.arrow_downward,
                priceSort == 'desc',
                () {
                  Map<String, String> filters = {
                    'priceSort': 'desc',
                    'ratingSort': 'none',
                    'distanceSort': 'none',
                    'selectedArea': selectedArea,
                  };
                  onFilterChanged(filters);
                  Navigator.pop(context);
                },
              ),
              _buildModernSortOption(
                context,
                'Meilleure note',
                Icons.star,
                ratingSort == 'desc',
                () {
                  Map<String, String> filters = {
                    'priceSort': 'none',
                    'ratingSort': 'desc',
                    'distanceSort': 'none',
                    'selectedArea': selectedArea,
                  };
                  onFilterChanged(filters);
                  Navigator.pop(context);
                },
              ),
              _buildModernSortOption(
                context,
                'Le plus proche',
                Icons.near_me,
                distanceSort == 'asc',
                isLocationLoading
                    ? null
                    : () {
                        Map<String, String> filters = {
                          'priceSort': 'none',
                          'ratingSort': 'none',
                          'distanceSort': 'asc',
                          'selectedArea': selectedArea,
                        };
                        onFilterChanged(filters);
                        Navigator.pop(context);
                      },
                showLocationIndicator: isLocationLoading,
              ),

              SizedBox(height: 8),
              Divider(color: isDark ? Colors.grey[800] : Colors.grey[200]),
              SizedBox(height: 8),

              // ✅ زر إعادة التعيين
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Map<String, String> filters = {
                      'priceSort': 'none',
                      'ratingSort': 'none',
                      'distanceSort': 'none',
                      'selectedArea': selectedArea,
                    };
                    onFilterChanged(filters);
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.refresh, size: 18),
                  label: Text('Réinitialiser'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ThemeColors.primaryColor,
                    side: BorderSide(color: ThemeColors.primaryColor),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// ✅ دالة جديدة للخيارات الحديثة
  Widget _buildModernSortOption(
    BuildContext context,
    String title,
    IconData icon,
    bool isSelected,
    VoidCallback? onTap, {
    bool showLocationIndicator = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? ThemeColors.primaryColor.withOpacity(0.1)
              : (isDark ? ThemeColors.darkSurface : Colors.grey[50]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? ThemeColors.primaryColor
                : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // ✅ الأيقونة
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? ThemeColors.primaryColor
                    : (isDark ? Colors.grey[800] : Colors.grey[200]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: showLocationIndicator
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(
                          isSelected ? Colors.white : ThemeColors.primaryColor,
                        ),
                      ),
                    )
                  : Icon(
                      icon,
                      size: 18,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
            ),
            SizedBox(width: 12),

            // ✅ النص
            Expanded(
              child: Text(
                showLocationIndicator ? 'Obtention de la position...' : title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? ThemeColors.primaryColor
                      : (isDark
                          ? ThemeColors.darkTextPrimary
                          : ThemeColors.lightTextPrimary),
                ),
              ),
            ),

            // ✅ علامة الاختيار
            if (isSelected && !showLocationIndicator)
              Icon(
                Icons.check_circle,
                color: ThemeColors.primaryColor,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
