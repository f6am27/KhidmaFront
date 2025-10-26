// lib/screens/shared_screens/notifications/widgets/notification_item.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../models/notification_model.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final String userRole;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onMarkAsRead;

  const NotificationItem({
    Key? key,
    required this.notification,
    required this.userRole,
    required this.onTap,
    required this.onDelete,
    required this.onMarkAsRead,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final type = notification.type;

    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Supprimer'),
            content: Text('Supprimer cette notification?'),
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
      },
      onDismissed: (direction) => onDelete(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: notification.isRead
              ? Colors.transparent
              : (isDark
                  ? ThemeColors.primaryColor.withOpacity(0.05)
                  : ThemeColors.primaryColor.withOpacity(0.03)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getIconBackgroundColor(type),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIconData(type),
                    color: _getIconColor(type),
                    size: 20,
                  ),
                ),
                SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: notification.isRead
                                        ? FontWeight.normal
                                        : FontWeight.w600,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            notification.timeAgo ??
                                _formatTime(notification.createdAt),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? ThemeColors.darkTextSecondary
                                          : ThemeColors.lightTextSecondary,
                                    ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDark ? Colors.white70 : Colors.grey[600],
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Task title if available
                      if (notification.taskTitle != null) ...[
                        SizedBox(height: 6),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: ThemeColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            notification.taskTitle!,
                            style: TextStyle(
                              color: ThemeColors.primaryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],

                      // Unread indicator
                      if (!notification.isRead) ...[
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: ThemeColors.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Nouveau',
                              style: TextStyle(
                                color: ThemeColors.primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getIconBackgroundColor(NotificationType type) {
    switch (type) {
      case NotificationType.taskPublished:
        return Colors.green.withOpacity(0.1);
      case NotificationType.workerApplied:
        return Colors.blue.withOpacity(0.1);
      case NotificationType.taskCompleted:
        return Colors.purple.withOpacity(0.1);
      case NotificationType.paymentReceived:
      case NotificationType.paymentSent:
        return Colors.teal.withOpacity(0.1);
      case NotificationType.messageReceived:
        return Colors.orange.withOpacity(0.1);
      case NotificationType.serviceReminder:
        return Colors.amber.withOpacity(0.1);
      case NotificationType.serviceCancelled:
        return Colors.red.withOpacity(0.1);
      case NotificationType.newTaskAvailable:
        return Colors.blue.withOpacity(0.1);
      case NotificationType.applicationAccepted:
        return Colors.green.withOpacity(0.1);
      case NotificationType.applicationRejected:
        return Colors.red.withOpacity(0.1);
      default:
        return ThemeColors.primaryColor.withOpacity(0.1);
    }
  }

  Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.taskPublished:
        return Colors.green;
      case NotificationType.workerApplied:
        return Colors.blue;
      case NotificationType.taskCompleted:
        return Colors.purple;
      case NotificationType.paymentReceived:
      case NotificationType.paymentSent:
        return Colors.teal;
      case NotificationType.messageReceived:
        return Colors.orange;
      case NotificationType.serviceReminder:
        return Colors.amber[700]!;
      case NotificationType.serviceCancelled:
        return Colors.red;
      case NotificationType.newTaskAvailable:
        return Colors.blue;
      case NotificationType.applicationAccepted:
        return Colors.green;
      case NotificationType.applicationRejected:
        return Colors.red;
      default:
        return ThemeColors.primaryColor;
    }
  }

  IconData _getIconData(NotificationType type) {
    switch (type) {
      case NotificationType.taskPublished:
        return Icons.publish;
      case NotificationType.workerApplied:
        return Icons.handyman;
      case NotificationType.taskCompleted:
        return Icons.done_all;
      case NotificationType.paymentReceived:
      case NotificationType.paymentSent:
        return Icons.account_balance_wallet;
      case NotificationType.messageReceived:
        return Icons.chat_bubble;
      case NotificationType.serviceReminder:
        return Icons.alarm;
      case NotificationType.serviceCancelled:
        return Icons.event_busy;
      case NotificationType.newTaskAvailable:
        return Icons.work_outline;
      case NotificationType.applicationAccepted:
        return Icons.check_circle_outline;
      case NotificationType.applicationRejected:
        return Icons.cancel_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatTime(String createdAt) {
    try {
      final dateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'maintenant';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}min';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h';
      } else if (difference.inDays == 1) {
        return '1 jour';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} jours';
      } else {
        final weeks = (difference.inDays / 7).floor();
        return weeks == 1 ? '1 semaine' : '$weeks semaines';
      }
    } catch (e) {
      return '';
    }
  }
}
