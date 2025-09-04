import 'package:flutter/material.dart';
import '../../../../core/theme/theme_colors.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSearch;
  final VoidCallback? onFilterTap;
  final Function(bool) onSearchActiveChanged;
  final Function(String) onSearchChanged;

  const SearchBarWidget({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onSearch,
    this.onFilterTap,
    required this.onSearchActiveChanged,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // حقل البحث
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? ThemeColors.darkCardBackground : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isDark ? ThemeColors.darkBorder : Colors.grey[300]!,
                width: 1,
              ),
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
            child: Row(
              children: [
                // أيقونة البحث في البداية
                Padding(
                  padding: EdgeInsets.only(left: 16, right: 8),
                  child: Icon(
                    Icons.search,
                    color: isDark
                        ? ThemeColors.darkTextSecondary
                        : Colors.grey[500],
                    size: 20,
                  ),
                ),
                // حقل النص
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onTap: () {
                      onSearchActiveChanged(true);
                    },
                    style: TextStyle(
                      color: isDark
                          ? ThemeColors.darkTextPrimary
                          : ThemeColors.lightTextPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Rechercher des services...',
                      hintStyle: TextStyle(
                        color: isDark
                            ? ThemeColors.darkTextSecondary
                            : Colors.grey[500],
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 16,
                      ),
                    ),
                    onChanged: onSearchChanged,
                    onSubmitted: (_) => onSearch(),
                  ),
                ),
              ],
            ),
          ),
        ),

        // زر الفلتر منفصل خارج حقل البحث
        if (onFilterTap != null) ...[
          SizedBox(width: 12),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ThemeColors.primaryColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: ThemeColors.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.tune,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
