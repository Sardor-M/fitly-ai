import 'package:flutter/material.dart';

class ColorPalette {
  final String name;
  final List<String> colors;
  final String skinTone;

  ColorPalette({
    required this.name,
    required this.colors,
    required this.skinTone,
  });

  List<Color> get colorList => colors.map((c) => _hexToColor(c)).toList();

  Color _hexToColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'colors': colors,
        'skinTone': skinTone,
      };

  factory ColorPalette.fromJson(Map<String, dynamic> json) => ColorPalette(
        name: json['name'] as String,
        colors: List<String>.from(json['colors'] as List),
        skinTone: json['skinTone'] as String,
      );
}

