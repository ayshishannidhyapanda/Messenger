import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/message_input.dart';
import '../../widgets/online_indicator.dart';

/// Individual chat screen.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scrollController = ScrollController();
  String? _otherPhone;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _otherPhone ??= ModalRoute.of(context)?.settings.arguments as String?;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_otherPhone == null) {
      return const Scaffold(
        body: Center(child: Text('No conversation selected')),
      );
    }

    return Consumer<ChatProvider>(
      builder: (_, chatProvider, __) {
        final conv = chatProvider.getConversation(_otherPhone!);
        final messages = conv.messages;

        // Scroll to bottom when new messages arrive
        _scrollToBottom();

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          AppTheme.primary.withValues(alpha: 0.2),
                      child: Text(
                        _initials(conv.otherUserName),
                        style: GoogleFonts.outfit(
                          color: AppTheme.primaryLight,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child:
                          OnlineIndicator(isOnline: conv.isOnline, size: 10),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conv.otherUserName,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        conv.isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          color: conv.isOnline
                              ? AppTheme.success
                              : AppTheme.onSurfaceDim,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              // ── Messages list ──
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_rounded,
                                color: AppTheme.onSurfaceDim.withValues(alpha: 0.3),
                                size: 40),
                            const SizedBox(height: 12),
                            Text(
                              'Start a conversation',
                              style: TextStyle(
                                color: AppTheme.onSurfaceDim,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 4),
                        itemCount: messages.length,
                        itemBuilder: (_, i) {
                          final msg = messages[i];
                          // Determine if sent by comparing sender to the
                          // "other" user's phone. If sender != otherPhone,
                          // it's a sent message.
                          final isSent = msg.sender != _otherPhone;
                          return ChatBubble(
                            message: msg,
                            isSent: isSent,
                          );
                        },
                      ),
              ),

              // ── Input bar ──
              MessageInput(
                onSend: (text) {
                  chatProvider.sendTextMessage(_otherPhone!, text);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
