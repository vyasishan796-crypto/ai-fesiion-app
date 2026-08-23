import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import 'package:ai_fashion_designer/features/stylist_chat/models/chat_message.dart';
import 'package:ai_fashion_designer/features/stylist_chat/services/advanced_stylist_service.dart';
import 'package:ai_fashion_designer/features/stylist_chat/widgets/ai_thinking_indicator.dart';
import 'package:ai_fashion_designer/features/stylist_chat/widgets/chat_composer.dart';
import 'package:ai_fashion_designer/features/stylist_chat/widgets/outfit_recommendation_card.dart';
import 'package:ai_fashion_designer/features/stylist_chat/widgets/product_recommendation_card.dart';
import 'package:ai_fashion_designer/features/stylist_chat/widgets/quick_action_chips.dart';

class StylistChatScreen extends StatefulWidget {
  const StylistChatScreen({super.key});

  @override
  State<StylistChatScreen> createState() => _StylistChatScreenState();
}

class _StylistChatScreenState extends State<StylistChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AdvancedStylistService _aiService = AdvancedStylistService();
  final List<ChatMessage> _messages = [];
  bool _isThinking = false;
  String _context = 'general';

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      id: 'welcome',
      sender: Sender.ai,
      timestamp: DateTime.now(),
      type: MessageType.text,
      text: 'Hey! I\'m StyleAI — your AI fashion stylist. I can create outfits, suggest products, advise on colors, and more. What can I help you with?',
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(ChatMessage.text(text, Sender.user));
      _isThinking = true;
    });
    _scrollToBottom();
    _detectContext(text);
    _getAIResponse(text);
  }

  void _detectContext(String msg) {
    final lower = msg.toLowerCase();
    if (RegExp(r'(find|shop|buy|price|cheap|under|budget|product|deal)').hasMatch(lower)) {
      _context = 'shopping';
    } else if (RegExp(r'(outfit|look|wear|dress|create|generate|style|combine)').hasMatch(lower)) {
      _context = 'outfit';
    } else if (RegExp(r'(color|colour|match|pair|complement|shade|tone)').hasMatch(lower)) {
      _context = 'color';
    } else if (RegExp(r'(tip|advice|suggest|help|how|trend|best)').hasMatch(lower)) {
      _context = 'tips';
    } else {
      _context = 'general';
    }
  }

  void _getAIResponse(String text) async {
    try {
      final response = await _aiService.getResponse(text);
      if (mounted) {
        setState(() {
          _messages.add(response);
          _isThinking = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage.error('Sorry, something went wrong. Please try again.'));
          _isThinking = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  List<QuickAction> _getQuickActions() {
    switch (_context) {
      case 'shopping':
        return [
          QuickAction(label: 'Under ₹1000', icon: Icons.attach_money, onTap: () => _sendMessage('Show me products under ₹1000')),
          QuickAction(label: 'Best Deals', icon: Icons.local_offer, onTap: () => _sendMessage('What are the best fashion deals right now?')),
          QuickAction(label: 'My Size', icon: Icons.straighten, onTap: () => _sendMessage('What is my recommended size?')),
          QuickAction(label: 'Compare Prices', icon: Icons.compare_arrows, onTap: () => _sendMessage('Compare prices across platforms')),
        ];
      case 'outfit':
        return [
          QuickAction(label: 'College', icon: Icons.school, onTap: () => _sendMessage('Create a college outfit')),
          QuickAction(label: 'Office', icon: Icons.work, onTap: () => _sendMessage('Suggest a formal office outfit')),
          QuickAction(label: 'Party', icon: Icons.celebration, onTap: () => _sendMessage('Create a party outfit')),
          QuickAction(label: 'Date', icon: Icons.favorite, onTap: () => _sendMessage('What should I wear on a date?')),
        ];
      case 'color':
        return [
          QuickAction(label: 'Skin Match', icon: Icons.face, onTap: () => _sendMessage('What colors suit my skin tone?')),
          QuickAction(label: 'Neutral Palette', icon: Icons.palette, onTap: () => _sendMessage('Suggest a neutral color palette')),
          QuickAction(label: 'Bold Colors', icon: Icons.brush, onTap: () => _sendMessage('Suggest bold color combinations')),
          QuickAction(label: 'Monochrome', icon: Icons.gradient, onTap: () => _sendMessage('Monochrome outfit ideas')),
        ];
      case 'tips':
        return [
          QuickAction(label: 'Summer Tips', icon: Icons.wb_sunny, onTap: () => _sendMessage('Summer styling tips for India')),
          QuickAction(label: 'Fit Guide', icon: Icons.accessibility_new, onTap: () => _sendMessage('How should clothes fit properly?')),
          QuickAction(label: 'Wardrobe', icon: Icons.checkroom, onTap: () => _sendMessage('Essential wardrobe basics')),
          QuickAction(label: 'Trends', icon: Icons.trending_up, onTap: () => _sendMessage('What are the current fashion trends?')),
        ];
      default:
        return [
          QuickAction(label: 'Create Outfit', icon: Icons.auto_awesome, onTap: () => _sendMessage('Create a casual outfit for me')),
          QuickAction(label: 'Find Products', icon: Icons.search, onTap: () => _sendMessage('Find trending products')),
          QuickAction(label: 'Style Tips', icon: Icons.lightbulb_outline, onTap: () => _sendMessage('Give me 3 quick style tips')),
          QuickAction(label: 'Color Match', icon: Icons.palette, onTap: () => _sendMessage('Suggest colors that go together')),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.charcoal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.white),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'AI Stylist',
                  style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.white),
                ),
              ],
            ),
            Text(
              'Powered by Gemini AI',
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withOpacity(0.5)),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(ChatMessage(
                  id: 'welcome',
                  sender: Sender.ai,
                  timestamp: DateTime.now(),
                  type: MessageType.text,
                  text: 'Chat cleared! How can I help you?',
                ));
                _aiService.clearHistory();
              });
            },
            icon: const Icon(Icons.refresh, color: AppColors.white, size: 22),
            tooltip: 'Clear chat',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _messages.length + (_isThinking ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: AIThinkingIndicator(),
                  );
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          QuickActionChips(actions: _getQuickActions()),
          const SizedBox(height: 8),
          ChatComposer(
            onSend: _sendMessage,
            isLoading: _isThinking,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    if (msg.sender == Sender.user) {
      return _buildUserBubble(msg);
    }
    return _buildAIBubble(msg);
  }

  Widget _buildUserBubble(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(60, 4, 16, 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(18).copyWith(bottomRight: Radius.circular(4)),
          ),
          child: Text(
            msg.text ?? '',
            style: GoogleFonts.inter(fontSize: 15, color: AppColors.white, height: 1.4),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildAIBubble(ChatMessage msg) {
    if (msg.type == MessageType.outfit && msg.outfitData != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 60, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg.text != null) _buildAIText(msg.text!),
            const SizedBox(height: 8),
            OutfitRecommendationCard(outfit: msg.outfitData!),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.05, end: 0);
    }

    if (msg.type == MessageType.product && msg.productData != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 60, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg.text != null) _buildAIText(msg.text!),
            const SizedBox(height: 8),
            ProductRecommendationCard(product: msg.productData!),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.05, end: 0);
    }

    if (msg.type == MessageType.recommendation && msg.recommendationData != null) {
      final rec = msg.recommendationData!;
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 60, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg.text != null) _buildAIText(msg.text!),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rec.title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink)),
                  if (rec.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(rec.subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppColors.inkMuted)),
                  ],
                  const SizedBox(height: 12),
                  ...rec.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle, size: 16, color: AppColors.accentPurple),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(item, style: GoogleFonts.inter(fontSize: 13, color: AppColors.ink, height: 1.3)),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.05, end: 0);
    }

    if (msg.isError) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 60, 4),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.error.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(msg.text ?? '', style: GoogleFonts.inter(fontSize: 13, color: AppColors.error))),
            ],
          ),
        ),
      ).animate().fadeIn();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 60, 4),
      child: _buildAIText(msg.text ?? ''),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.05, end: 0);
  }

  Widget _buildAIText(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(18).copyWith(bottomLeft: Radius.circular(4)),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(fontSize: 15, color: AppColors.ink, height: 1.5),
        ),
      ),
    );
  }
}
