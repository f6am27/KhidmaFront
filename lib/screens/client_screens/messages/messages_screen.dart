import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';
import 'chat_screen.dart'; // إضافة استيراد شاشة المحادثة

class MessagesScreen extends StatefulWidget {
  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<MessageModel> filteredMessages = [];

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
                message.senderName
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                message.lastMessage.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
        centerTitle: true,
        automaticallyImplyLeading: false, // إزالة زر الرجوع لأنها صفحة رئيسية
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
          _buildSearchBar(context, isDark),

          // Messages list
          Expanded(
            child: filteredMessages.isEmpty
                ? _buildEmptyState(context, isDark)
                : ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredMessages.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      thickness: 1,
                      indent: 80,
                      color: isDark
                          ? ThemeColors.darkDivider
                          : ThemeColors.lightDivider,
                    ),
                    itemBuilder: (context, index) {
                      final message = filteredMessages[index];
                      return _buildMessageItem(context, message, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.darkSurface : Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterMessages,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Rechercher des conversations...',
          hintStyle: TextStyle(
            color: isDark ? Colors.white54 : Colors.grey[500],
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? Colors.white54 : Colors.grey[500],
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: isDark ? Colors.white54 : Colors.grey[500],
                  ),
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

  Widget _buildMessageItem(
      BuildContext context, MessageModel message, bool isDark) {
    return InkWell(
      onTap: () => _openChat(context, message),
      onLongPress: () => _showDeleteDialog(message),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // Profile picture
            _buildProfilePicture(message, isDark),
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
                          message.senderName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatMessageTime(message.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.white54 : Colors.grey[600],
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
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color:
                                    isDark ? Colors.white70 : Colors.grey[700],
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
                            color: ThemeColors.primaryColor,
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

  Widget _buildProfilePicture(MessageModel message, bool isDark) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: isDark ? ThemeColors.darkSurface : Colors.grey[200],
          backgroundImage: message.profileImageUrl != null
              ? NetworkImage(message.profileImageUrl!)
              : null,
          child: message.profileImageUrl == null
              ? Icon(
                  Icons.person,
                  size: 32,
                  color: isDark ? Colors.white54 : Colors.grey[600],
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
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? ThemeColors.darkBackground : Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: isDark ? Colors.white38 : Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            'Aucun message trouvé',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
          ),
          SizedBox(height: 8),
          Text(
            'Commencez une nouvelle conversation',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white54 : Colors.grey[500],
                ),
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

  void _openChat(BuildContext context, MessageModel message) {
    // تحديث عدد الرسائل غير المقروءة فقط
    setState(() {
      final originalIndex =
          _sampleMessages.indexWhere((m) => m.id == message.id);
      final filteredIndex =
          filteredMessages.indexWhere((m) => m.id == message.id);

      if (originalIndex != -1) {
        _sampleMessages[originalIndex] = MessageModel(
          id: message.id,
          senderName: message.senderName,
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
        builder: (context) => ChatScreen(
          contactName: message.senderName,
          contactId: message.id,
          isOnline: message.isOnline,
          profileImageUrl: message.profileImageUrl,
        ),
      ),
    );
  }

  void _showDeleteDialog(MessageModel message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? ThemeColors.darkSurface : Colors.white,
        title: Text(
          'Supprimer la conversation',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'Voulez-vous supprimer la conversation avec ${message.senderName}?',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Annuler',
              style: TextStyle(color: Colors.grey[600]),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? ThemeColors.darkSurface : Colors.white,
        title: Text(
          'Supprimer tout',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'Voulez-vous supprimer toutes les conversations?',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Annuler',
              style: TextStyle(color: Colors.grey[600]),
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

  void _deleteMessage(MessageModel message) {
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

  // Sample messages data
  static List<MessageModel> _sampleMessages = [
    MessageModel(
      id: '1',
      senderName: 'Pierre Martin',
      lastMessage:
          'Merci pour le service de plomberie, tout fonctionne parfaitement!',
      timestamp: DateTime.now().subtract(Duration(minutes: 5)),
      isRead: false,
      isFromMe: false,
      unreadCount: 2,
      isOnline: true,
      profileImageUrl: null,
      isDelivered: true,
    ),
    MessageModel(
      id: '2',
      senderName: 'Marie Dubois',
      lastMessage: 'À quelle heure pouvez-vous venir demain pour le nettoyage?',
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
      isRead: false,
      isFromMe: false,
      unreadCount: 1,
      isOnline: false,
      profileImageUrl: null,
      isDelivered: true,
    ),
    MessageModel(
      id: '3',
      senderName: 'Ahmed Hassan',
      lastMessage: 'Parfait, je serai là à 14h comme convenu.',
      timestamp: DateTime.now().subtract(Duration(hours: 4)),
      isRead: true,
      isFromMe: true,
      unreadCount: 0,
      isOnline: true,
      profileImageUrl: null,
      isDelivered: true,
    ),
    MessageModel(
      id: '4',
      senderName: 'Sophie Leroy',
      lastMessage: 'Le travail d\'électricité est terminé. Tout est en ordre.',
      timestamp: DateTime.now().subtract(Duration(days: 1)),
      isRead: true,
      isFromMe: false,
      unreadCount: 0,
      isOnline: false,
      profileImageUrl: null,
      isDelivered: true,
    ),
    MessageModel(
      id: '5',
      senderName: 'Thomas Bernard',
      lastMessage: 'Merci pour votre rapidité! Service impeccable.',
      timestamp: DateTime.now().subtract(Duration(days: 2)),
      isRead: true,
      isFromMe: false,
      unreadCount: 0,
      isOnline: true,
      profileImageUrl: null,
      isDelivered: true,
    ),
    MessageModel(
      id: '6',
      senderName: 'Fatima Al-Zahra',
      lastMessage: 'Je recommande vivement vos services à mes amis.',
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

// Message model
class MessageModel {
  final String id;
  final String senderName;
  final String lastMessage;
  final DateTime timestamp;
  final bool isRead;
  final bool isFromMe;
  final int unreadCount;
  final bool isOnline;
  final String? profileImageUrl;
  final bool isDelivered;

  MessageModel({
    required this.id,
    required this.senderName,
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
