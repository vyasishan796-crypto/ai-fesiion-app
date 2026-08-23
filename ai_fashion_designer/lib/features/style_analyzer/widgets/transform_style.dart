import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class TransformStyle extends StatefulWidget {
  final String originalStyle;
  final ValueChanged<String> onStyleSelected;

  const TransformStyle({
    super.key,
    required this.originalStyle,
    required this.onStyleSelected,
  });

  @override
  State<TransformStyle> createState() => _TransformStyleState();
}

class _TransformStyleState extends State<TransformStyle> {
  String? _selected;

  static const _styles = [
    'Formal',
    'Streetwear',
    'Luxury',
    'Minimal',
    'Party',
    'College',
    'Traditional',
  ];

  static const _styleIcons = {
    'Formal': Icons.business_center,
    'Streetwear': Icons.accessibility_new,
    'Luxury': Icons.diamond,
    'Minimal': Icons.minimize,
    'Party': Icons.celebration,
    'College': Icons.school,
    'Traditional': Icons.temple_hindu,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transform This Look',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1D1D1F),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Currently: ${widget.originalStyle}',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _styles.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final style = _styles[index];
              final isSelected = _selected == style;
              return GestureDetector(
                onTap: () => setState(() => _selected = style),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF7C4DFF)
                        : const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF7C4DFF)
                          : const Color(0xFFE8E8E8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _styleIcons[style],
                        size: 15,
                        color: isSelected ? Colors.white : const Color(0xFF7C4DFF),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        style,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(
                    delay: Duration(milliseconds: 60 * index),
                    duration: 300.ms,
                  );
            },
          ),
        ),
        if (_selected != null) ...[
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => widget.onStyleSelected(_selected!),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C4DFF), Color(0xFFB388FF)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C4DFF).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '✨ Create This Style',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
        ],
      ],
    );
  }
}
