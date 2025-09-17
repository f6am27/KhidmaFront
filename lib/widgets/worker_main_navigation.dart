import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../screens/worker_screens/home/worker_home_screen.dart';
import '../screens/worker_screens/mission/worker_tasks_screen.dart';
import '../screens/worker_screens/messages/worker_messages_screen.dart';
import '../screens/worker_screens/profile/profile_screen.dart';
import '../screens/worker_screens/explore/explore_screen.dart';

class WorkerMainNavigation extends StatefulWidget {
  const WorkerMainNavigation({Key? key}) : super(key: key);

  @override
  State<WorkerMainNavigation> createState() => _WorkerMainNavigationState();
}

class _WorkerMainNavigationState extends State<WorkerMainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const WorkerHomeScreen(),

    WorkerExploreScreen(),

    // TODO: Ajouter MyTasksScreen
    WorkerTasksScreen(),
    // TODO: Ajouter MessagesScreen (réutiliser client)
    WorkerMessagesScreen(),
    // TODO: Ajouter ProfileScreen (adapter client)
    WorkerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
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
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore,
                  label: 'Explorer',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.assignment_outlined,
                  activeIcon: Icons.assignment,
                  label: 'Mes Tâches',
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.mail_outline,
                  activeIcon: Icons.mail,
                  label: 'Messages',
                ),
                _buildNavItem(
                  index: 4,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profil',
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
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
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
              color:
                  isSelected ? AppColors.primaryPurple : AppColors.mediumGray,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected ? AppColors.primaryPurple : AppColors.mediumGray,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
