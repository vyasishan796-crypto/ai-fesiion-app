import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _error;
  int _currentStep = 1;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      setState(() => _error = 'Please fill all required fields');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await AuthService.register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirm: _confirmPasswordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success']) {
        context.go('/home');
      } else {
        final error = result['error'];
        setState(() {
          if (error is Map) {
            final firstError = error.values.first;
            _error = firstError is List ? firstError.first.toString() : firstError.toString();
          } else {
            _error = error.toString();
          }
        });
      }
    }
  }

  void _nextStep() {
    if (_currentStep == 1) {
      if (_usernameController.text.isEmpty || _emailController.text.isEmpty) {
        setState(() => _error = 'Please fill username and email');
        return;
      }
      setState(() {
        _currentStep = 2;
        _error = null;
      });
    }
  }

  void _prevStep() {
    if (_currentStep == 2) {
      setState(() {
        _currentStep = 1;
        _error = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.ink,
          onPressed: () => _currentStep == 2 ? _prevStep() : context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildHeader(),
              const SizedBox(height: 28),
              _buildStepIndicator(),
              const SizedBox(height: 28),
              if (_currentStep == 1) _buildStep1() else _buildStep2(),
              const SizedBox(height: 20),
              if (_error != null) _buildError(),
              const SizedBox(height: 28),
              _buildNextButton(),
              const SizedBox(height: 24),
              _buildLoginLink(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            _currentStep == 1 ? Icons.person_add_rounded : Icons.lock_outline_rounded,
            color: AppColors.white,
            size: 30,
          ),
        ).animate().fadeIn(delay: 100.ms).scale(
          begin: const Offset(0.8, 0.8),
          curve: Curves.elasticOut,
        ),
        const SizedBox(height: 24),
        Text(
          _currentStep == 1 ? 'Create Account' : 'Set Password',
          style: GoogleFonts.inter(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            letterSpacing: -1,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
        const SizedBox(height: 8),
        Text(
          _currentStep == 1
              ? 'Start your fashion journey today'
              : 'Secure your account with a password',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: AppColors.inkSecondary,
          ),
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepDot(1, _currentStep >= 1),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _currentStep >= 2 ? 1.0 : 0.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildStepDot(2, _currentStep >= 2),
      ],
    ).animate().fadeIn(delay: 350.ms);
  }

  Widget _buildStepDot(int step, bool isActive) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.lightGrey,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.border,
          width: 1.5,
        ),
      ),
      child: Center(
        child: isActive
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
            : Text(
                '$step',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkMuted,
                ),
              ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        _buildInputField(
          controller: _usernameController,
          label: 'Username *',
          hint: 'Choose a username',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _emailController,
          label: 'Email *',
          hint: 'Enter your email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                controller: _firstNameController,
                label: 'First Name',
                hint: 'First',
                icon: Icons.badge_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInputField(
                controller: _lastNameController,
                label: 'Last Name',
                hint: 'Last',
                icon: Icons.badge_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _phoneController,
          label: 'Phone',
          hint: 'Enter phone number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildStep2() {
    return Column(
      children: [
        _buildInputField(
          controller: _passwordController,
          label: 'Password *',
          hint: 'Min 6 characters',
          icon: Icons.lock_outline_rounded,
          obscure: _obscurePassword,
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            child: Icon(
              _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: AppColors.inkMuted,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _confirmPasswordController,
          label: 'Confirm Password *',
          hint: 'Re-enter password',
          icon: Icons.lock_outline_rounded,
          obscure: _obscureConfirm,
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
            child: Icon(
              _obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: AppColors.inkMuted,
              size: 20,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscure,
            style: GoogleFonts.inter(fontSize: 15, color: AppColors.ink),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.inkMuted),
              prefixIcon: Icon(icon, color: AppColors.inkMuted, size: 20),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextButton() {
    final isStep2 = _currentStep == 2;
    return GestureDetector(
      onTap: _isLoading ? null : (isStep2 ? _register : _nextStep),
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: _isLoading ? null : AppColors.primaryGradient,
          color: _isLoading ? AppColors.mediumGrey : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: _isLoading ? [] : [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Creating account...',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isStep2 ? 'Create Account' : 'Continue',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isStep2 ? Icons.check_rounded : Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _error!,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.error),
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.inkSecondary),
        ),
        GestureDetector(
          onTap: () => context.pop(),
          child: Text(
            'Sign In',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
