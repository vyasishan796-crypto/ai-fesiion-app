import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../models/chat_message.dart';

class QuickActionChips extends StatelessWidget {
  final List<QuickAction> actions;

  const QuickActionChips({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final action = actions[index];
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              action.onTap();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(action.icon, size: 14, color: AppColors.primary),
                  const SizedBox(width: 5),
                  Text(
                    action.label,
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
