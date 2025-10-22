// lib/screens/shared/messages/widgets/message_bubble.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final String? senderImageUrl;
  final String? currentUserImageUrl;

  const MessageBubble({
    Key? key,
    required this.message,
    this.senderImageUrl,
    this.currentUserImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment:
            message.isFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isFromMe) ...[
            _buildAvatar(senderImageUrl, isDark),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.timeAgo,
                        style: TextStyle(
                          color: message.isFromMe
                              ? Colors.white70
                              : (isDark ? Colors.white54 : Colors.grey[600]),
                          fontSize: 12,
                        ),
                      ),
                      if (message.isFromMe) ...[
                        SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color: message.isRead
                              ? Colors.blue[300]
                              : Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (message.isFromMe) ...[
            SizedBox(width: 8),
            _buildAvatar(currentUserImageUrl, isDark, isCurrentUser: true),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(String? imageUrl, bool isDark,
      {bool isCurrentUser = false}) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: isCurrentUser
          ? ThemeColors.primaryColor.withOpacity(0.1)
          : (isDark ? ThemeColors.darkSurface : Colors.grey[200]),
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
      child: imageUrl == null
          ? Icon(
              Icons.person,
              size: 16,
              color: isCurrentUser
                  ? ThemeColors.primaryColor
                  : (isDark ? Colors.white54 : Colors.grey[600]),
            )
          : null,
    );
  }
}
