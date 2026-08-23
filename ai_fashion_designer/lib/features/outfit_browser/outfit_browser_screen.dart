import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/models/outfit_dataset.dart';
import '../../core/models/saved_outfit.dart';
import '../../core/services/outfit_data_service.dart';
import '../../core/services/outfit_matcher_service.dart';
import '../../core/services/ai_service.dart';
import '../../core/services/saved_outfit_service.dart';
import '../../core/services/platform_price_service.dart';
import '../../features/body_measurement/services/body_measurement_service.dart';
import '../../core/models/style_analysis.dart';
import 'widgets/outfit_card.dart';

class OutfitBrowserScreen extends StatefulWidget {
  const OutfitBrowserScreen({super.key});

  @override
  State<OutfitBrowserScreen> createState() => _OutfitBrowserScreenState();
}

class _OutfitBrowserScreenState extends State<OutfitBrowserScreen>
    with TickerProviderStateMixin {
  final OutfitDataService _dataService = OutfitDataService();
  final OutfitMatcherService _matcherService = OutfitMatcherService();
  final AiService _aiService = AiService();
  final SavedOutfitService _savedService = SavedOutfitService();
  final PlatformPriceService _priceService = PlatformPriceService();
  final BodyMeasurementService _measurementService = BodyMeasurementService();

  late TabController _tabController;

  // Filter state
  String _selectedOccasion = '';
  String _selectedStyle = '';
  String _selectedSeason = '';
  String _selectedSkinTone = '';
  String _searchQuery = '';

  // Data state
  List<OutfitDataset> _allOutfits = [];
  List<OutfitDataset> _filteredOutfits = [];
  List<Map<String, dynamic>> _personalizedOutfits = [];
  bool _isLoading = true;
  bool _isPersonalizedLoading = false;

  // AI image generation state
  bool _isGenerating = false;
  String? _generatedImageUrl;
  String? _generatedPrompt;
  OutfitDataset? _selectedOutfit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 &&
          _personalizedOutfits.isEmpty &&
          !_isPersonalizedLoading) {
        _loadPersonalizedOutfits();
      }
    });
    _loadData();
    _savedService.loadSavedOutfits();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _dataService.loadOutfits();
    setState(() {
      _allOutfits = _dataService.allOutfits;
      _filteredOutfits = _applyFilters(_allOutfits);
      _isLoading = false;
    });
  }

  Future<void> _loadPersonalizedOutfits() async {
    setState(() => _isPersonalizedLoading = true);

    try {
      final analysis = await _buildStyleAnalysis();
      if (analysis != null) {
        final matches = await _matcherService.matchOutfits(analysis, limit: 20);
        setState(() => _personalizedOutfits = matches);
      } else {
        // Fallback to top-scored outfits
        final topOutfits = _allOutfits
            .where((o) => (o.score ?? 0) >= 80)
            .take(20)
            .toList();
        setState(() => _personalizedOutfits =
            topOutfits.map((o) => {...o.toJson(), '_matchScore': 80.0}).toList());
      }
    } catch (e) {
      debugPrint('Personalization error: $e');
    } finally {
      if (mounted) {
        setState(() => _isPersonalizedLoading = false);
      }
    }
  }

  Future<StyleAnalysis?> _buildStyleAnalysis() async {
    final loaded = await _measurementService.load();

    if (!loaded || _measurementService.currentProfile == null) {
      final prefs = await SharedPreferences.getInstance();
      final preferredStyle = prefs.getString('preferred_style') ?? 'Minimal';
      final preferredOccasion = prefs.getString('preferred_occasion') ?? 'Casual';

      return StyleAnalysis(
        overallStyle: preferredStyle,
        styleScore: 8.5,
        clothing: ['t-shirt', 'jeans'],
        palette: [
          DetectedColor(name: 'Navy', color: const Color(0xFF1A365D), percentage: 30),
          DetectedColor(name: 'White', color: Colors.white, percentage: 25),
        ],
        fabric: 'cotton',
        occasions: [preferredOccasion],
        recommendations: [],
      );
    }

    final profile = _measurementService.currentProfile!;
    return StyleAnalysis(
      overallStyle: 'Smart Casual',
      styleScore: 8.2,
      clothing: ['t-shirt', 'jeans'],
      palette: [
        DetectedColor(name: 'Navy', color: const Color(0xFF1A365D), percentage: 25),
        DetectedColor(name: 'White', color: Colors.white, percentage: 30),
      ],
      fabric: 'cotton',
      occasions: ['Office', 'Casual'],
      recommendations: [],
    );
  }

  List<OutfitDataset> _applyFilters(List<OutfitDataset> source) {
    return source.where((outfit) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return (outfit.top?.toLowerCase().contains(query) ?? false) ||
            (outfit.bottom?.toLowerCase().contains(query) ?? false) ||
            (outfit.shoes?.toLowerCase().contains(query) ?? false) ||
            (outfit.layer?.toLowerCase().contains(query) ?? false) ||
            (outfit.accessory?.toLowerCase().contains(query) ?? false);
      }

      // Occasion filter
      if (_selectedOccasion.isNotEmpty && outfit.occasion != _selectedOccasion) {
        return false;
      }

      // Style filter
      if (_selectedStyle.isNotEmpty && outfit.style != _selectedStyle) {
        return false;
      }

      // Season filter
      if (_selectedSeason.isNotEmpty && outfit.season != _selectedSeason) {
        return false;
      }

      // Skin tone filter
      if (_selectedSkinTone.isNotEmpty && outfit.skinTone != _selectedSkinTone) {
        return false;
      }

      return true;
    }).toList();
  }

  void _applyFiltersAndRefresh() {
    setState(() {
      _filteredOutfits = _applyFilters(_allOutfits);
    });
  }

  void _setOccasion(String occasion) {
    setState(() {
      _selectedOccasion = _selectedOccasion == occasion ? '' : occasion;
      _applyFiltersAndRefresh();
    });
  }

  void _setStyle(String style) {
    setState(() {
      _selectedStyle = _selectedStyle == style ? '' : style;
      _applyFiltersAndRefresh();
    });
  }

  void _setSeason(String season) {
    setState(() {
      _selectedSeason = _selectedSeason == season ? '' : season;
      _applyFiltersAndRefresh();
    });
  }

  void _setSkinTone(String skinTone) {
    setState(() {
      _selectedSkinTone = _selectedSkinTone == skinTone ? '' : skinTone;
      _applyFiltersAndRefresh();
    });
  }

  void _setSearch(String query) {
    setState(() {
      _searchQuery = query;
      _applyFiltersAndRefresh();
    });
  }

  void _clearAllFilters() {
    setState(() {
      _selectedOccasion = '';
      _selectedStyle = '';
      _selectedSeason = '';
      _selectedSkinTone = '';
      _searchQuery = '';
      _applyFiltersAndRefresh();
    });
  }

  Future<void> _generateImage(OutfitDataset outfit) async {
    setState(() {
      _isGenerating = true;
      _selectedOutfit = outfit;
      _generatedImageUrl = null;
      _generatedPrompt = outfit.toAiPrompt();
    });

    try {
      final imageUrl = await _aiService.generateFromPrompt(outfit.toAiPrompt());
      setState(() {
        _generatedImageUrl = imageUrl;
      });
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
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  void _toggleSave(OutfitDataset outfit) async {
    await _savedService.toggleSave(outfit, aiImageUrl: _generatedImageUrl);
    setState(() {});
  }

  void _shareOutfit(OutfitDataset outfit) {
    final prompt = outfit.toAiPrompt();
    Share.share(
      'Check out this outfit from StyleAI!\n\n$prompt\n\nGenerated with AI fashion technology.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBrowseTab(),
                  _buildPersonalizedTab(),
                  _buildSavedTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isGenerating
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showFilterSheet(),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.filter_list),
              label: Text(
                'Filter',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Text(
            'Outfit Browser',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const Spacer(),
          if (_searchQuery.isEmpty)
            Text(
              '${_filteredOutfits.length} outfits',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.inkMuted48,
              ),
            ),
          if (_searchQuery.isNotEmpty)
            Text(
              '${_filteredOutfits.length} found',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.inkMuted48,
        labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        indicatorColor: AppColors.primary,
        indicatorWeight: 2.5,
        tabs: const [
          Tab(text: 'Browse'),
          Tab(text: 'For You'),
          Tab(text: 'Saved'),
        ],
      ),
    );
  }

  Widget _buildBrowseTab() {
    return Column(
      children: [
        _buildSearchBar(),
        _buildFilterChips(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _filteredOutfits.isEmpty
                  ? _buildEmptyState()
                  : _buildOutfitList(_filteredOutfits),
        ),
      ],
    );
  }

  Widget _buildPersonalizedTab() {
    if (_isPersonalizedLoading || _personalizedOutfits.isEmpty) {
      return _buildPersonalizedLoading();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _personalizedOutfits.length,
      itemBuilder: (context, index) {
        final outfit = _personalizedOutfits[index];
        final matchScore = (outfit['_matchScore'] as double?)?.toInt() ?? 80;
        return _buildPersonalizedOutfitCard(outfit, matchScore, index);
      },
    );
  }

  Widget _buildSavedTab() {
    return ValueListenableBuilder(
      valueListenable: _savedService.savedOutfitsNotifier,
      builder: (context, savedOutfits, _) {
        if (savedOutfits.isEmpty) {
          return _buildEmptySavedState();
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: savedOutfits.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final saved = savedOutfits[index];
            return OutfitCard(
              outfit: saved.outfit,
              isSaved: true,
              onGenerateImage: () => _generateImage(saved.outfit),
              onToggleSave: () => _toggleSave(saved.outfit),
              onShare: () => _shareOutfit(saved.outfit),
              savedImageUrl: saved.aiGeneratedImageUrl,
            ).animate().fadeIn(delay: Duration(milliseconds: 50 * (index % 20)));
          },
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.pill,
          border: Border.all(color: AppColors.hairline),
        ),
        child: TextField(
          onChanged: _setSearch,
          decoration: InputDecoration(
            hintText: 'Search outfits...',
            hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.inkMuted48),
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: AppColors.inkMuted48),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18, color: AppColors.inkMuted48),
                    onPressed: () => _setSearch(''),
                  )
                : null,
          ),
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.ink),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (_selectedOccasion.isNotEmpty ||
              _selectedStyle.isNotEmpty ||
              _selectedSeason.isNotEmpty ||
              _selectedSkinTone.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: _clearAllFilters,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: AppRadius.pill,
                  ),
                  child: Text(
                    'Clear All',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ..._buildFilterChip('Occasion', _selectedOccasion, _dataService.occasions, _setOccasion),
          ..._buildFilterChip('Style', _selectedStyle, _dataService.styles, _setStyle),
        ],
      ),
    );
  }

  List<Widget> _buildFilterChip(
    String label,
    String selected,
    List<String> options,
    Function(String) onSelect,
  ) {
    return options.asMap().entries.expand((entry) {
      final index = entry.key;
      final option = entry.value;
      final isSelected = selected == option;
      return [
        GestureDetector(
          onTap: () => onSelect(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.only(
              right: 8,
              left: index == 0 ? (label == 'Occasion' ? 0 : 0) : 0,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.white,
              borderRadius: AppRadius.pill,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.hairline,
              ),
            ),
            child: Text(
              option,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.ink,
              ),
            ),
          ),
        ),
      ];
    }).toList();
  }

  Widget _buildSeasonSkinToneFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterRow('Season', _dataService.seasons, _selectedSeason, _setSeason),
        const SizedBox(height: 8),
        _buildFilterRow('Skin Tone', _dataService.skinTones, _selectedSkinTone, _setSkinTone),
      ],
    );
  }

  Widget _buildFilterRow(
    String label,
    List<String> options,
    String selected,
    Function(String) onSelect,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.inkMuted48,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected == option;
            return GestureDetector(
              onTap: () => onSelect(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.white,
                  borderRadius: AppRadius.pill,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.hairline,
                  ),
                ),
                child: Text(
                  option,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.ink,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOutfitList(List<OutfitDataset> outfits) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: outfits.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final outfit = outfits[index];
        final isSaved = _savedService.isSaved(outfit.id);
        return OutfitCard(
          outfit: outfit,
          isSaved: isSaved,
          onGenerateImage: () => _generateImage(outfit),
          onToggleSave: () => _toggleSave(outfit),
          onShare: () => _shareOutfit(outfit),
          savedImageUrl: isSaved
              ? _savedService.savedOutfitsNotifier.value
                  .firstWhere((s) => s.outfit.id == outfit.id, orElse: () => SavedOutfit(
                    id: '',
                    outfit: outfit,
                    savedAt: DateTime.now(),
                  ))
                  .aiGeneratedImageUrl
              : null,
        ).animate().fadeIn(delay: Duration(milliseconds: 50 * (index % 20))).slideY(begin: 0.03);
      },
    );
  }

  Widget _buildPersonalizedOutfitCard(Map<String, dynamic> outfitMap, int matchScore, int index) {
    final outfit = OutfitDataset.fromJson(outfitMap);
    final isSaved = _savedService.isSaved(outfit.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: AppRadius.md.topLeft,
                topRight: AppRadius.md.topRight,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, size: 14, color: AppColors.success),
                const SizedBox(width: 4),
                Text(
                  '$matchScore% Match',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutfitCard(
              outfit: outfit,
              isSaved: isSaved,
              onGenerateImage: () => _generateImage(outfit),
              onToggleSave: () => _toggleSave(outfit),
              onShare: () => _shareOutfit(outfit),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * (index % 20))).slideY(begin: 0.03);
  }

  Widget _buildPersonalizedLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Finding your perfect outfits...',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.inkMuted48,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Analyzing your body type + style preferences',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.inkMuted48,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: AppColors.inkMuted48.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'No outfits found',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.inkMuted48,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.inkMuted48,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySavedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_outline,
            size: 48,
            color: AppColors.inkMuted48.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'No saved outfits',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.inkMuted48,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the bookmark icon to save outfits here',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.inkMuted48,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter Outfits',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildFilterRow('Season', _dataService.seasons, _selectedSeason, (value) {
                      setModalState(() => _setSeason(value));
                    }),
                    const SizedBox(height: 16),
                    _buildFilterRow('Skin Tone', _dataService.skinTones, _selectedSkinTone, (value) {
                      setModalState(() => _setSkinTone(value));
                    }),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Apply Filters',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
