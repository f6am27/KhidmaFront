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
              '4 NEW',
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
                  if (notification.clientName != null) ...[
                    SizedBox(height: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: ThemeColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        notification.clientName!,
                        style: TextStyle(
                          color: ThemeColors.primaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  if (notification.amount != null) ...[
                    SizedBox(height: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: ThemeColors.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '+${notification.amount} MRU',
                        style: TextStyle(
                          color: ThemeColors.successColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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
      case NotificationType.newTaskAvailable:
        return Colors.blue.withOpacity(0.1);
      case NotificationType.applicationAccepted:
        return Colors.green.withOpacity(0.1);
      case NotificationType.applicationRejected:
        return Colors.red.withOpacity(0.1);
      case NotificationType.paymentSent:
        return Colors.teal.withOpacity(0.1);
      case NotificationType.messageReceived:
        return Colors.orange.withOpacity(0.1);
      default:
        return ThemeColors.primaryColor.withOpacity(0.1);
    }
  }

  Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.newTaskAvailable:
        return Colors.blue;
      case NotificationType.applicationAccepted:
        return Colors.green;
      case NotificationType.applicationRejected:
        return Colors.red;
      case NotificationType.paymentSent:
        return Colors.teal;
      case NotificationType.messageReceived:
        return Colors.orange;
      default:
        return ThemeColors.primaryColor;
    }
  }

  IconData _getIconData(NotificationType type) {
    switch (type) {
      case NotificationType.newTaskAvailable:
        return Icons.work_outline;
      case NotificationType.applicationAccepted:
        return Icons.check_circle_outline;
      case NotificationType.applicationRejected:
        return Icons.cancel_outlined;
      case NotificationType.paymentSent:
        return Icons.account_balance_wallet;
      case NotificationType.messageReceived:
        return Icons.chat_bubble_outline;
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

  // Sample notifications data for worker - ONLY the 5 specified types
  static final List<NotificationModel> _notifications = [
    NotificationModel(
      id: '1',
      title: 'Nouvelle tâche disponible',
      description:
          'Une nouvelle tâche de "Réparation plomberie" est disponible près de chez vous à Ksar, Nouakchott.',
      timestamp: DateTime.now().subtract(Duration(minutes: 15)),
      isRead: false,
      type: NotificationType.newTaskAvailable,
      clientName: 'Ahmed Ould Salem',
    ),
    NotificationModel(
      id: '2',
      title: 'Candidature acceptée',
      description:
          'Félicitations! Fatima Al-Zahra a accepté votre candidature pour la tâche de nettoyage de maison.',
      timestamp: DateTime.now().subtract(Duration(minutes: 45)),
      isRead: false,
      type: NotificationType.applicationAccepted,
      clientName: 'Fatima Al-Zahra',
    ),
    NotificationModel(
      id: '3',
      title: 'Nouveau message reçu',
      description:
          'Mariem Mint Mohamed vous a envoyé un message concernant votre candidature pour le jardinage.',
      timestamp: DateTime.now().subtract(Duration(hours: 1, minutes: 20)),
      isRead: false,
      type: NotificationType.messageReceived,
      clientName: 'Mariem Mint Mohamed',
    ),
    NotificationModel(
      id: '4',
      title: 'Paiement envoyé',
      description:
          'Hassan Ba vous a envoyé un paiement de 3500 MRU pour le service de réparation électrique via Bankily.',
      timestamp: DateTime.now().subtract(Duration(hours: 3)),
      isRead: false,
      type: NotificationType.paymentSent,
      clientName: 'Hassan Ba',
      amount: 3500,
    ),
    NotificationModel(
      id: '5',
      title: 'Candidature rejetée',
      description:
          'Malheureusement, Omar Ba a choisi un autre prestataire pour la tâche de peinture. Ne vous découragez pas!',
      timestamp: DateTime.now().subtract(Duration(hours: 6)),
      isRead: true,
      type: NotificationType.applicationRejected,
      clientName: 'Omar Ba',
    ),
    NotificationModel(
      id: '6',
      title: 'Nouvelle tâche disponible',
      description:
          'Une tâche urgente de "Garde d\'enfants" est disponible ce soir à Sebkha. Candidatez rapidement!',
      timestamp: DateTime.now().subtract(Duration(days: 1)),
      isRead: true,
      type: NotificationType.newTaskAvailable,
      clientName: 'Aicha Mint Salem',
    ),
    NotificationModel(
      id: '7',
      title: 'Nouveau message reçu',
      description:
          'Vous avez reçu un message de Mohamed Ould Ahmed concernant les détails de la tâche de plomberie.',
      timestamp: DateTime.now().subtract(Duration(days: 1, hours: 5)),
      isRead: true,
      type: NotificationType.messageReceived,
      clientName: 'Mohamed Ould Ahmed',
    ),
    NotificationModel(
      id: '8',
      title: 'Candidature acceptée',
      description:
          'Super! Votre candidature pour la tâche de menuiserie a été acceptée. Le client vous contactera bientôt.',
      timestamp: DateTime.now().subtract(Duration(days: 2)),
      isRead: true,
      type: NotificationType.applicationAccepted,
      clientName: 'Khadija Mint Ali',
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
  final String? clientName;
  final int? amount;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.isRead,
    required this.type,
    this.clientName,
    this.amount,
  });
}

// Notification types for worker - ONLY the 5 specified types
enum NotificationType {
  newTaskAvailable, // Nouvelle tâche disponible
  applicationAccepted, // Candidature acceptée
  applicationRejected, // Candidature rejetée
  paymentSent, // Paiement envoyé
  messageReceived, // Message reçu
}
