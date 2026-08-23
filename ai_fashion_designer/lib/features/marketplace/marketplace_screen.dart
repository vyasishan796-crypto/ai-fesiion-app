import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/models/product.dart';
import '../../core/data/outfit_data.dart';
import '../../core/services/cart_service.dart';
import '../../core/services/wishlist_service.dart';
import '../../features/ai_studio/ai_design_studio_screen.dart';
import '../../features/shoes_outfit/screens/shoes_outfit_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  final String initialSearch;
  const MarketplaceScreen({super.key, this.initialSearch = ''});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  int _selectedGender = 0;
  String _selectedCategory = 'All';
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'popular';
  bool _showFilters = false;

  final List<String> _genders = ['All', 'Men', 'Women'];
  final List<String> _categories = [
    'All', 'T-Shirts', 'Shirts', 'Jackets', 'Jeans', 'Sneakers',
    'Formals', 'Tops', 'Dresses', 'Kurtis', 'Bags', 'Heels', 'Accessories',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialSearch.isNotEmpty) {
      _searchController.text = widget.initialSearch;
    }
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    List<Product> products = List.from(OutfitData.allProducts);

    if (_selectedGender == 1) {
      products = products.where((p) => p.gender == 'men').toList();
    } else if (_selectedGender == 2) {
      products = products.where((p) => p.gender == 'women').toList();
    }

    if (_selectedCategory != 'All') {
      products = products.where((p) => p.category == _selectedCategory).toList();
    }

    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      products = products.where((p) =>
        p.name.toLowerCase().contains(query) ||
        p.brand.toLowerCase().contains(query) ||
        p.category.toLowerCase().contains(query) ||
        p.description.toLowerCase().contains(query)
      ).toList();
    }

    switch (_sortBy) {
      case 'price_low':
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'discount':
        products.sort((a, b) => b.discount.compareTo(a.discount));
        break;
      case 'rating':
        products.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        products.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    }

    setState(() => _filteredProducts = products);
  }

  @override
  Widget build(BuildContext context) {
    final featured = _filteredProducts.length >= 4
        ? _filteredProducts.sublist(0, 4)
        : _filteredProducts;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 0,
            backgroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: Colors.white,
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'STYLE.AI',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 3,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded, size: 24),
                color: Colors.white,
                onPressed: () => _showSearchSheet(context),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined, size: 24),
                    color: Colors.white,
                    onPressed: () => context.push('/cart'),
                  ),
                  if (CartService().totalItems > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.accentPurple,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${CartService().totalItems}',
                          style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          SliverToBoxAdapter(child: _buildHeroBanner()),
          SliverToBoxAdapter(child: _buildGenderTabs()),
          SliverToBoxAdapter(child: _buildCategoryChips()),
          if (_showFilters) SliverToBoxAdapter(child: _buildSortBar()),
          if (featured.isNotEmpty) ...[
            SliverToBoxAdapter(child: _buildSectionHeader('Featured')),
            SliverToBoxAdapter(child: _buildFeaturedRow(featured)),
          ],
          SliverToBoxAdapter(child: _buildSectionHeader('Shop All')),
          _buildProductSliverGrid(),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    final heroProduct = _filteredProducts.isNotEmpty ? _filteredProducts.first : null;
    if (heroProduct == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: heroProduct)),
        );
      },
      child: Container(
        height: 340,
        width: double.infinity,
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: heroProduct.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: Colors.grey[900]),
              errorWidget: (_, __, ___) => Container(color: Colors.grey[900]),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.85),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 24,
              bottom: 28,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentPurple,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'NEW DROP',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    heroProduct.brand.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    heroProduct.name,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '₹${heroProduct.price.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      if (heroProduct.originalPrice > heroProduct.price) ...[
                        const SizedBox(width: 8),
                        Text(
                          '₹${heroProduct.originalPrice.toStringAsFixed(0)}',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: Colors.white54,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${heroProduct.discount}% OFF',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
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
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildGenderTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: List.generate(_genders.length, (i) {
          final isSelected = _selectedGender == i;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedGender = i;
                  _loadData();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey[300]!,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _genders[i],
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.ink,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == _categories[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = _categories[index];
                _loadData();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  _categories[index],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.inkMuted48,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortBar() {
    final sorts = [
      {'key': 'popular', 'label': 'Popular'},
      {'key': 'price_low', 'label': 'Price Low'},
      {'key': 'price_high', 'label': 'Price High'},
      {'key': 'discount', 'label': 'Discount'},
      {'key': 'rating', 'label': 'Rating'},
    ];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        children: [
          const Icon(Icons.sort_rounded, size: 18, color: AppColors.inkMuted48),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: sorts.map((s) {
                  final isSelected = _sortBy == s['key'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _sortBy = s['key']!;
                          _loadData();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black : Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          s['label']!,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.inkMuted48,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              letterSpacing: 1.5,
            ),
          ),
          Text(
            '${_filteredProducts.length} items',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.inkMuted48,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedRow(List<Product> products) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
              );
            },
            child: Container(
              width: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 150,
                        width: 160,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: CachedNetworkImage(
                          imageUrl: product.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: Colors.grey[100]),
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.grey[100],
                            child: const Icon(Icons.image_outlined, color: AppColors.inkMuted48, size: 28),
                          ),
                        ),
                      ),
                      if (product.discount > 0)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(4),
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
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Text(
                      product.brand.toUpperCase(),
                      style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.inkMuted48, letterSpacing: 1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
                    child: Text(
                      product.name,
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
                    child: Text(
                      '₹${product.price.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 350.ms, delay: Duration(milliseconds: 80 * index)).slideX(begin: 0.05),
          );
        },
      ),
    );
  }

  Widget _buildProductSliverGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: _filteredProducts.isEmpty
          ? SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    Icon(Icons.search_off_rounded, size: 56, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text(
                      'No products found',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.inkMuted48),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Try a different search or category',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.inkMuted48),
                    ),
                  ],
                ),
              ),
            )
          : SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.58,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _NikeProductCard(product: _filteredProducts[index]),
                childCount: _filteredProducts.length,
              ),
            ),
    );
  }

  void _showSearchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (_) => _loadData(),
                style: GoogleFonts.inter(fontSize: 16, color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: GoogleFonts.inter(fontSize: 15, color: AppColors.inkMuted48),
                  prefixIcon: const Icon(Icons.search_rounded, size: 22, color: AppColors.inkMuted48),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.black, width: 1.5),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NikeProductCard extends StatelessWidget {
  final Product product;
  const _NikeProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.grey[100]),
                    errorWidget: (_, __, ___) => Container(
                      color: Colors.grey[100],
                      child: const Icon(Icons.image_outlined, color: AppColors.inkMuted48, size: 32),
                    ),
                  ),
                ),
                if (product.discount > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-${product.discount}%',
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                if (product.isNewArrival)
                  Positioned(
                    top: 8,
                    right: 44,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accentPurple,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'NEW',
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () async {
                      final wishlist = WishlistService();
                      await wishlist.toggleWishlist(product.id);
                      (context as Element).markNeedsBuild();
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)],
                      ),
                      child: Icon(
                        WishlistService().isWishlisted(product.id)
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 16,
                        color: WishlistService().isWishlisted(product.id) ? Colors.red : AppColors.inkMuted48,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      final isShoes = product.category == 'Sneakers' || product.category == 'Footwear';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => isShoes ? ShoesOutfitScreen(initialShoes: product) : AIDesignStudioScreen(initialProduct: product),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.accentPurple,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: AppColors.accentPurple.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.checkroom_outlined, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'Try On',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 10, color: Colors.white),
                              const SizedBox(width: 2),
                              Text(
                                '${product.rating}',
                                style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${product.reviewCount})',
                          style: GoogleFonts.inter(fontSize: 9, color: AppColors.inkMuted48),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '₹${product.price.toStringAsFixed(0)}',
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.black),
                        ),
                        if (product.originalPrice > product.price) ...[
                          const SizedBox(width: 4),
                          Text(
                            '₹${product.originalPrice.toStringAsFixed(0)}',
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
            ),
          ],
        ),
      ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.03),
    );
  }
}

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 400,
            backgroundColor: Colors.black,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, size: 22),
                color: Colors.white,
                onPressed: () {
                  Share.share(
                    'Check out ${product.name} by ${product.brand} at Rs.${product.price.toStringAsFixed(0)}!\n\n'
                    '${product.description}\n\n'
                    'Found on StyleAI - Your AI Fashion Stylist',
                    subject: product.name,
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: product.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.grey[900]),
                errorWidget: (_, __, ___) => Container(color: Colors.grey[900]),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkMuted48,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.name,
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              '${product.rating}',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${product.reviewCount} reviews)',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.inkMuted48),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        '₹${product.price.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.black),
                      ),
                      if (product.originalPrice > product.price) ...[
                        const SizedBox(width: 10),
                        Text(
                          '₹${product.originalPrice.toStringAsFixed(0)}',
                          style: GoogleFonts.inter(fontSize: 16, color: AppColors.inkMuted48, decoration: TextDecoration.lineThrough),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${product.discount}% OFF',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.success),
                        ),
                      ],
                    ],
                  ),
                  if (product.deliveryInfo.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_shipping_outlined, size: 18, color: AppColors.inkMuted48),
                          const SizedBox(width: 10),
                          Text(
                            product.deliveryInfo,
                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.inkMuted48),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (product.platformPrices.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PRICE COMPARISON',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                            letterSpacing: 1,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PriceComparisonScreen(product: product),
                            ),
                          ),
                          child: Text(
                            'View All',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildPriceComparisonBar(product),
                  ],
                  if (product.sizes.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'SELECT SIZE',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: product.sizes.map((size) {
                        return Container(
                          width: 52,
                          height: 44,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              size,
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  if (product.description.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'DESCRIPTION',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      product.description,
                      style: GoogleFonts.inter(fontSize: 14, color: AppColors.inkMuted48, height: 1.6),
                    ),
                  ],
                  if (product.tags.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: product.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tag,
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.inkMuted48),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2)),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                CartService().addItem(product, size: product.sizes.isNotEmpty ? product.sizes.first : '');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} added to cart', style: GoogleFonts.inter()),
                    backgroundColor: Colors.black,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Icon(Icons.shopping_bag_outlined, size: 22, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  CartService().addItem(product, size: product.sizes.isNotEmpty ? product.sizes.first : '');
                  context.push('/cart');
                },
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      'Buy Now — ₹${product.price.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceComparisonBar(Product product) {
    final sorted = [...product.platformPrices]..sort((a, b) => a.price.compareTo(b.price));

    if (sorted.isEmpty) return const SizedBox.shrink();

    final cheapest = sorted.first;
    final mostExpensive = sorted.last;
    final savings = mostExpensive.price - cheapest.price;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Best: ₹${cheapest.price.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black),
                  ),
                  if (savings > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Save ₹$savings',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sorted.map((priceData) {
                  final isCheapest = priceData.price == cheapest.price;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCheapest ? Colors.black : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCheapest)
                          const Icon(Icons.star_rounded, size: 12, color: Colors.white),
                        if (isCheapest) const SizedBox(width: 4),
                        Text(
                          '${priceData.platform} ₹${priceData.price}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: isCheapest ? FontWeight.w700 : FontWeight.w500,
                            color: isCheapest ? Colors.white : AppColors.inkMuted48,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PriceComparisonScreen extends StatefulWidget {
  final Product product;
  const PriceComparisonScreen({super.key, required this.product});

  @override
  State<PriceComparisonScreen> createState() => _PriceComparisonScreenState();
}

class _PriceComparisonScreenState extends State<PriceComparisonScreen> {
  @override
  Widget build(BuildContext context) {
    final prices = [...widget.product.platformPrices]..sort((a, b) => a.price.compareTo(b.price));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'PRICE COMPARISON',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: prices.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 32, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'No price data available',
                      style: GoogleFonts.inter(fontSize: 16, color: AppColors.inkMuted48),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: prices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final priceData = prices[index];
                  final isCheapest = index == 0;

                  return Container(
                    decoration: BoxDecoration(
                      color: isCheapest ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isCheapest ? Colors.black : Colors.grey[200]!,
                        width: isCheapest ? 2 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                priceData.platform,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isCheapest ? Colors.white : Colors.black,
                                ),
                              ),
                              if (isCheapest)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentPurple,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'BEST PRICE',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '₹${priceData.price.toStringAsFixed(0)}',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: isCheapest ? Colors.white : Colors.black,
                            ),
                          ),
                          if (priceData.rating != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Row(
                                children: [
                                  Icon(Icons.star_rounded, size: 16, color: isCheapest ? Colors.amber : Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${priceData.rating}',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isCheapest ? Colors.white70 : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${priceData.reviewCount})',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: isCheapest ? Colors.white54 : AppColors.inkMuted48,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (priceData.deliveryDate != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Icon(Icons.local_shipping_outlined, size: 16, color: isCheapest ? Colors.white54 : AppColors.inkMuted),
                                  const SizedBox(width: 6),
                                  Text(
                                    priceData.deliveryDate!,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: isCheapest ? Colors.white54 : AppColors.inkMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: priceData.productUrl != null
                                  ? () async {
                                      final url = Uri.parse(priceData.productUrl!);
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url, mode: LaunchMode.externalApplication);
                                      } else {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Could not open ${priceData.platform}'),
                                              backgroundColor: AppColors.error,
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  : null,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isCheapest ? Colors.white : Colors.black,
                                side: BorderSide(
                                  color: isCheapest ? Colors.white : Colors.black,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text(
                                'View on ${priceData.platform}',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 350.ms, delay: Duration(milliseconds: 100 * index)).slideX(begin: 0.03);
                },
              ),
      ),
    );
  }
}
