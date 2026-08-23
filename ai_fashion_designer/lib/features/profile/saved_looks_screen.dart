import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/services/saved_outfit_service.dart';
import '../outfit_browser/widgets/outfit_card.dart';

class SavedLooksScreen extends StatefulWidget {
  const SavedLooksScreen({super.key});

  @override
  State<SavedLooksScreen> createState() => _SavedLooksScreenState();
}

class _SavedLooksScreenState extends State<SavedLooksScreen> {
  final SavedOutfitService _savedService = SavedOutfitService();

  @override
  void initState() {
    super.initState();
    _savedService.loadSavedOutfits();
  }

  Future<void> _removeOutfit(String outfitId) async {
    await _savedService.removeOutfit(outfitId);
    setState(() {});
  }

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
          'Saved Looks',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          ValueListenableBuilder(
            valueListenable: _savedService.savedOutfitsNotifier,
            builder: (context, savedOutfits, _) {
              if (savedOutfits.isNotEmpty) {
                return TextButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Clear All Saved Looks?', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        content: Text('This will remove all saved outfits', style: GoogleFonts.inter(fontSize: 14, color: AppColors.inkSecondary)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.inkMuted48))),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Clear All', style: GoogleFonts.inter(color: AppColors.error))),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _savedService.clearAll();
                      setState(() {});
                    }
                  },
                  child: Text(
                    'Clear All',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Fashion Collection',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn().slideY(begin: -0.1),
                  const SizedBox(height: 8),
                  Text(
                    'Outfits you\'ve saved for later.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.inkSecondary,
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _savedService.savedOutfitsNotifier,
                builder: (context, savedOutfits, _) {
                  if (savedOutfits.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: savedOutfits.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final saved = savedOutfits[index];
                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: AppRadius.md,
                              border: Border.all(color: AppColors.dividerSoft),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: OutfitCard(
                              outfit: saved.outfit,
                              isSaved: true,
                              showSaveButton: false,
                              onGenerateImage: () {},
                              savedImageUrl: saved.aiGeneratedImageUrl,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => _removeOutfit(saved.outfit.id),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: Duration(milliseconds: 50 * (index % 20))).slideY(begin: 0.03);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_outline,
            size: 56,
            color: AppColors.inkMuted48.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No saved outfits yet',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Browse outfits and tap the bookmark\nicon to save your favorites here',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.inkMuted48,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.push('/browse-outfits'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
            ),
            child: Text(
              'Browse Outfits',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
