import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatPrompt extends StatefulWidget {
  final TextEditingController controller;
  final String currentPrompt;
  final List<dynamic> messages;
  final VoidCallback onSend;
  final bool isLoading;
  final bool enabled;

  const ChatPrompt({
    super.key,
    required this.controller,
    required this.currentPrompt,
    required this.messages,
    required this.onSend,
    required this.isLoading,
    required this.enabled,
  });

  @override
  State<ChatPrompt> createState() => _ChatPromptState();
}

class _ChatPromptState extends State<ChatPrompt> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(() {
      if (mounted) setState(() => _hasText = widget.controller.text.isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.messages.isNotEmpty) ...[
            Text(
              'CONVERSATION',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: const Color(0xFF1D1D1F),
              ),
            ),
            const SizedBox(height: 12),
            ...widget.messages.map((msg) {
              final isUser = msg is _ChatMessage ? msg.isUser : false;
              final text = msg is _ChatMessage ? msg.text : msg.toString();
              return _MessageBubble(text: text, isUser: isUser);
            }),
            const SizedBox(height: 16),
          ],
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.enabled ? const Color(0xFF1D1D1F) : const Color(0xFFE0E0E0),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    enabled: widget.enabled && !widget.isLoading,
                    maxLines: 3,
                    minLines: 1,
                    style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF1D1D1F)),
                    decoration: InputDecoration(
                      hintText: widget.enabled
                          ? 'Describe your look...'
                          : 'Upload a photo first',
                      hintStyle: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF8E8E93)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      prefixIcon: Icon(
                        Icons.chat_outlined,
                        color: widget.enabled ? const Color(0xFF1D1D1F) : const Color(0xFF8E8E93),
                        size: 22,
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    ),
                  ),
                ),
                if (_hasText && widget.enabled && !widget.isLoading)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _SendButton(
                      onPressed: widget.onSend,
                      isLoading: widget.isLoading,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const _SendButton({required this.onPressed, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isLoading
          ? Container(
              key: const ValueKey('loading'),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1D1D1F).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1D1D1F)),
                ),
              ),
            )
          : IconButton(
              key: const ValueKey('send'),
              icon: const Icon(Icons.send_rounded, size: 22),
              color: const Color(0xFF1D1D1F),
              onPressed: onPressed,
            ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  _ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const _MessageBubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF1D1D1F) : const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: isUser ? Colors.white : const Color(0xFF1D1D1F),
            height: 1.4,
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
    );
  }
}
