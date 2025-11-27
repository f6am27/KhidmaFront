import 'package:flutter/material.dart';
import '../../../constants/colors.dart';

class WorkerChatScreen extends StatefulWidget {
  final String clientName;
  final String clientId;
  final bool isOnline;
  final String? profileImageUrl;

  const WorkerChatScreen({
    Key? key,
    required this.clientName,
    required this.clientId,
    this.isOnline = false,
    this.profileImageUrl,
  }) : super(key: key);

  @override
  _WorkerChatScreenState createState() => _WorkerChatScreenState();
}

class _WorkerChatScreenState extends State<WorkerChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<WorkerChatMessage> messages = [];

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
    // Sample conversation messages from worker perspective
    messages = [
      WorkerChatMessage(
        id: '1',
        text:
            'Bonjour, j\'ai vu votre demande de nettoyage. Je suis disponible demain matin.',
        isFromMe: true,
        timestamp: DateTime.now().subtract(Duration(minutes: 15)),
        isDelivered: true,
      ),
      WorkerChatMessage(
        id: '2',
        text: 'Parfait! À quelle heure pouvez-vous venir?',
        isFromMe: false,
        timestamp: DateTime.now().subtract(Duration(minutes: 14)),
        isDelivered: true,
      ),
      WorkerChatMessage(
        id: '3',
        text: 'Je peux être là vers 9h du matin, cela vous convient?',
        isFromMe: true,
        timestamp: DateTime.now().subtract(Duration(minutes: 13)),
        isDelivered: true,
      ),
      WorkerChatMessage(
        id: '4',
        text: 'Oui, c\'est parfait. L\'adresse est Tevragh Zeina, quartier 3.',
        isFromMe: false,
        timestamp: DateTime.now().subtract(Duration(minutes: 12)),
        isDelivered: true,
      ),
      WorkerChatMessage(
        id: '5',
        text:
            'Très bien, j\'apporterai tous les produits nécessaires. À demain!',
        isFromMe: true,
        timestamp: DateTime.now().subtract(Duration(minutes: 10)),
        isDelivered: true,
      ),
      WorkerChatMessage(
        id: '6',
        text: 'Merci beaucoup! À demain.',
        isFromMe: false,
        timestamp: DateTime.now().subtract(Duration(minutes: 9)),
        isDelivered: true,
      ),
    ];
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        messages.add(
          WorkerChatMessage(
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: Text(
            'Signaler le client',
            style: TextStyle(
              color: AppColors.textPrimary,
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
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 16),
              _buildReportOption('Contenu inapproprié', Icons.warning,
                  'Ce contenu ne respecte pas nos conditions d\'utilisation'),
              _buildReportOption('Harcèlement', Icons.person_remove,
                  'Cette personne me harcèle ou intimide'),
              _buildReportOption('Non-paiement', Icons.money_off,
                  'Le client refuse de payer pour les services'),
              _buildReportOption('Demandes inappropriées', Icons.block,
                  'Demandes non liées au service convenu'),
              _buildReportOption('Autre', Icons.more_horiz, 'Autre problème'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Annuler',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReportOption(String title, IconData icon, String description) {
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
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
          ),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.lightGray,
                  backgroundImage: widget.profileImageUrl != null
                      ? NetworkImage(widget.profileImageUrl!)
                      : null,
                  child: widget.profileImageUrl == null
                      ? Icon(
                          Icons.person,
                          size: 20,
                          color: AppColors.textSecondary,
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
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.clientName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (widget.isOnline)
                    Text(
                      'En ligne',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.green,
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
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Message input area
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(WorkerChatMessage message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            message.isFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isFromMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.lightGray,
              backgroundImage: widget.profileImageUrl != null
                  ? NetworkImage(widget.profileImageUrl!)
                  : null,
              child: widget.profileImageUrl == null
                  ? Icon(
                      Icons.person,
                      size: 16,
                      color: AppColors.textSecondary,
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
                  ? AppColors.primaryPurple
                  : AppColors.lightGray,
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
                    color:
                        message.isFromMe ? Colors.white : AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    color: message.isFromMe
                        ? Colors.white70
                        : AppColors.textSecondary,
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
              backgroundColor: AppColors.primaryPurple.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 16,
                color: AppColors.primaryPurple,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          top: BorderSide(
            color: AppColors.lightGray,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.lightGray.withOpacity(0.5),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Tapez votre message...',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
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
                      color: AppColors.textSecondary,
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
                color: AppColors.primaryPurple,
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

// Chat message model for worker
class WorkerChatMessage {
  final String id;
  final String text;
  final bool isFromMe;
  final DateTime timestamp;
  final bool isDelivered;

  WorkerChatMessage({
    required this.id,
    required this.text,
    required this.isFromMe,
    required this.timestamp,
    required this.isDelivered,
  });
}
