import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/conversation_tile.dart';

/// Home screen — list of conversations.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Connect WebSocket on home screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().connect();
    });
  }

  void _startNewChat() {
    final phoneCtrl = TextEditingController();
    final nameCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.onSurfaceDim.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'New Conversation',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Contact Name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '10-digit number',
                  prefixIcon: Icon(Icons.phone_rounded),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final phone = phoneCtrl.text.trim();
                    final name = nameCtrl.text.trim();
                    if (phone.isEmpty) return;

                    context
                        .read<ChatProvider>()
                        .startConversation(phone, name.isNotEmpty ? name : phone);
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, AppRoutes.chat,
                        arguments: phone);
                  },
                  child: const Text('Start Chat'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messenger',
            style: GoogleFonts.outfit(
                fontSize: 22, fontWeight: FontWeight.bold)),
        actions: [
          // Connection indicator
          Consumer<ChatProvider>(
            builder: (_, chat, __) {
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  chat.isConnected ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                  color: chat.isConnected ? AppTheme.success : AppTheme.error,
                  size: 20,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (_, chatProvider, __) {
          final convs = chatProvider.conversations;

          if (convs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(Icons.chat_bubble_outline_rounded,
                        color: AppTheme.primary, size: 40),
                  ).animate().fadeIn(duration: 500.ms).scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1)),

                  const SizedBox(height: 20),

                  Text(
                    'No conversations yet',
                    style: GoogleFonts.outfit(
                      color: AppTheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 8),

                  Text(
                    'Tap + to start a new chat',
                    style: TextStyle(
                        color: AppTheme.onSurfaceDim, fontSize: 14),
                  ).animate().fadeIn(delay: 300.ms),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: convs.length,
            separatorBuilder: (_, __) => Divider(
              indent: 76,
              endIndent: 16,
              color: Colors.white.withValues(alpha: 0.06),
            ),
            itemBuilder: (_, i) {
              final conv = convs[i];
              return ConversationTile(
                conversation: conv,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.chat,
                  arguments: conv.otherUserPhone,
                ),
              ).animate().fadeIn(
                    delay: Duration(milliseconds: 50 * i),
                    duration: 300.ms,
                  );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewChat,
        child: const Icon(Icons.chat_rounded),
      ).animate().scale(
            begin: const Offset(0, 0),
            end: const Offset(1, 1),
            delay: 300.ms,
            duration: 400.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }
}
