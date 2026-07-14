import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';

/// Message text field with send button.
class MessageInput extends StatefulWidget {
  final void Function(String text) onSend;

  const MessageInput({super.key, required this.onSend});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Text field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
                  maxLines: 4,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(
                      color: AppTheme.onSurfaceDim.withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 46,
              child: Material(
                color: _hasText ? AppTheme.primary : AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(23),
                child: InkWell(
                  onTap: _hasText ? _send : null,
                  borderRadius: BorderRadius.circular(23),
                  child: Icon(
                    Icons.send_rounded,
                    color: _hasText
                        ? Colors.white
                        : AppTheme.onSurfaceDim.withValues(alpha: 0.4),
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
