import 'clothing_item.dart';

/**
 * Represents a complete outfit recommendation.
 * It is also used to get the outfit from the json.
 * It is also used to convert the outfit to json.
 */
class Outfit {
  Outfit({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.items,
    required this.colors,
  });

  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<ClothingItem> items;
  final List<int> colors;

  factory Outfit.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return Outfit(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      items: itemsJson
          .map((dynamic e) =>
              ClothingItem.fromJson(e as Map<String, dynamic>? ?? {}))
          .toList(),
      colors: (json['colors'] as List<dynamic>? ?? [])
          .map((dynamic e) => e as int)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'items': items.map((item) => item.toJson()).toList(),
      'colors': colors,
    };
  }
}

