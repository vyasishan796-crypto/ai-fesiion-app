import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/services/ai_service.dart';
import '../../core/services/notification_service.dart';
import '../ai_studio/widgets/generated_outfit.dart';

class AiStudioScreen extends StatefulWidget {
  const AiStudioScreen({super.key});

  @override
  State<AiStudioScreen> createState() => _AiStudioScreenState();
}

class _AiStudioScreenState extends State<AiStudioScreen> {
  final TextEditingController _promptController = TextEditingController();
  final AiService _aiService = AiService();

  String _selectedStyle = 'Casual';
  String _selectedColor = 'Black';
  String _selectedFabric = 'Cotton';

  bool _isLoading = false;
  String? _generatedImageUrl;
  bool _hasGenerated = false;

  final List<Map<String, dynamic>> _styles = [
    {'label': 'Casual', 'icon': Icons.weekend_outlined},
    {'label': 'Formal', 'icon': Icons.business_center_outlined},
    {'label': 'Streetwear', 'icon': Icons.directions_walk_outlined},
    {'label': 'Luxury', 'icon': Icons.diamond_outlined},
  ];

  final List<Map<String, dynamic>> _colors = [
    {'name': 'Black', 'color': const Color(0xFF1E1E1E)},
    {'name': 'Navy', 'color': const Color(0xFF1B2A4A)},
    {'name': 'White', 'color': const Color(0xFFF3F4F6)},
    {'name': 'Cream', 'color': const Color(0xFFF5E6D3)},
    {'name': 'Brown', 'color': const Color(0xFF8B6F47)},
    {'name': 'Cobalt', 'color': const Color(0xFF2563EB)},
  ];

