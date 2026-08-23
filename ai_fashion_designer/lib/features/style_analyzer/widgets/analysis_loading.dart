import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class AnalysisLoading extends StatefulWidget {
  final String? imagePath;
  final VoidCallback? onCancel;

  const AnalysisLoading({super.key, this.imagePath, this.onCancel});

  @override
  State<AnalysisLoading> createState() => _AnalysisLoadingState();
}

class _AnalysisLoadingState extends State<AnalysisLoading>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  static const _stepDuration = Duration(milliseconds: 7000);

  final _steps = const [
    'Detecting clothing',
    'Analyzing colors',
    'Identifying style',
    'Creating recommendations',
  ];

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
    _startSteps();
  }

  void _startSteps() {
    Timer.periodic(_stepDuration, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _currentStep++;
        if (_currentStep >= _steps.length) {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            if (widget.imagePath != null)
              Positioned.fill(
                child: Image.file(
                  File(widget.imagePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.black),
                ),
              ),
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.55),
              ),
            ),
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _scanAnimation,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ScanPainter(
                      progress: _scanAnimation.value,
                      color: const Color(0xFF7C4DFF),
                    ),
                  );
                },
              ),
            ),
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF7C4DFF), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C4DFF).withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Color(0xFFB388FF),
                      size: 36,
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                        duration: 1200.ms,
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1.05, 1.05),
                      ),
                  const SizedBox(height: 32),
                  Text(
                    'Analyzing your style...',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Identifying clothing, colors, patterns\nand overall aesthetic.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ...List.generate(_steps.length, (index) {
                    final isDone = index < _currentStep;
                    final isCurrent = index == _currentStep;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 48),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone
                                  ? const Color(0xFF34C759)
                                  : isCurrent
                                      ? const Color(0xFF7C4DFF)
                                      : Colors.white.withOpacity(0.15),
                            ),
                            child: Center(
                              child: isDone
                                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                                  : isCurrent
                                      ? SizedBox(
                                          width: 12,
                                          height: 12,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white.withOpacity(0.8),
                                          ),
                                        )
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _steps[index],
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                              color: isDone
                                  ? const Color(0xFF34C759)
                                  : isCurrent
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            if (widget.onCancel != null)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: widget.onCancel,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ScanPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ScanPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.0),
          color.withOpacity(0.4),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, 40));

    final y = size.height * progress;
    canvas.drawRect(
      Rect.fromLTWH(0, y - 20, size.width, 40),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
