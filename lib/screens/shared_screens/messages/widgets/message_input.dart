// lib/screens/shared/messages/widgets/message_input.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/theme_colors.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSending;

  const MessageInput({
    Key? key,
    required this.controller,
    required this.onSend,
    this.isSending = false,
  }) : super(key: key);

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? ThemeColors.darkSurface : Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: widget.controller,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tapez votre message...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white54 : Colors.grey[500],
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        // Emoji picker functionality (optional)
                      },
                      icon: Icon(
                        Icons.emoji_emotions_outlined,
                        color: isDark ? Colors.white54 : Colors.grey[500],
                      ),
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty && !widget.isSending) {
                      widget.onSend();
                    }
                  },
                  enabled: !widget.isSending,
                ),
              ),
            ),
            SizedBox(width: 12),
            GestureDetector(
              onTap: widget.isSending
                  ? null
                  : () {
                      if (widget.controller.text.trim().isNotEmpty) {
                        widget.onSend();
                      }
                    },
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.isSending
                      ? Colors.grey
                      : (widget.controller.text.trim().isEmpty
                          ? Colors.grey
                          : ThemeColors.primaryColor),
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (!widget.isSending &&
                        widget.controller.text.trim().isNotEmpty)
                      BoxShadow(
                        color: ThemeColors.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                  ],
                ),
                child: widget.isSending
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
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
      ),
    );
  }
}
