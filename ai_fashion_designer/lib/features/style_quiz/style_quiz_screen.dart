import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/style_profile_service.dart';

class StyleQuizScreen extends StatefulWidget {
  const StyleQuizScreen({super.key});

  @override
  State<StyleQuizScreen> createState() => _StyleQuizScreenState();
}

class _StyleQuizScreenState extends State<StyleQuizScreen> {
  int _currentStep = 0;
  final int _totalSteps = 5;

  String _gender = 'male';
  String _bodyType = 'Average';
  List<String> _selectedStyles = [];
  List<String> _selectedColors = [];
  List<String> _selectedOccasions = [];

  final Map<String, List<String>> _stylesByGender = {
    'male': ['Casual', 'Formal', 'Streetwear', 'Sporty', 'Classic', 'Bohemian', 'Minimalist', 'Smart Casual'],
    'female': ['Casual', 'Formal', 'Bohemian', 'Romantic', 'Sporty', 'Chic', 'Minimalist', 'Ethnic Fusion'],
  };

  final List<Map<String, dynamic>> _colors = [
    {'name': 'Black', 'color': Colors.black},
    {'name': 'White', 'color': Colors.white},
    {'name': 'Navy', 'color': const Color(0xFF001F3F)},
    {'name': 'Grey', 'color': Colors.grey},
    {'name': 'Blue', 'color': Colors.blue},
    {'name': 'Green', 'color': Colors.green},
    {'name': 'Red', 'color': Colors.red},
    {'name': 'Pink', 'color': Colors.pink},
    {'name': 'Brown', 'color': const Color(0xFF8B4513)},
    {'name': 'Beige', 'color': const Color(0xFFF5F5DC)},
    {'name': 'Purple', 'color': Colors.purple},
    {'name': 'Orange', 'color': Colors.orange},
  ];

  final List<String> _occasions = ['Work/Office', 'Casual Outings', 'Parties', 'Date Night', 'Gym/Sports', 'Festivals', 'Travel', 'Weddings'];

  @override
  void initState() {
    super.initState();
    final profile = StyleProfileService().profile;
    if (profile.gender.isNotEmpty) _gender = profile.gender;
    if (profile.bodyType.isNotEmpty) _bodyType = profile.bodyType;
    if (profile.preferredStyles.isNotEmpty) _selectedStyles = List.from(profile.preferredStyles);
    if (profile.preferredColors.isNotEmpty) _selectedColors = List.from(profile.preferredColors);
    if (profile.occasions.isNotEmpty) _selectedOccasions = List.from(profile.occasions);
  }

  double get _progress => (_currentStep + 1) / _totalSteps;

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      _saveQuiz();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _saveQuiz() async {
    final answers = {
      'gender': _gender,
      'bodyType': _bodyType,
      'styles': _selectedStyles,
      'colors': _selectedColors,
      'occasions': _selectedOccasions,
    };
    await StyleProfileService().updateFromQuiz(answers);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Style profile updated!'),
          backgroundColor: const Color(0xFF1D1D1F),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D1D1F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 24, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'STYLE QUIZ',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildCurrentStep(),
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STEP ${_currentStep + 1} OF $_totalSteps',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: const Color(0xFF8E8E93),
                ),
              ),
              Text(
                '${(_progress * 100).toInt()}%',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: const Color(0xFF1D1D1F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: const Color(0xFFF5F5F7),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1D1D1F)),
            borderRadius: BorderRadius.circular(4),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return _buildGenderStep();
      case 1: return _buildBodyTypeStep();
      case 2: return _buildStylesStep();
      case 3: return _buildColorsStep();
      case 4: return _buildOccasionsStep();
      default: return const SizedBox();
    }
  }

  Widget _buildGenderStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "WHAT'S YOUR GENDER?",
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: const Color(0xFF1D1D1F),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This helps us personalize outfit recommendations',
          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF8E8E93)),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            _buildGenderOption('male', 'MEN', Icons.male_rounded),
            const SizedBox(width: 16),
            _buildGenderOption('female', 'WOMEN', Icons.female_rounded),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildGenderOption(String value, String label, IconData icon) {
    final isSelected = _gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() {
            _gender = value;
            _selectedStyles.clear();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1D1D1F) : const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, size: 48, color: isSelected ? Colors.white : const Color(0xFF8E8E93)),
              const SizedBox(height: 12),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: isSelected ? Colors.white : const Color(0xFF1D1D1F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBodyTypeStep() {
    final types = ['Slim', 'Average', 'Athletic', 'Muscular', 'Plus Size'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR BODY TYPE',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: const Color(0xFF1D1D1F),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Helps us suggest the best fits',
          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF8E8E93)),
        ),
        const SizedBox(height: 32),
        ...types.map((type) {
          final isSelected = _bodyType == type;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _bodyType = type);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1D1D1F) : const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isSelected ? Colors.white : const Color(0xFF8E8E93),
                    size: 22,
                  ),
                  const SizedBox(width: 14),
                  Text(
                    type,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF1D1D1F),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildStylesStep() {
    final styles = _stylesByGender[_gender] ?? _stylesByGender['male']!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR STYLE VIBES',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: const Color(0xFF1D1D1F),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pick all that resonate with you',
          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF8E8E93)),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: styles.map((style) {
            final isSelected = _selectedStyles.contains(style);
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  if (isSelected) {
                    _selectedStyles.remove(style);
                  } else {
                    _selectedStyles.add(style);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1D1D1F) : const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  style,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF1D1D1F),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildColorsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FAVORITE COLORS',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: const Color(0xFF1D1D1F),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pick up to 5 colors you love wearing',
          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF8E8E93)),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _colors.map((c) {
            final color = c['color'] as Color;
            final name = c['name'] as String;
            final isSelected = _selectedColors.contains(name);
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  if (isSelected) {
                    _selectedColors.remove(name);
                  } else if (_selectedColors.length < 5) {
                    _selectedColors.add(name);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 72, height: 80,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF1D1D1F) : (color == Colors.white ? Colors.grey.shade300 : Colors.transparent),
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF1D1D1F).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))] : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSelected) Icon(Icons.check_rounded, size: 20, color: color == Colors.white || color == Colors.yellow ? Colors.black : Colors.white),
                    const SizedBox(height: 4),
                    Text(name, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: color == Colors.white || color == Colors.yellow ? Colors.black : Colors.white)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildOccasionsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WHEN DO YOU DRESS UP?',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: const Color(0xFF1D1D1F),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We will suggest outfits for these occasions',
          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF8E8E93)),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _occasions.map((occ) {
            final isSelected = _selectedOccasions.contains(occ);
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  if (isSelected) {
                    _selectedOccasions.remove(occ);
                  } else {
                    _selectedOccasions.add(occ);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1D1D1F) : const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  occ,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF1D1D1F),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF1D1D1F)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'BACK',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: const Color(0xFF1D1D1F),
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D1D1F),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _currentStep == _totalSteps - 1 ? 'FINISH' : 'CONTINUE',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
