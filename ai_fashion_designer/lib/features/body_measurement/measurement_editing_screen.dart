import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import 'models/body_measurement.dart';
import 'services/body_measurement_service.dart';

class MeasurementEditingScreen extends StatefulWidget {
  const MeasurementEditingScreen({super.key});

  @override
  State<MeasurementEditingScreen> createState() => _MeasurementEditingScreenState();
}

class _MeasurementEditingScreenState extends State<MeasurementEditingScreen> {
  final BodyMeasurementService _service = BodyMeasurementService();
  late FitProfile _profile;
  final Map<String, TextEditingController> _controllers = {};
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _profile = _service.currentProfile ?? _service.engine.createDemoProfile();
    for (var m in _profile.measurements) {
      _controllers[m.name] = TextEditingController(
        text: m.value?.toStringAsFixed(1) ?? '',
      );
    }
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
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
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() => _isEditing = !_isEditing);
            },
            child: Text(
              _isEditing ? 'Done' : 'Edit',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Edit your measurements below. Manual adjustments override AI estimations.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.inkSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ..._profile.measurements.map((m) => _buildMeasurementField(m)),
            const SizedBox(height: 24),
            _buildSaveButton(),
            const SizedBox(height: 16),
            _buildResetButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementField(BodyMeasurement m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isEditing ? AppColors.primary.withOpacity(0.3) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(m.icon ?? '📏', style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.name,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                _isEditing
                    ? SizedBox(
                        height: 32,
                        child: TextField(
                          controller: _controllers[m.name],
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
                          ],
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.primary),
                            ),
                            suffixText: 'cm',
                            suffixStyle: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        '${m.value?.toStringAsFixed(1) ?? '--'} cm',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
              ],
            ),
          ),
          if (m.confidence < 0.8)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${(m.confidence * 100).toInt()}%',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: (100 * _profile.measurements.indexOf(m)).toInt()));
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
          onPressed: () async {
            HapticFeedback.lightImpact();

            final updated = <BodyMeasurement>[];
            for (var m in _profile.measurements) {
              final text = _controllers[m.name]?.text ?? '';
              final val = double.tryParse(text);
              updated.add(m.copyWith(
                value: val ?? m.value,
                source: val != null ? MeasurementSource.userEntered : m.source,
              ));
            }

            await _service.updateMeasurements(updated);

            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Measurements saved successfully!',
                  style: GoogleFonts.inter(fontSize: 14),
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
            context.pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            'Save Measurements',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          for (var entry in _controllers.entries) {
            final m = _profile.getMeasurement(entry.key);
            if (m != null) {
              entry.value.text = m.value?.toStringAsFixed(1) ?? '';
            }
          }
          setState(() => _isEditing = false);
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          'Reset to AI Measurements',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.inkSecondary,
          ),
        ),
      ),
    );
  }
}
