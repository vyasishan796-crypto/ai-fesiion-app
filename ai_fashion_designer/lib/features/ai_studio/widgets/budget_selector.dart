import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/option_chip.dart';

class BudgetSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const BudgetSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const List<String> budgets = [
    '₹500 - 2K',
    '₹2K - 5K',
    '₹5K - 10K',
    '₹10K+',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget',
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
          children: budgets.map((budget) {
            return OptionChip(
              label: budget,
              isSelected: selected == budget,
              onTap: () => onSelected(budget),
            );
          }).toList(),
        ),
      ],
    );
  }
}
