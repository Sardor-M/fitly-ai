import '../models/clothing_item.dart';
import '../models/outfit.dart';

class ClothingService {
  const ClothingService();

  Future<List<Outfit>> fetchRecommendedOutfits() async {
    // TODO(sardor): Replace with Supabase edge function or REST API call.
    await Future<void>.delayed(const Duration(milliseconds: 600));

    return List.generate(5, (index) {
      final color = 0xFF1B4DE4 + index * 0x000A0A;
      return Outfit(
        id: 'outfit-$index',
        title: 'Smart Casual ${index + 1}',
        description:
            'Designed to flatter your current mood with breathable textures.',
        imageUrl:
            'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=800&q=60',
        colors: [color, color - 0x001010, color + 0x000808],
        items: [
          ClothingItem(
            id: 'top-$index',
            name: 'Textured Knit Top',
            category: 'Top',
            imageUrl:
                'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=600&q=60',
            brand: 'Fitly Studio',
            price: 79.0,
            description: 'Slim fit knit with engineered shoulder contouring.',
          ),
          ClothingItem(
            id: 'bottom-$index',
            name: 'Tailored Trouser',
            category: 'Bottom',
            imageUrl:
                'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?auto=format&fit=crop&w=600&q=60',
            brand: 'Fitly Studio',
            price: 120.0,
            description:
                'High waist tapered leg that elongates your silhouette.',
          ),
          ClothingItem(
            id: 'shoe-$index',
            name: 'Minimalist Sneaker',
            category: 'Shoes',
            imageUrl:
                'https://images.unsplash.com/photo-1491553895911-0055eca6402d?auto=format&fit=crop&w=600&q=60',
            brand: 'Fitly Studio',
            price: 110.0,
            description: 'Neutral leather sneaker ideal for urban wear.',
          ),
        ],
      );
    });
  }
}

