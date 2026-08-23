import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import 'services/body_measurement_service.dart';

class BodyMeasurementPrivacyScreen extends StatefulWidget {
  const BodyMeasurementPrivacyScreen({super.key});

  @override
  State<BodyMeasurementPrivacyScreen> createState() => _BodyMeasurementPrivacyScreenState();
}

class _BodyMeasurementPrivacyScreenState extends State<BodyMeasurementPrivacyScreen> {
  bool _autoDelete = true;
  bool _shareAnalytics = false;

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
          'Privacy Settings',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildHeader(),
            const SizedBox(height: 24),
            _buildDataCard(),
            const SizedBox(height: 20),
            _buildSettingsCard(),
            const SizedBox(height: 20),
            _buildDeleteButton(),
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
            const Icon(Icons.shield, color: AppColors.primary, size: 28),
            const SizedBox(width: 10),
            Text(
              'Your Data, Your Control',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'We value your privacy. Your body measurements are stored securely and deleted automatically.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.inkSecondary,
            height: 1.5,
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildDataCard() {
    final items = [
      {'label': 'Profile Photos', 'desc': 'Deleted after analysis', 'icon': Icons.photo_camera},
      {'label': 'Body Measurements', 'desc': 'Encrypted, stored locally', 'icon': Icons.straighten},
      {'label': 'Size Preferences', 'desc': 'Used for recommendations', 'icon': Icons.checkroom},
      {'label': 'Fit History', 'desc': 'Kept for 30 days', 'icon': Icons.history},
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
            'What We Store',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 14),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item['icon'] as IconData, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['label'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        item['desc'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildSettingsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Privacy Settings',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 14),
          _buildSwitchTile(
            'Auto-Delete Photos',
            'Automatically delete photos after analysis',
            _autoDelete,
            (val) => setState(() => _autoDelete = val),
          ),
          const Divider(height: 1),
          _buildSwitchTile(
            'Share Anonymous Analytics',
            'Help us improve the app',
            _shareAnalytics,
            (val) => setState(() => _shareAnalytics = val),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (val) {
              HapticFeedback.lightImpact();
              onChanged(val);
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          _showDeleteDialog();
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          'Delete All My Data',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.error,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete All Data?',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'This will permanently delete all your body measurements, photos, and fit history. This action cannot be undone.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.inkSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.inkMuted,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await BodyMeasurementService().deleteAll();
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'All data deleted successfully',
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            child: Text(
              'Delete',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
