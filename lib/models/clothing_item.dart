/**
 * Represents an individual piece in an outfit recommendation.
 * It is also used to get the clothing item from the json.
 * It is also used to convert the clothing item to json.
 */
class ClothingItem {
  ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.brand,
    this.price,
    this.description,
  });

  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final String brand;
  final double? price;
  final String? description;

  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      price: json['price'] == null
          ? null
          : double.tryParse(json['price'].toString()),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'imageUrl': imageUrl,
      'brand': brand,
      'price': price,
      'description': description,
    };
  }
}

