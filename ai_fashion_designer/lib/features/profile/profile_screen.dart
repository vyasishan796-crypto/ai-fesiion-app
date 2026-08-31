import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../features/body_measurement/services/body_measurement_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _sizeText = 'Not measured yet';

  @override
  void initState() {
    super.initState();
    _loadMeasurements();
  }

  Future<void> _loadMeasurements() async {
    final service = BodyMeasurementService();
    final loaded = await service.load();
    if (loaded && service.currentProfile != null && mounted) {
      final profile = service.currentProfile!;
      String top = 'M';
      String bottom = '32';
      for (final m in profile.measurements) {
        if (m.name.toLowerCase().contains('chest') && m.value != null) {
          final cm = m.value!;
          if (cm < 92) top = 'S';
          else if (cm < 100) top = 'M';
          else if (cm < 108) top = 'L';
          else if (cm < 116) top = 'XL';
          else top = 'XXL';
        }
        if (m.name.toLowerCase().contains('waist') && m.value != null) {
          final cm = m.value!;
          if (cm < 76) bottom = '28';
          else if (cm < 82) bottom = '30';
          else if (cm < 88) bottom = '32';
          else if (cm < 94) bottom = '34';
          else bottom = '36';
        }
      }
      setState(() => _sizeText = '$top Top / $bottom Bottom');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                color: Colors.white,
                onPressed: () => Navigator.pop(context),
              )
            : null,
        centerTitle: true,
        title: Text('PROFILE', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 2)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nike hero user block
            Container(
              width: double.infinity,
              color: Colors.black,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 1)),
                    child: const Icon(Icons.person_rounded, size: 32, color: Colors.black),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AuthService.user?['username'] ?? AuthService.user?['first_name'] ?? 'Guest User',
                          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AuthService.user?['email'] ?? 'Sign in to sync your style',
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Text(AuthService.isLoggedIn ? 'MEMBER' : 'GUEST', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 1)),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 20),
            _buildMeasurementsCard(),
            const SizedBox(height: 20),
            _buildMenuSection(),
            const SizedBox(height: 20),
            if (AuthService.isLoggedIn)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: GestureDetector(
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: Text('LOGOUT?', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 1)),
                          content: Text('Are you sure you want to logout?', style: GoogleFonts.inter(fontSize: 13, color: AppColors.inkMuted48)),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('CANCEL', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.inkMuted48, letterSpacing: 0.5))),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('LOGOUT', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w800, letterSpacing: 0.5))),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await AuthService.logout();
                        if (mounted) context.go('/login');
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1.5), borderRadius: BorderRadius.circular(30)),
                      child: Center(child: Text('LOGOUT', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black, letterSpacing: 2))),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Center(child: Text('STYLE.AI  •  VERSION 1.0.0', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.inkMuted48, letterSpacing: 1.5))),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => context.push('/profile/body-measurement/upload'),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey[200]!)),
          child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.straighten_rounded, color: Colors.white, size: 22)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('BODY MEASUREMENTS', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 1)),
              const SizedBox(height: 2),
              Text(_sizeText, style: GoogleFonts.inter(fontSize: 12, color: AppColors.inkMuted48)),
            ])),
            const Icon(Icons.chevron_right_rounded, color: Colors.black),
          ]),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _menuGroup('AI FEATURES', [
            _menuItem(Icons.auto_awesome_rounded, 'AI Style Analyzer', () => context.push('/profile/style-analyzer')),
            _menuItem(Icons.chat_bubble_outline_rounded, 'AI Stylist Chat', () => context.push('/profile/stylist-chat')),
            _menuItem(Icons.straighten_rounded, 'Body Measurement', () => context.push('/profile/body-measurement/upload')),
          ]),
          const SizedBox(height: 18),
          if (AuthService.isLoggedIn) ...[
            _menuGroup('SHOPPING', [
              _menuItem(Icons.receipt_long_outlined, 'My Orders', () => context.go('/orders')),
              _menuItem(Icons.favorite_border_rounded, 'Wishlist', () => context.push('/profile/wishlist')),
              _menuItem(Icons.bookmark_outline_rounded, 'Saved Looks', () => context.push('/profile/saved-looks')),
              _menuItem(Icons.quiz_outlined, 'Style Quiz', () => context.push('/profile/style-quiz')),
              _menuItem(Icons.location_on_outlined, 'Addresses', () => context.push('/profile/addresses')),
            ]),
            const SizedBox(height: 18),
          ],
          _menuGroup('ACCOUNT', [
            _menuItem(Icons.person_outline_rounded, 'Edit Profile', () => context.push('/profile/edit-profile')),
            _menuItem(Icons.settings_outlined, 'Settings', () => context.push('/profile/settings')),
            _menuItem(Icons.help_outline_rounded, 'Help & Support', () => context.push('/profile/help-support')),
          ]),
          if (AuthService.user != null && AuthService.user!['is_superuser'] == true) ...[
            const SizedBox(height: 18),
            _menuGroup('ADMIN', [
              _menuItem(Icons.admin_panel_settings_outlined, 'Admin Panel', () => context.push('/profile/admin')),
            ]),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _menuGroup(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 1.5)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Icon(icon, size: 20, color: Colors.black),
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black))),
          const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.black38),
        ]),
      ),
    );
  }
}
