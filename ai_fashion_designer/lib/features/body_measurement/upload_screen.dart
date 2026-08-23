import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';

class BodyMeasurementUpload extends StatefulWidget {
  const BodyMeasurementUpload({super.key});

  @override
  State<BodyMeasurementUpload> createState() => _BodyMeasurementUploadState();
}

class _BodyMeasurementUploadState extends State<BodyMeasurementUpload> {
  String _gender = 'Men';

  Future<void> _pickFromCamera(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (photo != null && context.mounted) {
        context.push('/body-measurement/guided', extra: {
          'imagePath': photo.path,
          'photoNumber': 1,
          'gender': _gender,
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera access denied. Please allow camera permission.'), backgroundColor: Colors.black),
        );
      }
    }
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image != null && context.mounted) {
        context.push('/body-measurement/guided', extra: {
          'imagePath': image.path,
          'photoNumber': 1,
          'gender': _gender,
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick image. Please try again.'), backgroundColor: Colors.black),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text('BODY SCAN', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 2)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildGenderToggle(),
            const SizedBox(height: 24),
            _buildPhotoRequirements(),
            const SizedBox(height: 24),
            _buildExampleFrame(),
            const SizedBox(height: 24),
            _buildUploadButtons(context),
            const SizedBox(height: 20),
            _buildPrivacyNote(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AI BODY SCAN', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        Text('Upload a full-body photo and let AI create your fashion fit profile.', style: GoogleFonts.inter(fontSize: 14, color: AppColors.inkMuted48, height: 1.5)),
      ],
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildGenderToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SELECT GENDER', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 1)),
        const SizedBox(height: 12),
        Container(
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: ['Men', 'Women'].map((g) {
              final isSelected = _gender == g;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _gender = g);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(color: isSelected ? Colors.black : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                    child: Center(
                      child: Text(g.toUpperCase(), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.inkMuted48, letterSpacing: 1)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoRequirements() {
    final requirements = ['Full body visible', 'Head and feet visible', 'Good lighting', 'Camera straight-on', 'Minimal obstruction', 'Standing naturally'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PHOTO REQUIREMENTS', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 1)),
        const SizedBox(height: 14),
        ...requirements.map((req) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Container(width: 22, height: 22, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle), child: const Icon(Icons.check_rounded, color: Colors.white, size: 12)),
                const SizedBox(width: 10),
                Text(req, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black)),
              ]),
            )),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildExampleFrame() {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!, width: 1.5)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120, height: 220,
            decoration: BoxDecoration(border: Border.all(color: Colors.black.withOpacity(0.15), width: 2), borderRadius: BorderRadius.circular(60)),
          ),
          Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle), child: const Icon(Icons.person_rounded, color: Colors.white, size: 22)),
          Positioned(top: 16, right: 24, child: _buildFrameLabel('HEAD')),
          Positioned(bottom: 16, right: 24, child: _buildFrameLabel('FEET')),
          Positioned(left: 16, child: _buildFrameLabel('SIDE')),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildFrameLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1)),
    );
  }

  Widget _buildUploadButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _pickFromCamera(context);
            },
            child: Container(
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30)),
              child: Center(
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text('TAKE PHOTO', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1)),
                ]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _pickFromGallery(context);
            },
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1.5), borderRadius: BorderRadius.circular(30)),
              child: Center(
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.photo_library_rounded, color: Colors.black, size: 20),
                  const SizedBox(width: 10),
                  Text('CHOOSE FROM GALLERY', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black, letterSpacing: 1)),
                ]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _useDemoPhoto(context);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(30)),
            child: Center(child: Text('TRY WITH DEMO PHOTO', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black, letterSpacing: 1))),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  void _useDemoPhoto(BuildContext context) async {
    final demoDir = Directory.systemTemp;
    final demoFile = File('${demoDir.path}/demo_body_scan.jpg');
    final demoBytes = _createDemoJpeg();
    await demoFile.writeAsBytes(demoBytes);
    if (context.mounted) {
      context.push('/body-measurement/guided', extra: {'imagePath': demoFile.path, 'photoNumber': 1, 'isDemo': true, 'gender': _gender});
    }
  }

  List<int> _createDemoJpeg() {
    return [
      0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01, 0x01, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43, 0x00, 0x08, 0x06, 0x06, 0x07, 0x06, 0x05, 0x08, 0x07, 0x07, 0x07, 0x09, 0x09, 0x08, 0x0A, 0x0C, 0x14, 0x0D, 0x0C, 0x0B, 0x0B, 0x0C, 0x19, 0x12, 0x13, 0x0F, 0x14, 0x1D, 0x1A, 0x1F, 0x1E, 0x1D, 0x1A, 0x1C, 0x1C, 0x20, 0x24, 0x2E, 0x27, 0x20, 0x22, 0x2C, 0x23, 0x1C, 0x1C, 0x28, 0x37, 0x29, 0x2C, 0x30, 0x31, 0x34, 0x34, 0x34, 0x1F, 0x27, 0x39, 0x3D, 0x38, 0x32, 0x3C, 0x2E, 0x33, 0x34, 0x32, 0xFF, 0xC0, 0x00, 0x0B, 0x08, 0x00, 0x01, 0x00, 0x01, 0x01, 0x01, 0x11, 0x00, 0xFF, 0xC4, 0x00, 0x1F, 0x00, 0x00, 0x01, 0x05, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0xFF, 0xC4, 0x00, 0xB5, 0x10, 0x00, 0x02, 0x01, 0x03, 0x03, 0x02, 0x04, 0x03, 0x05, 0x05, 0x04, 0x04, 0x00, 0x00, 0x01, 0x7D, 0x01, 0x02, 0x03, 0x00, 0x04, 0x11, 0x05, 0x12, 0x21, 0x31, 0x41, 0x06, 0x13, 0x51, 0x61, 0x07, 0x22, 0x71, 0x14, 0x32, 0x81, 0x91, 0xA1, 0x08, 0x23, 0x42, 0xB1, 0xC1, 0x15, 0x52, 0xD1, 0xF0, 0x24, 0x33, 0x62, 0x72, 0x82, 0x09, 0x0A, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4A, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5A, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6A, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7A, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8A, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9A, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6, 0xA7, 0xA8, 0xA9, 0xAA, 0xB2, 0xB3, 0xB4, 0xB5, 0xB6, 0xB7, 0xB8, 0xB9, 0xBA, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7, 0xC8, 0xC9, 0xCA, 0xD2, 0xD3, 0xD4, 0xD5, 0xD6, 0xD7, 0xD8, 0xD9, 0xDA, 0xE1, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6, 0xE7, 0xE8, 0xE9, 0xEA, 0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7, 0xF8, 0xF9, 0xFA, 0xFF, 0xDA, 0x00, 0x08, 0x01, 0x01, 0x00, 0x00, 0x3F, 0x00, 0x7B, 0x94, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xD9,
    ];
  }

  Widget _buildPrivacyNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
      child: Row(children: [
        const Icon(Icons.shield_outlined, color: Colors.black, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text('Your photos are processed securely and deleted after analysis.', style: GoogleFonts.inter(fontSize: 11, color: AppColors.inkMuted48, height: 1.4))),
      ]),
    ).animate().fadeIn(delay: 500.ms);
  }
}
