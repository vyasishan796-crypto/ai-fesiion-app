import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/appearance_service.dart';
import '../../core/models/appearance_profile.dart';
import '../../core/widgets/empty_state_widget.dart';

enum _ResultState { initial, loading, result, error }

class AppearanceResultScreen extends StatefulWidget {
  final String analysisId;

  const AppearanceResultScreen({
    required this.analysisId,
    super.key,
  });

  @override
  State<AppearanceResultScreen> createState() => _AppearanceResultScreenState();
}

class _AppearanceResultScreenState extends State<AppearanceResultScreen> {
  _ResultState _state = _ResultState.initial;
  AppearanceAnalysis? _analysis;
  String? _error;
  Timer? _pollTimer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnalysis();
  }

  Future<void> _fetchAnalysis() async {
    setState(() => _state = _ResultState.loading);
    try {
      final service = AppearanceService();
      final analysis = await service.getAppearanceAnalysis(widget.analysisId);
      if (!mounted) return;
      setState(() {
        _analysis = analysis;
        _state = _ResultState.result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _state = _ResultState.error;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_state == _ResultState.initial) {
      return const Scaffold(
        body: Center(child: Text('Loading...')),
      );
    }

    if (_state == _ResultState.loading) {
      return _buildLoadingView();
    }

    if (_state == _ResultState.error) {
      return _buildErrorView();
    }

    return _buildResultView();
  }

  Widget _buildLoadingView() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(strokeWidth: 2),
            const SizedBox(height: 16),
            Text(
              'Fetching appearance analysis...',
              style: GoogleFonts.inter(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Appearance analysis not found',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchAnalysis,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView() {
    if (_analysis == null) {
      return const EmptyStateWidget(
        icon: Icons.remove,
        title: 'No analysis data',
        subtitle: 'The appearance analysis could not be loaded.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResultHeader(),
          const SizedBox(height: 24),
          _buildSkinAnalysis(),
          const SizedBox(height: 24),
          _buildBodyProportions(),
          const SizedBox(height: 24),
          _buildColorProfile(),
          const SizedBox(height: 24),
          _buildOutfitRecommendations(),
          const SizedBox(height: 32),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildResultHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF1D1D1F)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        Text(
          'Appearance Analysis',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D1D1F),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildSkinAnalysis() {
    if (_analysis == null) return const SizedBox();
    final skin = _analysis!.skin;
    final color = _analysis!.colorProfile;

    return Card(
      color: const Color(0xFFF5F5F7),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Skin Tone Analysis',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1D1D1F),
              ),
            ),
            const SizedBox(height: 16),
            _buildToneRow(
              label: 'Tone',
              value: skin.tone,
              confidence: skin.toneConfidence,
              color: _toneColor(skin.tone),
            ),
            _buildToneRow(
              label: 'Undertone',
              value: skin.undertone,
              confidence: skin.undertoneConfidence,
              color: _undertoneColor(skin.undertone),
            ),
            const SizedBox(height: 12),
            _buildColorChip('Primary', skin.primaryColor),
            _buildColorChip('Secondary', skin.secondaryColor),
            const SizedBox(height: 12),
            _buildContrastLevel(color.contrastLevel),
            const SizedBox(height: 12),
            _buildSeasonalPalette(color.seasonalPalette),
          ],
        ),
      ),
    );
  }

  Widget _buildToneRow({
    required String label,
    required String value,
    required double confidence,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600),
          ),
          Row(
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${(confidence * 100).toInt}%',
                  style: GoogleFonts.inter(fontSize: 11, color: color),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _toneColor(String tone) {
    switch (tone.toLowerCase()) {
      case 'warm':
        return const Color(0xFF7C4DFF);
      case 'cool':
        return const Color(0xFF3B82F6);
      case 'neutral':
        return const Color(0xFF6B7280);
      default:
        return Colors.grey;
    }
  }

  Color _undertoneColor(String undertone) {
    switch (undertone.toLowerCase()) {
      case 'golden':
        return const Color(0xFFF59E0B);
      case 'rosy':
        return const Color(0xFFEC4899);
      case 'neutral':
        return const Color(0xFF6B7280);
      default:
        return Colors.grey;
    }
  }

  Widget _buildColorChip(String label, String hexColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600),
          ),
          const Spacer(),
          Container(
            width: 36,
            height: 20,
            decoration: BoxDecoration(
              color: Color(int.parse(hexColor.replaceFirst('#', '0xFF'))),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContrastLevel(String level) {
    final Map<String, Color> levelColors = {
      'high': const Color(0xFF7C4DFF),
      'medium': const Color(0xFFF59E0B),
      'low': const Color(0xFF6B7280),
    };
    return _buildToneRow(
      label: 'Contrast Level',
      value: level.toUpperCase(),
      confidence: 1.0,
      color: levelColors[level] ?? Colors.grey,
    );
  }

  Widget _buildSeasonalPalette(String palette) {
    final Map<String, Color> paletteColors = {
      'Spring': const Color(0xFFEC4899),
      'Summer': const Color(0xFF3B82F6),
      'Autumn': const Color(0xFFF59E0B),
      'Winter': const Color(0xFF3B82F6),
      'Universal': const Color(0xFF7C4DFF),
    };

    return _buildToneRow(
      label: 'Seasonal Palette',
      value: palette,
      confidence: 1.0,
      color: paletteColors[palette] ?? Colors.grey,
    );
  }

  Widget _buildBodyProportions() {
    if (_analysis == null) return const SizedBox();
    final body = _analysis!.body;

    return Card(
      color: const Color(0xFFF5F5F7),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Body Proportions',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1D1D1F),
              ),
            ),
            const SizedBox(height: 16),
            _buildRatioRow(
              label: 'Silhouette',
              value: _silhouetteDisplayName(body.silhouette),
              confidence: body.confidence,
            ),
            _buildRatioRow(
              label: 'Shoulder/Hip Ratio',
              value: body.shoulderHipRatio.toStringAsFixed(2),
              confidence: body.confidence,
            ),
            _buildRatioRow(
              label: 'Torso/Leg Ratio',
              value: body.torsoLegRatio.toStringAsFixed(2),
              confidence: body.confidence,
            ),
            _buildRatioRow(
              label: 'Upper/Lower Body',
              value: body.upperBodyRatio.toStringAsFixed(2),
              confidence: body.confidence,
            ),
          ],
        ),
      ),
    );
  }

  String _silhouetteDisplayName(String silhouette) {
    switch (silhouette.toLowerCase()) {
      case 'inverted_triangle':
        return 'Inverted Triangle';
      case 'triangle':
      case 'pear':
        return 'Pear';
      case 'hourglass':
        return 'Hourglass';
      case 'rectangle':
        return 'Rectangle';
      default:
        return silhouette.isNotEmpty ? '${silhouette[0].toUpperCase()}${silhouette.substring(1)}' : '';
    }
  }

  Widget _buildRatioRow({required String label, required String value, required double confidence}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600),
          ),
          Row(
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1D1D1F),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C4DFF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${(confidence * 100).toInt}%',
                  style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF7C4DFF)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorProfile() {
    if (_analysis == null) return const SizedBox();
    final color = _analysis!.colorProfile;

    return Card(
      color: const Color(0xFFF5F5F7),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Color Profile',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1D1D1F),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Based on your skin analysis, here are your optimal colors:',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            _buildPaletteColor('Primary', color.primaryColor),
            _buildPaletteColor('Secondary', color.secondaryColor),
            _buildPaletteColor('Accent', color.accentColor),
            const SizedBox(height: 12),
            _buildContrastLevel(color.contrastLevel),
          ],
        ),
      ),
    );
  }

  Widget _buildPaletteColor(String label, String hexColor) {
    final color = Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600),
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                hexColor,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitRecommendations() {
    if (_analysis == null) return const SizedBox();
    return Card(
      color: const Color(0xFFF5F5F7),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Outfit Recommendations',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1D1D1F),
              ),
            ),
            const SizedBox(height: 16),
            ..._buildOutfitCards(),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  List<Widget> _buildOutfitCards() {
    if (_analysis == null) return [];

    final List<Widget> cards = [];

    final outfits = [
      {
        'name': 'Everyday Essential',
        'style': 'Casual',
        'items': ['White t-shirt', 'Dark denim jeans', 'White sneakers'],
        'colors': [_analysis!.skin.primaryColor, '#212121', '#FFFFFF'],
        'note': 'Perfect for daily wear - harmonizes with your skin tone',
      },
      {
        'name': 'Sophisticated Accent',
        'style': 'Smart Casual',
        'items': ['Navy blazer', 'Light shirt', 'Dark trousers', 'Navy shoes'],
        'colors': ['#000080', '#FFFFFF', _analysis!.skin.primaryColor, '#E0E0E0'],
        'note': 'Navy + your primary color creates sophisticated contrast',
      },
      {
        'name': 'Seasonal Edit',
        'style': 'Seasonal',
        'items': [
          '${_analysis!.colorProfile.seasonalPalette == 'Spring' ? 'Light jacket' : 'Coat'}',
          'White shirt',
          'Comfortable pants',
          'Loafers'
        ],
        'colors': [
          _analysis!.colorProfile.primaryColor,
          _analysis!.colorProfile.secondaryColor,
          '#FFFFFF',
          '#212121'
        ],
        'note': '${_analysis!.colorProfile.seasonalPalette} palette colors for you',
      },
    ];

    for (int i = 0; i < outfits.length; i++) {
      final outfit = outfits[i];
      cards.add(
        _buildOutfitCard(
          name: outfit['name'] as String,
          style: outfit['style'] as String,
          items: List<String>.from(outfit['items'] as List),
          colors: List<String>.from(outfit['colors'] as List),
          note: outfit['note'] as String,
        ),
      );
      if (i < outfits.length - 1) {
        const SizedBox(height: 12);
      }
    }

    return cards;
  }

  Widget _buildOutfitCard({
    required String name,
    required String style,
    required List<String> items,
    required List<String> colors,
    required String note,
  }) {
    final color0 = Color(int.parse(colors[0].replaceFirst('#', '0xFF')));
    final color1 = Color(int.parse(colors[1].replaceFirst('#', '0xFF')));

    return Card(
      color: const Color(0xFFF5F5F7),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color0.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.checkroom,
                    color: color0,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1D1D1F),
                        ),
                      ),
                      Text(
                        style,
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    Icons.shopping_bag,
                    size: 14,
                    color: color1,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item,
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 8),
            Text(
              note,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              // Save appearance profile
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF7C4DFF).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  'Save Profile',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF7C4DFF),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              // Share result
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF7C4DFF).withOpacity(0.3)),
              ),
              child: Center(
                child: Text(
                  'Share',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF7C4DFF),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}