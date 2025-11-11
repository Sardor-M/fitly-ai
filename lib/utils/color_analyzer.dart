import 'package:flutter/painting.dart';
import 'package:palette_generator/palette_generator.dart';

class ColorAnalyzer {
  const ColorAnalyzer();

  Future<List<Color>> generatePalette(ImageProvider imageProvider) async {
    final palette = await PaletteGenerator.fromImageProvider(
      imageProvider,
      size: const Size(200, 200),
      maximumColorCount: 12,
    );
    final dominant = palette.dominantColor?.color;
    final vibrant = palette.vibrantColor?.color;
    final muted = palette.mutedColor?.color;

    final candidates = <Color>[
      if (dominant != null) dominant,
      if (vibrant != null) vibrant,
      if (muted != null) muted,
      ...palette.colors,
    ];

    return candidates.toSet().toList();
  }
}

