import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/apple_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      icon: Icons.auto_awesome,
      title: 'AI Outfit\nGenerator',
      subtitle: 'Describe your dream outfit and watch AI create it for you in seconds.',
      color: AppColors.primary,
    ),
    OnboardingData(
      icon: Icons.straighten,
      title: 'Virtual\nTry-On',
      subtitle: 'See how any outfit looks on you before you buy it. No fitting room needed.',
      color: AppColors.primaryOnDark,
    ),
    OnboardingData(
      icon: Icons.style,
      title: 'Your Personal\nStylist',
      subtitle: 'Get personalized recommendations based on your body type and preferences.',
      color: AppColors.primary,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/home');
    }
  }

  void _skip() {
    context.go('/home');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    'Skip',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: AppColors.inkMuted48,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: page.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(
                            page.icon,
                            size: 60,
                            color: page.color,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .scale(begin: const Offset(0.8, 0.8)),
                        const SizedBox(height: 48),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 40,
                            fontWeight: FontWeight.w600,
                            height: 1.10,
                            letterSpacing: 0,
                            color: AppColors.ink,
                          ),
                        ).animate().fadeIn(
                              delay: 200.ms,
                              duration: 500.ms,
                            ),
                        const SizedBox(height: 16),
                        Text(
                          page.subtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            height: 1.47,
                            letterSpacing: -0.374,
                            color: AppColors.inkMuted48,
                          ),
                        ).animate().fadeIn(
                              delay: 400.ms,
                              duration: 500.ms,
                            ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.dividerSoft,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: AppleButton(
                      label: _currentPage == _pages.length - 1
                          ? 'Get Started'
                          : 'Next',
                      onPressed: _nextPage,
                      type: AppleButtonType.primary,
                    ),
                  ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  OnboardingData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
