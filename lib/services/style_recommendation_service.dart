import '../models/color_palette.dart';
import '../models/face_analysis_result.dart';
import '../models/style_recommendation.dart';

class StyleRecommendationService {
  static StyleRecommendation recommendStyle(FaceAnalysisResult analysis) {
    /** 
      Determine seasonal type
    */
    final seasonal = analysis.seasonalType;

    /** 
      Generate color palettes
    */
    final palettes = _generateColorPalettes(analysis.skinTone, seasonal);

    /** 
      Recommend styles
    */
    final styles = _recommendStyles(analysis, seasonal);

    return StyleRecommendation(
      seasonalType: seasonal,
      colorPalettes: palettes,
      recommendedStyles: styles,
      bodyTypes: ['classic', 'casual', 'formal', 'streetwear'],
    );
  }

  static List<String> _recommendStyles(
      FaceAnalysisResult analysis, String seasonal) {
    final styles = <String>[];

    /** 
      Analyze face shape and features to recommend styles
    */
    final faceShape = analysis.faceShape.toLowerCase();
    
    /** 
      Base recommendations on seasonal type and face shape
    */
    switch (seasonal.toLowerCase()) {
      case 'spring':
        if (faceShape == 'round' || faceShape == 'oval') {
          styles.addAll(['casual', 'romantic', 'classic']);
        } else {
          styles.addAll(['casual', 'classic', 'streetwear']);
        }
        break;
      case 'summer':
        if (faceShape == 'oval' || faceShape == 'square') {
          styles.addAll(['minimal', 'classic', 'formal']);
        } else {
          styles.addAll(['casual', 'classic', 'minimal']);
        }
        break;
      case 'autumn':
        styles.addAll(['classic', 'vintage', 'casual']);
        break;
      case 'winter':
        if (faceShape == 'square' || faceShape == 'oval') {
          styles.addAll(['formal', 'classic', 'minimal']);
        } else {
          styles.addAll(['formal', 'classic', 'streetwear']);
        }
        break;
      default:
        styles.addAll(['casual', 'classic', 'formal']);
    }

    if (styles.length < 3) {
      styles.addAll(['casual', 'classic']);
    }

    /** 
     Returning the styles list limited to 6 styles for better performance
    */
    return styles.take(6).toList();
    
  }

  static List<ColorPalette> _generateColorPalettes(
    String skinTone, String season) {
    /** 
      Generate colors based on actual skin tone analysis
    */
    final baseColors = _generateColorsFromSkinTone(skinTone, season);
    
    return baseColors
        .asMap()
        .entries
        .map((entry) => ColorPalette(
              name: '$season Palette ${entry.key + 1}',
              colors: entry.value,
              skinTone: skinTone,
            ))
        .toList();
  }

