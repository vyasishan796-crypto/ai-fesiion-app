import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import 'models/body_measurement.dart';
import 'services/body_measurement_service.dart';
import 'services/size_calculator.dart';

class MeasurementResultScreen extends StatefulWidget {
  const MeasurementResultScreen({super.key});

  @override
  State<MeasurementResultScreen> createState() => _MeasurementResultScreenState();
}

class _MeasurementResultScreenState extends State<MeasurementResultScreen> {
  final SizeCalculator _sizeCalculator = SizeCalculator();
  late FitProfile _profile;
  late SizeRecommendation _sizeRecommendation;

  @override
  void initState() {
    super.initState();
    _profile = BodyMeasurementService().currentProfile ?? BodyMeasurementService().engine.createDemoProfile();
    _sizeRecommendation = _sizeCalculator.getSizeRecommendation(_profile);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    if (extra != null && extra is Map<String, dynamic>) {
      final p = extra['profile'] as FitProfile?;
      if (p != null) {
        _profile = p;
        _sizeRecommendation = _sizeCalculator.getSizeRecommendation(_profile);
      }
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
          'Fit Profile Ready',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.push('/body-measurement/privacy'),
            icon: const Icon(Icons.shield_outlined, color: AppColors.white, size: 22),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_profile.frontImagePath != null) ...[
              _buildUserPhoto(),
              const SizedBox(height: 20),
            ],
            _buildSizeCard(),
            const SizedBox(height: 24),
            _buildMeasurementsSection(),
            const SizedBox(height: 24),
            _buildHowToUseCard(),
            const SizedBox(height: 28),
            _buildActionButtons(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildUserPhoto() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            Image.file(
              File(_profile.frontImagePath!),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'AI Analyzed',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildSizeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Your Best-Fit Size',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _profile.topSize,
            style: GoogleFonts.inter(
              fontSize: 56,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Based on AI analysis of your photo',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildMeasurementsSection() {
    final measurements = [
      {'label': 'Chest', 'value': _profile.getMeasurement('Chest')?.displayValue ?? '--'},
      {'label': 'Waist', 'value': _profile.getMeasurement('Waist')?.displayValue ?? '--'},
      {'label': 'Shoulder', 'value': _profile.getMeasurement('Shoulder')?.displayValue ?? '--'},
      {'label': 'Hip', 'value': _profile.getMeasurement('Hip')?.displayValue ?? '--'},
      {'label': 'Inseam', 'value': _profile.getMeasurement('Inseam')?.displayValue ?? '--'},
      {'label': 'Arm Length', 'value': _profile.getMeasurement('Arm Length')?.displayValue ?? '--'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Your Measurements',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () async {
                await context.push('/body-measurement/editing');
                if (mounted) {
                  final service = BodyMeasurementService();
                  if (service.currentProfile != null) {
                    setState(() {
                      _profile = service.currentProfile!;
                      _sizeRecommendation = _sizeCalculator.getSizeRecommendation(_profile);
                    });
                  }
                }
              },
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: Text(
                'Edit',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.8,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: measurements.length,
          itemBuilder: (context, index) {
            final m = measurements[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    m['label']!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${m['value']} cm',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildHowToUseCard() {
    final tips = [
      {'title': 'Top', 'desc': 'Select this size when shopping for shirts, t-shirts, and jackets.'},
      {'title': 'Bottom', 'desc': 'Choose this size for jeans, trousers, and shorts.'},
      {'title': 'Verify', 'desc': 'These are AI-estimated sizes. Always check the brand\'s size chart.'},
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
            'How to Use These Sizes',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 5),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: '${tip['title']}: ',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                      children: [
                        TextSpan(
                          text: tip['desc'],
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.inkSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
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
                context.push('/body-measurement/outfit-recommendation');
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
                  const Icon(Icons.checkroom, color: AppColors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Get Outfit Recommendations',
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
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            onPressed: () => context.push('/body-measurement/size-recommendation'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.straighten, color: AppColors.inkSecondary, size: 20),
                const SizedBox(width: 10),
                Text(
                  'View Detailed Sizes',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }
}
