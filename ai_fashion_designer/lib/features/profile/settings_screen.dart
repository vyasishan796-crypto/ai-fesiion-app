import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/notification_service.dart';
import '../../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _autoSave = true;
  bool _locationServices = false;

  @override
  void initState() {
    super.initState();
    _darkMode = themeNotifier.value == ThemeMode.dark;
    _notifications = NotificationService().enabled;
  }

  bool _darkMode = false;

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
          'Settings',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildSection(
              'Notifications',
              [
                _buildSwitchTile(
                  icon: Icons.notifications_outlined,
                  title: 'Push Notifications',
                  subtitle: 'Outfit suggestions & offers',
                  value: _notifications,
                  onChanged: (val) {
                    setState(() => _notifications = val);
                    NotificationService().setEnabled(val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Appearance',
              [
                _buildSwitchTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  subtitle: 'Use dark theme',
                  value: _darkMode,
                  onChanged: (val) {
                    setState(() => _darkMode = val);
                    themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Preferences',
              [
                _buildSwitchTile(
                  icon: Icons.save_outlined,
                  title: 'Auto-Save Looks',
                  subtitle: 'Automatically save generated outfits',
                  value: _autoSave,
                  onChanged: (val) => setState(() => _autoSave = val),
                ),
                _buildSwitchTile(
                  icon: Icons.location_on_outlined,
                  title: 'Location Services',
                  subtitle: 'Find nearby stores & tailors',
                  value: _locationServices,
                  onChanged: (val) => setState(() => _locationServices = val),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Account',
              [
                _buildNavTile(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Text('Change Password', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(obscureText: true, decoration: InputDecoration(hintText: 'Current Password', hintStyle: GoogleFonts.inter(fontSize: 14)), style: GoogleFonts.inter(fontSize: 14)),
                            const SizedBox(height: 12),
                            TextField(obscureText: true, decoration: InputDecoration(hintText: 'New Password', hintStyle: GoogleFonts.inter(fontSize: 14)), style: GoogleFonts.inter(fontSize: 14)),
                            const SizedBox(height: 12),
                            TextField(obscureText: true, decoration: InputDecoration(hintText: 'Confirm New Password', hintStyle: GoogleFonts.inter(fontSize: 14)), style: GoogleFonts.inter(fontSize: 14)),
                          ],
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.inkMuted))),
                          TextButton(
                            onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password updated!', style: GoogleFonts.inter()), backgroundColor: AppColors.charcoal)); },
                            child: Text('Update', style: GoogleFonts.inter(color: AppColors.accentPurple, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                _buildNavTile(
                  icon: Icons.language,
                  title: 'Language',
                  subtitle: 'English',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Text('Select Language', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: ['English', 'Hindi', 'Hinglish'].map((lang) => ListTile(
                            title: Text(lang, style: GoogleFonts.inter(fontSize: 15)),
                            trailing: lang == 'English' ? const Icon(Icons.check, color: AppColors.accentPurple) : null,
                            onTap: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Language set to $lang', style: GoogleFonts.inter()), backgroundColor: AppColors.charcoal)); },
                          )).toList(),
                        ),
                      ),
                    );
                  },
                ),
                _buildNavTile(
                  icon: Icons.delete_outline,
                  title: 'Delete Account',
                  isDestructive: true,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Text(
                          'Delete Account?',
                          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        content: Text(
                          'This will permanently delete your account and all data.',
                          style: GoogleFonts.inter(fontSize: 14, color: AppColors.inkSecondary),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.inkMuted)),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await AuthService.logout();
                              if (context.mounted) context.go('/login');
                            },
                            child: Text('Delete', style: GoogleFonts.inter(color: AppColors.error, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              'About',
              [
                _buildNavTile(
                  icon: Icons.info_outline,
                  title: 'App Version',
                  subtitle: '1.0.0',
                  onTap: () {},
                ),
                _buildNavTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  onTap: () => launchUrl(Uri.parse('https://styleai.app/terms'), mode: LaunchMode.externalApplication),
                ),
                _buildNavTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () => launchUrl(Uri.parse('https://styleai.app/privacy'), mode: LaunchMode.externalApplication),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.inkMuted,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (val) {
              HapticFeedback.lightImpact();
              onChanged(val);
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    String? subtitle,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.error.withOpacity(0.08)
                    : AppColors.lightGrey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isDestructive ? AppColors.error : AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDestructive ? AppColors.error : AppColors.ink,
                ),
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.inkMuted,
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.inkMuted.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
