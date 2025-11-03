import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../services/chat_service.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({Key? key}) : super(key: key);

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  bool _isLoading = true;
  List<dynamic> _blockedUsers = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await ChatService().getBlockedUsers();

      if (result['ok'] == true) {
        setState(() {
          _blockedUsers = result['blocked_users'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Erreur lors du chargement';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur réseau: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _unblockUser(int userId, String userName) async {
    // عرض Dialog للتأكيد
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Débloquer $userName?'),
        content: Text(
          'Êtes-vous sûr de vouloir débloquer cet utilisateur?',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text('Débloquer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // عرض Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await ChatService().unblockUser(userId);

      // إخفاء Loading
      if (mounted) Navigator.pop(context);

      if (result['ok'] == true) {
        _showSnackBar('Utilisateur débloqué avec succès', isSuccess: true);
        _loadBlockedUsers(); // إعادة تحميل القائمة
      } else {
        _showSnackBar(result['error'] ?? 'Erreur lors du déblocage');
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showSnackBar('Erreur réseau: ${e.toString()}');
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? ThemeColors.darkBackground : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: isDark ? ThemeColors.darkBackground : Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark
                ? ThemeColors.darkTextPrimary
                : ThemeColors.lightTextPrimary,
            size: 20,
          ),
        ),
        title: Text(
          'Comptes bloqués',
          style: TextStyle(
            color: isDark
                ? ThemeColors.darkTextPrimary
                : ThemeColors.lightTextPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage.isNotEmpty
              ? _buildErrorState()
              : _blockedUsers.isEmpty
                  ? _buildEmptyState(isDark)
                  : _buildBlockedUsersList(isDark),
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
            'Chargement...',
            style: TextStyle(fontSize: 16),
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
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Erreur',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadBlockedUsers,
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: ThemeColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.block_outlined,
                size: 60,
                color: ThemeColors.primaryColor,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Aucun compte bloqué',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? ThemeColors.darkTextPrimary
                    : ThemeColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Vous n\'avez bloqué aucun utilisateur',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color:
                    isDark ? ThemeColors.darkTextSecondary : Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockedUsersList(bool isDark) {
    return RefreshIndicator(
      onRefresh: _loadBlockedUsers,
      color: ThemeColors.primaryColor,
      child: ListView.separated(
        padding: EdgeInsets.all(20),
        itemCount: _blockedUsers.length,
        separatorBuilder: (context, index) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          final user = _blockedUsers[index];
          return _buildBlockedUserCard(user, isDark);
        },
      ),
    );
  }

  Widget _buildBlockedUserCard(dynamic user, bool isDark) {
    final userId = user['id'] ?? 0;
    final fullName = user['full_name'] ?? 'Utilisateur';
    final role = user['role'] ?? '';
    final profileImage = user['profile_image_url'];

    // ترجمة الدور
    String roleText = role == 'worker' ? 'Prestataire' : 'Client';

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? ThemeColors.shadowDark : ThemeColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // صورة المستخدم
          CircleAvatar(
            radius: 28,
            backgroundColor: ThemeColors.primaryColor.withOpacity(0.1),
            backgroundImage:
                profileImage != null ? NetworkImage(profileImage) : null,
            child: profileImage == null
                ? Icon(
                    Icons.person,
                    size: 28,
                    color: ThemeColors.primaryColor,
                  )
                : null,
          ),
          SizedBox(width: 16),

          // معلومات المستخدم
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? ThemeColors.darkTextPrimary
                        : ThemeColors.lightTextPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  roleText,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? ThemeColors.darkTextSecondary
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // زر إلغاء الحظر
          ElevatedButton.icon(
            onPressed: () => _unblockUser(userId, fullName),
            icon: Icon(Icons.block, size: 18),
            label: Text('Débloquer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red.shade700,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
