import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/color_palette.dart';
import 'supabase_outfit_service.dart';

class OutfitGenerationService {
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<List<String>> generateOutfits({
    required String selfieBase64,
    required ColorPalette palette,
    required List<String> styles,
    String? userId,
  }) async {
    List<String> generatedImages = [];

    /** 
      Generate outfit descriptions based on palette and styles
    */
    final outfitDescriptions = _createOutfitDescriptions(palette, styles);

    /** 
      Generate outfits one by one (to avoid overwhelming the edge function)
    */
    for (int i = 0; i < outfitDescriptions.length && i < 8; i++) {
      try {
        final description = outfitDescriptions[i];
        final style = styles[i % styles.length];
        
        final imageUrl = await generateSingleOutfit(
          selfieBase64: selfieBase64,
          palette: palette,
          style: style,
          index: i,
          userId: userId,
        );
        
        generatedImages.add(imageUrl);
      } catch (e) {
        print('Error generating outfit $i: $e');
        /** 
          Continue with next outfit even if one fails
        */
      }
    }

    return generatedImages;
  }

  static Future<String> generateSingleOutfit({
    required String selfieBase64,
    required ColorPalette palette,
    required String style,
    required int index,
    String? userId,
  }) async {
    final descriptions = _createOutfitDescriptions(palette, [style]);
    final description = descriptions[index % descriptions.length];
    /** 
      Generate new outfit via Supabase Edge Function (avoids CORS)
    */
    final imageUrl = await SupabaseOutfitService.generateOutfitViaEdgeFunction(
      selfieBase64: selfieBase64,
      description: description,
      index: index,
    );
    
    /** 
      Save to database if user is logged in
    */
    if (userId != null) {
      try {
        await SupabaseOutfitService.saveOutfit(
          userId: userId,
          imageUrl: imageUrl,
          style: style,
          paletteName: palette.name,
          paletteColors: palette.colors,
        );
      } catch (e) {
        print('Error saving outfit to database: $e');
      }
    }
    
    return imageUrl;
  }

  static List<String> _createOutfitDescriptions(
      ColorPalette palette, List<String> styles) {
    List<String> descriptions = [];
    
    /** 
      Create more varied descriptions by mixing styles and colors
      Using index to create unique combinations
    */
    int colorIndex = 0;
    int styleIndex = 0;
    
    for (int i = 0; i < 8; i++) {
      /** 
        Cycle through styles and colors to create variety
      */
      final style = styles[styleIndex % styles.length];
      final color = palette.colors[colorIndex % palette.colors.length];
      
      final variation = i % 3; // 3 variations per style/color combo
      final description = _getOutfitPrompt(style, color);
      
      /** 
        Add unique details to each description
      */
      String variedDescription = description;
      if (variation == 1) {
        variedDescription = '$description, different angle';
      } else if (variation == 2) {
        variedDescription = '$description, alternative styling';
      }
      
      descriptions.add(variedDescription);
      
      /** 
        Alternate between advancing color and style
      */
      if (i % 2 == 0) {
        colorIndex++;
      } else {
        styleIndex++;
      }
    }

    return descriptions;
  }

  static String _getOutfitPrompt(String style, String color) {
    /** 
      More detailed and varied prompts for better outfit generation
    */
    final styleLower = style.toLowerCase();
    
    /** 
      Remove # from color if present for better description
    */
    final colorName = color.replaceAll('#', '').toLowerCase();
    
    final prompts = {
      'casual': 'a $color casual t-shirt with jeans, white sneakers, full body outfit, natural lighting, standing pose, street style',
      'formal': 'a $color business suit with dress shirt, formal pants, dress shoes, full body professional outfit, office setting, confident pose',
      'streetwear': 'a $color oversized hoodie with cargo pants, designer sneakers, full body streetwear outfit, urban background, casual pose',
      'classic': 'a $color button-up shirt with chinos, leather loafers, full body classic outfit, timeless style, elegant pose',
      'minimal': 'a $color minimalist t-shirt with slim fit pants, clean sneakers, full body minimal outfit, simple style, neutral pose',
      'romantic': 'a $color blouse with flowy skirt, elegant shoes, full body romantic outfit, soft lighting, graceful pose',
      'vintage': 'a $color vintage shirt with high-waisted pants, retro shoes, full body vintage outfit, classic style, nostalgic pose',
      'sporty': 'a $color athletic top with sport pants, running shoes, full body sporty outfit, active wear, dynamic pose',
    };

    return prompts[styleLower] ?? 'a $color casual outfit, full body, modern style, natural pose';
  }
}

