import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import 'worker_chat_screen.dart';

class WorkerMessagesScreen extends StatefulWidget {
  @override
  _WorkerMessagesScreenState createState() => _WorkerMessagesScreenState();
}

class _WorkerMessagesScreenState extends State<WorkerMessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<WorkerMessageModel> filteredMessages = [];

  @override
  void initState() {
    super.initState();
    filteredMessages = List.from(_sampleMessages);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterMessages(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredMessages = List.from(_sampleMessages);
      } else {
        filteredMessages = _sampleMessages
            .where((message) =>
                message.clientName
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                message.lastMessage.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Messages',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              _showDeleteAllDialog();
            },
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            ),
            tooltip: 'Supprimer',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(),

          // Messages list
          Expanded(
            child: filteredMessages.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredMessages.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      thickness: 1,
                      indent: 80,
                      color: AppColors.lightGray,
                    ),
                    itemBuilder: (context, index) {
                      final message = filteredMessages[index];
                      return _buildMessageItem(message);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightGray.withOpacity(0.5),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterMessages,
        style: TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Rechercher des conversations...',
          hintStyle: TextStyle(color: AppColors.textSecondary),
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    _filterMessages('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildMessageItem(WorkerMessageModel message) {
    return InkWell(
      onTap: () => _openChat(message),
      onLongPress: () => _showDeleteDialog(message),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // Profile picture
            _buildProfilePicture(message),
            SizedBox(width: 16),

            // Message content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          message.clientName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatMessageTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message.lastMessage,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (message.unreadCount > 0) ...[
                        SizedBox(width: 8),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${message.unreadCount}',
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicture(WorkerMessageModel message) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.lightGray,
          backgroundImage: message.profileImageUrl != null
              ? NetworkImage(message.profileImageUrl!)
              : null,
          child: message.profileImageUrl == null
              ? Icon(
                  Icons.person,
                  size: 32,
                  color: AppColors.textSecondary,
                )
              : null,
        ),
        if (message.isOnline)
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.background,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: AppColors.mediumGray,
          ),
          SizedBox(height: 20),
          Text(
            'Aucun message trouvé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Vos conversations avec les clients apparaîtront ici',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'maintenant';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'hier';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  void _openChat(WorkerMessageModel message) {
    // تحديث عدد الرسائل غير المقروءة فقط
    setState(() {
      final originalIndex =
          _sampleMessages.indexWhere((m) => m.id == message.id);
      final filteredIndex =
          filteredMessages.indexWhere((m) => m.id == message.id);

      if (originalIndex != -1) {
        _sampleMessages[originalIndex] = WorkerMessageModel(
          id: message.id,
          clientName: message.clientName,
          lastMessage: message.lastMessage,
          timestamp: message.timestamp,
          isRead: message.isRead,
          isFromMe: message.isFromMe,
          unreadCount: 0, // إزالة عدد الرسائل غير المقروءة
          isOnline: message.isOnline,
          profileImageUrl: message.profileImageUrl,
          isDelivered: message.isDelivered,
        );
      }

      if (filteredIndex != -1) {
        filteredMessages[filteredIndex] = _sampleMessages[originalIndex];
      }
    });

    // الانتقال إلى شاشة المحادثة
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkerChatScreen(
          clientName: message.clientName,
          clientId: message.id,
          isOnline: message.isOnline,
          profileImageUrl: message.profileImageUrl,
        ),
      ),
    );
  }

  void _showDeleteDialog(WorkerMessageModel message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Supprimer la conversation',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Voulez-vous supprimer la conversation avec ${message.clientName}?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Annuler',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteMessage(message);
            },
            child: Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Supprimer tout',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Voulez-vous supprimer toutes les conversations?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Annuler',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteAllMessages();
            },
            child: Text(
              'Supprimer tout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteMessage(WorkerMessageModel message) {
    setState(() {
      filteredMessages.removeWhere((m) => m.id == message.id);
      _sampleMessages.removeWhere((m) => m.id == message.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Conversation supprimée'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _deleteAllMessages() {
    setState(() {
      filteredMessages.clear();
      _sampleMessages.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Toutes les conversations ont été supprimées'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Sample messages data - من منظور العامل مع العملاء
  static List<WorkerMessageModel> _sampleMessages = [
    WorkerMessageModel(
      id: '1',
      clientName: 'Mme. Aicha Mint Ahmed',
      lastMessage: 'Merci beaucoup! Le nettoyage était parfait.',
      timestamp: DateTime.now().subtract(Duration(minutes: 5)),
      isRead: false,
      isFromMe: false,
      unreadCount: 2,
      isOnline: true,
      profileImageUrl: null,
      isDelivered: true,
    ),
    WorkerMessageModel(
      id: '2',
      clientName: 'M. Mohamed Vall',
      lastMessage: 'Pouvez-vous venir demain à 14h pour la plomberie?',
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
      isRead: false,
      isFromMe: false,
      unreadCount: 1,
      isOnline: false,
      profileImageUrl: null,
      isDelivered: true,
    ),
    WorkerMessageModel(
      id: '3',
      clientName: 'Mme. Fatimetou Mint Sid Ahmed',
      lastMessage: 'D\'accord, je vous attends à 9h.',
      timestamp: DateTime.now().subtract(Duration(hours: 4)),
      isRead: true,
      isFromMe: true,
      unreadCount: 0,
      isOnline: true,
      profileImageUrl: null,
      isDelivered: true,
    ),
    WorkerMessageModel(
      id: '4',
      clientName: 'M. Abdellahi Ould Cheikh',
      lastMessage: 'Excellent travail d\'électricité! Je recommande.',
      timestamp: DateTime.now().subtract(Duration(days: 1)),
      isRead: true,
      isFromMe: false,
      unreadCount: 0,
      isOnline: false,
      profileImageUrl: null,
      isDelivered: true,
    ),
    WorkerMessageModel(
      id: '5',
      clientName: 'Mme. Mariem Mint Brahim',
      lastMessage: 'Service rapide et professionnel. Merci!',
      timestamp: DateTime.now().subtract(Duration(days: 2)),
      isRead: true,
      isFromMe: false,
      unreadCount: 0,
      isOnline: true,
      profileImageUrl: null,
      isDelivered: true,
    ),
    WorkerMessageModel(
      id: '6',
      clientName: 'M. Sidi Mohamed Ould Ahmed',
      lastMessage: 'Je ferai appel à vos services à nouveau.',
      timestamp: DateTime.now().subtract(Duration(days: 3)),
      isRead: true,
      isFromMe: false,
      unreadCount: 0,
      isOnline: false,
      profileImageUrl: null,
      isDelivered: true,
    ),
  ];
}

// Message model for worker
class WorkerMessageModel {
  final String id;
  final String clientName;
  final String lastMessage;
  final DateTime timestamp;
  final bool isRead;
  final bool isFromMe;
  final int unreadCount;
  final bool isOnline;
  final String? profileImageUrl;
  final bool isDelivered;

  WorkerMessageModel({
    required this.id,
    required this.clientName,
    required this.lastMessage,
    required this.timestamp,
    required this.isRead,
    required this.isFromMe,
    required this.unreadCount,
    required this.isOnline,
    this.profileImageUrl,
    required this.isDelivered,
  });
}
