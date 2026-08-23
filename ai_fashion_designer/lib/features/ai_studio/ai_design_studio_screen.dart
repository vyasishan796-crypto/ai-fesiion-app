import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/outfit.dart';
import '../../core/models/product.dart';
import '../../core/models/virtual_tryon_generation.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/virtual_tryon_service.dart';
import '../../core/services/product_image_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../features/virtual_tryon/widgets/outfit_selector.dart';
import 'widgets/chat_prompt.dart';
import 'widgets/loading_experience.dart';
import 'widgets/tryon_result_actions.dart';
import 'widgets/product_preview.dart';

class AIDesignStudioScreen extends StatefulWidget {
  final Product? initialProduct;
  final Outfit? initialOutfit;

  const AIDesignStudioScreen({
    super.key,
    this.initialProduct,
    this.initialOutfit,
  });

  @override
  State<AIDesignStudioScreen> createState() => _AIDesignStudioScreenState();
}

class _AIDesignStudioScreenState extends State<AIDesignStudioScreen> {
  final VirtualTryOnService _tryOnService = VirtualTryOnService();
  final AuthService _authService = AuthService();
  final TextEditingController _promptController = TextEditingController();

  File? _userImage;
  Outfit? _selectedOutfit;
  Product? _selectedProduct;
  bool _isLoading = false;
  VirtualTryOnGeneration? _lastGeneration;
  String _currentPrompt = '';
  final List<_ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialOutfit != null) {
      _selectedOutfit = widget.initialOutfit;
    } else if (widget.initialProduct != null) {
      _selectedProduct = widget.initialProduct;
      _selectedOutfit = Outfit.create(
        name: widget.initialProduct!.name,
        products: [widget.initialProduct!],
      );
    }
    _promptController.addListener(() {
      setState(() => _currentPrompt = _promptController.text);
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() => _userImage = File(pickedFile.path));
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text('Camera', style: GoogleFonts.inter()),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('Gallery', style: GoogleFonts.inter()),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateTryOn() async {
    if (_userImage == null) {
      _showSnackBar('Please upload your photo first', AppColors.warning);
      return;
    }

    if (_selectedOutfit == null || _selectedOutfit!.products.isEmpty) {
      _showSnackBar('Please select an outfit or product', AppColors.warning);
      return;
    }

    if (!_currentPrompt.trim().isNotEmpty) {
      _showSnackBar('Enter a prompt describing how you want the outfit to look', AppColors.warning);
      return;
    }

    // Check auth
    final isLoggedIn = AuthService.isLoggedIn;
    if (!isLoggedIn) {
      _showSnackBar('Please log in to use virtual try-on', AppColors.error);
      context.push('/login');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final generation = await VirtualTryOnService().generate(
        userImage: _userImage!,
        products: _selectedOutfit!.products,
        userPrompt: _currentPrompt.trim(),
        outfitId: _selectedOutfit!.id,
      );

      setState(() {
        _lastGeneration = generation;
        _isLoading = false;
        _messages.add(_ChatMessage(
          text: _currentPrompt,
          isUser: true,
          timestamp: DateTime.now(),
        ));
        _messages.add(_ChatMessage(
          text: 'Your virtual try-on is ready!',
          isUser: false,
          timestamp: DateTime.now(),
          generation: generation,
        ));
        _promptController.clear();
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error: $e', AppColors.error);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _regenerate() {
    if (_lastGeneration == null || _userImage == null) return;
    _generateTryOn();
  }

  void _editPrompt() {
    if (_lastGeneration == null) return;
    _promptController.text = _currentPrompt;
  }

  void _saveLook() async {
    if (_lastGeneration == null) return;
    try {
      await VirtualTryOnService().saveToLocalHistory(_lastGeneration!);
      _showSnackBar('Look saved!', AppColors.success);
    } catch (e) {
      _showSnackBar('Failed to save', AppColors.error);
    }
  }

  void _addToCart() {
    if (_lastGeneration == null) return;
    // Navigate to cart or add directly
    context.push('/cart');
  }

  void _viewProduct() {
    if (_selectedOutfit == null) return;
    final product = _selectedOutfit!.products.first;
    context.push('/marketplace/product/${product.id}');
  }

  void _tryAnother() {
    setState(() {
      _lastGeneration = null;
      _userImage = null;
      _selectedOutfit = null;
      _selectedProduct = null;
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthService.isLoggedIn;

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
                      'AI Design Studio',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    const Spacer(),
                    if (!isLoggedIn)
                      TextButton(
                        onPressed: () => context.push('/login'),
                        child: Text('Login', style: GoogleFonts.inter(color: AppColors.accentPurple)),
                      ),
                  ],
                ),
              ),
            ),

            // Title Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Your Look',
                      style: GoogleFonts.inter(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        letterSpacing: -0.5,
                      ),
                    ).animate().fadeIn().slideY(begin: -0.1),
                    const SizedBox(height: 8),
                    Text(
                      'Upload your photo, pick an outfit, and describe your vision.',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppColors.inkMuted48,
                      ),
                    ).animate().fadeIn(delay: 100.ms),
                  ],
                ),
              ),
            ),

            // Selected Outfit/Product Preview
            if (_selectedOutfit != null)
              SliverToBoxAdapter(
                child: ProductPreview(
                  outfit: _selectedOutfit!,
                  onChange: () => setState(() => _selectedOutfit = null),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
              ),

            // Outfit/Product Selector
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedOutfit == null ? 'Choose Your Outfit' : 'Change Outfit',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: OutfitSelector(
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
              ).animate().fadeIn(delay: 400.ms),
            ),

            // User Photo Upload
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Photo',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        width: double.infinity,
                        height: 240,
                        decoration: BoxDecoration(
                          color: _userImage != null ? AppColors.canvasParchment : AppColors.canvas,
                          borderRadius: AppRadius.lg,
                          border: Border.all(
                            color: _userImage != null ? AppColors.primary : AppColors.hairline,
                            width: _userImage != null ? 2 : 1,
                          ),
                        ),
                        child: _userImage != null
                            ? ClipRRect(
                                borderRadius: AppRadius.lg,
                                child: Image.file(_userImage!, fit: BoxFit.cover),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt_outlined,
                                    size: 56,
                                    color: AppColors.inkMuted48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Tap to upload your photo',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      color: AppColors.inkMuted48,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Full-body photo works best',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: AppColors.inkMuted48,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Chat Prompt
            SliverToBoxAdapter(
              child: ChatPrompt(
                controller: _promptController,
                currentPrompt: _currentPrompt,
                messages: _messages,
                onSend: _generateTryOn,
                isLoading: _isLoading,
                enabled: _userImage != null && _selectedOutfit != null && isLoggedIn,
              ).animate().fadeIn(delay: 600.ms),
            ),

            // Result Area
            if (_lastGeneration != null || _isLoading)
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceTile1,
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
                  child: Column(
                    children: [
                      if (_isLoading)
                        LoadingExperience(
                          message: _loadingMessages[(_lastGeneration?.id.hashCode ?? 0) % _loadingMessages.length],
                        ).animate().fadeIn()
                      else if (_lastGeneration != null)
                        TryOnResultActions(
                          generation: _lastGeneration!,
                          onRegenerate: _regenerate,
                          onEditPrompt: _editPrompt,
                          onSave: _saveLook,
                          onShare: () => _shareResult(),
                          onTryOn: _viewProduct,
                          onAddToCart: _addToCart,
                          onTryAnother: _tryAnother,
                        ).animate().fadeIn(),
                      const SizedBox(height: 24),
                      if (_lastGeneration != null && !isLoggedIn)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: AppColors.warning),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Log in to save this look and add to cart',
                                  style: GoogleFonts.inter(color: AppColors.warning),
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.push('/login'),
                                child: const Text('Login'),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(),
                    ],
                  ),
                ),
              ),

            // Prompt Suggestions (when no generation yet)
            if (_lastGeneration == null && !_isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Try These Prompts',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _promptSuggestions.map((s) => ActionChip(
                          label: Text(s, style: GoogleFonts.inter(fontSize: 13)),
                          onPressed: () {
                            _promptController.text = s;
                            setState(() => _currentPrompt = s);
                          },
                          backgroundColor: AppColors.canvasParchment,
                          side: BorderSide(color: AppColors.hairline),
                        )).toList(),
                      ),
                    ],
                  ).animate().fadeIn(delay: 700.ms),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _shareResult() {
    if (_lastGeneration != null) {
      _showSnackBar('Share functionality coming soon', AppColors.primary);
    }
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final VirtualTryOnGeneration? generation;

  _ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.generation,
  });
}

const _loadingMessages = [
  "Analyzing your look...",
  "Understanding the garment...",
  "Fitting the outfit...",
  "Rendering fabric details...",
  "Creating your virtual try-on...",
  "Almost ready...",
];

const _promptSuggestions = [
  "Put this on me",
  "Show me in street style",
  "Make it look fitted",
  "Casual weekend vibe",
  "Professional office look",
  "Evening party ready",
  "Change background to studio",
  "Keep my hairstyle",
];
