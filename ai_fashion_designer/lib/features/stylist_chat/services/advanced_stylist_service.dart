import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../models/chat_message.dart';
import '../../../features/body_measurement/services/body_measurement_service.dart';
import '../../../core/services/style_profile_service.dart';

class AdvancedStylistService {
  static final AdvancedStylistService _instance = AdvancedStylistService._();
  factory AdvancedStylistService() => _instance;
  AdvancedStylistService._();

  final List<Map<String, String>> _chatHistory = [];
  static const _geminiBase = 'https://generativelanguage.googleapis.com/v1beta/models';
  static const _geminiModels = ['gemini-3-flash-preview', 'gemini-3.7-flash', 'gemini-3.5-flash'];

  String _buildSystemPrompt() {
    final profileService = StyleProfileService();
    final measurementService = BodyMeasurementService();
    final profile = profileService.profile;
    final fitProfile = measurementService.currentProfile;

    final profileContext = profile.isOnboarded ? '''
USER STYLE PROFILE:
${profile.toContextString()}
''' : '';

    final measurementContext = fitProfile != null ? '''
USER BODY MEASUREMENTS:
- Top Size: ${fitProfile.topSize}
- Bottom Size: ${fitProfile.bottomSize}
- Chest: ${fitProfile.getMeasurement('Chest')?.displayValue ?? 'N/A'} cm
- Waist: ${fitProfile.getMeasurement('Waist')?.displayValue ?? 'N/A'} cm
- Height: ${fitProfile.knownHeight ?? 'N/A'} cm
''' : '';

    return '''You are StyleAI — India's most advanced AI Fashion Stylist. You combine deep knowledge of Indian fashion, global trends, body types, color theory, fabric science, and personal styling to deliver expert advice.

$profileContext
$measurementContext

YOUR CAPABILITIES:
1. **Outfit Recommendations** — Create complete outfits with specific items, brands, prices in INR
2. **Color Matching** — Advise on color combinations based on skin tone, occasion, and preferences
3. **Body Fit Advice** — Recommend fits based on body type and measurements
4. **Product Search** — Suggest specific products with prices on Myntra, Amazon, Flipkart, Ajio
5. **Trend Analysis** — Current fashion trends in India and globally
6. **Fabric & Care** — Fabric recommendations, seasonal fabric choices, and clothing care tips
7. **Occasion Styling** — College, office, party, wedding, date, travel, festival outfits
8. **Budget Styling** — Stylish outfits within any budget range (₹500 to ₹50,000+)
9. **Brand Advice** — Indian and international brand recommendations
10. **Seasonal Styling** — Summer (Apr-Jun), Monsoon (Jul-Sep), Winter (Oct-Feb) appropriate clothing
11. **Ethnic Wear** — Sherwani, Lehenga, Kurta sets, Saree, Nehru Jacket, Anarkali, Palazzo sets
12. **Regional Style** — Awareness of South Indian, North Indian, Northeast, and fusion styles

INDIAN BRANDS YOU KNOW (with typical price ranges):
- Budget: Roadster (₹399-1499), HRX (₹599-1999), Max (₹299-999), Decathlon (₹299-1499)
- Mid-Range: H&M (₹499-2999), Allen Solly (₹899-2999), Peter England (₹699-1999), Jack & Jones (₹799-2499), Westside (₹399-1499), Unit (₹499-1499)
- Premium: Zara (₹1299-4999), Marks & Spencer (₹999-3999), US Polo (₹999-2499), Arrow (₹1199-3499)
- Ethnic: Manyavar (₹1499-9999), FabIndia (₹999-4999), W (₹699-2499), Biba (₹599-1999), Aurelia (₹499-1499)
- Sneakers: Nike (₹3499-12999), Puma (₹2499-8999), Adidas (₹2999-9999), New Balance (₹4999-12999)

RULES:
- Reply in SHORT, punchy sentences (2-4 lines max unless detailed advice requested)
- ALWAYS use ₹ for prices (Indian Rupees)
- Use casual, friendly tone — like a fashionable best friend
- When suggesting outfits, be SPECIFIC: brand + item + color + price
- When user asks about colors, give hex codes
- If user asks in Hindi/Hinglish, reply in Hindi/Hinglish automatically
- Be honest — don't always say everything looks great, give constructive advice
- Know Indian seasons: Summer (Apr-Jun, 35-45°C), Monsoon (Jul-Sep, humid), Winter (Oct-Feb, 10-25°C)
- For weddings: mention Indian ethnic wear with specific items and prices
- For festivals: suggest appropriate ethnic/fusion wear (Diwali, Eid, Holi, Onam, Pongal, Baisakhi)
- Consider Indian body types: recommend fits that flatter different builds
- When budget is mentioned, stay within that range strictly
- Suggest 2-3 alternatives at different price points when possible

RESPONSE FORMAT — You MUST respond with valid JSON in ONE of these formats:

**For text responses:**
{"type": "text", "text": "your response here"}

**For outfit recommendations:**
{"type": "outfit", "outfit": {"name": "Outfit Name", "style": "Style Category", "occasion": "College / Office / Party / Wedding / Travel / Date", "season": "Summer / Winter / Monsoon / All Season", "components": ["Brand Item Color — ₹price", "Brand Item Color — ₹price", ...], "totalPrice": 2499, "fitAdvice": "body type specific fit tip", "alternatives": ["budget swap option 1", "premium upgrade option 1"], "tip": "Quick styling tip", "score": 87, "scoreBreakdown": {"personalStyle": 94, "occasion": 96, "color": 91, "weather": 89, "fit": 87, "budget": 95}, "whyNot": ["reason 1 why this isn't a 100", "reason 2 — what could be improved"]}}

**For product suggestions:**
{"type": "products", "products": [{"name": "Product Name", "brand": "Brand", "price": 1299, "originalPrice": 1999, "rating": 4.5, "platform": "Myntra", "sizes": ["S","M","L","XL"], "color": "Color Name", "reason": "Why this product suits the user", "url": "https://www.myntra.com/product-name"}]}

**For color advice:**
{"type": "colors", "colors": {"palette": [{"name": "Color Name", "hex": "#XXXXXX", "use": "Where to use it", "suitsSkinTone": "which skin tones"}], "tip": "Color matching tip", "avoid": ["colors to avoid"]}}

**For body/fit advice:**
{"type": "fit", "fit": {"bodyType": "detected body type", "bestFits": ["fit type 1", "fit type 2"], "avoid": ["fit type to avoid"], "brands": ["brand suggestions for this body type"], "tip": "Specific fit advice"}}

**For multiple recommendations:**
{"type": "recommendations", "title": "Title", "items": [{"title": "Item Title", "subtitle": "Description", "detail": "Extra info", "price": 1299}]}

RULES FOR JSON:
- ALWAYS return valid JSON only, no markdown, no code blocks, no extra text
- Use "type" field to indicate response type
- Prices must be in numbers (not strings)
- Keep text responses SHORT (2-3 sentences)
- For outfit components, include brand name and price in each item
- For alternatives, provide one budget option and one premium option
- For outfit type: ALWAYS include "score" (0-100), "scoreBreakdown" with 6 factors, and "whyNot" array with 1-3 honest reasons
- SCORING: personalStyle (how well items match), occasion (appropriate for event), color (color harmony), weather (season fit), fit (body proportion), budget (value for money) — each 60-100
- whyNot must be SPECIFIC and ACTIONABLE, e.g. "Heavy wool jacket — 34C tomorrow", "Neon green doesn't match your neutral preferences", "Rs 7,500 over your Rs 5,000 budget"''';
  }

