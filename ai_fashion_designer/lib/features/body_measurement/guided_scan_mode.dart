import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';

class GuidedScanMode extends StatefulWidget {
  const GuidedScanMode({super.key});

  @override
  State<GuidedScanMode> createState() => _GuidedScanModeState();
}

class _GuidedScanModeState extends State<GuidedScanMode> {
  int _currentPhoto = 1;
  final int _totalPhotos = 2;
  String? _frontImagePath;
  String? _sideImagePath;
  String _gender = 'Men';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    if (extra != null && extra is Map<String, dynamic>) {
      _frontImagePath = extra['imagePath'] as String?;
      _gender = extra['gender'] as String? ?? 'Men';
    }
  }

  Future<void> _capturePhoto() async {
    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (photo != null && mounted) {
        setState(() {
          if (_currentPhoto == 1) {
            _frontImagePath = photo.path;
          } else {
            _sideImagePath = photo.path;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera access denied.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image != null && mounted) {
        setState(() {
          if (_currentPhoto == 1) {
            _frontImagePath = image.path;
          } else {
            _sideImagePath = image.path;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not pick image.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _nextStep() {
    HapticFeedback.heavyImpact();
    if (_currentPhoto == 1) {
      setState(() => _currentPhoto = 2);
    } else {
      context.push('/body-measurement/quality', extra: {
        'frontImagePath': _frontImagePath,
        'sideImagePath': _sideImagePath,
        'gender': _gender,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          'GUIDED SCAN',
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 2),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildProgressIndicator(),
            const SizedBox(height: 28),
            _buildCurrentStep(),
            const SizedBox(height: 28),
            _buildPhotoPreview(),
            const SizedBox(height: 20),
            _buildPhotoSourceButtons(),
            const SizedBox(height: 16),
            _buildContinueButton(),
            const SizedBox(height: 16),
            if (_currentPhoto == 2) _buildSkipButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _buildStepDot(1, _frontImagePath != null),
        Expanded(
          child: Container(
            height: 2,
            color: _frontImagePath != null ? AppColors.primary : AppColors.border,
          ),
        ),
        _buildStepDot(2, _sideImagePath != null),
      ],
    ).animate().fadeIn();
  }

  Widget _buildStepDot(int step, bool isCompleted) {
    final isCurrent = step == _currentPhoto;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.primary
            : isCurrent
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.lightGrey,
        shape: BoxShape.circle,
        border: isCurrent
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: AppColors.white, size: 16)
            : Text(
                '$step',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isCurrent ? AppColors.primary : AppColors.inkMuted,
                ),
              ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    final isFront = _currentPhoto == 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isFront ? 'Front View' : 'Side View',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isFront
              ? 'Stand facing the camera with arms slightly away from your body.'
              : 'Turn to your side and stand naturally. This helps improve measurement accuracy.',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: AppColors.inkSecondary,
            height: 1.5,
          ),
        ),
        if (!isFront) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'An additional angle can improve garment-fit estimation.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildPhotoPreview() {
    final currentPath = _currentPhoto == 1 ? _frontImagePath : _sideImagePath;
    final hasPhoto = currentPath != null;

    return Container(
      width: double.infinity,
      height: 350,
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasPhoto ? AppColors.primary : AppColors.border,
          width: hasPhoto ? 2 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (hasPhoto)
              Image.file(
                File(currentPath!),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              )
            else
              Icon(
                _currentPhoto == 1 ? Icons.person : Icons.person_off,
                size: 80,
                color: AppColors.mediumGrey.withOpacity(0.3),
              ),
            Positioned(
              top: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.charcoal.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hasPhoto
                      ? '${_currentPhoto == 1 ? "Front" : "Side"} - Captured'
                      : '${_currentPhoto == 1 ? "Front" : "Side"} View',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.charcoal.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_currentPhoto / $_totalPhotos',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildPhotoSourceButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              onPressed: _capturePhoto,
              icon: const Icon(Icons.camera_alt, size: 18),
              label: Text(
                'Camera',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.photo_library, size: 18),
              label: Text(
                'Gallery',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 350.ms);
  }

  Widget _buildContinueButton() {
    final hasPhoto = _currentPhoto == 1 ? _frontImagePath != null : _sideImagePath != null;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: GestureDetector(
        onTap: hasPhoto ? _nextStep : null,
        child: Container(
          decoration: BoxDecoration(color: hasPhoto ? Colors.black : Colors.grey[300], borderRadius: BorderRadius.circular(30)),
          child: Center(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(_currentPhoto == 1 ? Icons.arrow_forward_rounded : Icons.auto_awesome_rounded, color: hasPhoto ? Colors.white : AppColors.inkMuted48, size: 20),
              const SizedBox(width: 10),
              Text(_currentPhoto == 1 ? 'CONTINUE' : 'START ANALYSIS', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: hasPhoto ? Colors.white : AppColors.inkMuted48, letterSpacing: 1)),
            ]),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildSkipButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          context.push('/body-measurement/quality', extra: {
            'frontImagePath': _frontImagePath,
            'sideImagePath': null,
            'gender': _gender,
          });
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          'Skip Side View',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.inkSecondary,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 500.ms);
  }
}
