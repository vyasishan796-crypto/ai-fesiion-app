import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import 'widgets/scan_progress.dart';
import 'services/scanner_service.dart';

class ScanProcessingScreen extends StatefulWidget {
  const ScanProcessingScreen({super.key});

  @override
  State<ScanProcessingScreen> createState() => _ScanProcessingScreenState();
}

class _ScanProcessingScreenState extends State<ScanProcessingScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  final int _totalSteps = 5;
  late AnimationController _controller;
  late Animation<double> _scanLineAnimation;

  final List<String> _steps = [
    'Detecting pose landmarks',
    'Checking scan quality',
    'Estimating clothing-fit parameters',
    'Preparing recommendations',
    'Creating your fashion profile',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _startProcessing();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startProcessing() {
    Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _currentStep++;
      });
      if (_currentStep >= _totalSteps) {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.push('/body-scan/result');
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoal,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              _buildScanAnimation(),
              const SizedBox(height: 48),
              _buildTitle(),
              const SizedBox(height: 32),
              _buildProgress(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanAnimation() {
    return SizedBox(
      width: 200,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 160,
            height: 240,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(80),
            ),
          ),
          Positioned(
            top: 40,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: AppColors.primary.withOpacity(0.6),
                size: 24,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _scanLineAnimation,
            builder: (context, child) {
              return Positioned(
                top: 20 + (_scanLineAnimation.value * 220),
                left: 20,
                right: 20,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.0),
                        AppColors.primary.withOpacity(0.8),
                        AppColors.primary.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          ..._buildScanDots(),
        ],
      ),
    );
  }

  List<Widget> _buildScanDots() {
    final dots = <Widget>[];
    final positions = [
      const Offset(100, 40),
      const Offset(60, 65),
      const Offset(140, 65),
      const Offset(55, 100),
      const Offset(145, 100),
      const Offset(100, 150),
      const Offset(85, 220),
      const Offset(115, 220),
    ];

    for (int i = 0; i < positions.length; i++) {
      dots.add(
        Positioned(
          left: positions[i].dx - 4,
          top: positions[i].dy - 4,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentStep > 0
                  ? AppColors.primary.withOpacity(0.6 + (_currentStep * 0.08))
                  : AppColors.mediumGrey.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }
    return dots;
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'Analyzing Your Fit Profile...',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'This usually takes a few seconds',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.inkOnDarkMuted,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildProgress() {
    return ScanProgress(
      currentStep: _currentStep,
      totalSteps: _totalSteps,
      steps: _steps,
    ).animate().fadeIn(delay: 400.ms);
  }
}
