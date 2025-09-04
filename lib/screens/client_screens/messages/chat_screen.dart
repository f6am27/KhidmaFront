import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';

class ChatScreen extends StatefulWidget {
  final String contactName;
  final String contactId;
  final bool isOnline;
  final String? profileImageUrl;

  const ChatScreen({
    Key? key,
    required this.contactName,
    required this.contactId,
    this.isOnline = false,
    this.profileImageUrl,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> messages = [];

  @override
  void initState() {
    super.initState();
    _loadSampleMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadSampleMessages() {
    // Sample conversation messages
    messages = [
      ChatMessage(
        id: '1',
        text: 'Comment puis-je obtenir le code de réduction?',
        isFromMe: false,
        timestamp: DateTime.now().subtract(Duration(minutes: 10)),
        isDelivered: true,
      ),
      ChatMessage(
        id: '2',
        text: 'Avez-vous une carte de membre?',
        isFromMe: true,
        timestamp: DateTime.now().subtract(Duration(minutes: 9)),
        isDelivered: true,
      ),
      ChatMessage(
        id: '3',
        text: 'Si vous n\'en avez pas, veuillez vous inscrire',
        isFromMe: true,
        timestamp: DateTime.now().subtract(Duration(minutes: 9)),
        isDelivered: true,
      ),
      ChatMessage(
        id: '4',
        text: 'Parfait, merci pour les informations',
        isFromMe: false,
        timestamp: DateTime.now().subtract(Duration(minutes: 8)),
        isDelivered: true,
      ),
      ChatMessage(
        id: '5',
        text: 'À votre service! Y a-t-il autre chose?',
        isFromMe: true,
        timestamp: DateTime.now().subtract(Duration(minutes: 7)),
        isDelivered: true,
      ),
      ChatMessage(
        id: '6',
        text: 'Non, c\'est tout. Merci beaucoup!',
        isFromMe: false,
        timestamp: DateTime.now().subtract(Duration(minutes: 7)),
        isDelivered: true,
      ),
    ];
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: _messageController.text.trim(),
            isFromMe: true,
            timestamp: DateTime.now(),
            isDelivered: false,
          ),
        );
      });
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showReportDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? ThemeColors.darkSurface : Colors.white,
          title: Text(
            'Signaler l\'utilisateur',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choisissez la raison du signalement:',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[700],
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 16),
              _buildReportOption(
                  context,
                  isDark,
                  'Contenu inapproprié',
                  Icons.warning,
                  'Ce contenu ne respecte pas nos conditions d\'utilisation'),
              _buildReportOption(context, isDark, 'Harcèlement',
                  Icons.person_remove, 'Cette personne me harcèle ou intimide'),
              _buildReportOption(
                  context,
                  isDark,
                  'Arnaque/Fraude',
                  Icons.security,
                  'Je pense que c\'est une tentative d\'arnaque'),
              _buildReportOption(context, isDark, 'Spam', Icons.block,
                  'Messages répétitifs ou non sollicités'),
              _buildReportOption(
                  context, isDark, 'Autre', Icons.more_horiz, 'Autre problème'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Annuler',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReportOption(BuildContext context, bool isDark, String title,
      IconData icon, String description) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        _submitReport(title);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        margin: EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.red,
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white54 : Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _submitReport(String reason) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Signalement envoyé: $reason'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? ThemeColors.darkBackground : Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      isDark ? ThemeColors.darkSurface : Colors.grey[200],
                  backgroundImage: widget.profileImageUrl != null
                      ? NetworkImage(widget.profileImageUrl!)
                      : null,
                  child: widget.profileImageUrl == null
                      ? Icon(
                          Icons.person,
                          size: 20,
                          color: isDark ? Colors.white54 : Colors.grey[600],
                        )
                      : null,
                ),
                if (widget.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? ThemeColors.darkBackground
                              : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.contactName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  if (widget.isOnline)
                    Text(
                      'En ligne',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showReportDialog,
            icon: Icon(
              Icons.flag,
              color: Colors.red,
              size: 22,
            ),
            tooltip: 'Signaler',
          ),
          SizedBox(width: 8),
        ],
        elevation: 1,
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessageBubble(message, isDark);
              },
            ),
          ),

          // Message input area
          _buildMessageInput(isDark),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            message.isFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isFromMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor:
                  isDark ? ThemeColors.darkSurface : Colors.grey[200],
              backgroundImage: widget.profileImageUrl != null
                  ? NetworkImage(widget.profileImageUrl!)
                  : null,
              child: widget.profileImageUrl == null
                  ? Icon(
                      Icons.person,
                      size: 16,
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    )
                  : null,
            ),
            SizedBox(width: 8),
          ],
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: message.isFromMe
                  ? ThemeColors.primaryColor
                  : (isDark ? ThemeColors.darkSurface : Colors.grey[200]),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(message.isFromMe ? 20 : 4),
                bottomRight: Radius.circular(message.isFromMe ? 4 : 20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    color: message.isFromMe
                        ? Colors.white
                        : (isDark ? Colors.white : Colors.black87),
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    color: message.isFromMe
                        ? Colors.white70
                        : (isDark ? Colors.white54 : Colors.grey[600]),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (message.isFromMe) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: ThemeColors.primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 16,
                color: ThemeColors.primaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.darkBackground : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? ThemeColors.darkDivider : ThemeColors.lightDivider,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? ThemeColors.darkSurface : Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Tapez votre message...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey[500],
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      // Add emoji or attachment functionality
                    },
                    icon: Icon(
                      Icons.emoji_emotions_outlined,
                      color: isDark ? Colors.white54 : Colors.grey[500],
                    ),
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.newline,
                onSubmitted: (value) => _sendMessage(),
              ),
            ),
          ),
          SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ThemeColors.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

// Chat message model (simplified without read indicators)
class ChatMessage {
  final String id;
  final String text;
  final bool isFromMe;
  final DateTime timestamp;
  final bool isDelivered;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isFromMe,
    required this.timestamp,
    required this.isDelivered,
  });
}
