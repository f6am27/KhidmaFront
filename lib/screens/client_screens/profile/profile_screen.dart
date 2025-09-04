import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_colors.dart';
import 'widgets/logout_confirmation.dart';
import 'widgets/change_password.dart';
import 'widgets/profile_edit.dart';
import 'widgets/notification.dart';
import 'widgets/language.dart';
import 'widgets/support.dart';
import 'widgets/favorite_providers.dart';
import 'widgets/payment_history.dart'; // إضافة استيراد payment_history

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _navigateToSettings(context),
            icon: Icon(
              Icons.settings,
              color: ThemeColors.primaryColor,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),

            // صورة البروفايل
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? ThemeColors.darkSurface
                  : Colors.grey[200],
              child: Icon(
                Icons.person,
                size: 60,
                color: Theme.of(context).brightness == Brightness.dark
                    ? ThemeColors.darkTextSecondary
                    : Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),

            // الاسم
            Text(
              'Fatima Al-Kharrachi',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            SizedBox(height: 4),
            Text(
              'Client depuis Mars 2024',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 30),

            // الإحصائيات السريعة
            _buildQuickStats(context),
            SizedBox(height: 30),

            // القائمة الرئيسية (بدون Mes Demandes)
            _buildMainMenu(context),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? ThemeColors.shadowDark : ThemeColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(
              context, '12', 'Demandes\nPubliées', Icons.work_outline),
          _buildDivider(context),
          _buildStatItem(
              context, '8', 'Services\nTerminés', Icons.check_circle_outline),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, String number, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: ThemeColors.primaryColor,
          ),
          SizedBox(height: 8),
          Text(
            number,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 1,
      height: 40,
      color: isDark ? ThemeColors.darkBorder : ThemeColors.lightBorder,
    );
  }

  Widget _buildMainMenu(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? ThemeColors.shadowDark : ThemeColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            context: context,
            icon: Icons.favorite_outline,
            title: 'Prestataires Favoris',
            subtitle: 'Vos prestataires de confiance',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoriteProvidersScreen(),
                ),
              );
            },
          ),
          _buildMenuDivider(context),
          _buildMenuItem(
            context: context,
            icon: Icons.payment,
            title: 'Historique des Paiements',
            subtitle: 'Vos transactions et factures',
            onTap: () {
              // إضافة التنقل إلى صفحة payment_history
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showBadge = false,
    String? badgeCount,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: ThemeColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: ThemeColors.primaryColor,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (showBadge && badgeCount != null) ...[
                        SizedBox(width: 8),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: ThemeColors.errorColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            badgeCount,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? ThemeColors.darkTextSecondary : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: isDark ? ThemeColors.darkDivider : ThemeColors.lightDivider,
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(),
      ),
    );
  }
}

// صفحة الإعدادات (بدون تغيير)
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paramètres'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),

            // قسم الحساب
            _buildSectionTitle(context, 'Votre compte'),
            _buildSettingsItem(
              context: context,
              icon: Icons.person_outline,
              title: 'Modifier le Profil',
              subtitle: 'Photo, nom, informations personnelles',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileEditScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              context: context,
              icon: Icons.lock_outline,
              title: 'Sécurité',
              subtitle: 'Mot de passe, authentification',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangePasswordScreen(),
                  ),
                );
              },
            ),
            SizedBox(height: 30),

            // قسم التفضيلات
            _buildSectionTitle(context, 'Préférences'),
            _buildSettingsItem(
              context: context,
              icon: Icons.language,
              title: 'Langue',
              subtitle: 'Changer la langue de l\'application',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LanguageScreen(),
                  ),
                );
              },
            ),
            _buildThemeSettingsItem(context),
            _buildSettingsItem(
              context: context,
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Préférences de notification',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationScreen(),
                  ),
                );
              },
            ),

            SizedBox(height: 30),

            // قسم الدعم
            _buildSectionTitle(context, 'Support'),
            _buildSettingsItem(
              context: context,
              icon: Icons.help_outline,
              title: 'Aide & Support',
              subtitle: 'FAQ, contact, signaler un problème',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SupportScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              context: context,
              icon: Icons.logout,
              title: 'Déconnexion',
              subtitle: 'Se déconnecter de l\'application',
              onTap: () => _showLogoutDialog(context),
              textColor: ThemeColors.errorColor,
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? ThemeColors.darkTextSecondary
                  : ThemeColors.lightTextSecondary,
            ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: textColor ??
                  (isDark
                      ? ThemeColors.darkTextPrimary
                      : ThemeColors.lightTextPrimary),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: textColor,
                        ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? ThemeColors.darkTextSecondary : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSettingsItem(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                size: 24,
                color: isDark
                    ? ThemeColors.darkTextPrimary
                    : ThemeColors.lightTextPrimary,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thème de l\'application',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 2),
                    Text(
                      isDark ? 'Mode sombre activé' : 'Mode clair activé',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Switch(
                value: isDark,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
                activeColor: ThemeColors.primaryColor,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    LogoutConfirmation.show(
      context,
      onConfirm: () {
        _performLogout(context);
      },
      onCancel: () {
        print('Logout cancelled');
      },
    );
  }

  void _performLogout(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تسجيل الخروج بنجاح'),
        backgroundColor: ThemeColors.primaryColor,
      ),
    );
  }
}
