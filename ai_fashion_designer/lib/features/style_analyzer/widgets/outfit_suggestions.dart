import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/style_analysis.dart';

class OutfitSuggestions extends StatelessWidget {
  final String style;
  final List<String> clothing;
  final List<String> occasions;
  final List<DetectedColor> detectedColors;

  const OutfitSuggestions({
    super.key,
    required this.style,
    required this.clothing,
    required this.occasions,
    required this.detectedColors,
  });

  @override
  Widget build(BuildContext context) {
    final suggestions = _generateSuggestions();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.palette_outlined, color: Color(0xFF7C4DFF), size: 20),
            const SizedBox(width: 8),
            Text(
              'Style Suggestions',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1D1D1F),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Curated outfits with color palettes based on your look',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(suggestions.length, (index) {
          final s = suggestions[index];
          final colors = s.colors;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8E8E8)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getOccasionColor(s.occasion),
                              _getOccasionColor(s.occasion).withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getOccasionIcon(s.occasion),
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.title,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1D1D1F),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              s.occasion,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    s.description,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF555555),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: s.items.map((item) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFF8F6FF),
                          const Color(0xFFF0EBFF).withOpacity(0.5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE8E0FF)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.palette, size: 14, color: const Color(0xFF7C4DFF)),
                            const SizedBox(width: 6),
                            Text(
                              'Color Palette',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF7C4DFF),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: colors.map((c) {
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${c.name} — ${c.hex}'),
                                      backgroundColor: c.color,
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      height: 32,
                                      margin: const EdgeInsets.symmetric(horizontal: 2),
                                      decoration: BoxDecoration(
                                        color: c.color,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: c.color == const Color(0xFFFFFFFF)
                                              ? Colors.grey.shade200
                                              : Colors.transparent,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: c.color.withOpacity(0.3),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      c.name,
                                      style: GoogleFonts.inter(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF333333),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      c.usage,
                                      style: GoogleFonts.inter(
                                        fontSize: 8,
                                        color: Colors.grey.shade500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(
                  delay: Duration(milliseconds: 80 * index),
                  duration: 400.ms,
                ).slideX(begin: 0.06, duration: 350.ms),
          );
        }),
      ],
    );
  }

  List<_SuggestionData> _generateSuggestions() {
    final lowerStyle = style.toLowerCase();

    final tops = clothing.where((c) {
      final l = c.toLowerCase();
      return l.contains('t-shirt') || l.contains('tee') || l.contains('shirt') ||
          l.contains('polo') || l.contains('hoodie') || l.contains('sweatshirt') ||
          l.contains('sweater') || l.contains('tank') || l.contains('kurta') ||
          l.contains('jacket') || l.contains('blazer') || l.contains('coat') ||
          l.contains('vest') || l.contains('overshirt') || l.contains('bomber');
    }).toList();
    final bottoms = clothing.where((c) {
      final l = c.toLowerCase();
      return l.contains('jean') || l.contains('pant') || l.contains('trouser') ||
          l.contains('chino') || l.contains('cargo') || l.contains('short') ||
          l.contains(' jogger') || l.contains('dhoti') || l.contains('pyjama');
    }).toList();
    final footwear = clothing.where((c) {
      final l = c.toLowerCase();
      return l.contains('sneaker') || l.contains('shoe') || l.contains('boot') ||
          l.contains('loafer') || l.contains('sandal') || l.contains('slide') ||
          l.contains('derby') || l.contains('chelsea') || l.contains('oxford');
    }).toList();
    final accessories = clothing.where((c) {
      final l = c.toLowerCase();
      return l.contains('watch') || l.contains('sunglass') || l.contains('glasses') ||
          l.contains('necklace') || l.contains('chain') || l.contains('ring') ||
          l.contains('bracelet') || l.contains('cap') || l.contains('hat') ||
          l.contains('bag') || l.contains('belt');
    }).toList();

    final topItem = tops.isNotEmpty ? tops.first : '';
    final bottomItem = bottoms.isNotEmpty ? bottoms.first : '';
    final shoeItem = footwear.isNotEmpty ? footwear.first : '';
    final accessoryItem = accessories.isNotEmpty ? accessories.first : '';

    final realColors = detectedColors.map((c) => c.name).toList();
    final primaryColor = detectedColors.isNotEmpty ? detectedColors.first : null;
    final secondaryColor = detectedColors.length > 1 ? detectedColors[1] : null;
    final accentColor = detectedColors.length > 2 ? detectedColors[2] : null;

    final isDark = realColors.any((c) =>
        c.toLowerCase().contains('black') || c.toLowerCase().contains('dark') ||
        c.toLowerCase().contains('navy') || c.toLowerCase().contains('charcoal'));

    final suggestions = <_SuggestionData>[];

    // Suggestion 1: Enhance Current Look
    suggestions.add(_SuggestionData(
      title: 'Enhance Your Look',
      occasion: style,
      description:
          'You are wearing ${clothing.join(", ")}. '
          '${topItem.isNotEmpty ? "Your $topItem looks great — " : ""}'
          '${shoeItem.isNotEmpty ? "try swapping $shoeItem for a different style." : "add clean sneakers to complete the look."} '
          '${accessoryItem.isNotEmpty ? "Keep your $accessoryItem for a polished finish." : "A minimal watch would elevate this."}',
      items: [
        ...clothing,
        if (accessories.isEmpty) 'Minimal Watch',
      ],
      colors: _buildRealPalette(primaryColor, secondaryColor, accentColor, realColors),
    ));

    // Suggestion 2: Color Swap
    suggestions.add(_SuggestionData(
      title: 'Color Swap Variation',
      occasion: 'Casual / Daily',
      description:
          'Same outfit, different energy. '
          '${topItem.isNotEmpty ? "Swap your $topItem for a " : "Try a "}'
          '${isDark ? "lighter shade to brighten things up." : "deeper tone for a more refined vibe."} '
          '${bottomItem.isNotEmpty ? "Keep your $bottomItem as is." : ""}',
      items: [
        if (topItem.isNotEmpty) _suggestAlternateTop(topItem, isDark),
        if (bottomItem.isNotEmpty) bottomItem,
        if (shoeItem.isNotEmpty) shoeItem,
        if (accessoryItem.isNotEmpty) accessoryItem,
      ],
      colors: _buildContrastPalette(realColors),
    ));

    // Suggestion 3: Upgrade / Dress Up
    suggestions.add(_SuggestionData(
      title: 'Dress It Up',
      occasion: 'Semi-Formal / College',
      description:
          '${topItem.isNotEmpty ? "Take your $topItem and layer it with a structured piece." : "Add a structured layer to elevate."} '
          '${bottomItem.isNotEmpty ? "Pair with your $bottomItem for a smart silhouette." : "Fitted trousers work perfectly here."} '
          '${shoeItem.isNotEmpty ? "Upgrade $shoeItem to loafers or derbies." : "Loafers complete the formal upgrade."}',
      items: [
        ...tops.take(1),
        'Structured Outer Layer',
        if (bottomItem.isNotEmpty) bottomItem else 'Fitted Trousers',
        if (shoeItem.isNotEmpty) 'Loafers / Derbies',
        if (accessoryItem.isNotEmpty) accessoryItem,
      ],
      colors: _buildRealPalette(primaryColor, secondaryColor, accentColor, realColors),
    ));

    // Suggestion 4: Casual Downgrade
    suggestions.add(_SuggestionData(
      title: 'Casual Refresh',
      occasion: 'Relax / Weekend',
      description:
          '${topItem.isNotEmpty ? "Your $topItem can be styled more casually." : "Go relaxed with loose layers."} '
          '${bottomItem.isNotEmpty ? "Roll up your $bottomItem for a laid-back vibe." : "Pair with joggers for comfort."} '
          '${shoeItem.isNotEmpty ? "Swap $shoeItem for slides or sneakers." : "Slides or chunky sneakers work great."}',
      items: [
        ...tops.take(1),
        if (bottomItem.isNotEmpty) bottomItem else 'Joggers',
        'Slides / Chunky Sneakers',
        if (accessories.isNotEmpty) accessories.first else 'Cap / Sunglasses',
      ],
      colors: _buildRealPalette(primaryColor, secondaryColor, accentColor, realColors),
    ));

    // Suggestion 5: Indian Ethnic Fusion
    suggestions.add(_SuggestionData(
      title: 'Indian Ethnic Fusion',
      occasion: 'Festival / Wedding / Pooja',
      description:
          'Fusion look: pair a ${isDark ? "white kurta" : "pastel kurta"} with ${isDark ? "white pyjama" : "churidar"}. '
          'Add Kolhapuri chappals or mojaris for an authentic touch. '
          '${accessoryItem.isNotEmpty ? "Keep your $accessoryItem" : "A brass bracelet"} to complete the ethnic vibe. '
          'Brands: Manyavar, FabIndia, W, Biba (Rs 800-3000).',
      items: [
        isDark ? 'White Cotton Kurta' : 'Pastel Blue Kurta',
        isDark ? 'White Pyjama' : 'Churidar',
        'Kolhapuri Chappals / Mojaris',
        'Brass Kada / Ethnic Bracelet',
      ],
      colors: [
        ColorSuggestion(name: isDark ? 'Ivory' : 'Pastel Blue', color: isDark ? const Color(0xFFFFFFF0) : const Color(0xFF93C5FD), hex: isDark ? '#FFFFF0' : '#93C5FD', usage: 'Base'),
        ColorSuggestion(name: 'Gold', color: const Color(0xFFDAA520), hex: '#DAA520', usage: 'Accent'),
        ColorSuggestion(name: 'Maroon', color: const Color(0xFF800000), hex: '#800000', usage: 'Detail'),
      ],
    ));

    // Suggestion 6: Indian-Western Hybrid
    suggestions.add(_SuggestionData(
      title: 'Desi x Street Style',
      occasion: 'College / Casual / Hangout',
      description:
          'Mix Indian with streetwear: ${topItem.isNotEmpty ? "layer your $topItem over" : "Try a"} Nehru Jacket over a plain tee. '
          'Pair with slim-fit jeans and white sneakers. '
          'Add aviator sunglasses for swag. '
          'Brands: Jack & Jones, H&M, Allen Solly, Roadster (Rs 500-2500).',
      items: [
        'Nehru Jacket / Bandi',
        'Plain White T-Shirt',
        'Slim Fit Jeans',
        'White Sneakers',
        'Aviator Sunglasses',
      ],
      colors: [
        ColorSuggestion(name: 'Black', color: const Color(0xFF1D1D1F), hex: '#1D1D1F', usage: 'Jacket'),
        ColorSuggestion(name: 'White', color: const Color(0xFFFFFFFF), hex: '#FFFFFF', usage: 'Base'),
        ColorSuggestion(name: 'Denim', color: const Color(0xFF4B6B8A), hex: '#4B6B8A', usage: 'Bottom'),
      ],
    ));

    return suggestions;
  }

  String _suggestAlternateTop(String currentTop, bool isDark) {
    final lower = currentTop.toLowerCase();
    if (lower.contains('t-shirt') || lower.contains('tee')) {
      return isDark ? 'White T-Shirt' : 'Black T-Shirt';
    }
    if (lower.contains('shirt')) return isDark ? 'Light Blue Shirt' : 'Navy Shirt';
    if (lower.contains('polo')) return isDark ? 'White Polo' : 'Navy Polo';
    if (lower.contains('hoodie') || lower.contains('sweatshirt')) {
      return isDark ? 'Light Grey Hoodie' : 'Black Hoodie';
    }
    return isDark ? 'Lighter Shade Top' : 'Darker Shade Top';
  }

  List<ColorSuggestion> _buildRealPalette(DetectedColor? primary, DetectedColor? secondary, DetectedColor? accent, List<String> allColors) {
    final list = <ColorSuggestion>[];
    if (primary != null) list.add(ColorSuggestion(name: primary.name, color: primary.color, hex: '#${primary.color.value.toRadixString(16).substring(2).toUpperCase()}', usage: 'Base'));
    if (secondary != null) list.add(ColorSuggestion(name: secondary.name, color: secondary.color, hex: '#${secondary.color.value.toRadixString(16).substring(2).toUpperCase()}', usage: 'Complement'));
    if (accent != null) list.add(ColorSuggestion(name: accent.name, color: accent.color, hex: '#${accent.color.value.toRadixString(16).substring(2).toUpperCase()}', usage: 'Accent'));
    if (list.isEmpty && allColors.isNotEmpty) {
      for (final c in allColors.take(3)) {
        list.add(ColorSuggestion(name: c, color: _getColorFromName(c), hex: _hexFromName(c), usage: list.isEmpty ? 'Base' : 'Accent'));
      }
    }
    if (list.isEmpty) {
      list.add(ColorSuggestion(name: 'Black', color: const Color(0xFF1D1D1F), hex: '#1D1D1F', usage: 'Base'));
      list.add(ColorSuggestion(name: 'White', color: const Color(0xFFFFFFFF), hex: '#FFFFFF', usage: 'Accent'));
    }
    return list;
  }

  List<ColorSuggestion> _buildContrastPalette(List<String> currentColors) {
    if (currentColors.isEmpty) {
      return [
        ColorSuggestion(name: 'White', color: const Color(0xFFFFFFFF), hex: '#FFFFFF', usage: 'Base'),
        ColorSuggestion(name: 'Navy', color: const Color(0xFF000080), hex: '#000080', usage: 'Accent'),
      ];
    }
    final primary = currentColors.first;
    final isDark = _getColorFromName(primary).computeLuminance() < 0.4;
    if (isDark) {
      return [
        ColorSuggestion(name: 'White', color: const Color(0xFFFFFFFF), hex: '#FFFFFF', usage: 'Swap To'),
        ColorSuggestion(name: primary, color: _getColorFromName(primary), hex: _hexFromName(primary), usage: 'Current'),
        ColorSuggestion(name: 'Cream', color: const Color(0xFFFFDDC1), hex: '#FFDDC1', usage: 'Alt'),
      ];
    }
    return [
      ColorSuggestion(name: 'Navy', color: const Color(0xFF000080), hex: '#000080', usage: 'Swap To'),
      ColorSuggestion(name: primary, color: _getColorFromName(primary), hex: _hexFromName(primary), usage: 'Current'),
      ColorSuggestion(name: 'Charcoal', color: const Color(0xFF36454F), hex: '#36454F', usage: 'Alt'),
    ];
  }

  Color _getColorFromName(String name) {
    final lower = name.toLowerCase();
    final map = {
      'black': Color(0xFF1D1D1F), 'off black': Color(0xFF2C2C2C), 'jet black': Color(0xFF0A0A0A),
      'white': Color(0xFFFFFFFF), 'off white': Color(0xFFF5F5F5), 'ivory': Color(0xFFFFFFF0),
      'navy': Color(0xFF000080), 'dark navy': Color(0xFF000040), 'light navy': Color(0xFF1A1A4E),
      'blue': Color(0xFF2563EB), 'light blue': Color(0xFF93C5FD), 'sky blue': Color(0xFF38BDF8),
      'royal blue': Color(0xFF4169E1), 'baby blue': Color(0xFF89CFF0), 'cobalt': Color(0xFF0047AB),
      'teal': Color(0xFF14B8A6), 'turquoise': Color(0xFF40E0D0), 'cyan': Color(0xFF06B6D4),
      'red': Color(0xFFDC2626), 'dark red': Color(0xFF991B1B), 'crimson': Color(0xFFDC143C),
      'maroon': Color(0xFF800000), 'burgundy': Color(0xFF800020), 'wine': Color(0xFF722F37),
      'cherry': Color(0xFFDE3163), 'ruby': Color(0xFFE0115F), 'scarlet': Color(0xFFFF2400),
      'coral': Color(0xFFFF7F50), 'salmon': Color(0xFFFA8072), 'rose': Color(0xFFFF007F),
      'pink': Color(0xFFEC4899), 'hot pink': Color(0xFFFF69B4), 'blush': Color(0xFFDE5D83),
      'dusty pink': Color(0xFFDCAE96), 'baby pink': Color(0xFFF4C2C1), 'fuchsia': Color(0xFFFF00FF),
      'green': Color(0xFF16A34A), 'dark green': Color(0xFF166534), 'light green': Color(0xFF86EFAC),
      'olive': Color(0xFF6B8E23), 'olive green': Color(0xFF808000), 'army green': Color(0xFF4B5320),
      'sage': Color(0xFF9CAF88), 'mint': Color(0xFF98FF98), 'emerald': Color(0xFF50C878),
      'forest green': Color(0xFF228B22), 'lime': Color(0xFF32CD32), 'seafoam': Color(0xFF93E9BE),
      'brown': Color(0xFF92400E), 'dark brown': Color(0xFF654321), 'light brown': Color(0xFFC4A484),
      'chocolate': Color(0xFFD2691E), 'coffee': Color(0xFF6F4E37), 'mocha': Color(0xFF967969),
      'caramel': Color(0xFFC68E5B), 'toffee': Color(0xFF755139), 'mahogany': Color(0xFFC04000),
      'taupe': Color(0xFF483C32), 'sand': Color(0xFFC2B280), 'khaki': Color(0xFFC3B091),
      'grey': Color(0xFF6B7280), 'gray': Color(0xFF6B7280), 'dark grey': Color(0xFF374151),
      'light grey': Color(0xFFD1D5DB), 'charcoal': Color(0xFF36454F), 'slate': Color(0xFF708090),
      'silver': Color(0xFFC0C0C0), 'ash': Color(0xFFB2BEB5), 'pebble': Color(0xFFADA999),
      'beige': Color(0xFFF5F5DC), 'cream': Color(0xFFFFDDC1), 'vanilla': Color(0xFFF3E5AB),
      'tan': Color(0xFFD2B48C), 'wheat': Color(0xFFF5DEB3), 'linen': Color(0xFFFAF0E6),
      'champagne': Color(0xFFF7E7CE), 'ecru': Color(0xFFC2B280),
      'yellow': Color(0xFFFACC15), 'mustard': Color(0xFFFFDB58), 'gold': Color(0xFFFFD700),
      'lemon': Color(0xFFFFF44F), 'canary': Color(0xFFFFEF00),
      'orange': Color(0xFFF97316), 'burnt orange': Color(0xFFCC5500), 'peach': Color(0xFFFFCBA4),
      'tangerine': Color(0xFFFF9966), 'apricot': Color(0xFFFBCEB1), 'rust': Color(0xFFB7410E),
      'purple': Color(0xFF9333EA), 'dark purple': Color(0xFF581C87), 'light purple': Color(0xFFC4B5FD),
      'lavender': Color(0xFFB6A4D6), 'mauve': Color(0xFFE0B0FF), 'plum': Color(0xFF8E4585),
      'violet': Color(0xFF7F00FF), 'lilac': Color(0xFFC8A2C8), 'amethyst': Color(0xFF9966CC),
      'indigo': Color(0xFF4B0082), 'periwinkle': Color(0xFFCCCCFF), 'magenta': Color(0xFFFF00FF),
    };
    if (map.containsKey(lower)) return map[lower]!;
    for (final entry in map.entries) {
      if (lower.contains(entry.key) || entry.key.contains(lower)) return entry.value;
    }
    return Color(0xFF6B7280);
  }

  String _hexFromName(String name) {
    final c = _getColorFromName(name);
    return '#${c.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  Color _getOccasionColor(String occasion) {
    final lower = occasion.toLowerCase();
    if (lower.contains('casual') || lower.contains('daily')) return const Color(0xFF34C759);
    if (lower.contains('college') || lower.contains('semi')) return const Color(0xFF007AFF);
    if (lower.contains('party') || lower.contains('evening')) return const Color(0xFFAF52DE);
    if (lower.contains('street') || lower.contains('urban')) return const Color(0xFFFF9500);
    return const Color(0xFF7C4DFF);
  }

  IconData _getOccasionIcon(String occasion) {
    final lower = occasion.toLowerCase();
    if (lower.contains('casual') || lower.contains('daily')) return Icons.coffee;
    if (lower.contains('college') || lower.contains('semi')) return Icons.school;
    if (lower.contains('party') || lower.contains('evening')) return Icons.celebration;
    if (lower.contains('street') || lower.contains('urban')) return Icons.location_city;
    return Icons.checkroom;
  }
}

class _SuggestionData {
  final String title;
  final String occasion;
  final String description;
  final List<String> items;
  final List<ColorSuggestion> colors;

  const _SuggestionData({
    required this.title,
    required this.occasion,
    required this.description,
    required this.items,
    required this.colors,
  });
}

class ColorSuggestion {
  final String name;
  final Color color;
  final String hex;
  final String usage;

  const ColorSuggestion({
    required this.name,
    required this.color,
    required this.hex,
    required this.usage,
  });
}
