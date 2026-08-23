import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/outfit_dataset.dart';

class OutfitDataService {
  static final OutfitDataService _instance = OutfitDataService._internal();
  factory OutfitDataService() => _instance;
  OutfitDataService._internal();

  List<OutfitDataset> _allOutfits = [];
  bool _isLoaded = false;

  Future<void> loadOutfits() async {
    if (_isLoaded) return;

    final jsonString = await rootBundle.loadString('assets/data/outfits.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);
    _allOutfits = jsonList.map((j) => OutfitDataset.fromJson(j)).toList();
    _isLoaded = true;
  }

  List<OutfitDataset> get allOutfits => _allOutfits;

  List<OutfitDataset> filter({
    String? occasion,
    String? style,
    String? season,
    String? skinTone,
    String? budgetRange,
  }) {
    return _allOutfits.where((o) {
      if (occasion != null && occasion.isNotEmpty && o.occasion != occasion) return false;
      if (style != null && style.isNotEmpty && o.style != style) return false;
      if (season != null && season.isNotEmpty && o.season != season) return false;
      if (skinTone != null && skinTone.isNotEmpty && o.skinTone != skinTone) return false;
      if (budgetRange != null && budgetRange.isNotEmpty && o.budget != budgetRange) return false;
      return true;
    }).toList();
  }

  List<String> get occasions => ['College', 'Office', 'Party', 'Travel', 'Relax'];
  List<String> get styles => ['Minimal', 'Streetwear', 'Smart Casual', 'Classic', 'Modern'];
  List<String> get seasons => ['Summer', 'Winter', 'Monsoon', 'All Season'];
  List<String> get skinTones => ['Very Light', 'Wheatish'];
}