  static List<List<String>> _generateColorsFromSkinTone(
    String skinToneHex, String season) {
    /** 
      Parse the analyzed skin tone hex
    */
    final hex = skinToneHex.replaceAll('#', '');
    final r = int.parse(hex.substring(0, 2), radix: 16);
    final g = int.parse(hex.substring(2, 4), radix: 16);
    final b = int.parse(hex.substring(4, 6), radix: 16);

    /** 
      Generate complementary colors based on skin tone and season
    */
    final palettes = <List<String>>[];

    switch (season.toLowerCase()) {
      case 'spring':
        /** 
          Light, warm, fresh colors that complement warm skin tones
        */
        palettes.addAll([
          [
            _adjustColor(r, g, b, 0.3, 0.4, 0.3), 
            _adjustColor(r, g, b, 0.2, 0.5, 0.3), 
            _adjustColor(r, g, b, 0.2, 0.3, 0.5), 
          ],
          [
            _adjustColor(r, g, b, 0.4, 0.4, 0.2), 
            _adjustColor(r, g, b, 0.5, 0.3, 0.2), 
            _adjustColor(r, g, b, 0.3, 0.3, 0.4), 
          ],
          [
            _adjustColor(r, g, b, 0.5, 0.2, 0.3), 
            _adjustColor(r, g, b, 0.4, 0.3, 0.3), 
            _adjustColor(r, g, b, 0.3, 0.4, 0.3), 
          ],
        ]);
        break;
      case 'summer':
        /** 
          Cool, soft, muted colors
        */
        palettes.addAll([
          [
            _adjustColor(r, g, b, 0.3, 0.3, 0.4), 
            _adjustColor(r, g, b, 0.3, 0.2, 0.5), 
            _adjustColor(r, g, b, 0.4, 0.3, 0.3), 
          ],
          [
            _adjustColor(r, g, b, 0.2, 0.4, 0.4), 
            _adjustColor(r, g, b, 0.3, 0.3, 0.4), 
            _adjustColor(r, g, b, 0.4, 0.3, 0.3), 
          ],
          [
            _adjustColor(r, g, b, 0.3, 0.3, 0.4), 
            _adjustColor(r, g, b, 0.3, 0.2, 0.5), 
            _adjustColor(r, g, b, 0.4, 0.3, 0.3), 
          ],
        ]);
        break;
      case 'autumn':
        /** 
          Warm, rich, earthy colors
        */
        palettes.addAll([
          [
            _adjustColor(r, g, b, 0.6, 0.3, 0.1), 
            _adjustColor(r, g, b, 0.5, 0.4, 0.1), 
            _adjustColor(r, g, b, 0.4, 0.2, 0.4), 
          ],
          [
            _adjustColor(r, g, b, 0.5, 0.3, 0.2), 
            _adjustColor(r, g, b, 0.4, 0.4, 0.2), 
            _adjustColor(r, g, b, 0.6, 0.2, 0.2), 
          ],
          [
            _adjustColor(r, g, b, 0.5, 0.3, 0.2), 
            _adjustColor(r, g, b, 0.6, 0.2, 0.2), 
            _adjustColor(r, g, b, 0.4, 0.1, 0.5), 
          ],
        ]);
        break;
      case 'winter':
        /** 
          Cool, clear, bold colors
        */
        palettes.addAll([
          [
            _adjustColor(r, g, b, 0.1, 0.1, 0.8), 
            _adjustColor(r, g, b, 0.2, 0.1, 0.7), 
            _adjustColor(r, g, b, 0.3, 0.1, 0.6), 
          ],
          [
            _adjustColor(r, g, b, 0.3, 0.1, 0.6), 
            _adjustColor(r, g, b, 0.2, 0.2, 0.6), 
            _adjustColor(r, g, b, 0.4, 0.1, 0.5), 
          ],
          [
            _adjustColor(r, g, b, 0.2, 0.2, 0.6), 
            _adjustColor(r, g, b, 0.3, 0.3, 0.4), 
            _adjustColor(r, g, b, 0.1, 0.1, 0.8), 
          ],
        ]);
        break;
      default:
        /** 
          Default to spring colors
        */
        palettes.addAll([
          [
            _adjustColor(r, g, b, 0.3, 0.4, 0.3),
            _adjustColor(r, g, b, 0.2, 0.5, 0.3),
            _adjustColor(r, g, b, 0.2, 0.3, 0.5),
          ],
        ]);
    }

    return palettes;
  }

  static String _adjustColor(int r, int g, int b, double rFactor,
      double gFactor, double bFactor) {
    /** 
      Generate complementary colors by adjusting RGB values
    */
    final newR = ((r * rFactor) + (255 * (1 - rFactor))).clamp(0, 255).toInt();
    final newG = ((g * gFactor) + (255 * (1 - gFactor))).clamp(0, 255).toInt();
    final newB = ((b * bFactor) + (255 * (1 - bFactor))).clamp(0, 255).toInt();
    return '#${newR.toRadixString(16).padLeft(2, '0')}${newG.toRadixString(16).padLeft(2, '0')}${newB.toRadixString(16).padLeft(2, '0')}'.toUpperCase();
  }
}

