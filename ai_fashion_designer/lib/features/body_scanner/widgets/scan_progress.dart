import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class ScanProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> steps;

  const ScanProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Step $currentStep of $totalSteps',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const Spacer(),
            Text(
              '${((currentStep / totalSteps) * 100).toInt()}%',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: currentStep / totalSteps,
            backgroundColor: AppColors.lightGrey,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(steps.length, (index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep - 1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.primary
                        : isCurrent
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.lightGrey,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: AppColors.white, size: 14)
                        : isCurrent
                            ? const SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              )
                            : Text(
                                '${index + 1}',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.inkMuted,
                                ),
                              ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    steps[index],
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                      color: isCompleted
                          ? AppColors.ink
                          : isCurrent
                              ? AppColors.primary
                              : AppColors.inkMuted,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