  final List<Map<String, dynamic>> _fabrics = [
    {'name': 'Cotton', 'pattern': 'crosshatch'},
    {'name': 'Denim', 'pattern': 'diagonal'},
    {'name': 'Leather', 'pattern': 'smooth'},
    {'name': 'Linen', 'pattern': 'horizontal'},
    {'name': 'Wool', 'pattern': 'knit'},
  ];

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _saveDesign() async {
    if (_generatedImageUrl == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedList = prefs.getStringList('ai_studio_saved_designs') ?? [];
      final design = {
        'imageUrl': _generatedImageUrl,
        'prompt': _promptController.text,
        'style': _selectedStyle,
        'color': _selectedColor,
        'fabric': _selectedFabric,
        'savedAt': DateTime.now().toIso8601String(),
      };
      savedList.add(jsonEncode(design));
      await prefs.setStringList('ai_studio_saved_designs', savedList);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Design saved to your collection!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _shareDesign() async {
    if (_generatedImageUrl == null) return;
    try {
      await Share.share(
        'Check out my AI-generated outfit design on StyleAI!\n\n'
        'Prompt: ${_promptController.text}\n'
        'Style: $_selectedStyle | Color: $_selectedColor | Fabric: $_selectedFabric\n\n'
        '$_generatedImageUrl',
        subject: 'My StyleAI Design',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not share: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _generateOutfit() async {
    if (_isLoading) return;
    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe your dream outfit'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasGenerated = false;
    });

    final prompt =
        '${_promptController.text} in $_selectedStyle style, '
        'color $_selectedColor, made of $_selectedFabric fabric';

    try {
      final imageUrl = await _aiService.generateOutfit(prompt);
      setState(() {
        _generatedImageUrl = imageUrl;
        _hasGenerated = true;
      });
      NotificationService().showOutfitReady(_selectedStyle);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating outfit: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.charcoal,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'AI Design Studio',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildPromptInput(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Style'),
                  const SizedBox(height: 10),
                  _buildStyleChips(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Color'),
                  const SizedBox(height: 10),
                  _buildColorPalette(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Fabric'),
                  const SizedBox(height: 10),
                  _buildFabricRow(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Your Design'),
                  const SizedBox(height: 12),
                  _buildDesignOutput(),
                  const SizedBox(height: 20),
                  if (_hasGenerated && _generatedImageUrl != null)
                    _buildActionButtons(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildGenerateButton(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildPromptInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: _promptController,
            maxLength: 300,
            maxLines: 3,
            minLines: 2,
            onChanged: (_) => setState(() {}),
            style: GoogleFonts.inter(fontSize: 15, color: AppColors.ink),
            decoration: InputDecoration(
              hintText: 'e.g., Black oversized hoodie with techwear style',
              hintStyle: GoogleFonts.inter(fontSize: 15, color: AppColors.inkMuted),
              border: InputBorder.none,
              counterText: '',
              contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, bottom: 10),
            child: Text(
              '${_promptController.text.length}/300',
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.inkMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _styles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final style = _styles[index];
          final isSelected = _selectedStyle == style['label'];
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedStyle = style['label']);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.white,
                borderRadius: AppRadius.pill,
                border: isSelected ? null : Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    style['icon'] as IconData,
                    size: 15,
                    color: isSelected ? AppColors.white : AppColors.inkSecondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    style['label'],
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.white : AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorPalette() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _colors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final colorData = _colors[index];
          final isSelected = _selectedColor == colorData['name'];
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedColor = colorData['name'] as String);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorData['color'] as Color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: AppColors.primary, width: 2.5)
                        : (colorData['name'] == 'White' || colorData['name'] == 'Cream')
                            ? Border.all(color: AppColors.border, width: 1)
                            : null,
                    boxShadow: isSelected
                        ? [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 6)]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 12, color: AppColors.white)
                      : null,
                ),
                const SizedBox(height: 3),
                Text(
                  colorData['name'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.primary : AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFabricRow() {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _fabrics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final fabric = _fabrics[index];
          final isSelected = _selectedFabric == fabric['name'];
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedFabric = fabric['name'] as String);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.06) : AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: AppColors.primary, width: 1.5)
                    : Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _getFabricColor(fabric['pattern'] as String),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    fabric['name'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? AppColors.primary : AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getFabricColor(String pattern) {
    switch (pattern) {
      case 'crosshatch': return const Color(0xFFE5E7EB);
      case 'diagonal': return const Color(0xFF3B5998).withOpacity(0.7);
      case 'smooth': return const Color(0xFF5C4033).withOpacity(0.8);
      case 'horizontal': return const Color(0xFFE5E7EB);
      case 'knit': return const Color(0xFFD1D5DB);
      default: return AppColors.lightGrey;
    }
  }

  Widget _buildDesignOutput() {
    if (_isLoading) {
      return Container(
        width: double.infinity,
        height: 360,
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
            ),
            const SizedBox(height: 16),
            Text(
              'Generating your design...',
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
            ),
            const SizedBox(height: 4),
            Text(
              'This may take ~30 seconds',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.inkMuted),
            ),
          ],
        ),
      );
    }

    if (_hasGenerated && _generatedImageUrl != null) {
      return GeneratedOutfit(
        imageUrl: _generatedImageUrl,
        isLoading: false,
        onRegenerate: _generateOutfit,
        onSave: () => _saveDesign(),
        onShare: () => _shareDesign(),
        onTryOn: () {},
      );
    }

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_outlined, size: 36, color: AppColors.primary.withOpacity(0.4)),
          const SizedBox(height: 12),
          Text(
            'Your design will appear here',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.inkMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildSmallButton(
            label: 'Regenerate',
            icon: Icons.refresh,
            isPrimary: false,
            onTap: _generateOutfit,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSmallButton(
            label: 'Save',
            icon: Icons.bookmark_outline,
            isPrimary: true,
            onTap: () => _saveDesign(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSmallButton(
            label: 'Share',
            icon: Icons.share_outlined,
            isPrimary: false,
            onTap: () {
              final prompt = _promptController.text.isNotEmpty ? _promptController.text : 'AI Fashion Design';
              final style = _selectedStyle;
              final color = _selectedColor;
              final fabric = _selectedFabric;
              Share.share(
                'Check out my AI-generated ${style.toLowerCase()} outfit design!\n\n'
                'Style: $style | Color: $color | Fabric: $fabric\n'
                'Prompt: $prompt\n\n'
                'Created with StyleAI - Your AI Fashion Stylist',
                subject: 'My StyleAI Design',
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSmallButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
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
          color: isPrimary ? AppColors.primary : AppColors.lightGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isPrimary ? AppColors.white : AppColors.inkSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isPrimary ? AppColors.white : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(color: AppColors.charcoal.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6)),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _generateOutfit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.white),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_awesome, color: AppColors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Generate Design',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.white),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
