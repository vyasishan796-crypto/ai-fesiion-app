import '../models/body_measurement.dart';

class SizeCalculator {
  SizeRecommendation getSizeRecommendation(FitProfile profile) {
    return SizeRecommendation(
      category: 'Shirts',
      recommendedSize: profile.topSize,
      matchScore: 0.92,
      bestMatch: 'Best Match: ${profile.topSize}',
      confidence: 'High',
    );
  }

  Map<String, SizeRecommendation> getAllRecommendations(FitProfile profile) {
    return {
      'Tops': SizeRecommendation(
        category: 'Tops',
        recommendedSize: profile.topSize,
        matchScore: 0.92,
        bestMatch: 'Best Match: ${profile.topSize}',
        confidence: 'High',
      ),
      'Bottoms': SizeRecommendation(
        category: 'Bottoms',
        recommendedSize: profile.bottomSize,
        matchScore: 0.91,
        bestMatch: 'Best Match: ${profile.bottomSize}',
        confidence: 'High',
      ),
      'Dresses': SizeRecommendation(
        category: 'Dresses',
        recommendedSize: profile.topSize,
        matchScore: 0.85,
        bestMatch: 'Best Match: ${profile.topSize}',
        confidence: 'Medium',
      ),
      'Outerwear': SizeRecommendation(
        category: 'Outerwear',
        recommendedSize: profile.topSize,
        matchScore: 0.88,
        bestMatch: 'Best Match: ${profile.topSize}',
        confidence: 'High',
      ),
    };
  }

  List<SizeRecommendation> calculateSizes(FitProfile profile) {
    return [
      SizeRecommendation(
        category: 'Shirts',
        recommendedSize: profile.topSize,
        matchScore: 0.92,
        bestMatch: 'Best Match: ${profile.topSize}',
        confidence: 'High',
      ),
      SizeRecommendation(
        category: 'T-Shirts',
        recommendedSize: profile.topSize,
        matchScore: 0.90,
        bestMatch: 'Best Match: ${profile.topSize}',
        confidence: 'High',
      ),
      SizeRecommendation(
        category: 'Jackets',
        recommendedSize: profile.topSize,
        matchScore: 0.88,
        bestMatch: 'Best Match: ${profile.topSize}',
        confidence: 'Medium',
      ),
      SizeRecommendation(
        category: 'Trousers',
        recommendedSize: profile.bottomSize,
        matchScore: 0.91,
        bestMatch: 'Best Match: ${profile.bottomSize}',
        confidence: 'High',
      ),
      SizeRecommendation(
        category: 'Jeans',
        recommendedSize: profile.bottomSize,
        matchScore: 0.89,
        bestMatch: 'Best Match: ${profile.bottomSize}',
        confidence: 'High',
      ),
      SizeRecommendation(
        category: 'Formal Pants',
        recommendedSize: profile.bottomSize,
        matchScore: 0.87,
        bestMatch: 'Best Match: ${profile.bottomSize}',
        confidence: 'Medium',
      ),
    ];
  }

  List<OutfitSuggestion> getOutfitSuggestions(FitProfile profile) {
    return [
      const OutfitSuggestion(
        name: 'College Casual',
        description: 'Relaxed fit tee with straight-leg jeans and sneakers',
        occasion: 'College',
        fitType: 'Regular',
        items: ['Regular-Fit Polo T-Shirt', 'Straight-Leg Jeans', 'White Sneakers', 'Canvas Backpack'],
      ),
      const OutfitSuggestion(
        name: 'Office Ready',
        description: 'Tailored oxford shirt with chinos and loafers',
        occasion: 'Office',
        fitType: 'Tailored',
        items: ['Slim-Fit Oxford Shirt', 'Tapered Chinos', 'Leather Loafers', 'Minimal Watch'],
      ),
      const OutfitSuggestion(
        name: 'Street Style',
        description: 'Oversized hoodie with cargo pants and chunky sneakers',
        occasion: 'Streetwear',
        fitType: 'Oversized',
        items: ['Oversized Graphic Hoodie', 'Baggy Cargo Pants', 'Chunky Sneakers', 'Bucket Hat'],
      ),
      const OutfitSuggestion(
        name: 'Weekend Vibes',
        description: 'Linen shirt with shorts for a relaxed weekend look',
        occasion: 'Casual',
        fitType: 'Relaxed',
        items: ['Linen Camp-Collar Shirt', 'Relaxed-Fit Shorts', 'Slide Sandals', 'Sunglasses'],
      ),
      const OutfitSuggestion(
        name: 'Date Night',
        description: 'Fitted blazer with dark jeans for a smart-casual evening',
        occasion: 'Evening',
        fitType: 'Tailored',
        items: ['Structured Blazer', 'Dark Slim Jeans', 'Chelsea Boots', 'Leather Belt'],
      ),
    ];
  }
}
