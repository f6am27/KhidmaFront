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

    return PopupMenuButton<String>(
      onSelected: (value) {
        Map<String, String> newFilters = {
          'priceSort': priceSort,
          'ratingSort': ratingSort,
          'distanceSort': distanceSort,
          'selectedArea': value,
        };
        onFilterChanged(newFilters);
      },
      itemBuilder: (context) {
        return nouakchottAreas.map((area) {
          final bool selected = area == selectedArea;
          return PopupMenuItem<String>(
            value: area,
            child: Row(
              children: [
                if (selected)
                  Icon(Icons.check, size: 16, color: ThemeColors.primaryColor),
                if (selected) SizedBox(width: 8),
                Text(
                  area,
                  style: TextStyle(
                    color: selected
                        ? ThemeColors.primaryColor
                        : (isDark ? ThemeColors.darkTextPrimary : Colors.black),
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      elevation: 4,
      offset: const Offset(0, 8),
      color: isDark ? ThemeColors.darkCardBackground : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              'Zone',
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : (isDark ? ThemeColors.darkTextPrimary : Colors.grey[700]),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
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
      backgroundColor: isDark ? ThemeColors.darkBackground : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trier par',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? ThemeColors.darkTextPrimary
                      : ThemeColors.lightTextPrimary,
                ),
              ),
              SizedBox(height: 16),
              _buildSortOption(context, 'Prix croissant', priceSort == 'asc',
                  () {
                Map<String, String> filters = {
                  'priceSort': 'asc',
                  'ratingSort': 'none',
                  'distanceSort': 'none',
                  'selectedArea': selectedArea,
                };
                onFilterChanged(filters);
                Navigator.pop(context);
              }),
              _buildSortOption(context, 'Prix décroissant', priceSort == 'desc',
                  () {
                Map<String, String> filters = {
                  'priceSort': 'desc',
                  'ratingSort': 'none',
                  'distanceSort': 'none',
                  'selectedArea': selectedArea,
                };
                onFilterChanged(filters);
                Navigator.pop(context);
              }),
              _buildSortOption(context, 'Meilleure note', ratingSort == 'desc',
                  () {
                Map<String, String> filters = {
                  'priceSort': 'none',
                  'ratingSort': 'desc',
                  'distanceSort': 'none',
                  'selectedArea': selectedArea,
                };
                onFilterChanged(filters);
                Navigator.pop(context);
              }),
              _buildSortOption(
                context,
                'Distance croissante (le plus proche)',
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
              _buildSortOption(context, 'Réinitialiser', false, () {
                Map<String, String> filters = {
                  'priceSort': 'none',
                  'ratingSort': 'none',
                  'distanceSort': 'none',
                  'selectedArea': selectedArea,
                };
                onFilterChanged(filters);
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    String title,
    bool isSelected,
    VoidCallback? onTap, {
    bool showLocationIndicator = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            if (showLocationIndicator) ...[
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(ThemeColors.primaryColor),
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Obtention de la position...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: ThemeColors.primaryColor,
                ),
              ),
            ] else ...[
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected
                    ? ThemeColors.primaryColor
                    : (isDark
                        ? ThemeColors.darkTextSecondary
                        : Colors.grey[400]),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? ThemeColors.primaryColor
                      : (isDark
                          ? ThemeColors.darkTextPrimary
                          : Colors.grey[700]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
