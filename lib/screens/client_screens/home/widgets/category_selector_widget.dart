import 'package:flutter/material.dart';
import '../../../../core/theme/theme_colors.dart'; // تأكد من المسار

class CategorySelectorWidget extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategorySelectorWidget({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories
              .map((category) => _buildCategoryChip(category, context))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isSelected = selectedCategory == category;

    return GestureDetector(
      onTap: () => onCategorySelected(category),
      child: Container(
        margin: EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? ThemeColors.primaryColor.withOpacity(0.1)
              : (isDark ? ThemeColors.darkCardBackground : Colors.white),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
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
        child: Text(
          category,
          style: TextStyle(
            color: isSelected
                ? ThemeColors.primaryColor
                : (isDark ? ThemeColors.darkTextPrimary : Colors.grey[700]),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
