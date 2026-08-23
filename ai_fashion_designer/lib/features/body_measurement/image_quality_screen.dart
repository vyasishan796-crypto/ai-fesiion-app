import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import 'models/body_measurement.dart';
import 'services/image_analyzer.dart';

class ImageQualityScreen extends StatefulWidget {
  const ImageQualityScreen({super.key});

  @override
  State<ImageQualityScreen> createState() => _ImageQualityScreenState();
}

class _ImageQualityScreenState extends State<ImageQualityScreen> {
  final ImageAnalyzer _analyzer = ImageAnalyzer();
  ImageQualityResult? _result;
  bool _isAnalyzing = true;
  String? _frontImagePath;
  String? _sideImagePath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra;
      if (extra != null && extra is Map<String, dynamic>) {
        _frontImagePath = extra['frontImagePath'] as String?;
        _sideImagePath = extra['sideImagePath'] as String?;
      }
      _analyzeImage();
    });
  }

  void _analyzeImage() async {
    final result = await _analyzer.analyzeImageQuality(_frontImagePath ?? 'mock');
    if (mounted) {
      setState(() {
        _result = result;
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.charcoal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Image Quality',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildHeader(),
            const SizedBox(height: 16),
            if (_frontImagePath != null) _buildImagePreview(),
            const SizedBox(height: 28),
            if (_isAnalyzing)
              _buildAnalyzingState()
            else if (_result != null && _result!.isAcceptable)
              _buildSuccessState()
            else if (_result != null)
              _buildFailureState(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Checking Image Quality',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We analyze your photo for optimal measurement accuracy.',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: AppColors.inkSecondary,
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.file(
          File(_frontImagePath!),
          fit: BoxFit.cover,
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildAnalyzingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Analyzing your photo...',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Checking quality, lighting, and framing',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.inkMuted,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildSuccessState() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.success.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: AppColors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Image Quality: Good',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your photo is suitable for measurement analysis.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.inkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildQualityDetails(),
        const SizedBox(height: 28),
        _buildContinueButton(),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildQualityDetails() {
    final checks = [
      {'label': 'Full Body Visible', 'value': _result!.isFullBodyVisible},
      {'label': 'Head Visible', 'value': _result!.isHeadVisible},
      {'label': 'Feet Visible', 'value': _result!.isFeetVisible},
      {'label': 'Good Lighting', 'value': _result!.isLightingGood},
      {'label': 'Image Sharpness', 'value': _result!.isSharpnessGood},
      {'label': 'Camera Angle', 'value': _result!.isAngleGood},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quality Checks',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          ...checks.map((check) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  check['value'] as bool ? Icons.check_circle : Icons.cancel,
                  color: check['value'] as bool ? AppColors.success : AppColors.error,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  check['label'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFailureState() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.error.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: AppColors.white, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                'Image Quality Issue',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We can\'t clearly estimate your fit profile from this photo.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.inkSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_result!.issues.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Issues Found',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 12),
                ..._result!.issues.map((issue) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber, color: AppColors.warning, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          issue,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        const SizedBox(height: 16),
        _buildPhotoTips(),
        const SizedBox(height: 28),
        _buildRetryButtons(),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildPhotoTips() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Tips for Better Photos',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem('Stand 2-3 meters from camera'),
          _buildTipItem('Make sure head AND feet are visible'),
          _buildTipItem('Use good lighting (not too dark/bright)'),
          _buildTipItem('Stand straight, face the camera'),
          _buildTipItem('Wear fitted clothes for better accuracy'),
          _buildTipItem('Use a plain background if possible'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.inkSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            context.push('/body-measurement/processing', extra: {
              'frontImagePath': _frontImagePath,
              'sideImagePath': _sideImagePath,
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                'Start AI Analysis',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRetryButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.push('/body-measurement/upload');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Retake Photo',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push('/body-measurement/upload');
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Choose Another Photo',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
