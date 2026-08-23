import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import 'models/body_measurement.dart';
import 'services/size_calculator.dart';
import 'services/body_measurement_service.dart';

class SizeRecommendationScreen extends StatefulWidget {
  const SizeRecommendationScreen({super.key});

  @override
  State<SizeRecommendationScreen> createState() => _SizeRecommendationScreenState();
}

class _SizeRecommendationScreenState extends State<SizeRecommendationScreen> {
  final SizeCalculator _sizeCalculator = SizeCalculator();
  late FitProfile _profile;
  late Map<String, SizeRecommendation> _recommendations;

  @override
  void initState() {
    super.initState();
    _profile = BodyMeasurementService().currentProfile ?? BodyMeasurementService().engine.createDemoProfile();
    _recommendations = _sizeCalculator.getAllRecommendations(_profile);
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
          'Size Recommendations',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSizeGrid(),
            const SizedBox(height: 24),
            _buildBrandSizeChart(),
            const SizedBox(height: 20),
            _buildDisclaimer(),
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
          'Recommended Sizes',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Based on your AI-measured body dimensions.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.inkSecondary,
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildSizeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _recommendations.length,
      itemBuilder: (context, index) {
        final entry = _recommendations.entries.elementAt(index);
        return _buildSizeCard(entry.key, entry.value);
      },
    );
  }

  Widget _buildSizeCard(String category, SizeRecommendation rec) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: rec.confidence == 'High'
              ? AppColors.success.withOpacity(0.3)
              : AppColors.border,
          width: rec.confidence == 'High' ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    category == 'Tops' ? '👕' : category == 'Bottoms' ? '👖' : '👟',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: rec.confidence == 'High'
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  rec.confidence ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: rec.confidence == 'High'
                        ? AppColors.success
                        : AppColors.inkMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            category,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.inkSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            rec.recommendedSize,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rec.bestMatch ?? '',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.inkMuted,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 * _recommendations.keys.toList().indexOf(category)));
  }

  Widget _buildBrandSizeChart() {
    final chest = _profile.getMeasurement('Chest')?.value ?? 96.0;
    final waist = _profile.getMeasurement('Waist')?.value ?? 82.0;

    final brandSizes = _getBrandSizes(chest, waist);

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
          Row(
            children: [
              const Icon(Icons.store, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Brand Size Chart',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Your chest: ${chest.toStringAsFixed(0)} cm | waist: ${waist.toStringAsFixed(0)} cm',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.inkMuted,
            ),
          ),
          const SizedBox(height: 12),
          ...brandSizes.map((brand) => _buildBrandRow(brand['name']!, brand['top']!, brand['bottom']!)),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  List<Map<String, String>> _getBrandSizes(double chest, double waist) {
    return [
      {'name': 'Allen Solly', 'top': _allenSollyTop(chest), 'bottom': _allenSollyBottom(waist)},
      {'name': 'H&M', 'top': _hmTop(chest), 'bottom': _hmBottom(waist)},
      {'name': 'Zara', 'top': _zaraTop(chest), 'bottom': _zaraBottom(waist)},
      {'name': "Levi's", 'top': _levisTop(chest), 'bottom': _levisBottom(waist)},
      {'name': 'Nike', 'top': _nikeTop(chest), 'bottom': _nikeBottom(waist)},
      {'name': 'US Polo', 'top': _usPoloTop(chest), 'bottom': _usPoloBottom(waist)},
      {'name': 'Jack & Jones', 'top': _jackJonesTop(chest), 'bottom': _jackJonesBottom(waist)},
    ];
  }

  String _allenSollyTop(double chest) {
    if (chest < 86) return 'S';
    if (chest < 92) return 'M';
    if (chest < 100) return 'L';
    if (chest < 108) return 'XL';
    return 'XXL';
  }

  String _allenSollyBottom(double waist) {
    if (waist < 70) return '28';
    if (waist < 76) return '30';
    if (waist < 82) return '32';
    if (waist < 88) return '34';
    if (waist < 94) return '36';
    return '38';
  }

  String _hmTop(double chest) {
    if (chest < 88) return 'S';
    if (chest < 96) return 'M';
    if (chest < 104) return 'L';
    if (chest < 112) return 'XL';
    return 'XXL';
  }

  String _hmBottom(double waist) {
    if (waist < 72) return '28';
    if (waist < 78) return '30';
    if (waist < 84) return '32';
    if (waist < 90) return '34';
    if (waist < 96) return '36';
    return '38';
  }

  String _zaraTop(double chest) {
    if (chest < 88) return 'S';
    if (chest < 94) return 'M';
    if (chest < 102) return 'L';
    if (chest < 110) return 'XL';
    return 'XXL';
  }

  String _zaraBottom(double waist) {
    if (waist < 72) return '28';
    if (waist < 78) return '30';
    if (waist < 84) return '32';
    if (waist < 90) return '34';
    if (waist < 96) return '36';
    return '38';
  }

  String _levisTop(double chest) {
    if (chest < 88) return 'S';
    if (chest < 96) return 'M';
    if (chest < 104) return 'L';
    if (chest < 112) return 'XL';
    return 'XXL';
  }

  String _levisBottom(double waist) {
    if (waist < 70) return '28';
    if (waist < 76) return '30';
    if (waist < 82) return '32';
    if (waist < 88) return '34';
    if (waist < 94) return '36';
    return '38';
  }

  String _nikeTop(double chest) {
    if (chest < 86) return 'S';
    if (chest < 94) return 'M';
    if (chest < 102) return 'L';
    if (chest < 110) return 'XL';
    return 'XXL';
  }

  String _nikeBottom(double waist) {
    if (waist < 70) return 'S';
    if (waist < 78) return 'M';
    if (waist < 86) return 'L';
    if (waist < 94) return 'XL';
    return 'XXL';
  }

  String _usPoloTop(double chest) {
    if (chest < 88) return 'S';
    if (chest < 96) return 'M';
    if (chest < 104) return 'L';
    if (chest < 112) return 'XL';
    return 'XXL';
  }

  String _usPoloBottom(double waist) {
    if (waist < 72) return '28';
    if (waist < 78) return '30';
    if (waist < 84) return '32';
    if (waist < 90) return '34';
    if (waist < 96) return '36';
    return '38';
  }

  String _jackJonesTop(double chest) {
    if (chest < 88) return 'S';
    if (chest < 96) return 'M';
    if (chest < 104) return 'L';
    if (chest < 112) return 'XL';
    return 'XXL';
  }

  String _jackJonesBottom(double waist) {
    if (waist < 72) return '28';
    if (waist < 78) return '30';
    if (waist < 84) return '32';
    if (waist < 90) return '34';
    if (waist < 96) return '36';
    return '38';
  }

  Widget _buildBrandRow(String brand, String topSize, String bottomSize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              brand,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.ink,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                topSize,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                bottomSize,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.inkMuted, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'AI-estimated sizes. Always check the brand\'s size chart for the best fit.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.inkMuted,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
