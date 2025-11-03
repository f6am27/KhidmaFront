import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../models/models.dart';
import '../../../services/profile_service.dart';
import '../../shared_screens/dialogs/logout_confirmation.dart';
import '../../shared_screens/settings/change_password.dart';
import 'widgets/profile_edit.dart';
import '../../shared_screens/notifications/notifications_screen.dart';
import '../../shared_screens/settings/language.dart';
import '../../shared_screens/settings/support.dart';
import '../../shared_screens/settings/blocked_users_screen.dart';
import 'widgets/favorite_providers.dart';
import '../../shared_screens/payment_history.dart';
import '../../../services/auth_manager.dart';
import '../../../routes/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();

  bool _isLoading = true;
  ClientProfile? _clientProfile;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadClientProfile();
  }

  Future<void> _loadClientProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await _profileService.getClientProfile();

      if (result['ok'] == true) {
        setState(() {
          _clientProfile = result['clientProfile'] as ClientProfile;
          _isLoading = false;
        });

        // Debug
        print('✅ Client Profile Loaded:');
        print('Published: ${_clientProfile?.totalTasksPublished}');
        print('Completed: ${_clientProfile?.totalTasksCompleted}');
        print('Amount Spent: ${_clientProfile?.totalAmountSpent}');
      } else {
        setState(() {
          _errorMessage =
              result['error'] ?? 'Erreur lors du chargement du profil';
          _isLoading = false;
        });

        if (result['needsLogin'] == true) {
          _showError('Session expirée, veuillez vous reconnecter');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur réseau: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshProfile() async {
    await _loadClientProfile();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ThemeColors.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage.isNotEmpty
              ? _buildErrorState()
              : _buildProfileContent(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: ThemeColors.primaryColor),
          SizedBox(height: 16),
          Text(
            'Chargement du profil...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: ThemeColors.errorColor,
            ),
            SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return RefreshIndicator(
      onRefresh: _refreshProfile,
      color: ThemeColors.primaryColor,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 20),

            // صورة البروفايل
            _buildProfilePhoto(),
            SizedBox(height: 16),

            // الاسم
            _buildProfileInfo(),
            SizedBox(height: 30),

            // الإحصائيات السريعة
            _buildQuickStats(context),
            SizedBox(height: 30),

            // القائمة الرئيسية
            _buildMainMenu(context),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePhoto() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CircleAvatar(
      radius: 50,
      backgroundColor: isDark ? ThemeColors.darkSurface : Colors.grey[200],
      backgroundImage: _clientProfile?.profileImageUrl != null
          ? NetworkImage(_clientProfile!.profileImageUrl!)
          : null,
      child: _clientProfile?.profileImageUrl == null
          ? Icon(
              Icons.person,
              size: 60,
              color: isDark ? ThemeColors.darkTextSecondary : Colors.grey[600],
            )
          : null,
    );
  }

  Widget _buildProfileInfo() {
    if (_clientProfile == null) return SizedBox.shrink();

    return Column(
      children: [
        // الاسم
        Text(
          _clientProfile!.fullName,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        SizedBox(height: 4),

        // عضو منذ
        Text(
          'Client depuis ${_clientProfile!.memberSince}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),

        // المنطقة (إذا موجودة)
        if (_clientProfile!.address != null &&
            _clientProfile!.address!.isNotEmpty) ...[
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.grey[600],
              ),
              SizedBox(width: 4),
              Text(
                _clientProfile!.address!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ],
      ],
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
              context,
              _clientProfile?.totalTasksPublished.toString() ?? '0',
              'Demandes\nPubliées',
              Icons.work_outline),
          _buildDivider(context),
          _buildStatItem(
              context,
              _clientProfile?.totalTasksCompleted.toString() ?? '0',
              'Services\nTerminés',
              Icons.check_circle_outline),
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

  void _navigateToSettings(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(),
      ),
    );

    if (result == true) {
      _refreshProfile();
    }
  }
}

// صفحة الإعدادات
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
            _buildSectionTitle(context, 'Votre compte'),
            _buildSettingsItem(
              context: context,
              icon: Icons.person_outline,
              title: 'Modifier le Profil',
              subtitle: 'Photo, nom, informations personnelles',
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileEditScreen(),
                  ),
                );

                if (result == true) {
                  Navigator.pop(context, true);
                }
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
                    builder: (context) => NotificationsScreen(),
                  ),
                );
              },
            ),
            SizedBox(height: 30),
            _buildSectionTitle(context, 'Confidentialité'),
            _buildSettingsItem(
              context: context,
              icon: Icons.block_outlined,
              title: 'Comptes bloqués',
              subtitle: 'Gérer les utilisateurs bloqués',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlockedUsersScreen(),
                  ),
                );
              },
            ),
            SizedBox(height: 30),
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

  Future<void> _performLogout(BuildContext context) async {
    try {
      // عرض مؤشر التحميل
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // تسجيل الخروج من Backend
      await AuthManager.logoutWithBackend();

      // إخفاء مؤشر التحميل
      if (context.mounted) Navigator.of(context).pop();

      // الانتقال لشاشة اختيار نوع المستخدم
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.registrationType,
          (route) => false,
        );
      }
    } catch (e) {
      // إخفاء مؤشر التحميل في حالة الخطأ
      if (context.mounted) Navigator.of(context).pop();

      // عرض رسالة خطأ
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la déconnexion: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
