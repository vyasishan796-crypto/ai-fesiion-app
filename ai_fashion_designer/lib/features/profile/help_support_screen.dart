import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

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
          'Help & Support',
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
            Text(
              'How Can We Help?',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                letterSpacing: -0.5,
              ),
            ).animate().fadeIn(),
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildFAQSection(),
            const SizedBox(height: 24),
            _buildContactSection(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.inkMuted, size: 22),
          const SizedBox(width: 12),
          Text(
            'Search help topics...',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.inkMuted,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildFAQSection() {
    final faqs = [
      {
        'q': 'How does AI outfit generation work?',
        'a': 'Describe your dream outfit and our AI creates it in seconds using advanced image generation.',
      },
      {
        'q': 'How accurate are body measurements?',
        'a': 'AI measurements are estimated from photos. For professional tailoring, we recommend manual verification.',
      },
      {
        'q': 'Can I return AI-generated outfits?',
        'a': 'AI outfits are virtual. Physical items purchased through marketplace partners have standard return policies.',
      },
      {
        'q': 'Is my data secure?',
        'a': 'Yes! Photos are processed securely and deleted after analysis. Your measurements are encrypted.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 14),
        ...faqs.asMap().entries.map((entry) {
          final faq = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  faq['q']!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  faq['a']!,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.inkSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 100 * entry.key));
        }),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Us',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 14),
        _buildContactTile(
          icon: Icons.email_outlined,
          title: 'Email Support',
          subtitle: 'support@styleai.com',
          onTap: () => launchUrl(Uri.parse('mailto:support@styleai.com?subject=StyleAI Support Request')),
        ),
        const SizedBox(height: 10),
        _buildContactTile(
          icon: Icons.chat_bubble_outline,
          title: 'Live Chat',
          subtitle: 'Available 9 AM - 6 PM',
          onTap: () => launchUrl(Uri.parse('https://styleai.app/chat'), mode: LaunchMode.externalApplication),
        ),
        const SizedBox(height: 10),
        _buildContactTile(
          icon: Icons.phone_outlined,
          title: 'Call Us',
          subtitle: '1800-XXX-XXXX (Toll Free)',
          onTap: () => launchUrl(Uri.parse('tel:18001234567')),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
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
