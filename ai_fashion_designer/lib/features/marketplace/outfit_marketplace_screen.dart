import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/brand_images.dart';

class OutfitMarketplaceScreen extends StatefulWidget {
  const OutfitMarketplaceScreen({super.key});
  @override
  State<OutfitMarketplaceScreen> createState() => _OutfitMarketplaceScreenState();
}

class _OutfitMarketplaceScreenState extends State<OutfitMarketplaceScreen> {
  List<Map<String, dynamic>> _allOutfits = [];
  List<Map<String, dynamic>> _filtered = [];
  String _selectedOccasion = 'All';
  final _searchController = TextEditingController();
  bool _isLoading = true;

  static const Map<String, String> _imageMap = {
    'white oversized t-shirt': 'https://image.hm.com/assets/hm/00/8a/008af4accd1366994998b0918f9ede5120b8a405.jpg?imwidth=400',
    'black oversized t-shirt': 'https://image.hm.com/assets/hm/19/b9/19b96c80c6b674abacbb46438fab81b4b4c1779f.jpg?imwidth=400',
    'charcoal t-shirt': 'https://image.hm.com/assets/hm/35/74/3574cc023e2b552237ce7df2f1e232174ec242e3.jpg?imwidth=400',
    'navy polo': 'https://image.hm.com/assets/hm/08/d9/08d969cad35ad29dc0aa7adc9bbe26d8e39286c6.jpg?imwidth=400',
    'black polo': 'https://image.hm.com/assets/hm/28/1a/281aaa9b132d7f5f80765f6ae2566034ae05564c.jpg?imwidth=400',
    'olive t-shirt': 'https://image.hm.com/assets/hm/0b/19/0b193f4320f30801155e33b5d6bd3b08f27d22cd.jpg?imwidth=400',
    'brown polo': 'https://image.hm.com/assets/hm/3b/3f/3b3fba73af98beffd461adff2a75762163cce8a8.jpg?imwidth=400',
    'grey sweatshirt': 'https://image.hm.com/assets/hm/52/c8/52c89a5466e598717b291cffd3c53cdb55292cd9.jpg?imwidth=400',
    'denim shirt': 'https://image.hm.com/assets/hm/01/31/0131c7474f01444248341928cf29cb54a03e9c28.jpg?imwidth=400',
    'white shirt': 'https://image.hm.com/assets/hm/11/37/1137ebe8505ee3b148d0aed7d24fbf87d3744868.jpg?imwidth=400',
    'blue shirt': 'https://image.hm.com/assets/hm/21/8a/218a56d244a764b627ebdc5b828264a93400ae12.jpg?imwidth=400',
    'white t-shirt': 'https://image.hm.com/assets/hm/00/8a/008af4accd1366994998b0918f9ede5120b8a405.jpg?imwidth=400',
    'black t-shirt': 'https://image.hm.com/assets/hm/19/b9/19b96c80c6b674abacbb46438fab81b4b4c1779f.jpg?imwidth=400',
    'black hoodie': 'https://image.hm.com/assets/hm/01/fd/01fd86bce62ec488046edcd51bb8528f86bf52a1.jpg?imwidth=400',
    'white hoodie': 'https://image.hm.com/assets/hm/0e/9d/0e9d5aad30cdb02146ec21cd1ac8059183935ead.jpg?imwidth=400',
  };

  @override
  void initState() {
    super.initState();
    _loadOutfits();
  }

