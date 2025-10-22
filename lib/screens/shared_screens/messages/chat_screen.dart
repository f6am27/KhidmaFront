// lib/screens/shared/messages/chat_screen.dart

import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/theme/theme_colors.dart';
import '../../../services/chat_service.dart';
import '../../../services/report_service.dart';
import '../../../models/conversation_model.dart';
import '../../../models/message_model.dart';
import '../../../models/report_model.dart';

class ChatScreen extends StatefulWidget {
  final int conversationId;
  final String contactName;
  final int contactId;
  final bool isOnline;
  final String? profileImageUrl;

  const ChatScreen({
    Key? key,
    required this.conversationId,
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

  List<MessageModel> messages = [];
  bool isLoading = true;
  bool isSending = false;
  String? errorMessage;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _startPolling();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      _loadMessages(silent: true);
    });
  }

  Future<void> _loadMessages({bool silent = false}) async {
    if (!silent) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    final result = await chatService.getMessages(widget.conversationId);

    if (result['ok']) {
      setState(() {
        messages = result['messages'];
        messages = messages.reversed.toList();
        isLoading = false;
      });

      if (!silent) {
        _scrollToBottom();
      }
    } else {
      if (!silent) {
        setState(() {
          errorMessage = result['error'];
          isLoading = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || isSending) return;

    final content = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      isSending = true;
    });

    final result =
        await chatService.sendMessage(widget.conversationId, content);

    setState(() {
      isSending = false;
    });

    if (result['ok']) {
      await _loadMessages(silent: true);
      _scrollToBottom();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${result['error']}'),
          backgroundColor: Colors.red,
        ),
      );
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
    final reasons = ReportReasons.getAllReasons();

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
              ...reasons.map((reason) => _buildReportOption(
                    context,
                    isDark,
                    reason['label']!,
                    _getIconData(reason['icon']!),
                    reason['description']!,
                    reason['value']!,
                  )),
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

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'warning':
        return Icons.warning;
      case 'person_remove':
        return Icons.person_remove;
      case 'security':
        return Icons.security;
      case 'block':
        return Icons.block;
      case 'verified_user':
        return Icons.verified_user;
      case 'more_horiz':
        return Icons.more_horiz;
      default:
        return Icons.flag;
    }
  }

  Widget _buildReportOption(
    BuildContext context,
    bool isDark,
    String title,
    IconData icon,
    String description,
    String reasonValue,
  ) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        _submitReport(reasonValue);
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

  Future<void> _submitReport(String reason) async {
    final result = await reportService.quickReport(
      reportedUserId: widget.contactId,
      reason: reason,
      conversationId: widget.conversationId,
    );

    if (result['ok']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signalement envoyé avec succès'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${result['error']}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }
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
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? _buildErrorState(isDark)
                    : messages.isEmpty
                        ? _buildEmptyState(isDark)
                        : ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
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

  Widget _buildMessageBubble(MessageModel message, bool isDark) {
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
                  message.content,
                  style: TextStyle(
                    color: message.isFromMe
                        ? Colors.white
                        : (isDark ? Colors.white : Colors.black87),
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  message.timeAgo,
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
                    onPressed: () {},
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
            onTap: isSending ? null : _sendMessage,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSending ? Colors.grey : ThemeColors.primaryColor,
                shape: BoxShape.circle,
              ),
              child: isSending
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
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

  Widget _buildEmptyState(bool isDark) {
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
            'Aucun message',
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Commencez la conversation',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red,
          ),
          SizedBox(height: 20),
          Text(
            'Erreur de chargement',
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            errorMessage ?? 'Une erreur est survenue',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadMessages,
            child: Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}
