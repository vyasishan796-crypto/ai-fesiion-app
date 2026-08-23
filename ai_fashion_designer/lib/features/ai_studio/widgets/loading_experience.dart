import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class LoadingExperience extends StatelessWidget {
  final String message;
  final double progress;
  const LoadingExperience({super.key, required this.message, this.progress = 0.0});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(color: AppColors.accentPurple.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.auto_awesome_rounded, size: 32, color: AppColors.accentPurple),
        ),
        const SizedBox(height: 24),
        Text(message, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.ink), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text("Qwen-VL + Flux is creating your look...", style: GoogleFonts.inter(fontSize: 14, color: AppColors.inkMuted48), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        SizedBox(width: 240, child: LinearProgressIndicator(value: progress > 0 ? progress : null, backgroundColor: AppColors.dividerSoft, color: AppColors.accentPurple)),
        const SizedBox(height: 12),
        Text('${(progress * 100).round()}%', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accentPurple)),
      ],
    );
  }
}

class InlineLoading extends StatelessWidget {
  final String message;
  final Color? color;
  const InlineLoading({super.key, required this.message, this.color});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: color ?? AppColors.accentPurple)),
      const SizedBox(width: 12),
      Text(message, style: GoogleFonts.inter(fontSize: 15, color: color ?? AppColors.inkMuted48)),
    ]);
  }
}
