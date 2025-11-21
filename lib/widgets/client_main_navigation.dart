import 'package:flutter/material.dart';
import 'dart:async';
import '../../screens/client_screens/home/home_screen.dart';
import '../../screens/client_screens/favorites/favorites_screen.dart';
import '../screens/shared_screens/messages/messages_list_screen.dart';
import '../../screens/client_screens/profile/profile_screen.dart';
import '../../screens/client_screens/missions/tasks_screen.dart';
import '../../core/theme/theme_colors.dart';
import '../../services/notification_service.dart';
import '../../services/chat_service.dart';

class ClientMainNavigation extends StatefulWidget {
  @override
  _ClientMainNavigationState createState() => _ClientMainNavigationState();
}

class _ClientMainNavigationState extends State<ClientMainNavigation> {
  int _selectedIndex = 0;
  int _unreadNotifications = 0;
  int _unreadMessages = 0;
  Timer? _updateTimer;

  final List<Widget> _pages = [
    ClientHomeScreen(),
    FavoritesScreen(),
    TasksScreen(),
    MessagesListScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadCounts();
    _startAutoUpdate();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startAutoUpdate() {
    _updateTimer = Timer.periodic(Duration(seconds: 10), (_) {
      _loadCounts();
    });
  }

  Future<void> _loadCounts() async {
    try {
      // Load notifications count
      final notifResult = await notificationService.getStats();
      if (notifResult['ok']) {
        final stats = notifResult['statistics'];
        if (mounted) {
          setState(() {
            _unreadNotifications = stats.unreadNotifications;
          });
        }
      }

      // Load messages count
      final msgResult = await chatService.getConversations();
      if (msgResult['ok']) {
        final conversations = msgResult['conversations'] as List;
        final unreadCount = conversations.fold<int>(
          0,
          (sum, conv) => sum + (conv.unreadCount as int),
        );
        if (mounted) {
          setState(() {
            _unreadMessages = unreadCount;
          });
        }
      }
    } catch (e) {
      print('Error loading counts: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Reset count when opening the screen
    if (index == 3) {
      setState(() => _unreadMessages = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDark ? ThemeColors.shadowDark : Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 'Accueil', 0, isDark),
                _buildNavItem(Icons.favorite_border, 'Favoris', 1, isDark),
                SizedBox(width: 60),
                _buildNavItem(Icons.mail_outline, 'Messages', 3, isDark,
                    badge: _unreadMessages),
                _buildNavItem(Icons.person_outline, 'Profil', 4, isDark),
              ],
            ),
          ),

          // أيقونة المهام الوسطى
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 30,
            top: 10,
            child: GestureDetector(
              onTap: () => _onItemTapped(2),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: ThemeColors.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ThemeColors.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.task_alt,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, bool isDark,
      {int badge = 0}) {
    bool isSelected = index == _selectedIndex;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? ThemeColors.primaryColor
                      : (isDark
                          ? ThemeColors.darkTextSecondary
                          : Colors.grey[600]),
                  size: 24,
                ),
                SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? ThemeColors.primaryColor
                        : (isDark
                            ? ThemeColors.darkTextSecondary
                            : Colors.grey[600]),
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),

          // Badge
          if (badge > 0)
            Positioned(
              right: 8,
              top: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  badge > 99 ? '99+' : '$badge',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
