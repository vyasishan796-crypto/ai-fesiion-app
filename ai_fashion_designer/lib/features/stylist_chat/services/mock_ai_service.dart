import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../models/chat_message.dart';

class MockAiService {
  static final MockAiService _instance = MockAiService._internal();
  factory MockAiService() => _instance;
  MockAiService._internal();

  final List<Map<String, String>> _chatHistory = [];

  Future<ChatMessage> getResponse(String userMessage) async {
    _chatHistory.add({'role': 'user', 'content': userMessage});

    if (_chatHistory.length > 20) {
      _chatHistory.removeRange(0, _chatHistory.length - 20);
    }

    try {
      final systemPrompt = '''You are StyleAI — India's most advanced AI Fashion Stylist. You combine deep knowledge of Indian fashion, global trends, body types, color theory, and personal styling.

INDIAN BRANDS YOU KNOW:
- Budget: Roadster (₹399-1499), HRX (₹599-1999), Max (₹299-999)
- Mid-Range: H&M (₹499-2999), Allen Solly (₹899-2999), Peter England (₹699-1999), Jack & Jones (₹799-2499), Westside (₹399-1499)
- Premium: Zara (₹1299-4999), Marks & Spencer (₹999-3999), US Polo (₹999-2499)
- Ethnic: Manyavar (₹1499-9999), FabIndia (₹999-4999), W (₹699-2499), Biba (₹599-1999)

Rules:
- Give SHORT, punchy replies (2-4 sentences max)
- Always use ₹ for prices (Indian Rupees)
- Be casual and friendly — like a fashionable best friend
- If user asks in Hindi/Hinglish, reply in Hindi/Hinglish
- For outfit suggestions: give 3-5 items with brand + item + color + price
- For color advice: be specific with hex codes
- For body/fit advice: reference body measurements if available
- Know Indian seasons: Summer (Apr-Jun), Monsoon (Jul-Sep), Winter (Oct-Feb)
- For weddings/festivals: suggest Indian ethnic wear
- Be honest — give constructive advice, not just compliments
- Suggest products available on Myntra, Amazon, Flipkart, Ajio''';

      final messages = [
        {'role': 'system', 'content': systemPrompt},
        ..._chatHistory,
      ];

      final response = await http.post(
        Uri.parse('${ApiConstants.openRouterBaseUrl}/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConstants.openRouterApiKey}',
          'HTTP-Referer': 'https://styleai.app',
          'X-Title': 'StyleAI Fashion Assistant',
        },
        body: jsonEncode({
          'model': ApiConstants.openRouterModel,
          'messages': messages,
          'max_tokens': 500,
          'temperature': 0.8,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiText = data['choices'][0]['message']['content'] as String;
        _chatHistory.add({'role': 'assistant', 'content': aiText});
        return ChatMessage.text(aiText, Sender.ai);
      } else {
        debugPrint('[OpenRouter] Error ${response.statusCode}: ${response.body}');
        return _fallbackResponse(userMessage);
      }
    } catch (e) {
      debugPrint('[OpenRouter] Network error: $e');
      return _fallbackResponse(userMessage);
    }
  }

  ChatMessage _fallbackResponse(String userMessage) {
    final msg = userMessage.toLowerCase();

    if (msg.contains('jacket') || msg.contains('find') || msg.contains('buy')) {
      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: Sender.ai,
        timestamp: DateTime.now(),
        type: MessageType.product,
        text: 'Here are some great options under ₹2000:',
        productData: ProductCardData(
          name: 'Oversized Denim Jacket',
          price: 1499,
          rating: 4.5,
          sizes: ['S', 'M', 'L', 'XL'],
          brand: 'H&M',
        ),
      );
    }

    if (msg.contains('create') || msg.contains('outfit') || msg.contains('look')) {
      return ChatMessage.outfit(
        OutfitCardData(
          name: 'AI Style Pick',
          style: 'Smart Casual',
          occasion: 'College / Casual',
          components: ['Graphic Oversized Tee', 'Slim Chinos', 'White Sneakers', 'Minimal Watch', 'Canvas Backpack'],
          estimatedPrice: '₹2,499',
        ),
        text: 'Here\'s a fresh outfit I put together for you!',
      );
    }

    if (msg.contains('color') || msg.contains('match')) {
      return ChatMessage.recommendation(
        const RecommendationData(
          title: 'Color Match',
          subtitle: 'Best colors for your outfit',
          items: ['Navy Blue — Perfect base', 'White — Clean contrast', 'Olive — Earthy vibe', 'Burgundy — Bold accent'],
        ),
        text: 'These colors will match your look perfectly!',
      );
    }

    return ChatMessage.text(
      'I\'m your AI fashion stylist! Try asking me:\n\n'
      '• "Create a college outfit under ₹3000"\n'
      '• "What colors go with black jeans?"\n'
      '• "Help me pick a party look"\n'
      '• "Suggest a jacket under ₹2000"\n\n'
      'I know Indian brands, prices, and seasons! What do you need?',
      Sender.ai,
    );
  }

  void clearHistory() {
    _chatHistory.clear();
  }
}
