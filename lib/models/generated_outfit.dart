class GeneratedOutfit {
  final String imageUrl;
  final String style;
  final int index;
  final DateTime createdAt;
  final String? productUrl;

  GeneratedOutfit({
    required this.imageUrl,
    required this.style,
    required this.index,
    DateTime? createdAt,
    this.productUrl,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'imageUrl': imageUrl,
        'style': style,
        'index': index,
        'createdAt': createdAt.toIso8601String(),
        'productUrl': productUrl,
      };

  factory GeneratedOutfit.fromJson(Map<String, dynamic> json) =>
      GeneratedOutfit(
        imageUrl: json['imageUrl'] as String,
        style: json['style'] as String,
        index: json['index'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
        productUrl: json['productUrl'] as String?,
      );
}

