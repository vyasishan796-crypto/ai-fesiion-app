import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import 'models/body_measurement.dart';
import 'services/measurement_engine.dart';
import 'services/size_calculator.dart';

class OutfitRecommendationScreen extends StatefulWidget {
  const OutfitRecommendationScreen({super.key});

  @override
  State<OutfitRecommendationScreen> createState() => _OutfitRecommendationScreenState();
}

class _OutfitRecommendationScreenState extends State<OutfitRecommendationScreen> {
  final MeasurementEngine _engine = MeasurementEngine();
  final SizeCalculator _sizeCalculator = SizeCalculator();
  late FitProfile _profile;

  @override
  void initState() {
    super.initState();
    _profile = _engine.createDemoProfile();
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
          'Outfit Recommendations',
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
            _buildOutfitCards(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 32),
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
          'Perfect Fits For You',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'AI-selected outfits based on your body profile.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.inkSecondary,
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildOutfitCards() {
    final outfits = [
      {
        'title': 'Casual Everyday',
        'desc': 'Classic fit t-shirt and slim jeans combo',
        'size': 'M Top / 32 Bottom',
        'color': AppColors.primary,
        'icon': '👕',
      },
      {
        'title': 'Smart Casual',
        'desc': 'Tailored shirt with chinos',
        'size': 'M Top / 32 Bottom',
        'color': const Color(0xFF10B981),
        'icon': '👔',
      },
      {
        'title': 'Athletic Fit',
        'desc': 'Performance tee with joggers',
        'size': 'M Top / M Bottom',
        'color': const Color(0xFFF59E0B),
        'icon': '🏃',
      },
      {
        'title': 'Formal',
        'desc': 'Slim-fit blazer with dress pants',
        'size': 'M Top / 32 Bottom',
        'color': AppColors.charcoal,
        'icon': '🤵',
      },
    ];

    return Column(
      children: outfits.asMap().entries.map((entry) {
        final outfit = entry.value;
        final index = entry.key;
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: (outfit['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(outfit['icon'] as String, style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      outfit['title'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      outfit['desc'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.inkSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      outfit['size'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: outfit['color'] as Color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.inkMuted,
              ),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 100 * index));
      }).toList(),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                icon: Icons.refresh,
                label: 'Retake Scan',
                onTap: () => context.push('/home/body-measurement/upload'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionTile(
                icon: Icons.edit_outlined,
                label: 'Edit Measurements',
                onTap: () => context.push('/home/body-measurement/editing'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                icon: Icons.straighten,
                label: 'View Sizes',
                onTap: () => context.push('/home/body-measurement/size-recommendation'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionTile(
                icon: Icons.shield_outlined,
                label: 'Privacy',
                onTap: () => context.push('/home/body-measurement/privacy'),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
