import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/tryon_service.dart' as tryon;
import '../../core/widgets/apple_button.dart';
import '../../core/models/outfit.dart';
import '../../core/models/product.dart';
import 'widgets/selfie_upload.dart';
import 'widgets/outfit_selector.dart';
import 'widgets/tryon_result.dart';

class VirtualTryOnScreen extends StatefulWidget {
  const VirtualTryOnScreen({super.key});

  @override
  State<VirtualTryOnScreen> createState() => _VirtualTryOnScreenState();
}

class _VirtualTryOnScreenState extends State<VirtualTryOnScreen> {
  File? _selfieImage;
  Outfit? _selectedOutfit;
  Product? _selectedProduct;
  bool _isLoading = false;
  String? _resultImageUrl;
  String? _tryOnSource;

  final tryon.TryOnService _tryOnService = tryon.TryOnService();

  Future<void> _tryOn() async {
    if (_selfieImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a photo first'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (_selectedOutfit == null || _selectedOutfit!.products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an outfit or product'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _resultImageUrl = null;
    });

    try {
      final result = await _tryOnService.tryOn(
        personImage: _selfieImage!,
        garmentImageUrl: _selectedOutfit!.primaryImage ?? '',
      );
      setState(() {
        _resultImageUrl = result.imageUrl;
        if (result.error != null) {
          _tryOnSource = result.source;
        }
      });
      if (result.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.source}: ${result.error}', style: GoogleFonts.inter()),
            backgroundColor: AppColors.charcoal,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _shareResult() {
    if (_resultImageUrl != null) {
      Share.share(
        'Check out my virtual try-on! Created with AI Fashion Designer app.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Virtual Try-On',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'See How It Looks',
                      style: GoogleFonts.inter(
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                        letterSpacing: 0,
                      ),
                    ).animate().fadeIn().slideY(begin: -0.1),

                    const SizedBox(height: 8),

                    Text(
                      'Upload your photo and select an outfit to try on',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        color: AppColors.inkMuted48,
                      ),
                    ).animate().fadeIn(delay: 100.ms),

                    const SizedBox(height: 24),

                    // Selfie upload
                    SelfieUpload(
                      image: _selfieImage,
                      onImageSelected: (file) {
                        setState(() => _selfieImage = file);
                      },
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 24),

                    // Outfit selector
                    OutfitSelector(
                      selectedOutfitId: _selectedOutfit?.id,
                      selectedProductId: _selectedProduct?.id,
                      onOutfitSelected: (outfit) {
                        setState(() {
                          _selectedOutfit = outfit;
                          _selectedProduct = null;
                        });
                      },
                      onProductSelected: (product) {
                        setState(() {
                          _selectedProduct = product;
                          _selectedOutfit = Outfit.create(
                            name: product.name,
                            products: [product],
                          );
                        });
                      },
                      showProducts: true,
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: 24),

                    // Try On button
                    SizedBox(
                      width: double.infinity,
                      child: AppleButton(
                        label: _isLoading ? 'Processing...' : 'Try On Now',
                        icon: _isLoading ? null : Icons.checkroom,
                        onPressed: _isLoading ? null : _tryOn,
                      ),
                    ).animate().fadeIn(delay: 400.ms),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Result area (dark tile)
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceTile1,
                ),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
                child: TryOnResult(
                  resultImageUrl: _resultImageUrl,
                  isLoading: _isLoading,
                  onSave: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Result saved!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  onShare: _shareResult,
                  onTryAnother: () {
                    setState(() {
                      _resultImageUrl = null;
                      _selectedOutfit = null;
                      _selectedProduct = null;
                    });
                  },
                ).animate().fadeIn(delay: 500.ms),
              ),
            ),
          ],
        ),
      ),
    );
  }
}