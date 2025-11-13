class FaceAnalysisResult {
  final String skinTone;
  final String hairColor;
  final String eyeColor;
  final String faceShape;
  final String seasonalType;

  FaceAnalysisResult({
    required this.skinTone,
    required this.hairColor,
    required this.eyeColor,
    required this.faceShape,
    required this.seasonalType,
  });

  Map<String, dynamic> toJson() => {
        'skinTone': skinTone,
        'hairColor': hairColor,
        'eyeColor': eyeColor,
        'faceShape': faceShape,
        'seasonalType': seasonalType,
      };

  factory FaceAnalysisResult.fromJson(Map<String, dynamic> json) =>
      FaceAnalysisResult(
        skinTone: json['skinTone'] as String,
        hairColor: json['hairColor'] as String,
        eyeColor: json['eyeColor'] as String,
        faceShape: json['faceShape'] as String,
        seasonalType: json['seasonalType'] as String,
      );
}

