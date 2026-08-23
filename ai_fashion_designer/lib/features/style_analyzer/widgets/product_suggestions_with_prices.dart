import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/data/outfit_data.dart';
import '../../../core/models/product.dart';
import '../../../core/models/style_analysis.dart';

class ProductSuggestionsWithPrices extends StatelessWidget {
  final StyleAnalysis analysis;

  const ProductSuggestionsWithPrices({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final matchedProducts = _matchProducts();

    if (matchedProducts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF7C4DFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: Color(0xFF7C4DFF),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shop This Look',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1D1D1F),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Best prices across platforms for your style',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF7C4DFF).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${matchedProducts.length} matches',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF7C4DFF),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 230,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: min(matchedProducts.length, 5),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final match = matchedProducts[index];
              return _ProductCard(
                product: match.product,
                matchScore: match.score,
                matchedItem: match.matchedItem,
              );
            },
          ),
        ),
      ],
    );
  }

  List<_ProductMatch> _matchProducts() {
    final products = OutfitData.allProducts;
    final List<_ProductMatch> matches = [];

    for (final detectedItem in analysis.clothing) {
      final lowerDetected = detectedItem.toLowerCase();

      for (final product in products) {
        final score = _calculateMatchScore(lowerDetected, product);
        if (score >= 40) {
          matches.add(_ProductMatch(
            product: product,
            score: score,
            matchedItem: detectedItem,
          ));
        }
      }
    }

    matches.sort((a, b) => b.score.compareTo(a.score));
    final uniqueProducts = <String>{};
    final uniqueMatches = <_ProductMatch>[];
    for (final match in matches) {
      if (!uniqueProducts.contains(match.product.id)) {
        uniqueProducts.add(match.product.id);
        uniqueMatches.add(match);
      }
    }

    return uniqueMatches;
  }

  int _calculateMatchScore(String detected, Product product) {
    int score = 0;
    final lowerDetected = detected.toLowerCase();
    final lowerCategory = product.category.toLowerCase();
    final lowerColor = product.color.toLowerCase();
    final lowerStyle = product.style.toLowerCase();
    final lowerName = product.name.toLowerCase();

    final categoryKeywords = {
      'shirt': ['t-shirt', 'tshirt', 'shirt', 'tee', 'top'],
      't-shirt': ['t-shirt', 'tshirt', 'tee', 'top', 'shirt'],
      'tee': ['t-shirt', 'tshirt', 'tee', 'top', 'shirt'],
      'jeans': ['jeans', 'trouser', 'pants', 'bottom', 'denim'],
      'trouser': ['jeans', 'trouser', 'pants', 'bottom'],
      'pants': ['jeans', 'trouser', 'pants', 'bottom'],
      'sneakers': ['sneakers', 'shoes', 'trainers', 'footwear'],
      'shoes': ['sneakers', 'shoes', 'trainers', 'boots', 'footwear'],
      'jacket': ['jacket', 'blazer', 'coat', 'outerwear'],
      'hoodie': ['hoodie', 'sweatshirt', 'pullover'],
      'dress': ['dress', 'gown', 'frock'],
      'kurta': ['kurta', 'kurti', 'ethnic'],
    };

    bool categoryMatch = false;
    for (final entry in categoryKeywords.entries) {
      if (lowerDetected.contains(entry.key)) {
        for (final keyword in entry.value) {
          if (lowerCategory.contains(keyword) ||
              lowerName.contains(keyword)) {
            categoryMatch = true;
            break;
          }
        }
      }
      if (categoryMatch) break;
    }

    if (categoryMatch) {
      score += 40;
    } else {
      for (final word in lowerDetected.split(' ')) {
        if (word.length > 3 &&
            (lowerCategory.contains(word) || lowerName.contains(word))) {
          score += 20;
          break;
        }
      }
    }

    final colorKeywords = ['black', 'white', 'blue', 'red', 'green', 'navy',
      'grey', 'gray', 'brown', 'pink', 'yellow', 'olive', 'beige', 'cream',
      'charcoal', 'maroon', 'purple', 'orange', 'teal'];

    bool colorMatch = false;
    for (final color in colorKeywords) {
      if (lowerDetected.contains(color) && lowerColor.contains(color)) {
        colorMatch = true;
        break;
      }
    }

    if (colorMatch) {
      score += 30;
    } else {
      for (final color in colorKeywords) {
        if (lowerDetected.contains(color) || lowerColor.contains(color)) {
          score += 10;
          break;
        }
      }
    }

    final styleKeywords = {
      'casual': ['casual', 'relaxed', 'everyday'],
      'formal': ['formal', 'professional', 'office', 'business'],
      'streetwear': ['streetwear', 'urban', 'street'],
      'ethnic': ['ethnic', 'traditional', 'indian'],
      'sporty': ['sporty', 'athletic', 'gym', 'activewear'],
    };

    for (final entry in styleKeywords.entries) {
      final detectedHasStyle = entry.value.any((k) => lowerDetected.contains(k));
      final productHasStyle = entry.value.any((k) =>
          lowerStyle.contains(k) || lowerName.contains(k));
      if (detectedHasStyle && productHasStyle) {
        score += 20;
        break;
      }
    }

    if (product.rating >= 4.5) {
      score += 10;
    } else if (product.rating >= 4.0) {
      score += 5;
    }

    return min(score, 100);
  }
}

