import 'dart:math';
import '../../../core/models/outfit_dataset.dart';
import '../../../core/services/outfit_data_service.dart';

class StylistService {
  static final StylistService _instance = StylistService._internal();
  factory StylistService() => _instance;
  StylistService._internal();

  final OutfitDataService _outfitService = OutfitDataService();

  String getResponse(String userMessage) {
    final msg = userMessage.toLowerCase();

    final occasion = _detectOccasion(msg);
    final style = _detectStyle(msg);
    final season = _detectSeason(msg);

    if (_isGreeting(msg)) {
      return _greetingResponse();
    }

    if (_isHelp(msg)) {
      return _helpResponse();
    }

    final outfits = _outfitService.filter(
      occasion: occasion,
      style: style,
      season: season,
    );

    if (outfits.isEmpty) {
      return _noMatchResponse(occasion, style, season);
    }

    final top3 = (outfits.toList()..shuffle(Random())).take(3).toList();
    return _recommendationResponse(top3, occasion, style);
  }

  List<OutfitDataset> getSuggestedOutfits(String userMessage) {
    final msg = userMessage.toLowerCase();
    final occasion = _detectOccasion(msg);
    final style = _detectStyle(msg);
    final season = _detectSeason(msg);

    final outfits = _outfitService.filter(
      occasion: occasion,
      style: style,
      season: season,
    );

    return (outfits.toList()..shuffle(Random())).take(3).toList();
  }

  bool _isGreeting(String msg) {
    return msg.contains('hi') ||
        msg.contains('hello') ||
        msg.contains('hey') ||
        msg == 'yo' ||
        msg.contains('namaste') ||
        msg.contains('sup') ||
        msg.length < 4;
  }

  bool _isHelp(String msg) {
    return msg.contains('help') ||
        msg.contains('what can you') ||
        msg.contains('kya kar') ||
        msg.contains('kaise');
  }

  String? _detectOccasion(String msg) {
    if (msg.contains('college') || msg.contains('university') || msg.contains('campus') || msg.contains('class')) return 'College';
    if (msg.contains('office') || msg.contains('work') || msg.contains('formal') || msg.contains('professional') || msg.contains('meeting') || msg.contains('interview')) return 'Office';
    if (msg.contains('party') || msg.contains('night') || msg.contains('club') || msg.contains('birthday') || msg.contains('celebration') || msg.contains('wedding') || msg.contains('date')) return 'Party';
    if (msg.contains('travel') || msg.contains('trip') || msg.contains('vacation') || msg.contains('trek') || msg.contains('beach')) return 'Travel';
    if (msg.contains('relax') || msg.contains('home') || msg.contains('casual') || msg.contains('daily') || msg.contains('comfort') || msg.contains('loung')) return 'Relax';
    return null;
  }

  String? _detectStyle(String msg) {
    if (msg.contains('minimal') || msg.contains('clean') || msg.contains('simple')) return 'Minimal';
    if (msg.contains('street') || msg.contains('hip hop') || msg.contains('urban') || msg.contains('sneaker')) return 'Streetwear';
    if (msg.contains('smart') || msg.contains('semi-formal') || msg.contains('semi formal')) return 'Smart Casual';
    if (msg.contains('classic') || msg.contains('traditional') || msg.contains('ethnic') || msg.contains('kurta')) return 'Classic';
    if (msg.contains('modern') || msg.contains('trendy') || msg.contains('fashion')) return 'Modern';
    return null;
  }

  String? _detectSeason(String msg) {
    if (msg.contains('summer') || msg.contains('hot') || msg.contains('garmi')) return 'Summer';
    if (msg.contains('winter') || msg.contains('cold') || msg.contains('thand')) return 'Winter';
    if (msg.contains('monsoon') || msg.contains('rain') || msg.contains('barish')) return 'Monsoon';
    return null;
  }

  String _greetingResponse() {
    final greetings = [
      "Hey! I'm your AI fashion stylist. Tell me the occasion — college, office, party, travel — and I'll suggest the perfect outfit from our collection of 1000+ styles!",
      "Welcome! What's the plan today? Tell me where you're headed and I'll style you up with the best look.",
      "Hi there! Ready to look your best? Just tell me the occasion — casual day out, office meeting, party night — and I've got you covered!",
    ];
    return greetings[Random().nextInt(greetings.length)];
  }

  String _helpResponse() {
    return "I can help you with:\n\n"
        "• Occasion-based outfits — say 'college outfit' or 'office wear'\n"
        "• Season styles — 'summer look' or 'winter outfit'\n"
        "• Style preferences — 'minimal', 'streetwear', 'classic'\n"
        "• Budget — 'budget friendly' or 'premium'\n\n"
        "Just describe what you need and I'll find the perfect match from our 1000+ outfit database!";
  }

  String _noMatchResponse(String? occasion, String? style, String? season) {
    if (occasion == null && style == null && season == null) {
      return "I couldn't quite catch that. Try telling me something like:\n\n"
          "• 'College outfit for summer'\n"
          "• 'Party wear for night'\n"
          "• 'Smart casual for office'\n"
          "• 'Travel outfit for monsoon'\n\n"
          "The more details, the better I can style you!";
    }
    return "I don't have the perfect match right now. Try a different occasion or style — like 'casual college look' or 'formal office wear'. I'll find something great for you!";
  }

  String _recommendationResponse(List<OutfitDataset> outfits, String? occasion, String? style) {
    final buffer = StringBuffer();

    if (occasion != null && style != null) {
      buffer.writeln("Great choice! Here are my top picks for a $style $occasion look:\n");
    } else if (occasion != null) {
      buffer.writeln("Here are the best outfits for your $occasion:\n");
    } else if (style != null) {
      buffer.writeln("Love the $style vibe! Here are my top picks:\n");
    } else {
      buffer.writeln("Here are some great outfit suggestions for you:\n");
    }

    for (int i = 0; i < outfits.length; i++) {
      final o = outfits[i];
      buffer.writeln("${i + 1}. ${o.displayTitle}");
      if (o.shoes != null) buffer.writeln("   Shoes: ${o.shoes}");
      if (o.accessory != null && o.accessory != 'None') buffer.writeln("   Accessory: ${o.accessory}");
      buffer.writeln("   Score: ${o.score ?? 'N/A'}/10");
      buffer.writeln();
    }

    buffer.writeln("Want me to generate an AI image of any of these? Just say 'generate outfit 1'!");

    return buffer.toString();
  }
}
