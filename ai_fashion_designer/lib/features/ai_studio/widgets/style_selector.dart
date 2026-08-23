import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/option_chip.dart';

class StyleSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const StyleSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const List<String> styles = [
    'Casual',
    'Formal',
    'Streetwear',
    'Ethnic',
    'Bohemian',
    'Minimal',
    'Vintage',
    'Sporty',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Style',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
            letterSpacing: -0.224,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: styles.map((style) {
            return OptionChip(
              label: style,
              isSelected: selected == style,
              onTap: () => onSelected(style),
            );
          }).toList(),
        ),
      ],
    );
  }
}
