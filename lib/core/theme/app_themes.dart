import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_colors.dart';

class AppThemes {
  // الثيم الفاتح
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: MaterialColor(0xFF6366F1, {
      50: Color(0xFFEEF2FF),
      100: Color(0xFFE0E7FF),
      200: Color(0xFFC7D2FE),
      300: Color(0xFFA5B4FC),
      400: Color(0xFF818CF8),
      500: Color(0xFF6366F1),
      600: Color(0xFF4F46E5),
      700: Color(0xFF4338CA),
      800: Color(0xFF3730A3),
      900: Color(0xFF312E81),
    }),
    primaryColor: ThemeColors.primaryColor,
    scaffoldBackgroundColor: ThemeColors.lightBackground,

    // الألوان العامة
    colorScheme: const ColorScheme.light(
      primary: ThemeColors.primaryColor,
      secondary: ThemeColors.secondaryColor,
      surface: ThemeColors.lightSurface,
      background: ThemeColors.lightBackground,
      error: ThemeColors.errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: ThemeColors.lightTextPrimary,
      onBackground: ThemeColors.lightTextPrimary,
      onError: Colors.white,
    ),

    // شريط التطبيق
    appBarTheme: AppBarTheme(
      backgroundColor: ThemeColors.lightBackground,
      elevation: 0,
      iconTheme: const IconThemeData(color: ThemeColors.lightTextPrimary),
      titleTextStyle: GoogleFonts.inter(
        color: ThemeColors.lightTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    // النصوص
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        color: ThemeColors.lightTextPrimary,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.inter(
        color: ThemeColors.lightTextPrimary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.inter(
        color: ThemeColors.lightTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: GoogleFonts.inter(
        color: ThemeColors.lightTextPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: GoogleFonts.inter(
        color: ThemeColors.lightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.inter(
        color: ThemeColors.lightTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.inter(
        color: ThemeColors.lightTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.inter(
        color: ThemeColors.lightTextPrimary,
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.inter(
        color: ThemeColors.lightTextSecondary,
        fontSize: 14,
      ),
      bodySmall: GoogleFonts.inter(
        color: ThemeColors.lightTextSecondary,
        fontSize: 12,
      ),
    ),

    // البطاقات
    // cardTheme: CardTheme(
    //   color: ThemeColors.lightCardBackground,
    //   elevation: 2,
    //   shadowColor: ThemeColors.shadowLight,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(16),
    //   ),
    // ),

    // الأزرار
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ThemeColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),

    // المفاتيح
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return ThemeColors.primaryColor;
        }
        return Colors.grey;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return ThemeColors.primaryColor.withOpacity(0.5);
        }
        return Colors.grey.withOpacity(0.5);
      }),
    ),

    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  // الثيم المظلم
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: MaterialColor(0xFF6366F1, {
      50: Color(0xFFEEF2FF),
      100: Color(0xFFE0E7FF),
      200: Color(0xFFC7D2FE),
      300: Color(0xFFA5B4FC),
      400: Color(0xFF818CF8),
      500: Color(0xFF6366F1),
      600: Color(0xFF4F46E5),
      700: Color(0xFF4338CA),
      800: Color(0xFF3730A3),
      900: Color(0xFF312E81),
    }),
    primaryColor: ThemeColors.primaryColor,
    scaffoldBackgroundColor: ThemeColors.darkBackground,

    // الألوان العامة
    colorScheme: const ColorScheme.dark(
      primary: ThemeColors.primaryColor,
      secondary: ThemeColors.secondaryColor,
      surface: ThemeColors.darkSurface,
      background: ThemeColors.darkBackground,
      error: ThemeColors.errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: ThemeColors.darkTextPrimary,
      onBackground: ThemeColors.darkTextPrimary,
      onError: Colors.white,
    ),

    // شريط التطبيق
    appBarTheme: AppBarTheme(
      backgroundColor: ThemeColors.darkBackground,
      elevation: 0,
      iconTheme: const IconThemeData(color: ThemeColors.darkTextPrimary),
      titleTextStyle: GoogleFonts.inter(
        color: ThemeColors.darkTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    // النصوص
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        color: ThemeColors.darkTextPrimary,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.inter(
        color: ThemeColors.darkTextPrimary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.inter(
        color: ThemeColors.darkTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: GoogleFonts.inter(
        color: ThemeColors.darkTextPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: GoogleFonts.inter(
        color: ThemeColors.darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.inter(
        color: ThemeColors.darkTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.inter(
        color: ThemeColors.darkTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.inter(
        color: ThemeColors.darkTextPrimary,
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.inter(
        color: ThemeColors.darkTextSecondary,
        fontSize: 14,
      ),
      bodySmall: GoogleFonts.inter(
        color: ThemeColors.darkTextSecondary,
        fontSize: 12,
      ),
    ),

    // البطاقات
    // cardTheme: CardTheme(
    //   color: ThemeColors.darkCardBackground,
    //   elevation: 2,
    //   shadowColor: ThemeColors.shadowDark,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(16),
    //   ),
    // ),

    // الأزرار
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ThemeColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),

    // المفاتيح
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return ThemeColors.primaryColor;
        }
        return Colors.grey;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return ThemeColors.primaryColor.withOpacity(0.5);
        }
        return Colors.grey.withOpacity(0.5);
      }),
    ),

    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
