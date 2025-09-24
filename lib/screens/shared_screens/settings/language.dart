import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';

class LanguageScreen extends StatefulWidget {
  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String selectedLanguage = 'fr'; // Default French

  final List<LanguageModel> languages = [
    LanguageModel(
      code: 'ar',
      name: 'العربية',
      englishName: 'Arabic',
      flag: '🇲🇷',
    ),
    LanguageModel(
      code: 'fr',
      name: 'Français',
      englishName: 'French',
      flag: '🇫🇷',
    ),
    LanguageModel(
      code: 'en',
      name: 'English',
      englishName: 'English',
      flag: '🇺🇸',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Langue'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Choisissez votre langue préférée',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white70 : Colors.grey[600],
                  ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: languages.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 1,
                color:
                    isDark ? ThemeColors.darkDivider : ThemeColors.lightDivider,
              ),
              itemBuilder: (context, index) {
                final language = languages[index];
                return _buildLanguageItem(context, language, isDark);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveLanguageSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Sauvegarder',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageItem(
      BuildContext context, LanguageModel language, bool isDark) {
    final isSelected = selectedLanguage == language.code;

    return InkWell(
      onTap: () {
        setState(() {
          selectedLanguage = language.code;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            // Flag
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? ThemeColors.darkSurface : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  language.flag,
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            SizedBox(width: 16),

            // Language info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    language.englishName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white60 : Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),

            // Selection indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? ThemeColors.primaryColor : Colors.grey,
                  width: 2,
                ),
                color:
                    isSelected ? ThemeColors.primaryColor : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _saveLanguageSelection() {
    // Here you would typically save the language preference
    // and update the app's locale
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Langue sauvegardée avec succès'),
        backgroundColor: ThemeColors.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
    Navigator.pop(context);
  }
}

class LanguageModel {
  final String code;
  final String name;
  final String englishName;
  final String flag;

  LanguageModel({
    required this.code,
    required this.name,
    required this.englishName,
    required this.flag,
  });
}
