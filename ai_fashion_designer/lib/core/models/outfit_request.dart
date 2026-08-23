class OutfitRequest {
  final String style;
  final String occasion;
  final List<String> colors;
  final String budget;
  final String prompt;

  const OutfitRequest({
    this.style = '',
    this.occasion = '',
    this.colors = const [],
    this.budget = '',
    this.prompt = '',
  });

  String buildPrompt() {
    final parts = <String>[
      'professional fashion photography, studio lighting, high resolution, editorial style, magazine quality',
    ];

    if (style.isNotEmpty) {
      parts.insert(0, '$style style outfit');
    } else {
      parts.insert(0, 'fashion outfit');
    }

    if (occasion.isNotEmpty) {
      parts.insert(1, 'for $occasion');
    }

    if (colors.isNotEmpty) {
      final colorNames = colors.map(_colorNameFromHex).join(', ');
      parts.insert(2, '$colorNames color palette');
    }

    if (prompt.isNotEmpty) {
      parts.insert(parts.length - 1, prompt);
    }

    parts.add('detailed fabric texture, realistic');

    return parts.join(', ');
  }

  String _colorNameFromHex(String hex) {
    const colorMap = {
      '#FF0000': 'red',
      '#FF5722': 'orange',
      '#FF9800': 'amber',
      '#FFC107': 'yellow',
      '#4CAF50': 'green',
      '#00BCD4': 'cyan',
      '#2196F3': 'blue',
      '#3F51B5': 'indigo',
      '#9C27B0': 'purple',
      '#E91E63': 'pink',
      '#795548': 'brown',
      '#000000': 'black',
      '#FFFFFF': 'white',
      '#607D8B': 'grey',
    };
    return colorMap[hex.toUpperCase()] ?? 'mixed';
  }

  OutfitRequest copyWith({
    String? style,
    String? occasion,
    List<String>? colors,
    String? budget,
    String? prompt,
  }) {
    return OutfitRequest(
      style: style ?? this.style,
      occasion: occasion ?? this.occasion,
      colors: colors ?? this.colors,
      budget: budget ?? this.budget,
      prompt: prompt ?? this.prompt,
    );
  }
}
