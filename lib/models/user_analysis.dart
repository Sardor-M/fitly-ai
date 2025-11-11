class UserAnalysis {
  UserAnalysis({
    required this.id,
    required this.skinToneDescription,
    required this.bodyShape,
    required this.recommendedColors,
    required this.occasions,
  });

  final String id;
  final String skinToneDescription;
  final String bodyShape;
  final List<String> recommendedColors;
  final List<String> occasions;

  factory UserAnalysis.fromJson(Map<String, dynamic> json) {
    return UserAnalysis(
      id: json['id'] as String? ?? '',
      skinToneDescription: json['skinToneDescription'] as String? ?? '',
      bodyShape: json['bodyShape'] as String? ?? '',
      recommendedColors: (json['recommendedColors'] as List<dynamic>? ?? [])
          .map((dynamic e) => e.toString())
          .toList(),
      occasions: (json['occasions'] as List<dynamic>? ?? [])
          .map((dynamic e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skinToneDescription': skinToneDescription,
      'bodyShape': bodyShape,
      'recommendedColors': recommendedColors,
      'occasions': occasions,
    };
  }
}

