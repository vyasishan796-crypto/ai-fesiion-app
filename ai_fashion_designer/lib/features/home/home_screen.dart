import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDynamicStats,
          color: const Color(0xFF1D1D1F),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDarkHeader(),
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
        color: Color(0xFF1D1D1F),
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
                    'HELLO, ${_getUserName().toUpperCase()}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'What\'s your style today?',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _statChip('$_designCount DESIGNS', Icons.auto_awesome),
              const SizedBox(width: 10),
              _statChip('$_savedCount SAVED', Icons.bookmark_outline),
              const SizedBox(width: 10),
              _statChip(_topCategory.toUpperCase(), Icons.star_outline),
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
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withOpacity(0.6)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: Colors.white.withOpacity(0.7),
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

  Widget _buildSearchBar() {
    final controller = TextEditingController();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, size: 22, color: Color(0xFF8E8E93)),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.search,
                onSubmitted: (val) {
                  if (val.isNotEmpty) {
                    context.go('/marketplace?search=${Uri.encodeComponent(val)}');
                  } else {
                    context.go('/marketplace');
                  }
                },
                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1D1D1F)),
                decoration: InputDecoration(
                  hintText: 'Search outfits, styles, brands...',
                  hintStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF8E8E93)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
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
          _quickAction('Scan', Icons.camera_alt_outlined, () => context.push('/home/body-measurement/upload')),
          const SizedBox(width: 12),
          _quickAction('Generate', Icons.auto_awesome_outlined, () => context.push('/home/ai-studio')),
          const SizedBox(width: 12),
          _quickAction('Chat', Icons.chat_bubble_outline_rounded, () => context.push('/home/stylist-chat')),
          const SizedBox(width: 12),
          _quickAction('Browse', Icons.explore_outlined, () => context.push('/home/browse-outfits')),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms);
  }

  Widget _quickAction(String label, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon, size: 24, color: const Color(0xFF1D1D1F)),
              const SizedBox(height: 6),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: const Color(0xFF1D1D1F),
                ),
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
            'AI FEATURES',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: const Color(0xFF8E8E93),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _featureCard('AI Design Studio', Icons.palette_outlined, () => context.push('/home/ai-studio'))),
              const SizedBox(width: 12),
              Expanded(child: _featureCard('Style Analyzer', Icons.auto_awesome_outlined, () => context.push('/home/style-analyzer'))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _featureCard('AI Assistant', Icons.chat_outlined, () => context.push('/home/stylist-chat'))),
              const SizedBox(width: 12),
              Expanded(child: _featureCard('Outfit Builder', Icons.checkroom_outlined, () => context.push('/home/browse-outfits'))),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _featureCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: const Color(0xFF1D1D1F)),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF1D1D1F)),
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
            'TRENDING STYLES',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: const Color(0xFF8E8E93),
            ),
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
                {'title': 'STREETWEAR', 'image': 'https://image.hm.com/assets/hm/19/b9/19b96c80c6b674abacbb46438fab81b4b4c1779f.jpg?imwidth=400'},
                {'title': 'ETHNIC FUSION', 'image': 'https://image.hm.com/assets/hm/1b/6c/1b6cde4a7a2eb444a0d2ad75e826bbb714aa48e7.jpg?imwidth=400'},
                {'title': 'FORMAL', 'image': 'https://image.hm.com/assets/hm/08/d9/08d969cad35ad29dc0aa7adc9bbe26d8e39286c6.jpg?imwidth=400'},
                {'title': 'CASUAL', 'image': 'https://image.hm.com/assets/hm/00/8a/008af4accd1366994998b0918f9ede5120b8a405.jpg?imwidth=400'},
              ];
              final style = styles[index];
              return GestureDetector(
                onTap: () => context.go('/marketplace'),
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
                        placeholder: (_, __) => Container(color: const Color(0xFFF5F5F7), child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1D1D1F)))),
                        errorWidget: (_, __, ___) => Container(color: const Color(0xFFF5F5F7), child: const Icon(Icons.image_outlined, color: Color(0xFF8E8E93), size: 32)),
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
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
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
            'RECOMMENDED FOR YOU',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: const Color(0xFF8E8E93),
            ),
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
      onTap: () => context.go('/marketplace'),
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F0F5)),
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
                    placeholder: (_, __) => Container(color: const Color(0xFFF5F5F7), child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1D1D1F)))),
                    errorWidget: (_, __, ___) => Container(color: const Color(0xFFF5F5F7), child: const Icon(Icons.image_outlined, color: Color(0xFF8E8E93), size: 32)),
                  ),
                ),
                if (product.discount > 0)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D1D1F),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '-${product.discount}%',
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
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
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1D1D1F)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.brand,
                    style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF8E8E93)),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '?${product.price}',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1D1D1F)),
                      ),
                      if (product.discount > 0) ...[
                        const SizedBox(width: 6),
                        Text(
                          '?${(product.price * (1 + product.discount / 100)).round()}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF8E8E93),
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
            'CATEGORY PICKS',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: const Color(0xFF8E8E93),
            ),
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
                {'title': 'SHIRTS', 'image': 'https://image.hm.com/assets/hm/00/8a/008af4accd1366994998b0918f9ede5120b8a405.jpg?imwidth=400'},
                {'title': 'JEANS', 'image': 'https://image.hm.com/assets/hm/02/41/02419d88b2721a5ac4f49705686fcd1ec4c07092.jpg?imwidth=400'},
                {'title': 'KURTAS', 'image': 'https://image.hm.com/assets/hm/0b/19/0b193f4320f30801155e33b5d6bd3b08f27d22cd.jpg?imwidth=400'},
                {'title': 'SNEAKERS', 'image': 'https://image.hm.com/assets/hm/29/e3/29e3119399abafcd5ae96470ca25d693ce7db2d6.jpg?imwidth=400'},
              ];
              final cat = cats[index];
              return GestureDetector(
                onTap: () => context.go('/marketplace'),
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
                        placeholder: (_, __) => Container(color: const Color(0xFFF5F5F7), child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1D1D1F)))),
                        errorWidget: (_, __, ___) => Container(color: const Color(0xFFF5F5F7), child: const Icon(Icons.image_outlined, color: Color(0xFF8E8E93), size: 32)),
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
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: Colors.white,
                          ),
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
                'NEARBY TAILORS',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: const Color(0xFF8E8E93),
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/tailors'),
                child: Text(
                  'SEE ALL',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: const Color(0xFF1D1D1F),
                  ),
                ),
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
                onTap: () => context.go('/tailors'),
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFF0F0F5)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: 'https://image.hm.com/assets/hm/0e/9d/0e9d5aad30cdb02146ec21cd1ac8059183935ead.jpg?imwidth=400',
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: const Color(0xFFF5F5F7), child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1D1D1F)))),
                        errorWidget: (_, __, ___) => Container(color: const Color(0xFFF5F5F7), child: const Icon(Icons.content_cut_rounded, color: Color(0xFF8E8E93), size: 32)),
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
        onTap: () => context.push('/home/invite-earn'),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1D1D1F),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INVITE FRIENDS',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Get ?200 off for every friend who joins',
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withOpacity(0.6)),
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
                  'INVITE',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: const Color(0xFF1D1D1F),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }
}
