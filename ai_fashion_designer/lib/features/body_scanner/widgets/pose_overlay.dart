import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PoseOverlay extends StatefulWidget {
  final List<Offset> landmarks;
  final bool isAligned;
  final String feedback;

  const PoseOverlay({
    super.key,
    required this.landmarks,
    this.isAligned = false,
    this.feedback = '',
  });

  @override
  State<PoseOverlay> createState() => _PoseOverlayState();
}

class _PoseOverlayState extends State<PoseOverlay>
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
          painter: _PosePainter(
            landmarks: widget.landmarks,
            isAligned: widget.isAligned,
            pulseValue: _pulseAnimation.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _PosePainter extends CustomPainter {
  final List<Offset> landmarks;
  final bool isAligned;
  final double pulseValue;

  _PosePainter({
    required this.landmarks,
    required this.isAligned,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBodyOutline(canvas, size);
    _drawGuides(canvas, size);
    if (landmarks.isNotEmpty) {
      _drawLandmarks(canvas);
      _drawPoseConnections(canvas);
    }
  }

  void _drawBodyOutline(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isAligned ? AppColors.primary : AppColors.mediumGrey)
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
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

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

  void _drawLandmarks(Canvas canvas) {
    final pointPaint = Paint()
      ..color = isAligned ? AppColors.primary : AppColors.warning
      ..style = PaintingStyle.fill;

    for (final point in landmarks) {
      canvas.drawCircle(point, 4 * pulseValue, pointPaint);
      canvas.drawCircle(
        point,
        6 * pulseValue,
        Paint()
          ..color = (isAligned ? AppColors.primary : AppColors.warning)
              .withOpacity(0.3)
          ..style = PaintingStyle.fill,
      );
    }
  }

  void _drawPoseConnections(Canvas canvas) {
    if (landmarks.length < 14) return;

    final linePaint = Paint()
      ..color = (isAligned ? AppColors.primary : AppColors.warning)
          .withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final connections = [
      [0, 1], [0, 2], [1, 3], [2, 4], [1, 2],
      [5, 7], [6, 8], [7, 9], [8, 10], [9, 11], [10, 12],
    ];

    for (final conn in connections) {
      if (conn[0] < landmarks.length && conn[1] < landmarks.length) {
        canvas.drawLine(landmarks[conn[0]], landmarks[conn[1]], linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PosePainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue ||
        oldDelegate.isAligned != isAligned;
  }
}
