// lib/screens/shared_screens/notifications/widgets/empty_notifications.dart
import 'package:flutter/material.dart';

class EmptyNotifications extends StatelessWidget {
  final String filterText;
  final VoidCallback onRefresh;

  const EmptyNotifications({
    Key? key,
    required this.filterText,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Aucune notification',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          SizedBox(height: 8),
          Text(
            filterText == 'Tous'
                ? 'Vous n\'avez pas encore de notifications'
                : 'Aucune notification $filterText',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRefresh,
            icon: Icon(Icons.refresh),
            label: Text('Actualiser'),
          ),
        ],
      ),
    );
  }
}
