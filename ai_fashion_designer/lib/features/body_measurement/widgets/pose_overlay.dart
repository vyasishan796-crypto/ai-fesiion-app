import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PoseOverlayWidget extends StatefulWidget {
  final bool isActive;
  final double scanProgress;

  const PoseOverlayWidget({
    super.key,
    this.isActive = true,
    this.scanProgress = 0.0,
  });

  @override
  State<PoseOverlayWidget> createState() => _PoseOverlayWidgetState();
}

class _PoseOverlayWidgetState extends State<PoseOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
      animation: _pulseAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: _PoseOverlayPainter(
            isActive: widget.isActive,
            pulseValue: _pulseAnimation.value,
            scanProgress: widget.scanProgress,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _PoseOverlayPainter extends CustomPainter {
  final bool isActive;
  final double pulseValue;
  final double scanProgress;

  _PoseOverlayPainter({
    required this.isActive,
    required this.pulseValue,
    required this.scanProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBodyOutline(canvas, size);
    _drawGuides(canvas, size);
    _drawLandmarks(canvas, size);
  }

  void _drawBodyOutline(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isActive ? AppColors.primary : AppColors.mediumGrey)
          .withOpacity(0.4 * pulseValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final centerX = size.width / 2;
    final topY = size.height * 0.08;
    final bottomY = size.height * 0.92;
    final bodyWidth = size.width * 0.35;

    final path = Path();
    path.moveTo(centerX, topY);
    path.lineTo(centerX, topY + 20);
    path.quadraticBezierTo(
      centerX - bodyWidth * 0.3, topY + 25,
      centerX - bodyWidth * 0.5, topY + 50,
    );
    path.lineTo(centerX - bodyWidth, topY + 60);
    path.lineTo(centerX - bodyWidth * 0.9, topY + 120);
    path.lineTo(centerX - bodyWidth * 0.3, topY + 130);
    path.lineTo(centerX - bodyWidth * 0.25, bottomY - 60);
    path.lineTo(centerX - bodyWidth * 0.15, bottomY);
    path.lineTo(centerX + bodyWidth * 0.15, bottomY);
    path.lineTo(centerX + bodyWidth * 0.25, bottomY - 60);
    path.lineTo(centerX + bodyWidth * 0.3, topY + 130);
    path.lineTo(centerX + bodyWidth * 0.9, topY + 120);
    path.lineTo(centerX + bodyWidth, topY + 60);
    path.lineTo(centerX + bodyWidth * 0.5, topY + 50);
    path.quadraticBezierTo(
      centerX + bodyWidth * 0.3, topY + 25,
      centerX, topY + 20,
    );

    canvas.drawPath(path, paint);
  }

  void _drawGuides(Canvas canvas, Size size) {
    final guidePaint = Paint()
      ..color = AppColors.mediumGrey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final centerX = size.width / 2;

    canvas.drawLine(
      Offset(centerX - 40, size.height * 0.08),
      Offset(centerX + 40, size.height * 0.08),
      guidePaint,
    );

    canvas.drawLine(
      Offset(centerX - 40, size.height * 0.92),
      Offset(centerX + 40, size.height * 0.92),
      guidePaint,
    );

    final dashedPaint = Paint()
      ..color = AppColors.mediumGrey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (double y = size.height * 0.15; y < size.height * 0.85; y += 12) {
      canvas.drawLine(
        Offset(centerX, y),
        Offset(centerX, y + 6),
        dashedPaint,
      );
    }
  }

  void _drawLandmarks(Canvas canvas, Size size) {
    final pointPaint = Paint()
      ..color = (isActive ? AppColors.primary : AppColors.warning)
          .withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final topY = size.height * 0.12;

    final joints = [
      Offset(centerX, topY),
      Offset(centerX, topY + 30),
      Offset(centerX - 25, topY + 35),
      Offset(centerX + 25, topY + 35),
      Offset(centerX - 45, topY + 75),
      Offset(centerX + 45, topY + 75),
      Offset(centerX, topY + 150),
      Offset(centerX - 18, topY + 230),
      Offset(centerX + 18, topY + 230),
      Offset(centerX - 20, size.height * 0.88),
      Offset(centerX + 20, size.height * 0.88),
    ];

    for (final point in joints) {
      canvas.drawCircle(point, 4 * pulseValue, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PoseOverlayPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue ||
        oldDelegate.isActive != isActive;
  }
}
