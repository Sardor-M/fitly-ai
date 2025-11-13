import 'color_palette.dart';

class StyleRecommendation {
  final String seasonalType;
  final List<ColorPalette> colorPalettes;
  final List<String> recommendedStyles;
  final List<String> bodyTypes;

  StyleRecommendation({
    required this.seasonalType,
    required this.colorPalettes,
    required this.recommendedStyles,
    required this.bodyTypes,
  });

  Map<String, dynamic> toJson() => {
        'seasonalType': seasonalType,
        'colorPalettes': colorPalettes.map((p) => p.toJson()).toList(),
        'recommendedStyles': recommendedStyles,
        'bodyTypes': bodyTypes,
      };

  factory StyleRecommendation.fromJson(Map<String, dynamic> json) =>
      StyleRecommendation(
        seasonalType: json['seasonalType'] as String,
        colorPalettes: (json['colorPalettes'] as List)
            .map((p) => ColorPalette.fromJson(p as Map<String, dynamic>))
            .toList(),
        recommendedStyles: List<String>.from(json['recommendedStyles'] as List),
        bodyTypes: List<String>.from(json['bodyTypes'] as List),
      );
}

