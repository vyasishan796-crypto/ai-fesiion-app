import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';

class PromptInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const PromptInput({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Describe your dream outfit',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
            letterSpacing: -0.224,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.canvas,
            borderRadius: AppRadius.pill,
            border: Border.all(color: AppColors.hairline),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: 2,
            minLines: 1,
            style: GoogleFonts.inter(
              fontSize: 17,
              color: AppColors.ink,
              letterSpacing: -0.374,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. A blue floral summer dress with bell sleeves...',
              hintStyle: GoogleFonts.inter(
                fontSize: 17,
                color: AppColors.inkMuted48,
                letterSpacing: -0.374,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              prefixIcon: const Icon(
                Icons.edit_outlined,
                color: AppColors.inkMuted48,
                size: 20,
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 44,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
