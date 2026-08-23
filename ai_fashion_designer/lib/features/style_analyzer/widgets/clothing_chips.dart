import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class ClothingChips extends StatelessWidget {
  final List<String> items;

  const ClothingChips({super.key, required this.items});

  static const _icons = {
    'jacket': Icons.checkroom,
    'coat': Icons.checkroom,
    'shirt': Icons.dry_cleaning,
    't-shirt': Icons.dry_cleaning,
    'tee': Icons.dry_cleaning,
    'top': Icons.dry_cleaning,
    'blouse': Icons.dry_cleaning,
    'sweater': Icons.dry_cleaning,
    'hoodie': Icons.dry_cleaning,
    'jean': Icons.directions_walk,
    'pant': Icons.directions_walk,
    'trouser': Icons.directions_walk,
    'short': Icons.directions_walk,
    'skirt': Icons.directions_walk,
    'shoe': Icons.hiking,
    'sneaker': Icons.hiking,
    'boot': Icons.hiking,
    'sandal': Icons.hiking,
    'watch': Icons.watch,
    'ring': Icons.diamond,
    'chain': Icons.link,
    'necklace': Icons.diamond,
    'glasses': Icons.visibility,
    'cap': Icons.face,
    'hat': Icons.face,
    'bag': Icons.shopping_bag,
    'backpack': Icons.shopping_bag,
  };

  IconData _getIcon(String item) {
    final lower = item.toLowerCase();
    for (final entry in _icons.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return Icons.checkroom;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DETECTED CLOTHING',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: const Color(0xFF1D1D1F),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(items.length, (index) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getIcon(items[index]),
                    size: 16,
                    color: const Color(0xFF1D1D1F),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    items[index],
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1D1D1F),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(
                  delay: Duration(milliseconds: 60 * index),
                  duration: 300.ms,
                ).slideX(begin: 0.1, duration: 300.ms);
          }),
        ),
      ],
    );
  }
}
