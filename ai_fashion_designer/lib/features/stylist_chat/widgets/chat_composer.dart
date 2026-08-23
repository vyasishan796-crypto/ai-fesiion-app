import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../core/theme/app_colors.dart';

class ChatComposer extends StatefulWidget {
  final Function(String) onSend;
  final bool isLoading;

  const ChatComposer({
    super.key,
    required this.onSend,
    this.isLoading = false,
  });

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final TextEditingController _controller = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _hasText = false;
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _controller.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
      },
    );
  }

  Future<void> _toggleVoice() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      if (!_speechAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Microphone permission denied. Please enable it in Settings.',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: AppColors.charcoal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
            _hasText = result.recognizedWords.trim().isNotEmpty;
          });
          if (result.finalResult) {
            setState(() => _isListening = false);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        localeId: 'en_US',
      );
    }
  }

  void _send() {
    if (_controller.text.trim().isEmpty) return;
    HapticFeedback.lightImpact();
    widget.onSend(_controller.text.trim());
    _controller.clear();
    setState(() => _hasText = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(color: AppColors.charcoal.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isListening)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Listening... Speak now',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await _speech.stop();
                        setState(() => _isListening = false);
                      },
                      child: Icon(Icons.close, size: 18, color: AppColors.error),
                    ),
                  ],
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: _toggleVoice,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _isListening ? AppColors.error : AppColors.lightGrey,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening ? AppColors.white : AppColors.inkMuted,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                      onChanged: (val) => setState(() => _hasText = val.trim().isNotEmpty),
                      style: GoogleFonts.inter(fontSize: 15, color: AppColors.ink),
                      decoration: InputDecoration(
                        hintText: _isListening ? 'Listening...' : 'Ask AI Stylist anything...',
                        hintStyle: GoogleFonts.inter(fontSize: 15, color: AppColors.inkMuted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _hasText && !widget.isLoading ? _send : null,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: _hasText ? AppColors.primaryGradient : null,
                      color: _hasText ? null : AppColors.mediumGrey,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.send,
                      color: _hasText ? AppColors.white : AppColors.inkMuted,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
