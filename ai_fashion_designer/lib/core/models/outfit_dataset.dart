class OutfitDataset {
  final String id;
  final String occasion;
  final String? top;
  final String? bottom;
  final String? shoes;
  final String? layer;
  final String? accessory;
  final String? skinTone;
  final String? goodColors;
  final String? season;
  final String? style;
  final String? budget;
  final int? score;

  const OutfitDataset({
    required this.id,
    required this.occasion,
    this.top,
    this.bottom,
    this.shoes,
    this.layer,
    this.accessory,
    this.skinTone,
    this.goodColors,
    this.season,
    this.style,
    this.budget,
    this.score,
  });

  factory OutfitDataset.fromJson(Map<String, dynamic> json) {
    return OutfitDataset(
      id: json['id'] as String? ?? '',
      occasion: json['occasion'] as String? ?? '',
      top: json['top'] as String?,
      bottom: json['bottom'] as String?,
      shoes: json['shoes'] as String?,
      layer: json['layer'] as String?,
      accessory: json['accessory'] as String?,
      skinTone: json['skinTone'] as String?,
      goodColors: json['goodColors'] as String?,
      season: json['season'] as String?,
      style: json['style'] as String?,
      budget: json['budget'] as String?,
      score: json['score'] as int?,
    );
  }

  String toAiPrompt() {
    final parts = <String>[];

    parts.add('Fashion photo of young Indian man');

    if (top != null) parts.add('${top!.toLowerCase()} top');
    if (bottom != null) parts.add('${bottom!.toLowerCase()} pants');
    if (layer != null && layer != 'None') parts.add('${layer!.toLowerCase()} over shoulders');
    if (accessory != null && accessory != 'None') parts.add('with ${accessory!.toLowerCase()}');
    if (shoes != null) parts.add('${shoes!.toLowerCase()} on feet');

    parts.add('full body shot, standing pose, shoes clearly visible, camera shows head to toe, fashion magazine photo, studio lighting, white background, photorealistic');

    return parts.join(', ');
  }

  String get displayTitle {
    final parts = <String>[];
    if (top != null) parts.add(top!);
    if (bottom != null) parts.add(bottom!);
    return parts.isNotEmpty ? parts.join(' + ') : occasion;
  }

  String get displaySubtitle {
    final parts = <String>[occasion];
    if (style != null) parts.add(style!);
    if (season != null) parts.add(season!);
    return parts.join(' · ');
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'occasion': occasion,
    'top': top,
    'bottom': bottom,
    'shoes': shoes,
    'layer': layer,
    'accessory': accessory,
    'skinTone': skinTone,
    'goodColors': goodColors,
    'season': season,
    'style': style,
    'budget': budget,
    'score': score,
  };
}
