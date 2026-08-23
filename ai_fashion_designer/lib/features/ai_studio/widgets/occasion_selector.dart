import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/option_chip.dart';

class OccasionSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const OccasionSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const List<String> occasions = [
    'Wedding',
    'Office',
    'Party',
    'Date',
    'Festival',
    'Travel',
    'Casual',
    'Gym',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Occasion',
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
          children: occasions.map((occasion) {
            return OptionChip(
              label: occasion,
              isSelected: selected == occasion,
              onTap: () => onSelected(occasion),
            );
          }).toList(),
        ),
      ],
    );
  }
}