  Future<void> _loadOutfits() async {
    setState(() => _isLoading = true);
    try {
      final jsonStr = await rootBundle.loadString('assets/data/outfits.json');
      final List<dynamic> data = json.decode(jsonStr);
      _allOutfits = data.cast<Map<String, dynamic>>();
      _filtered = List.from(_allOutfits);
    } catch (e) {
      _allOutfits = _getDefaultOutfits();
      _filtered = List.from(_allOutfits);
    }
    setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> _getDefaultOutfits() {
    return [
      {'name': 'Street Casual', 'style': 'streetwear', 'occasion': 'college', 'season': 'summer', 'top': 'white oversized t-shirt', 'bottom': 'ripped jeans', 'shoes': 'sneakers', 'description': 'Relaxed street style', 'estimatedPrice': 2499},
      {'name': 'Office Ready', 'style': 'smart casual', 'occasion': 'office', 'season': 'all season', 'top': 'white shirt', 'bottom': 'formal trousers', 'shoes': 'loafers', 'description': 'Professional look', 'estimatedPrice': 3999},
      {'name': 'Night Out', 'style': 'modern', 'occasion': 'party', 'season': 'all season', 'top': 'black polo', 'bottom': 'dark jeans', 'shoes': 'formal shoes', 'description': 'Sleek evening look', 'estimatedPrice': 4499},
      {'name': 'Weekend Vibes', 'style': 'casual', 'occasion': 'relax', 'season': 'summer', 'top': 'grey t-shirt', 'bottom': 'joggers', 'shoes': 'sliders', 'description': 'Easy weekend outfit', 'estimatedPrice': 1999},
      {'name': 'Travel Explorer', 'style': 'casual', 'occasion': 'travel', 'season': 'all season', 'top': 'olive t-shirt', 'bottom': 'cargo pants', 'shoes': 'trekking shoes', 'description': 'Travel-ready outfit', 'estimatedPrice': 3299},
      {'name': 'Classic Elegance', 'style': 'classic', 'occasion': 'office', 'season': 'winter', 'top': 'navy polo', 'bottom': 'chinos', 'shoes': 'oxford shoes', 'description': 'Timeless classic look', 'estimatedPrice': 5499},
    ];
  }

  void _filterOutfits() {
    setState(() {
      _filtered = _allOutfits.where((outfit) {
        final matchOccasion = _selectedOccasion == 'All' || (outfit['occasion'] ?? '').toString().toLowerCase() == _selectedOccasion.toLowerCase();
        final matchSearch = _searchController.text.isEmpty ||
            (outfit['name'] ?? '').toString().toLowerCase().contains(_searchController.text.toLowerCase());
        return matchOccasion && matchSearch;
      }).toList();
    });
  }

  String _getImageUrl(Map<String, dynamic> outfit) {
    final top = (outfit['top'] ?? '').toString();
    final bottom = (outfit['bottom'] ?? '').toString();
    if (_imageMap.containsKey(top.toLowerCase())) return _imageMap[top.toLowerCase()]!;
    final index = _allOutfits.indexOf(outfit);
    return BrandImages.shirtsList[index % BrandImages.shirtsList.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasParchment,
      appBar: AppBar(
        backgroundColor: AppColors.charcoal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text('Outfit Marketplace', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _filterOutfits(),
              style: GoogleFonts.inter(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search outfits...',
                hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.inkMuted48),
                prefixIcon: Icon(Icons.search_rounded, size: 20, color: AppColors.inkMuted48),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _filterChip('All'),
                const SizedBox(width: 8),
                _filterChip('College'),
                const SizedBox(width: 8),
                _filterChip('Office'),
                const SizedBox(width: 8),
                _filterChip('Party'),
                const SizedBox(width: 8),
                _filterChip('Travel'),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.accentPurple))
                : _filtered.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.checkroom_outlined, size: 64, color: AppColors.inkMuted48), const SizedBox(height: 16), Text('No outfits found', style: GoogleFonts.inter(fontSize: 16, color: AppColors.inkMuted48))]))
                    : RefreshIndicator(
                        onRefresh: _loadOutfits,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.55),
                          itemCount: _filtered.length,
                          itemBuilder: (ctx, i) => _buildOutfitCard(_filtered[i], i),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    final isSelected = _selectedOccasion == label;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedOccasion = label);
        _filterOutfits();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentPurple : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.ink)),
      ),
    );
  }

  Widget _buildOutfitCard(Map<String, dynamic> outfit, int index) {
    final imageUrl = _getImageUrl(outfit);
    final price = outfit['estimatedPrice'] ?? 0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppColors.canvasParchment, child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentPurple))),
                  errorWidget: (_, __, ___) => Container(color: AppColors.canvasParchment, child: const Icon(Icons.checkroom_rounded, color: AppColors.inkMuted48, size: 32)),
                ),
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
                    child: Text(outfit['occasion'] ?? '', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(outfit['name'] ?? '', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(outfit['description'] ?? '', style: GoogleFonts.inter(fontSize: 10, color: AppColors.inkMuted48), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text('\u20B9$price', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.accentPurple)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index));
  }
}
