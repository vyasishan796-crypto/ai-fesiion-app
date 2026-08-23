import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/body_scan_service.dart';
import '../../core/widgets/apple_button.dart';
import 'widgets/scan_result.dart';

class BodyScanScreen extends StatefulWidget {
  const BodyScanScreen({super.key});

  @override
  State<BodyScanScreen> createState() => _BodyScanScreenState();
}

class _BodyScanScreenState extends State<BodyScanScreen> {
  File? _bodyImage;
  bool _isLoading = false;
  BodyProfile? _profile;

  final BodyScanService _bodyScanService = BodyScanService();

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _bodyImage = File(pickedFile.path);
        _profile = null;
      });
    }
  }

  Future<void> _scanBody() async {
    if (_bodyImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a photo first'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _profile = null;
    });

    try {
      final imageBytes = await _bodyImage!.readAsBytes();
      final profile = await _bodyScanService.scanBody(imageBytes);
      setState(() {
        _profile = profile;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text('Camera', style: GoogleFonts.inter()),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('Gallery', style: GoogleFonts.inter()),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Body Scan',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'Your Body Profile',
                      style: GoogleFonts.inter(
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                        letterSpacing: 0,
                      ),
                    ).animate().fadeIn().slideY(begin: -0.1),

                    const SizedBox(height: 8),

                    Text(
                      'Get personalized size recommendations',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        color: AppColors.inkMuted48,
                      ),
                    ).animate().fadeIn(delay: 100.ms),

                    const SizedBox(height: 24),

                    // Photo upload
                    GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        width: double.infinity,
                        height: 250,
                        decoration: BoxDecoration(
                          color: _bodyImage != null
                              ? AppColors.canvasParchment
                              : AppColors.canvas,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: _bodyImage != null
                                ? AppColors.primary
                                : AppColors.hairline,
                            width: _bodyImage != null ? 2 : 1,
                          ),
                        ),
                        child: _bodyImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(
                                  _bodyImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.accessibility_new,
                                    size: 64,
                                    color: AppColors.inkMuted48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Tap to upload full body photo',
                                    style: GoogleFonts.inter(
                                      fontSize: 17,
                                      color: AppColors.inkMuted48,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 16),

                    // Tips
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.canvasParchment,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tips for best results:',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildTip('Stand straight facing the camera'),
                          _buildTip('Wear fitted clothes'),
                          _buildTip('Full body should be in frame'),
                          _buildTip('Good lighting helps accuracy'),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: 24),

                    // Scan button
                    SizedBox(
                      width: double.infinity,
                      child: AppleButton(
                        label: _isLoading ? 'Scanning...' : 'Scan Body',
                        icon: _isLoading ? null : Icons.straighten,
                        onPressed: _isLoading ? null : _scanBody,
                      ),
                    ).animate().fadeIn(delay: 400.ms),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Result area (light tile)
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.canvasParchment,
                ),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
                child: ScanResult(
                  profile: _profile,
                  isLoading: _isLoading,
                ).animate().fadeIn(delay: 500.ms),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.inkMuted48,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.inkMuted48,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
