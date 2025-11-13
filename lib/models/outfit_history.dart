class OutfitHistory {
  final String id;
  final String userId;
  final String imageUrl;
  final String style;
  final String? selfieUrl;
  final String? paletteName;
  final List<String>? paletteColors;
  final DateTime createdAt;

  OutfitHistory({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.style,
    this.selfieUrl,
    this.paletteName,
    this.paletteColors,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'image_url': imageUrl,
        'style': style,
        'selfie_url': selfieUrl,
        'palette_name': paletteName,
        'palette_colors': paletteColors,
        'created_at': createdAt.toIso8601String(),
      };

  factory OutfitHistory.fromJson(Map<String, dynamic> json) => OutfitHistory(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        imageUrl: json['image_url'] as String,
        style: json['style'] as String,
        selfieUrl: json['selfie_url'] as String?,
        paletteName: json['palette_name'] as String?,
        paletteColors: json['palette_colors'] != null
            ? List<String>.from(json['palette_colors'] as List)
            : null,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

