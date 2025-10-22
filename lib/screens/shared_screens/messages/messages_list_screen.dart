// lib/screens/shared/messages/messages_list_screen.dart

import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../services/chat_service.dart';
import '../../../models/conversation_model.dart';
import 'chat_screen.dart';

class MessagesListScreen extends StatefulWidget {
  @override
  _MessagesListScreenState createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends State<MessagesListScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<ConversationModel> allConversations = [];
  List<ConversationModel> filteredConversations = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await chatService.getConversations();

    if (result['ok']) {
      setState(() {
        allConversations = result['conversations'];
        filteredConversations = List.from(allConversations);
        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage = result['error'];
        isLoading = false;
      });
    }
  }

  void _filterConversations(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredConversations = List.from(allConversations);
      } else {
        filteredConversations = allConversations.where((conversation) {
          final name = conversation.otherParticipant.fullName.toLowerCase();
          final lastMsg = conversation.lastMessage?.content.toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();

          return name.contains(searchQuery) || lastMsg.contains(searchQuery);
        }).toList();
      }
    });
  }

  Future<void> _deleteConversation(ConversationModel conversation) async {
    final result = await chatService.deleteConversation(conversation.id);

    if (result['ok']) {
      setState(() {
        allConversations.removeWhere((c) => c.id == conversation.id);
        filteredConversations.removeWhere((c) => c.id == conversation.id);
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${result['error']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteAllConversations() async {
    // حذف كل المحادثات واحدة تلو الأخرى
    for (var conversation in List.from(allConversations)) {
      await chatService.deleteConversation(conversation.id);
    }

    setState(() {
      allConversations.clear();
      filteredConversations.clear();
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              if (filteredConversations.isNotEmpty) {
                _showDeleteAllDialog();
              }
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
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? _buildErrorState(context, isDark)
                    : filteredConversations.isEmpty
                        ? _buildEmptyState(context, isDark)
                        : RefreshIndicator(
                            onRefresh: _loadConversations,
                            child: ListView.separated(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              itemCount: filteredConversations.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                thickness: 1,
                                indent: 80,
                                color: isDark
                                    ? ThemeColors.darkDivider
                                    : ThemeColors.lightDivider,
                              ),
                              itemBuilder: (context, index) {
                                final conversation =
                                    filteredConversations[index];
                                return _buildConversationItem(
                                    context, conversation, isDark);
                              },
                            ),
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
        onChanged: _filterConversations,
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
                    _filterConversations('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildConversationItem(
      BuildContext context, ConversationModel conversation, bool isDark) {
    return InkWell(
      onTap: () => _openChat(context, conversation),
      onLongPress: () => _showDeleteDialog(conversation),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // Profile picture
            _buildProfilePicture(conversation, isDark),
            SizedBox(width: 16),

            // Conversation content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conversation.otherParticipant.fullName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        conversation.timeAgo,
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
                          conversation.lastMessage?.content ?? 'Aucun message',
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
                      if (conversation.unreadCount > 0) ...[
                        SizedBox(width: 8),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: ThemeColors.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${conversation.unreadCount}',
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

  Widget _buildProfilePicture(ConversationModel conversation, bool isDark) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: isDark ? ThemeColors.darkSurface : Colors.grey[200],
          backgroundImage: conversation.otherParticipant.profileImageUrl != null
              ? NetworkImage(conversation.otherParticipant.profileImageUrl!)
              : null,
          child: conversation.otherParticipant.profileImageUrl == null
              ? Icon(
                  Icons.person,
                  size: 32,
                  color: isDark ? Colors.white54 : Colors.grey[600],
                )
              : null,
        ),
        if (conversation.otherParticipant.isOnline)
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

  Widget _buildErrorState(BuildContext context, bool isDark) {
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
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
          ),
          SizedBox(height: 8),
          Text(
            errorMessage ?? 'Une erreur est survenue',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white54 : Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadConversations,
            child: Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  void _openChat(BuildContext context, ConversationModel conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          conversationId: conversation.id,
          contactName: conversation.otherParticipant.fullName,
          contactId: conversation.otherParticipant.id ?? 0,
          isOnline: conversation.otherParticipant.isOnline,
          profileImageUrl: conversation.otherParticipant.profileImageUrl,
        ),
      ),
    ).then((_) {
      // إعادة تحميل المحادثات عند العودة
      _loadConversations();
    });
  }

  void _showDeleteDialog(ConversationModel conversation) {
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
          'Voulez-vous supprimer la conversation avec ${conversation.otherParticipant.fullName}?',
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
              _deleteConversation(conversation);
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
              _deleteAllConversations();
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
}
