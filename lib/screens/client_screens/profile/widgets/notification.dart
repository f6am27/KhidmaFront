import 'package:flutter/material.dart';
import '../../../../core/theme/theme_colors.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        centerTitle: true,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ThemeColors.errorColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '3 NEW',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 16),
        itemCount: _notifications.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 1,
          color: Theme.of(context).brightness == Brightness.dark
              ? ThemeColors.darkDivider
              : ThemeColors.lightDivider,
        ),
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _buildNotificationItem(context, notification);
        },
      ),
    );
  }

  Widget _buildNotificationItem(
      BuildContext context, NotificationModel notification) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
                color: _getIconBackgroundColor(notification.type),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIconData(notification.type),
                color: _getIconColor(notification.type),
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
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: notification.isRead
                                        ? FontWeight.normal
                                        : FontWeight.w600,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        _formatTime(notification.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? ThemeColors.darkTextSecondary
                                  : ThemeColors.lightTextSecondary,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    notification.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white70 : Colors.grey[600],
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (notification.workerName != null) ...[
                    SizedBox(height: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: ThemeColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        notification.workerName!,
                        style: TextStyle(
                          color: ThemeColors.primaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
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
    );
  }

  Color _getIconBackgroundColor(NotificationType type) {
    switch (type) {
      case NotificationType.taskPublished:
        return Colors.green.withOpacity(0.1);
      case NotificationType.workerRequested:
        return Colors.blue.withOpacity(0.1);
      case NotificationType.taskCompleted:
        return Colors.purple.withOpacity(0.1);
      case NotificationType.paymentConfirmed:
        return Colors.teal.withOpacity(0.1);
      case NotificationType.newMessage:
        return Colors.orange.withOpacity(0.1);
      case NotificationType.serviceReminder:
        return Colors.amber.withOpacity(0.1);
      case NotificationType.serviceCancelled:
        return Colors.red.withOpacity(0.1);
      default:
        return ThemeColors.primaryColor.withOpacity(0.1);
    }
  }

  Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.taskPublished:
        return Colors.green;
      case NotificationType.workerRequested:
        return Colors.blue;
      case NotificationType.taskCompleted:
        return Colors.purple;
      case NotificationType.paymentConfirmed:
        return Colors.teal;
      case NotificationType.newMessage:
        return Colors.orange;
      case NotificationType.serviceReminder:
        return Colors.amber[700]!;
      case NotificationType.serviceCancelled:
        return Colors.red;
      default:
        return ThemeColors.primaryColor;
    }
  }

  IconData _getIconData(NotificationType type) {
    switch (type) {
      case NotificationType.taskPublished:
        return Icons.publish;
      case NotificationType.workerRequested:
        return Icons.handyman;
      case NotificationType.taskCompleted:
        return Icons.done_all;
      case NotificationType.paymentConfirmed:
        return Icons.account_balance_wallet;
      case NotificationType.newMessage:
        return Icons.chat_bubble;
      case NotificationType.serviceReminder:
        return Icons.alarm;
      case NotificationType.serviceCancelled:
        return Icons.event_busy;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

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
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 semaine' : '$weeks semaines';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 mois' : '$months mois';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 an' : '$years ans';
    }
  }

  // Sample notifications data for client - ONLY the 7 specified types
  static final List<NotificationModel> _notifications = [
    NotificationModel(
      id: '1',
      title: 'Tâche publiée avec succès',
      description:
          'Votre demande de "Nettoyage de maison" a été publiée et est maintenant visible par les prestataires.',
      timestamp: DateTime.now().subtract(Duration(minutes: 15)),
      isRead: false,
      type: NotificationType.taskPublished,
    ),
    NotificationModel(
      id: '2',
      title: 'Nouvelle demande reçue',
      description:
          'Fatima Al-Zahra souhaite effectuer votre tâche de nettoyage. Consultez son profil et acceptez l\'offre.',
      timestamp: DateTime.now().subtract(Duration(minutes: 45)),
      isRead: false,
      type: NotificationType.workerRequested,
      workerName: 'Fatima Al-Zahra',
    ),
    NotificationModel(
      id: '3',
      title: 'Nouveau message reçu',
      description:
          'Mohamed Ould Ahmed vous a envoyé un message concernant votre demande de réparation plomberie.',
      timestamp: DateTime.now().subtract(Duration(hours: 1, minutes: 20)),
      isRead: false,
      type: NotificationType.newMessage,
      workerName: 'Mohamed Ould Ahmed',
    ),
    NotificationModel(
      id: '4',
      title: 'Rappel de service',
      description:
          'Votre service de jardinage avec Omar Ba est programmé pour demain à 9h00. N\'oubliez pas!',
      timestamp: DateTime.now().subtract(Duration(hours: 3)),
      isRead: true,
      type: NotificationType.serviceReminder,
      workerName: 'Omar Ba',
    ),
    NotificationModel(
      id: '5',
      title: 'Service terminé',
      description:
          'Aicha Mint Salem a marqué votre tâche de garde d\'enfants comme terminée. Confirmez et effectuez le paiement.',
      timestamp: DateTime.now().subtract(Duration(hours: 6)),
      isRead: true,
      type: NotificationType.taskCompleted,
      workerName: 'Aicha Mint Salem',
    ),
    NotificationModel(
      id: '6',
      title: 'Paiement confirmé',
      description:
          'Votre paiement de 5000 MRU pour le service de peinture a été effectué avec succès via Bankily.',
      timestamp: DateTime.now().subtract(Duration(days: 1)),
      isRead: true,
      type: NotificationType.paymentConfirmed,
    ),
    NotificationModel(
      id: '7',
      title: 'Service annulé',
      description:
          'Hassan Ould Baba a dû annuler votre rendez-vous de réparation électrique prévu aujourd\'hui. Il vous contactera pour reprogrammer.',
      timestamp: DateTime.now().subtract(Duration(days: 1, hours: 5)),
      isRead: true,
      type: NotificationType.serviceCancelled,
      workerName: 'Hassan Ould Baba',
    ),
  ];
}

// Notification model
class NotificationModel {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;
  final String? workerName;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.isRead,
    required this.type,
    this.workerName,
  });
}

// Notification types for client - ONLY the 7 specified types
enum NotificationType {
  taskPublished, // نشر مهمة بنجاح
  workerRequested, // عامل طلب القيام بمهمتك
  taskCompleted, // إكمال المهمة
  paymentConfirmed, // تأكيد الدفع
  newMessage, // رسالة جديدة من عامل
  serviceReminder, // تذكير بموعد الخدمة
  serviceCancelled, // إلغاء أو تأجيل من العامل
}
