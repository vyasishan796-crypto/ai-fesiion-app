import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import 'services/pose_detection_service.dart';
import 'widgets/pose_overlay.dart';

class BodyScannerCamera extends StatefulWidget {
  const BodyScannerCamera({super.key});

  @override
  State<BodyScannerCamera> createState() => _BodyScannerCameraState();
}

class _BodyScannerCameraState extends State<BodyScannerCamera> {
  final PoseDetectionService _poseService = PoseDetectionService();
  List<Offset> _landmarks = [];
  String _feedback = 'Position yourself inside the frame';
  bool _isAligned = false;
  bool _isScanning = false;
  int _scanAngle = 1;
  int _totalAngles = 2;
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    _startPoseDetection();
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    super.dispose();
  }

  void _startPoseDetection() {
    _scanTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) return;
      setState(() {
        _landmarks = _poseService.generateMockPose(
          const Size(300, 500),
        );
        _feedback = _poseService.getPoseFeedback(
          _landmarks,
          const Size(300, 500),
        );
        _isAligned = _poseService.isPoseAligned(
          _landmarks,
          const Size(300, 500),
        );
      });
    });
  }

  void _captureScan() {
    if (_isScanning) return;
    setState(() => _isScanning = true);

    HapticFeedback.heavyImpact();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_scanAngle < _totalAngles) {
        setState(() {
          _scanAngle++;
          _isScanning = false;
          _feedback = 'Great! Now turn to the side';
        });
      } else {
        context.push('/home/body-scan/quality');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildCameraPreview(),
          _buildOverlay(),
          _buildTopBar(),
          _buildBottomBar(),
          if (_isScanning) _buildScanningOverlay(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Container(
      color: const Color(0xFF1A1A2E),
      child: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
                Colors.black.withOpacity(0.3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        height: MediaQuery.of(context).size.height * 0.8,
        child: PoseOverlay(
          landmarks: _landmarks,
          isAligned: _isAligned,
          feedback: _feedback,
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          MediaQuery.of(context).padding.top + 12,
          16,
          16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.white, size: 28),
                  onPressed: () => context.pop(),
                ),
                Expanded(
                  child: Text(
                    'AI BODY SCAN',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$_scanAngle / $_totalAngles',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryLight,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _isAligned
                    ? AppColors.success.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isAligned
                      ? AppColors.success.withOpacity(0.5)
                      : Colors.white.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isAligned ? Icons.check_circle : Icons.info_outline,
                    color: _isAligned ? AppColors.success : AppColors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _feedback,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _isAligned ? AppColors.success : AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (_scanAngle > 1)
                  _buildSkipButton()
                else
                  const SizedBox(width: 80),
                _buildCaptureButton(),
                const SizedBox(width: 80),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _isScanning ? null : _captureScan,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white, width: 4),
        ),
        child: Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isScanning ? AppColors.mediumGrey : AppColors.white,
          ),
          child: _isScanning
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.charcoal,
                    strokeWidth: 3,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return GestureDetector(
      onTap: () {
        context.push('/home/body-scan/quality');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Skip',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildScanningOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.charcoal,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Capturing...',
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
    ).animate().fadeIn();
  }
}
