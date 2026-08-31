import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import 'widgets/scan_quality_indicator.dart';

class ScanQualityScreen extends StatefulWidget {
  const ScanQualityScreen({super.key});

  @override
  State<ScanQualityScreen> createState() => _ScanQualityScreenState();
}

class _ScanQualityScreenState extends State<ScanQualityScreen> {
  double _overallQuality = 0.0;
  double _lightingQuality = 0.0;
  double _poseQuality = 0.0;
  double _clarityQuality = 0.0;
  bool _isAnalyzing = true;

  @override
  void initState() {
    super.initState();
    _analyzeScanQuality();
  }

  void _analyzeScanQuality() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _lightingQuality = 0.85;
        _poseQuality = 0.78;
        _clarityQuality = 0.82;
        _overallQuality = (_lightingQuality + _poseQuality + _clarityQuality) / 3;
        _isAnalyzing = false;
      });
    });
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
          'Scan Quality',
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
            const SizedBox(height: 28),
            if (_isAnalyzing)
              _buildAnalyzingState()
            else ...[
              _buildQualityIndicators(),
              const SizedBox(height: 28),
              _buildReadyCard(),
              const SizedBox(height: 24),
              _buildAnalyzeButton(context),
            ],
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
          'Analyzing Scan Quality',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We check your scan for optimal fit recommendations.',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: AppColors.inkSecondary,
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: -0.1);
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
            'Analyzing your scan...',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Checking lighting, pose, and clarity',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.inkMuted,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildQualityIndicators() {
    return Column(
      children: [
        ScanQualityIndicator(
          quality: _overallQuality,
          label: 'Overall Quality',
        ),
        const SizedBox(height: 12),
        ScanQualityIndicator(
          quality: _lightingQuality,
          label: 'Lighting',
          showDetails: false,
        ),
        const SizedBox(height: 12),
        ScanQualityIndicator(
          quality: _poseQuality,
          label: 'Pose Alignment',
          showDetails: false,
        ),
        const SizedBox(height: 12),
        ScanQualityIndicator(
          quality: _clarityQuality,
          label: 'Image Clarity',
          showDetails: false,
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildReadyCard() {
    return Container(
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
                  'Ready to Analyze',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your scan quality is good. Proceed for fit analysis.',
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
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildAnalyzeButton(BuildContext context) {
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
            context.push('/home/body-scan/processing');
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
    ).animate().fadeIn(delay: 500.ms);
  }
}
