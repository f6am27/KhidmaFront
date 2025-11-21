import 'package:flutter/material.dart';
import 'dart:async';
import '../constants/colors.dart';
import '../screens/worker_screens/home/worker_home_screen.dart';
import '../screens/worker_screens/mission/worker_tasks_screen.dart';
import '../screens/shared_screens/messages/messages_list_screen.dart';
import '../screens/worker_screens/profile/profile_screen.dart';
import '../screens/worker_screens/explore/explore_screen.dart';
import '../core/theme/theme_colors.dart';
import '../services/notification_service.dart';
import '../services/chat_service.dart';

class WorkerMainNavigation extends StatefulWidget {
  const WorkerMainNavigation({Key? key}) : super(key: key);

  @override
  State<WorkerMainNavigation> createState() => _WorkerMainNavigationState();
}

class _WorkerMainNavigationState extends State<WorkerMainNavigation> {
  int _currentIndex = 0;
  int _unreadNotifications = 0;
  int _unreadMessages = 0;
  Timer? _updateTimer;

  final List<Widget> _screens = [
    const WorkerHomeScreen(),
    WorkerExploreScreen(),
    WorkerTasksScreen(),
    MessagesListScreen(),
    WorkerProfileScreen(),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? ThemeColors.darkCardBackground : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? ThemeColors.shadowDark
                  : Colors.black.withOpacity(0.08),
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Accueil',
                  isDark: isDark,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore,
                  label: 'Explorer',
                  isDark: isDark,
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.assignment_outlined,
                  activeIcon: Icons.assignment,
                  label: 'Mes Tâches',
                  isDark: isDark,
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.mail_outline,
                  activeIcon: Icons.mail,
                  label: 'Messages',
                  isDark: isDark,
                  badge: _unreadMessages,
                ),
                _buildNavItem(
                  index: 4,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profil',
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isDark,
    int badge = 0,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        if (index == 3) {
          setState(() => _unreadMessages = 0);
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isSelected
                  ? AppColors.primaryPurple.withOpacity(0.1)
                  : Colors.transparent,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected
                      ? AppColors.primaryPurple
                      : (isDark
                          ? ThemeColors.darkTextSecondary
                          : AppColors.mediumGray),
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primaryPurple
                        : (isDark
                            ? ThemeColors.darkTextSecondary
                            : AppColors.mediumGray),
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Badge
          if (badge > 0)
            Positioned(
              right: 4,
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
