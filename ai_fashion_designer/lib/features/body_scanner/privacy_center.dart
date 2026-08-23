import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import 'widgets/privacy_data_card.dart';

class PrivacyCenter extends StatelessWidget {
  const PrivacyCenter({super.key});

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
          'Privacy Center',
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
            _buildDataSection(),
            const SizedBox(height: 28),
            _buildDeleteAllButton(context),
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
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Scan Data',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Manage your body scan information',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.inkSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saved Data',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 14),
        PrivacyDataCard(
          title: 'Scan Images',
          description: '2 images from your last scan',
          icon: Icons.camera_alt_outlined,
          onDelete: () {},
        ),
        const SizedBox(height: 10),
        PrivacyDataCard(
          title: 'Estimated Measurements',
          description: '8 measurements from AI analysis',
          icon: Icons.straighten,
          onDelete: () {},
        ),
        const SizedBox(height: 10),
        PrivacyDataCard(
          title: 'Fit Profile',
          description: 'Your size preferences and recommendations',
          icon: Icons.person_outline,
          onDelete: () {},
        ),
        const SizedBox(height: 10),
        PrivacyDataCard(
          title: 'Processing Status',
          description: 'Last scan completed successfully',
          icon: Icons.check_circle_outline,
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildDeleteAllButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          _showDeleteAllConfirmation(context);
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
            const SizedBox(width: 10),
            Text(
              'Delete All Scan Data',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  void _showDeleteAllConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete All Data?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will permanently delete all your scan images, measurements, and fit profile. This action cannot be undone.',
          style: GoogleFonts.inter(
            color: AppColors.inkSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppColors.inkSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All scan data deleted'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(
              'Delete All',
              style: GoogleFonts.inter(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
