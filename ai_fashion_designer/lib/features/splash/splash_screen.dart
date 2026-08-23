import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _navigate();
  }

  Future<void> _navigate() async {
    await AuthService.init();
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      if (AuthService.isLoggedIn) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoal,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E1E1E),
              Color(0xFF0F0F0F),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.1),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.checkroom,
                      size: 44,
                      color: AppColors.primary,
                    ),
                  ).animate().fadeIn(duration: 600.ms).scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                    curve: Curves.easeOut,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Style',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideX(begin: -0.1, end: 0),
                      Text(
                        'AI',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: -0.5,
                        ),
                      ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideX(begin: -0.1, end: 0),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fashion reimplemented with AI',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.5),
                      letterSpacing: 0.3,
                    ),
                  ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: AppColors.primary.withOpacity(0.6),
                    strokeWidth: 2.5,
                  ),
                ).animate().fadeIn(delay: 800.ms, duration: 400.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
