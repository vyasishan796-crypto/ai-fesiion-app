import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class AIThinkingIndicator extends StatefulWidget {
  const AIThinkingIndicator({super.key});

  @override
  State<AIThinkingIndicator> createState() => _AIThinkingIndicatorState();
}

class _AIThinkingIndicatorState extends State<AIThinkingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  late Animation<double> _dot1;
  late Animation<double> _dot2;
  late Animation<double> _dot3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this)..repeat();
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 1.0, curve: Curves.easeInOut)),
    );
    _dot1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );
    _dot2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.6, curve: Curves.easeOut)),
    );
    _dot3 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.8, curve: Curves.easeOut)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 16,
                color: AppColors.primary.withOpacity(_glowAnimation.value),
              ),
              const SizedBox(width: 8),
              Text(
                'AI Stylist is thinking',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.primary.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 6),
              _buildDot(_dot1.value),
              const SizedBox(width: 3),
              _buildDot(_dot2.value),
              const SizedBox(width: 3),
              _buildDot(_dot3.value),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDot(double value) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.3 + (value * 0.7)),
        shape: BoxShape.circle,
      ),
    );
  }
}
