import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_outfit.dart';
import '../models/outfit_dataset.dart';
import 'platform_price_service.dart';

class SavedOutfitService {
  static final SavedOutfitService _instance = SavedOutfitService._internal();
  factory SavedOutfitService() => _instance;
  SavedOutfitService._internal();

  static const String _storageKey = 'saved_outfits';
  final PlatformPriceService _priceService = PlatformPriceService();

  List<SavedOutfit> _savedOutfits = [];
  bool _isLoaded = false;

  final ValueNotifier<List<SavedOutfit>> savedOutfitsNotifier = ValueNotifier([]);

  Future<void> loadSavedOutfits() async {
    if (_isLoaded) return;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _savedOutfits = list.map((e) => SavedOutfit.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        debugPrint('Error loading saved outfits: $e');
        _savedOutfits = [];
      }
    }

    _isLoaded = true;
    savedOutfitsNotifier.value = _savedOutfits;
  }

  List<OutfitDataset> get savedOutfitDatasets => _savedOutfits.map((s) => s.outfit).toList();

  bool isSaved(String outfitId) => _savedOutfits.any((s) => s.outfit.id == outfitId);

  Future<void> toggleSave(OutfitDataset outfit, {String? aiImageUrl}) async {
    final id = 'saved_${DateTime.now().millisecondsSinceEpoch}';
    if (!isSaved(outfit.id)) {
      final saved = SavedOutfit(
        id: id,
        outfit: outfit,
        savedAt: DateTime.now(),
        aiGeneratedImageUrl: aiImageUrl,
      );

      _savedOutfits.add(saved);
    } else {
      _savedOutfits.removeWhere((s) => s.outfit.id == outfit.id);
    }
    await _persist();
    savedOutfitsNotifier.value = List.from(_savedOutfits);
  }

  Future<void> saveOutfit(OutfitDataset outfit, {String? notes, String? aiImageUrl}) async {
    await toggleSave(outfit, aiImageUrl: aiImageUrl);
  }

  Future<void> removeOutfit(String outfitId) async {
    _savedOutfits.removeWhere((s) => s.outfit.id == outfitId);
    await _persist();
    savedOutfitsNotifier.value = List.from(_savedOutfits);
  }

  Future<void> addNote(String savedOutfitId, String note) async {
    final index = _savedOutfits.indexWhere((s) => s.id == savedOutfitId);
    if (index != -1) {
      final existing = _savedOutfits[index];
      _savedOutfits[index] = SavedOutfit(
        id: existing.id,
        outfit: existing.outfit,
        savedAt: existing.savedAt,
        notes: note,
        aiGeneratedImageUrl: existing.aiGeneratedImageUrl,
        price: existing.price,
        platformPrices: existing.platformPrices,
      );
      await _persist();
      savedOutfitsNotifier.value = List.from(_savedOutfits);
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _savedOutfits.map((s) => s.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(data));
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    _savedOutfits = [];
    savedOutfitsNotifier.value = [];
  }
}
