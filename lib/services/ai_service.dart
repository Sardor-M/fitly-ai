import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/user_analysis.dart';
import '../utils/color_analyzer.dart';

class AnalysisResult {
  AnalysisResult({
    required this.analysis,
    required this.palette,
  });

  final UserAnalysis analysis;
  final List<int> palette;
}

class AIService {
  const AIService(this._colorAnalyzer);

  final ColorAnalyzer _colorAnalyzer;

  Future<AnalysisResult> analyzeUser(File photo) async {
    final colors =
        await _colorAnalyzer.generatePalette(FileImage(photo)).catchError((_) {
      return <Color>[
        const Color(0xFF1B4DE4),
        const Color(0xFF00D6C2),
        const Color(0xFFFFB74D),
      ];
    });

    int colorToInt(Color color) {
      final alpha = (color.a * 255.0).round() & 0xff;
      final red = (color.r * 255.0).round() & 0xff;
      final green = (color.g * 255.0).round() & 0xff;
      final blue = (color.b * 255.0).round() & 0xff;
      return (alpha << 24) | (red << 16) | (green << 8) | blue;
    }

    final List<int> palette =
        colors.take(6).map((color) => colorToInt(color)).toList();

    // Fake AI response for now.
    final random = Random();
    final bodyShapes = ['Hourglass', 'Rectangle', 'Triangle', 'Inverted'];
    final occasions = ['Office', 'Weekend', 'Date Night', 'Gym'];

    final analysis = UserAnalysis(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      skinToneDescription: 'Warm undertone with golden highlights.',
      bodyShape: bodyShapes[random.nextInt(bodyShapes.length)],
      recommendedColors: palette
          .map((color) => '#${color.toRadixString(16).padLeft(8, '0')}')
          .toList(),
      occasions: occasions..shuffle(),
    );

    return AnalysisResult(
      analysis: analysis,
      palette: palette,
    );
  }
}

