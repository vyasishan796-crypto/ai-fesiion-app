import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class ColorPicker extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<String> onToggle;

  const ColorPicker({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  static const List<Map<String, dynamic>> colors = [
    {'name': 'Red', 'hex': '#FF0000', 'color': Color(0xFFFF0000)},
    {'name': 'Orange', 'hex': '#FF5722', 'color': Color(0xFFFF5722)},
    {'name': 'Amber', 'hex': '#FFC107', 'color': Color(0xFFFFC107)},
    {'name': 'Green', 'hex': '#4CAF50', 'color': Color(0xFF4CAF50)},
    {'name': 'Cyan', 'hex': '#00BCD4', 'color': Color(0xFF00BCD4)},
    {'name': 'Blue', 'hex': '#2196F3', 'color': Color(0xFF2196F3)},
    {'name': 'Indigo', 'hex': '#3F51B5', 'color': Color(0xFF3F51B5)},
    {'name': 'Purple', 'hex': '#9C27B0', 'color': Color(0xFF9C27B0)},
    {'name': 'Pink', 'hex': '#E91E63', 'color': Color(0xFFE91E63)},
    {'name': 'Brown', 'hex': '#795548', 'color': Color(0xFF795548)},
    {'name': 'Black', 'hex': '#000000', 'color': Color(0xFF000000)},
    {'name': 'White', 'hex': '#FFFFFF', 'color': Color(0xFFFFFFFF)},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Colors',
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
          children: colors.map((c) {
            final isSelected = selected.contains(c['hex']);
            return GestureDetector(
              onTap: () => onToggle(c['hex']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: c['color'],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (c['hex'] == '#FFFFFF'
                            ? AppColors.hairline
                            : Colors.transparent),
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 18,
                        color: Colors.white,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
