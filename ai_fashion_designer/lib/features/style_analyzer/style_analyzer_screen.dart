import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/services/gemini_analyzer_service.dart';
import '../../core/services/ai_service.dart';
import '../../core/models/style_analysis.dart';
import 'widgets/analysis_loading.dart';
import 'widgets/style_breakdown_card.dart';
import 'widgets/color_palette_widget.dart';
import 'widgets/clothing_chips.dart';
import 'widgets/ai_recommendations.dart';
import 'widgets/outfit_suggestions.dart';
import 'widgets/product_suggestions_with_prices.dart';
import 'widgets/transform_style.dart';

enum _ScreenState { initial, preview, analyzing, result, transforming }

class StyleAnalyzerScreen extends StatefulWidget {
  const StyleAnalyzerScreen({super.key});

  @override
  State<StyleAnalyzerScreen> createState() => _StyleAnalyzerScreenState();
}

class _StyleAnalyzerScreenState extends State<StyleAnalyzerScreen> {
  _ScreenState _state = _ScreenState.initial;
  File? _imageFile;
  StyleAnalysis? _analysis;
  String? _userQuestion;
  bool _isGeneratingTransform = false;
  String? _transformedImageUrl;

  final _picker = ImagePicker();
  final _analyzer = GeminiAnalyzerService();
  final _aiService = AiService();
  String? _aiResponse;
  bool _isAskingQuestion = false;

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _state = _ScreenState.preview;
      });
    }
  }

  String? _analyzeError;
  Future<void> _analyzeImage() async {
    if (_imageFile == null) return;
    setState(() {
      _state = _ScreenState.analyzing;
      _analyzeError = null;
    });
    try {
      final analysis = await _analyzer.analyzeImage(_imageFile!);
      if (!mounted) return;
      setState(() {
        _analysis = analysis;
        _state = _ScreenState.result;
      });
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceAll('Exception: ', '');
      setState(() {
        _state = _ScreenState.preview;
        _analyzeError = msg;
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Analyze failed: $msg', style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF1D1D1F),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(label: 'RETRY', textColor: Colors.white, onPressed: _analyzeImage),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _transformStyle(String style) async {
    if (_analysis == null) return;
    setState(() {
      _isGeneratingTransform = true;
      _state = _ScreenState.transforming;
    });
    try {
      final prompt =
          'A man wearing ${_analysis!.clothing.join(", ")} in ${style.toLowerCase()} style, '
          'fashion photography, full body shot, professional lighting, clean background';
      final imageUrl = await _aiService.generateOutfit(prompt);
      if (!mounted) return;
      setState(() {
        _transformedImageUrl = imageUrl;
        _isGeneratingTransform = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGeneratingTransform = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Generation failed: $e'), backgroundColor: const Color(0xFF1D1D1F)),
        );
      }
    }
  }

  void _reset() {
    setState(() {
      _state = _ScreenState.initial;
      _imageFile = null;
      _analysis = null;
      _userQuestion = null;
      _transformedImageUrl = null;
      _aiResponse = null;
      _isAskingQuestion = false;
    });
  }

  Future<void> _askQuestion() async {
    if (_analysis == null || _userQuestion == null || _userQuestion!.trim().isEmpty) return;
    setState(() => _isAskingQuestion = true);
    try {
      final response = await _analyzer.askQuestion(_analysis!, _userQuestion!);
      if (!mounted) return;
      setState(() {
        _aiResponse = response;
        _isAskingQuestion = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _aiResponse = 'Sorry, could not process your question. Try again.';
        _isAskingQuestion = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_state == _ScreenState.analyzing) {
      return AnalysisLoading(
        imagePath: _imageFile?.path,
        onCancel: _reset,
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _state == _ScreenState.result || _state == _ScreenState.transforming
            ? _buildResultView()
            : _state == _ScreenState.preview
                ? _buildPreviewView()
                : _buildInitialView(),
      ),
    );
  }

  Widget _buildHeader({VoidCallback? onBack}) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack ?? () => Navigator.of(context).pop(),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF1D1D1F)),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          'AI STYLE STUDIO',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1D1D1F),
            letterSpacing: 1.5,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildInitialView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildHeroCard(),
          const SizedBox(height: 20),
          _buildTryExample(),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1D1F),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'JUST ANALYZE IT.',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Upload a photo. Get instant style intelligence — colors, fit, score.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _buildActionBtn(
                  icon: Icons.camera_alt_outlined,
                  label: 'CAMERA',
                  isWhite: true,
                  onTap: () => _pickImage(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildActionBtn(
                  icon: Icons.photo_library_outlined,
                  label: 'GALLERY',
                  isWhite: false,
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.15);
  }

  Widget _buildActionBtn({
    required IconData icon,
    required String label,
    required bool isWhite,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isWhite ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: isWhite ? null : Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isWhite ? const Color(0xFF1D1D1F) : Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: isWhite ? const Color(0xFF1D1D1F) : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTryExample() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pick an outfit photo to analyze!'),
            backgroundColor: Color(0xFF1D1D1F),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.explore_outlined, size: 16, color: Color(0xFF1D1D1F)),
              const SizedBox(width: 8),
              Text(
                'Try with an example',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1D1D1F),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }

  Widget _buildPreviewView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Image.file(
                  _imageFile!,
                  width: double.infinity,
                  height: 360,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSmallBtn(
                  icon: Icons.refresh,
                  label: 'RETAKE',
                  onTap: _reset,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSmallBtn(
                  icon: Icons.photo_library_outlined,
                  label: 'CHANGE',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              onChanged: (v) => setState(() => _userQuestion = v),
              style: GoogleFonts.inter(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Ask about this outfit...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                ),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.chat_bubble_outline, color: Colors.grey.shade400, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _suggestionChip('How can I improve this look?'),
              _suggestionChip('Suggest similar outfits'),
              _suggestionChip('Make this more formal'),
              _suggestionChip('What colors work better?'),
            ],
          ),
          if (_analyzeError != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFECACA))),
              child: Row(children: [
                const Icon(Icons.error_outline, size: 18, color: Color(0xFFEF4444)),
                const SizedBox(width: 8),
                Expanded(child: Text(_analyzeError!, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF991B1B), fontWeight: FontWeight.w500))),
                TextButton(onPressed: _analyzeImage, child: Text('RETRY', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF1D1D1F)))),
              ]),
            ),
          const SizedBox(height: 24),
          _buildAnalyzeButton(),
          const SizedBox(height: 12),
          _buildAskAIButton(),
        ],
      ),
    );
  }

  Widget _buildSmallBtn({
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF1D1D1F)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: const Color(0xFF1D1D1F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _suggestionChip(String text) {
    final isSelected = _userQuestion == text;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _userQuestion = text);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1D1D1F) : const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : const Color(0xFF1D1D1F),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _analyzeImage();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF1D1D1F),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              'ANALYZE MY OUTFIT',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildAskAIButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _askQuestion();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 18, color: _userQuestion != null ? const Color(0xFF1D1D1F) : Colors.grey.shade400),
            const SizedBox(width: 8),
            Text(
              _isAskingQuestion ? 'THINKING...' : 'ASK AI',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: _userQuestion != null ? const Color(0xFF1D1D1F) : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }

  Widget _buildResultView() {
    if (_analysis == null) return const SizedBox();
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildResultHeader(),
                if (_aiResponse != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome, size: 16, color: Color(0xFFFA5400)),
                            const SizedBox(width: 8),
                            Text(
                              'AI ANSWER',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                                color: const Color(0xFFFA5400),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _aiResponse!,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF1D1D1F),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                ],
                const SizedBox(height: 16),
                Text(
                  'STYLE BREAKDOWN',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: const Color(0xFF1D1D1F),
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                const SizedBox(height: 16),
                StyleBreakdownCard(analysis: _analysis!),
                const SizedBox(height: 24),
                AiRecommendations(recommendations: _analysis!.recommendations)
                    .animate().fadeIn(delay: 200.ms, duration: 400.ms),
                const SizedBox(height: 24),
                OutfitSuggestions(
                  style: _analysis!.overallStyle,
                  clothing: _analysis!.clothing,
                  occasions: _analysis!.occasions,
                  detectedColors: _analysis!.palette,
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                const SizedBox(height: 24),
                ProductSuggestionsWithPrices(analysis: _analysis!)
                    .animate().fadeIn(delay: 350.ms, duration: 400.ms),
                const SizedBox(height: 24),
                ColorPaletteWidget(colors: _analysis!.palette)
                    .animate().fadeIn(delay: 400.ms, duration: 400.ms),
                const SizedBox(height: 24),
                ClothingChips(items: _analysis!.clothing)
                    .animate().fadeIn(delay: 500.ms, duration: 400.ms),
                const SizedBox(height: 24),
                _buildFabricOccasion()
                    .animate().fadeIn(delay: 600.ms, duration: 400.ms),
                const SizedBox(height: 28),
                TransformStyle(
                  originalStyle: _analysis!.overallStyle,
                  onStyleSelected: _transformStyle,
                ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
                const SizedBox(height: 16),
                if (_state == _ScreenState.transforming) _buildTransformResult(),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: _buildBottomActions()),
      ],
    );
  }

  Widget _buildResultHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _reset();
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF1D1D1F)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            'AI STYLE STUDIO',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: const Color(0xFF1D1D1F),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Share.share(
              'Check out my style analysis from StyleAI!\n'
              'Style: ${_analysis!.overallStyle}\n'
              'Score: ${_analysis!.styleScore}/10',
            );
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.share_outlined, size: 18, color: Color(0xFF1D1D1F)),
          ),
        ),
      ],
    );
  }

  Widget _buildFabricOccasion() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.texture, size: 18, color: Color(0xFF1D1D1F)),
                const SizedBox(height: 8),
                Text(
                  'FABRIC',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _analysis!.fabric,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1D1D1F),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.event, size: 18, color: Color(0xFF1D1D1F)),
                const SizedBox(height: 8),
                Text(
                  'OCCASION',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _analysis!.occasions.join(', '),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1D1D1F),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransformResult() {
    if (_isGeneratingTransform) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xFF1D1D1F),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Generating transformed look...',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    if (_transformedImageUrl != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'TRANSFORMED LOOK',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: const Color(0xFF1D1D1F),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              _transformedImageUrl!,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: 300,
                  color: Colors.grey.shade100,
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              },
              errorBuilder: (_, __, ___) => Container(
                height: 300,
                color: Colors.grey.shade100,
                child: const Center(child: Icon(Icons.error_outline, color: Colors.grey)),
              ),
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
        ],
      );
    }

    return const SizedBox();
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildBottomBtn(
                  icon: Icons.bookmark_outline,
                  label: 'SAVE',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Analysis saved!'),
                        backgroundColor: Color(0xFF1D1D1F),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildBottomBtn(
                  icon: Icons.share_outlined,
                  label: 'SHARE',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Share.share(
                      'My style: ${_analysis!.overallStyle} | Score: ${_analysis!.styleScore}/10',
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              _reset();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  'ANALYZE ANOTHER OUTFIT',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: const Color(0xFF1D1D1F),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF1D1D1F)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: const Color(0xFF1D1D1F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
