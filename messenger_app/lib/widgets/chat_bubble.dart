import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../models/chat_message.dart';

/// WhatsApp-style chat bubble.
class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isSent;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isSent,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.only(
          left: isSent ? 60 : 12,
          right: isSent ? 12 : 60,
          top: 4,
          bottom: 4,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSent ? AppTheme.sentBubble : AppTheme.receivedBubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isSent ? 16 : 4),
            bottomRight: Radius.circular(isSent ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Message text
            Text(
              message.message ?? '',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14.5,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 4),

            // Timestamp + read status
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
                if (isSent) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead
                        ? Icons.done_all_rounded
                        : message.isReceived
                            ? Icons.done_all_rounded
                            : Icons.done_rounded,
                    size: 14,
                    color: message.isRead
                        ? AppTheme.accent
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
