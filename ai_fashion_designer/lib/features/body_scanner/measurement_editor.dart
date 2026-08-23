import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import 'models/fit_profile.dart';
import 'services/scanner_service.dart';

class MeasurementEditor extends StatefulWidget {
  const MeasurementEditor({super.key});

  @override
  State<MeasurementEditor> createState() => _MeasurementEditorState();
}

class _MeasurementEditorState extends State<MeasurementEditor> {
  final ScannerService _scannerService = ScannerService();
  late FitProfile _profile;
  late Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _profile = _scannerService.generateFitProfile({});
    for (final m in _profile.measurements) {
      _controllers[m.name] = TextEditingController(
        text: m.value?.toStringAsFixed(1) ?? '',
      );
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _saveChanges() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Measurements saved successfully'),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
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
          'Edit Measurements',
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
            const SizedBox(height: 8),
            _buildPrivacyNote(),
            const SizedBox(height: 24),
            _buildMeasurementFields(),
            const SizedBox(height: 28),
            _buildSaveButton(),
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
          'Your Measurements',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter or correct your measurements for better fit recommendations.',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: AppColors.inkSecondary,
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildPrivacyNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.inkMuted, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'These measurements are optional and can be edited or deleted anytime.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.inkMuted,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildMeasurementFields() {
    return Column(
      children: _profile.measurements.asMap().entries.map((entry) {
        final measurement = entry.value;
        final controller = _controllers[measurement.name];
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        measurement.name,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      if (measurement.isEstimated)
                        Text(
                          'Auto-detected',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.inkMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                    decoration: InputDecoration(
                      hintText: '--',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppColors.inkMuted,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      suffixText: measurement.unit,
                      suffixStyle: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildSaveButton() {
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
          onPressed: _saveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            'Save Changes',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
}