class _ProductMatch {
  final Product product;
  final int score;
  final String matchedItem;

  _ProductMatch({
    required this.product,
    required this.score,
    required this.matchedItem,
  });
}

class _ProductCard extends StatefulWidget {
  final Product product;
  final int matchScore;
  final String matchedItem;

  const _ProductCard({
    required this.product,
    required this.matchScore,
    required this.matchedItem,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final sortedPrices = [...product.platformPrices]
      ..sort((a, b) => a.price.compareTo(b.price));

    final imageUrl = product.imageUrl;

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.matchScore >= 80
              ? const Color(0xFF7C4DFF).withOpacity(0.3)
              : const Color(0xFFF0F0F5),
        ),
        boxShadow: [
          BoxShadow(
            color: widget.matchScore >= 80
                ? const Color(0xFF7C4DFF).withOpacity(0.08)
                : Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  imageUrl,
                  height: 100,
                  width: 260,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 100,
                    width: 260,
                    color: const Color(0xFFF5F5F7),
                    child: const Icon(Icons.checkroom, color: Color(0xFFC7C7CC), size: 32),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.matchScore >= 80
                        ? const Color(0xFF7C4DFF)
                        : widget.matchScore >= 60
                            ? const Color(0xFFFF9500)
                            : const Color(0xFF8E8E93),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${widget.matchScore}% match',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (sortedPrices.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34C759),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.savings_outlined, size: 10, color: Colors.white),
                        const SizedBox(width: 3),
                        Text(
                          'Save ₹${product.bestSavings}',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
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
                    product.brand,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF8E8E93),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1D1D1F),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (sortedPrices.isNotEmpty) ...[
                    Row(
                      children: [
                        Text(
                          '₹${product.bestPrice}',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF34C759),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'on ${product.cheapestPlatform?.platform ?? ''}',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF34C759),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => setState(() => _expanded = !_expanded),
                      child: Row(
                        children: [
                          Text(
                            _expanded ? 'Hide prices' : 'Compare ${sortedPrices.length} platforms',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF7C4DFF),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            _expanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 14,
                            color: const Color(0xFF7C4DFF),
                          ),
                        ],
                      ),
                    ),
                    if (_expanded) ...[
                      const SizedBox(height: 6),
                      ...sortedPrices.take(4).map((p) {
                        final isCheapest = p.price == product.bestPrice;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Row(
                            children: [
                              if (isCheapest)
                                const Icon(Icons.star_rounded, size: 10, color: Color(0xFF34C759))
                              else
                                const SizedBox(width: 10),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  p.platform,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: isCheapest
                                        ? const Color(0xFF34C759)
                                        : const Color(0xFF636366),
                                    fontWeight: isCheapest ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              ),
                              Text(
                                '₹${p.price}',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: isCheapest
                                      ? const Color(0xFF34C759)
                                      : const Color(0xFF1D1D1F),
                                  fontWeight: isCheapest ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ] else
                    Text(
                      '₹${product.price}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1D1D1F),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideX(begin: 0.05);
  }
}
