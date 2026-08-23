import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/data/outfit_data.dart';
import '../../core/models/product.dart';
import '../../core/services/saved_outfit_service.dart';
import '../../core/services/body_scan_service.dart';
import '../../features/body_measurement/services/body_measurement_service.dart';
import '../../core/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _savedCount = 0;
  int _designCount = 0;
  String _topCategory = 'Top Rated';

  @override
  void initState() {
    super.initState();
    _loadDynamicStats();
  }

  Future<void> _loadDynamicStats() async {
    final savedService = SavedOutfitService();
    await savedService.loadSavedOutfits();
    final bodyService = BodyMeasurementService();
    final hasMeasurements = await bodyService.load();
    final trendingCount = OutfitData.allProducts.where((p) => p.isTrending).length;
    String topCat = 'Top Rated';
    if (hasMeasurements && bodyService.currentProfile != null) {
      final sizes = bodyService.currentProfile!.measurements;
      if (sizes.isNotEmpty) {
        topCat = 'Size: M';
      }
    }
    if (mounted) {
      setState(() {
        _savedCount = savedService.savedOutfitsNotifier.value.length;
        _designCount = trendingCount;
        _topCategory = topCat;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasParchment,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDynamicStats,
          color: AppColors.accentPurple,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDarkHeader(),
                _buildWhiteContainerTop(),
                _buildSearchBar(),
                _buildQuickActions(),
                _buildFeatureGrid(),
                _buildTrendingStyles(),
                _buildRecommendedSection(),
                _buildCategoryPicks(),
                _buildNearbyTailors(),
                _buildPromoBanner(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDarkHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F0F1A), Color(0xFF1A1A2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${_getUserName()}',
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Discover your style today',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.violet.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.violet, width: 2),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(Icons.person_rounded, color: AppColors.white, size: 24),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF0F0F1A), width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _statChip('$_designCount Designs', Icons.auto_awesome),
              const SizedBox(width: 10),
              _statChip('$_savedCount Saved', Icons.bookmark_outline),
              const SizedBox(width: 10),
              _statChip(_topCategory, Icons.star_outline),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _statChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.violetLight),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  String _getUserName() {
    if (AuthService.user != null) {
      final name = AuthService.user!['first_name'] ?? AuthService.user!['username'] ?? '';
      return name.isNotEmpty ? name : 'Friend';
    }
    return 'Friend';
  }

  Widget _buildWhiteContainerTop() {
    return Container(
      height: 20,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  Widget _buildSearchBar() {
    final controller = TextEditingController();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dividerSoft),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, size: 22, color: AppColors.inkMuted48),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.search,
                onSubmitted: (val) {
                  if (val.isNotEmpty) {
                    context.push('/marketplace?search=${Uri.encodeComponent(val)}');
                  } else {
                    context.push('/marketplace');
                  }
                },
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.ink),
                decoration: InputDecoration(
                  hintText: 'Search outfits, styles, brands...',
                  hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.inkMuted48),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (controller.text.isNotEmpty) {
                  context.push('/marketplace?search=${Uri.encodeComponent(controller.text)}');
                } else {
                  context.push('/marketplace');
                }
              },
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tune_rounded, size: 18, color: AppColors.accentPurple),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          _quickAction('Scan', Icons.camera_alt_outlined, const Color(0xFF3B82F6), () => context.push('/body-measurement/upload')),
          const SizedBox(width: 12),
          _quickAction('Generate', Icons.auto_awesome_outlined, AppColors.accentPurple, () => context.push('/ai-studio')),
          const SizedBox(width: 12),
          _quickAction('Chat', Icons.chat_bubble_outline_rounded, const Color(0xFF22C55E), () => context.push('/stylist-chat')),
          const SizedBox(width: 12),
          _quickAction('Browse', Icons.explore_outlined, const Color(0xFFF59E0B), () => context.push('/browse-outfits')),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms);
  }

  Widget _quickAction(String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Features',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink, letterSpacing: -0.3),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _featureCard('AI Design Studio', Icons.palette_outlined, const Color(0xFF3B82F6), () => context.push('/ai-studio'))),
              const SizedBox(width: 12),
              Expanded(child: _featureCard('Style Analyzer', Icons.auto_awesome_outlined, AppColors.accentPurple, () => context.push('/style-analyzer'))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _featureCard('AI Fashion Assistant', Icons.chat_outlined, const Color(0xFF22C55E), () => context.push('/stylist-chat'))),
              const SizedBox(width: 12),
              Expanded(child: _featureCard('Outfit Builder', Icons.checkroom_outlined, const Color(0xFFF59E0B), () => context.push('/browse-outfits'))),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _featureCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dividerSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingStyles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            'Trending Styles',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink, letterSpacing: -0.3),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final styles = [
                {'title': 'Streetwear', 'image': 'https://image.hm.com/assets/hm/19/b9/19b96c80c6b674abacbb46438fab81b4b4c1779f.jpg?imwidth=400'},
                {'title': 'Ethnic Fusion', 'image': 'https://image.hm.com/assets/hm/1b/6c/1b6cde4a7a2eb444a0d2ad75e826bbb714aa48e7.jpg?imwidth=400'},
                {'title': 'Formal', 'image': 'https://image.hm.com/assets/hm/08/d9/08d969cad35ad29dc0aa7adc9bbe26d8e39286c6.jpg?imwidth=400'},
                {'title': 'Casual', 'image': 'https://image.hm.com/assets/hm/00/8a/008af4accd1366994998b0918f9ede5120b8a405.jpg?imwidth=400'},
              ];
              final style = styles[index];
              return GestureDetector(
                onTap: () => context.push('/marketplace'),
                child: Container(
                  width: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: style['image']!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: AppColors.canvasParchment, child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentPurple))),
                        errorWidget: (_, __, ___) => Container(color: AppColors.canvasParchment, child: const Icon(Icons.image_outlined, color: AppColors.inkMuted48, size: 32)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                          ),
                        ),
                        alignment: Alignment.bottomLeft,
                        padding: const EdgeInsets.all(14),
                        child: Text(
                          style['title']!,
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: 100 * index)).slideX(begin: 0.05);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedSection() {
    final products = OutfitData.recommended.take(4).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            'Recommended for You',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink, letterSpacing: -0.3),
          ),
        ),
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _recommendedCard(products[index], index),
          ),
        ),
      ],
    );
  }

  Widget _recommendedCard(Product product, int index) {
    return GestureDetector(
      onTap: () => context.push('/marketplace'),
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dividerSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 150,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: AppColors.canvasParchment, child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentPurple))),
                    errorWidget: (_, __, ___) => Container(color: AppColors.canvasParchment, child: const Icon(Icons.image_outlined, color: AppColors.inkMuted48, size: 32)),
                  ),
                ),
                if (product.discount > 0)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '-${product.discount}%',
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.white),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.brand,
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.inkMuted48),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '?${product.price}',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.accentPurple),
                      ),
                      if (product.discount > 0) ...[
                        const SizedBox(width: 6),
                        Text(
                          '?${(product.price * (1 + product.discount / 100)).round()}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.inkMuted48,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 80 * index));
  }

  Widget _buildCategoryPicks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            'Category Picks',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink, letterSpacing: -0.3),
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final cats = [
                {'title': 'Shirts', 'image': 'https://image.hm.com/assets/hm/00/8a/008af4accd1366994998b0918f9ede5120b8a405.jpg?imwidth=400'},
                {'title': 'Jeans', 'image': 'https://image.hm.com/assets/hm/02/41/02419d88b2721a5ac4f49705686fcd1ec4c07092.jpg?imwidth=400'},
                {'title': 'Kurtas', 'image': 'https://image.hm.com/assets/hm/0b/19/0b193f4320f30801155e33b5d6bd3b08f27d22cd.jpg?imwidth=400'},
                {'title': 'Sneakers', 'image': 'https://image.hm.com/assets/hm/29/e3/29e3119399abafcd5ae96470ca25d693ce7db2d6.jpg?imwidth=400'},
              ];
              final cat = cats[index];
              return GestureDetector(
                onTap: () => context.push('/marketplace'),
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: cat['image']!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: AppColors.canvasParchment, child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentPurple))),
                        errorWidget: (_, __, ___) => Container(color: AppColors.canvasParchment, child: const Icon(Icons.image_outlined, color: AppColors.inkMuted48, size: 32)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                          ),
                        ),
                        alignment: Alignment.bottomLeft,
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          cat['title']!,
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNearbyTailors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nearby Tailors',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink, letterSpacing: -0.3),
              ),
              TextButton(
                onPressed: () => context.push('/tailors'),
                child: Text('See All', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accentPurple)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final tailors = [
                {'name': 'Libas Tailor', 'specialty': 'Suits & Formal', 'rating': '4.9', 'distance': '1.2 km'},
                {'name': 'Sana Studio', 'specialty': 'Bridal & Lehengas', 'rating': '4.8', 'distance': '2.5 km'},
                {'name': 'Sameeksha', 'specialty': 'Western Wear', 'rating': '4.7', 'distance': '1.8 km'},
              ];
              final tailor = tailors[index];
              return GestureDetector(
                onTap: () => context.push('/tailors'),
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.dividerSoft),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: 'https://image.hm.com/assets/hm/0e/9d/0e9d5aad30cdb02146ec21cd1ac8059183935ead.jpg?imwidth=400',
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: AppColors.canvasParchment, child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentPurple))),
                        errorWidget: (_, __, ___) => Container(color: AppColors.canvasParchment, child: const Icon(Icons.content_cut_rounded, color: AppColors.inkMuted48, size: 32)),
                      ),
                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8)]),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(tailor['name']!, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(tailor['specialty']!, style: GoogleFonts.inter(fontSize: 11, color: Colors.white70)),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, size: 12, color: Color(0xFFFFD700)),
                                      const SizedBox(width: 3),
                                      Text(tailor['rating']!, style: GoogleFonts.inter(fontSize: 11, color: Colors.white)),
                                      const SizedBox(width: 6),
                                      Text(tailor['distance']!, style: GoogleFonts.inter(fontSize: 11, color: Colors.white70)),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: Duration(milliseconds: 100 * index));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPromoBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: GestureDetector(
        onTap: () => context.push('/invite-earn'),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invite Friends',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Get ?200 off for every friend who joins',
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Invite',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accentPurple),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }
}
