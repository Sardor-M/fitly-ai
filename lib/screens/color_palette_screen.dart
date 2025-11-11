import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/analysis/color_palette_grid.dart';

class ColorPaletteScreen extends StatelessWidget {
  const ColorPaletteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors =
        (Get.arguments as List<dynamic>? ?? <dynamic>[]).cast<int>().toList();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your palette'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mix and match these tones to keep your look balanced.',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ColorPaletteGrid(colors: colors),
            ),
            const SizedBox(height: 24),
            ...colors.map(
              (color) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      height: 28,
                      width: 28,
                      decoration: BoxDecoration(
                        color: Color(color),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '#${color.toRadixString(16).padLeft(8, '0').toUpperCase()}',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

