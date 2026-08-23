import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;
  bool _rememberMe = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _error = 'Please fill all fields');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await AuthService.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success']) {
        context.go('/home');
      } else {
        final error = result['error'];
        setState(() {
          if (error is Map) {
            _error = error['network'] ?? error['error'] ?? error['detail'] ?? 'Login failed';
          } else {
            _error = error.toString();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 60),
              _buildHeader(),
              const SizedBox(height: 48),
              _buildLoginForm(),
              const SizedBox(height: 16),
              _buildRememberRow(),
              const SizedBox(height: 28),
              _buildLoginButton(),
              const SizedBox(height: 16),
              if (_error != null) _buildError(),
              const SizedBox(height: 28),
              _buildDivider(),
              const SizedBox(height: 28),
              _buildSocialLogin(),
              const SizedBox(height: 32),
              _buildRegisterLink(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.checkroom_rounded,
            color: AppColors.white,
            size: 36,
          ),
        ).animate().fadeIn(duration: 500.ms).scale(
          begin: const Offset(0.8, 0.8),
          curve: Curves.elasticOut,
        ),
        const SizedBox(height: 28),
        Text(
          'Welcome Back',
          style: GoogleFonts.inter(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            letterSpacing: -1,
          ),
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue your style journey',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: AppColors.inkSecondary,
          ),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        _buildInputField(
          controller: _usernameController,
          label: 'Username',
          hint: 'Enter your username',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 18),
        _buildInputField(
          controller: _passwordController,
          label: 'Password',
          hint: 'Enter your password',
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
      ],
    ).animate().fadeIn(delay: 300.ms);
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
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
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

  Widget _buildRememberRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => setState(() => _rememberMe = !_rememberMe),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _rememberMe ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _rememberMe ? AppColors.primary : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: _rememberMe
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                    : null,
              ),
              const SizedBox(width: 10),
              Text(
                'Remember me',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.inkSecondary,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => _showForgotPasswordDialog(),
          child: Text(
            'Forgot Password?',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _login,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: _isLoading ? null : AppColors.primaryGradient,
          color: _isLoading ? AppColors.mediumGrey : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: _isLoading ? [] : [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
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
                      'Signing in...',
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
                      'Sign In',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
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

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.inkMuted,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppColors.border)),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }

  bool _isGoogleLoading = false;

  Widget _buildSocialLogin() {
    return Row(
      children: [
        Expanded(
          child: _buildGoogleButton(),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildAppleButton(),
        ),
      ],
    ).animate().fadeIn(delay: 700.ms);
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _error = null;
    });

    final result = await AuthService.loginWithGoogle();

    if (mounted) {
      setState(() => _isGoogleLoading = false);
      if (result['success']) {
        context.go('/home');
      } else {
        final error = result['error'];
        setState(() {
          if (error is Map) {
            _error = error['error'] ?? error['detail'] ?? 'Google login failed';
          } else {
            _error = error.toString();
          }
        });
      }
    }
  }

  Widget _buildGoogleButton() {
    return GestureDetector(
      onTap: _isGoogleLoading ? null : _loginWithGoogle,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isGoogleLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else ...[
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage('https://developers.google.com/identity/images/g-logo.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 10),
            Text(
              _isGoogleLoading ? 'Signing in...' : 'Google',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppleButton() {
    return GestureDetector(
      onTap: () => _showAppleSignInDialog(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.charcoal,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.apple_rounded,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              'Apple',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.inkSecondary),
        ),
        GestureDetector(
          onTap: () => context.push('/register'),
          child: Text(
            'Sign Up',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 800.ms);
  }

  void _showAppleSignInDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.apple_rounded, size: 22),
            const SizedBox(width: 8),
            Text('Apple Sign-In', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
          ],
        ),
        content: Text(
          'Apple Sign-In is available on iOS devices. On Android, please use Google Sign-In or your email/password to sign in.',
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.inkSecondary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.charcoal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Got it', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reset Password', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.inkSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.inter(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Enter your email',
                hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.inkMuted),
                prefixIcon: const Icon(Icons.email_outlined, size: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.inkMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (emailController.text.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Password reset link sent to ${emailController.text}', style: GoogleFonts.inter()),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Send Link', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
