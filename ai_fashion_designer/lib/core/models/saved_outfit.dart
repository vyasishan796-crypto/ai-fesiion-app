import 'dart:convert';
import '../models/outfit_dataset.dart';
import '../models/price_data.dart';

class SavedOutfit {
  final String id;
  final OutfitDataset outfit;
  final DateTime savedAt;
  final String? notes;
  final String? aiGeneratedImageUrl;
  final int? price;
  final List<PriceData>? platformPrices;

  SavedOutfit({
    required this.id,
    required this.outfit,
    required this.savedAt,
    this.notes,
    this.aiGeneratedImageUrl,
    this.price,
    this.platformPrices,
  });

  factory SavedOutfit.fromJson(Map<String, dynamic> json) {
    return SavedOutfit(
      id: json['id'] as String? ?? '',
      outfit: OutfitDataset.fromJson(json['outfit'] as Map<String, dynamic>),
      savedAt: DateTime.tryParse(json['savedAt'] as String? ?? '') ?? DateTime.now(),
      notes: json['notes'] as String?,
      aiGeneratedImageUrl: json['aiGeneratedImageUrl'] as String?,
      price: json['price'] as int?,
      platformPrices: (json['platformPrices'] as List<dynamic>?)
          ?.map((p) => PriceData.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'outfit': outfit.toJson(),
    'savedAt': savedAt.toIso8601String(),
    'notes': notes,
    'aiGeneratedImageUrl': aiGeneratedImageUrl,
    'price': price,
    'platformPrices': platformPrices?.map((p) => p.toJson()).toList(),
  };
}
