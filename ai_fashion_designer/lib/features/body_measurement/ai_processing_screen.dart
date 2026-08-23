import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import 'services/body_measurement_service.dart';
import 'models/body_measurement.dart';

class AIProcessingScreen extends StatefulWidget {
  const AIProcessingScreen({super.key});

  @override
  State<AIProcessingScreen> createState() => _AIProcessingScreenState();
}

class _AIProcessingScreenState extends State<AIProcessingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _currentStep = 0;
  String? _frontImagePath;
  String? _sideImagePath;
  String _gender = 'Men';
  bool _hasError = false;
  String _errorMessage = '';

  final List<String> _steps = [
    'Analyzing your photo with AI...',
    'Detecting body proportions...',
    'Estimating measurements...',
    'Building your fit profile...',
    'Finding best size recommendations...',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    if (extra != null && extra is Map<String, dynamic>) {
      final front = extra['frontImagePath'] as String?;
      final side = extra['sideImagePath'] as String?;
      final gender = extra['gender'] as String?;
      if (front != _frontImagePath) {
        _frontImagePath = front;
        _sideImagePath = side;
        _gender = gender ?? 'Men';
        _startProcessing();
      }
    }
  }

  void _startProcessing() async {
    try {
      for (int i = 0; i < _steps.length; i++) {
        if (!mounted) return;
        setState(() => _currentStep = i);
        await Future.delayed(const Duration(milliseconds: 1200));
      }

      if (!mounted) return;

      final service = BodyMeasurementService();
      final profile = await service.analyzePhotos(
        frontImagePath: _frontImagePath,
        sideImagePath: _sideImagePath,
        gender: _gender,
      );

      if (!mounted) return;
      context.pushReplacement('/body-measurement/result', extra: {
        'profile': profile,
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              if (_hasError) _buildErrorState() else _buildProcessingVisual(),
              const Spacer(),
              if (!_hasError) _buildStepIndicator(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.error.withOpacity(0.1),
            border: Border.all(color: AppColors.error.withOpacity(0.3), width: 2),
          ),
          child: const Icon(Icons.error_outline, color: AppColors.error, size: 48),
        ),
        const SizedBox(height: 24),
        Text(
          'Analysis Failed',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _errorMessage.isNotEmpty
              ? 'Could not analyze your photo. Please try again.'
              : 'Something went wrong.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.inkSecondary,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'Go Back',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingVisual() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.05),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Center(
            child: Container(
              width: 140 * _pulseAnimation.value,
              height: 140 * _pulseAnimation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3 * _pulseAnimation.value),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.straighten,
                color: AppColors.white.withOpacity(0.9),
                size: 48,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analyzing Your Measurements',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'AI is analyzing your body measurements...',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.inkSecondary,
          ),
        ),
        const SizedBox(height: 24),
        ...List.generate(_steps.length, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.success
                        : isCurrent
                            ? AppColors.primary
                            : AppColors.lightGrey,
                    shape: BoxShape.circle,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, color: AppColors.white, size: 14)
                      : isCurrent
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _steps[index],
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                      color: isCompleted
                          ? AppColors.success
                          : isCurrent
                              ? AppColors.ink
                              : AppColors.inkMuted,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }
}