  Future<ChatMessage> getResponse(String userMessage) async {
    _chatHistory.add({'role': 'user', 'content': userMessage});
    if (_chatHistory.length > 24) {
      _chatHistory.removeRange(0, _chatHistory.length - 24);
    }

    final systemPrompt = _buildSystemPrompt();
    final messages = [
      {'role': 'user', 'content': systemPrompt},
      {'role': 'assistant', 'content': 'I understand. I am StyleAI, your advanced fashion stylist. I will respond with structured JSON as instructed.'},
      ..._chatHistory,
    ];

    // Try Gemini models first
    for (final model in _geminiModels) {
      try {
        final response = await http.post(
          Uri.parse('$_geminiBase/$model:generateContent?key=${ApiConstants.geminiApiKey}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {'role': 'user', 'parts': [{'text': messages.map((m) => '${m["role"]}: ${m["content"]}').join('\n\n')}]}
            ],
            'generationConfig': {
              'temperature': 0.7,
              'maxOutputTokens': 1024,
            },
          }),
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          final aiMessage = _parseStructuredResponse(text);
          _chatHistory.add({'role': 'assistant', 'content': text});
          return aiMessage;
        }
        debugPrint('[Stylist] $model failed: ${response.statusCode}');
      } catch (e) {
        debugPrint('[Stylist] $model error: $e');
      }
    }

    // Fallback to OpenRouter
    try {
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
        final text = data['choices'][0]['message']['content'];
        final aiMessage = _parseStructuredResponse(text);
        _chatHistory.add({'role': 'assistant', 'content': text});
        return aiMessage;
      }
    } catch (e) {
      debugPrint('[Stylist] OpenRouter error: $e');
    }

    // All APIs failed — use smart fallback
    return _smartFallback(userMessage);
  }

  ChatMessage _parseStructuredResponse(String rawText) {
    try {
      // Clean the response — remove markdown code blocks if present
      String cleaned = rawText.trim();
      if (cleaned.startsWith('```')) {
        cleaned = cleaned.replaceFirst(RegExp(r'^```\w*\n?'), '');
        cleaned = cleaned.replaceFirst(RegExp(r'\n?```$'), '');
      }
      cleaned = cleaned.trim();

      final data = jsonDecode(cleaned);
      final type = data['type'] as String? ?? 'text';

      switch (type) {
        case 'outfit':
          final outfit = data['outfit'];
          return ChatMessage.outfit(
            OutfitCardData(
              name: outfit['name'] ?? 'AI Outfit',
              style: outfit['style'] ?? 'Casual',
              occasion: outfit['occasion'] ?? 'Everyday',
              components: List<String>.from(outfit['components'] ?? []),
              estimatedPrice: '₹${outfit['totalPrice'] ?? 0}',
            ),
          );

        case 'products':
          final products = (data['products'] as List? ?? []);
          if (products.isNotEmpty) {
            final p = products.first;
            return ChatMessage.product(
              ProductCardData(
                name: p['name'] ?? 'Product',
                brand: p['brand'] ?? '',
                price: (p['price'] ?? 0).toDouble(),
                rating: (p['rating'] ?? 4.0).toDouble(),
                sizes: List<String>.from(p['sizes'] ?? ['M', 'L', 'XL']),
                imageUrl: p['imageUrl'],
              ),
            );
          }
          return ChatMessage.text(cleaned, Sender.ai);

        case 'colors':
          final colors = data['colors'];
          final palette = (colors['palette'] as List? ?? [])
              .map((c) => '${c['name']} (${c['hex']}) — ${c['use']}')
              .toList();
          return ChatMessage.recommendation(
            RecommendationData(
              title: 'Color Palette',
              subtitle: colors['tip'] ?? '',
              items: palette,
            ),
          );

        case 'recommendations':
          final items = (data['items'] as List? ?? [])
              .map((i) => '${i['title']}: ${i['subtitle']}')
              .toList();
          return ChatMessage.recommendation(
            RecommendationData(
              title: data['title'] ?? 'Recommendations',
              subtitle: 'Personalized for you',
              items: items,
            ),
          );

        default:
          return ChatMessage.text(data['text'] ?? cleaned, Sender.ai);
      }
    } catch (e) {
      // JSON parsing failed — return as text
      debugPrint('[Stylist] JSON parse error: $e');
      return ChatMessage.text(rawText, Sender.ai);
    }
  }

  ChatMessage _smartFallback(String userMessage) {
    final msg = userMessage.toLowerCase();

    // Greetings
    if (RegExp(r'(hi|hello|hey|namaste|sup|hola|yo)').hasMatch(msg)) {
      final profile = StyleProfileService().profile;
      final greeting = profile.isOnboarded
          ? 'Welcome back! Your style profile is loaded — ${profile.preferredStyles.join(", ")} specialist here.'
          : 'Hey! I\'m StyleAI — your personal fashion stylist. Tell me about your style, or just ask me anything about fashion!';
      return ChatMessage.text(greeting, Sender.ai);
    }

    // Outfit requests
    if (RegExp(r'(outfit|look|wear|dress|create|style)').hasMatch(msg)) {
      return ChatMessage.outfit(
        OutfitCardData(
          name: 'Smart Casual Look',
          style: 'Smart Casual',
          occasion: 'College / Casual Outing',
          components: [
            'H&M Oversized Graphic Tee — ₹999',
            'Levis 511 Slim Jeans — ₹2,499',
            'Nike Air Force 1 Low — ₹7,495',
            'Casio Vintage Watch — ₹3,995',
          ],
          estimatedPrice: '₹14,988',
        ),
      );
    }

    // Product search
    if (RegExp(r'(find|buy|shop|search|product|jacket|shirt|shoe)').hasMatch(msg)) {
      return ChatMessage.product(
        ProductCardData(
          name: 'Oversized Denim Jacket',
          brand: 'H&M',
          price: 2999,
          rating: 4.5,
          sizes: ['S', 'M', 'L', 'XL'],
          imageUrl: 'https://image.hm.com/assets/hm/0e/9d/0e9d5aad30cdb02146ec21cd1ac8059183935ead.jpg?imwidth=400',
        ),
      );
    }

    // Fallback
    return ChatMessage.text(
      "I can help with outfit recommendations, style analysis, and product suggestions. Try asking about a specific outfit or style!",
      Sender.ai,
    );
  }

  void clearHistory() {
    _chatHistory.clear();
  }
}
