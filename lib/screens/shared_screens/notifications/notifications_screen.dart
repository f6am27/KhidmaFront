// lib/screens/shared_screens/notifications/notifications_screen.dart
import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../models/notification_model.dart';
import '../../../services/notification_service.dart';
import '../../../core/storage/token_storage.dart';
import 'widgets/notification_item.dart';
import 'widgets/empty_notifications.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = notificationService;

  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;
  int _unreadCount = 0;
  String? _userRole;

  // Filter state
  bool? _filterIsRead;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadNotifications();
    _loadStats();
  }

  /// Load user role
  Future<void> _loadUserRole() async {
    try {
      final userData = await TokenStorage.readUserData();
      setState(() {
        _userRole = userData?['role'] as String?;
      });
    } catch (e) {
      print('Error loading user role: $e');
    }
  }

  /// Load notifications from API
  Future<void> _loadNotifications({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final result = await _notificationService.getNotifications(
        isRead: _filterIsRead,
        limit: 50,
      );

      if (result['ok']) {
        setState(() {
          _notifications = result['notifications'] as List<NotificationModel>;
          _isLoading = false;
          _isRefreshing = false;
        });
      } else {
        setState(() {
          _error = result['error'] as String?;
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur de chargement: ${e.toString()}';
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  /// Load notification statistics
  Future<void> _loadStats() async {
    try {
      final result = await _notificationService.getStats();

      if (result['ok']) {
        final stats = result['statistics'] as NotificationStatsModel;
        setState(() {
          _unreadCount = stats.unreadNotifications;
        });
      }
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  /// Refresh notifications
  Future<void> _refreshNotifications() async {
    setState(() {
      _isRefreshing = true;
    });

    await _loadNotifications(showLoading: false);
    await _loadStats();
  }

  /// Mark notification as read
  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    try {
      final result = await _notificationService.markAsRead(notification.id);

      if (result['ok']) {
        setState(() {
          final index =
              _notifications.indexWhere((n) => n.id == notification.id);
          if (index != -1) {
            _notifications[index] = notification.copyWith(
              isRead: true,
              readAt: DateTime.now().toIso8601String(),
            );
          }
          _unreadCount = (_unreadCount - 1).clamp(0, 999);
        });

        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Marquée comme lue'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  /// Mark all as read
  Future<void> _markAllAsRead() async {
    try {
      final result = await _notificationService.markAllAsRead();

      if (result['ok']) {
        setState(() {
          _notifications = _notifications
              .map((n) => n.copyWith(
                  isRead: true, readAt: DateTime.now().toIso8601String()))
              .toList();
          _unreadCount = 0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Toutes marquées comme lues'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  /// Delete notification
  Future<void> _deleteNotification(NotificationModel notification) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer la notification'),
        content: Text('Voulez-vous vraiment supprimer cette notification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final result =
          await _notificationService.deleteNotification(notification.id);

      if (result['ok']) {
        setState(() {
          _notifications.removeWhere((n) => n.id == notification.id);
          if (!notification.isRead) {
            _unreadCount = (_unreadCount - 1).clamp(0, 999);
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Notification supprimée'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(NotificationModel notification) {
    // Mark as read
    _markAsRead(notification);

    // Navigate to related task if available
    if (notification.taskId != null) {
      // TODO: Navigate to task details
      // Navigator.pushNamed(context, '/task-details', arguments: {'taskId': notification.taskId});
      print('Navigate to task: ${notification.taskId}');
    }
  }

  /// Toggle filter
  void _toggleFilter() {
    setState(() {
      if (_filterIsRead == null) {
        _filterIsRead = false; // Show unread only
      } else if (_filterIsRead == false) {
        _filterIsRead = true; // Show read only
      } else {
        _filterIsRead = null; // Show all
      }
    });
    _loadNotifications();
  }

  /// Get filter text
  String _getFilterText() {
    if (_filterIsRead == null) return 'Tous';
    if (_filterIsRead == false) return 'Non lus';
    return 'Lus';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        centerTitle: true,
        actions: [
          // Unread count badge
          if (_unreadCount > 0)
            Container(
              margin: EdgeInsets.only(right: 8),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ThemeColors.errorColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _unreadCount > 99 ? '99+' : '$_unreadCount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          // Filter button
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _toggleFilter,
            tooltip: _getFilterText(),
          ),

          // More options
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'mark_all_read') {
                _markAllAsRead();
              } else if (value == 'refresh') {
                _refreshNotifications();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.done_all, size: 20),
                    SizedBox(width: 12),
                    Text('Tout marquer comme lu'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 20),
                    SizedBox(width: 12),
                    Text('Actualiser'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadNotifications,
              icon: Icon(Icons.refresh),
              label: Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return EmptyNotifications(
        filterText: _getFilterText(),
        onRefresh: _refreshNotifications,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshNotifications,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 16),
        itemCount: _notifications.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 1,
          color: isDark ? ThemeColors.darkDivider : ThemeColors.lightDivider,
        ),
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return NotificationItem(
            notification: notification,
            userRole: _userRole ?? 'client',
            onTap: () => _handleNotificationTap(notification),
            onDelete: () => _deleteNotification(notification),
            onMarkAsRead: () => _markAsRead(notification),
          );
        },
      ),
    );
  }
}
