import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:palette_generator/palette_generator.dart';

import '../models/face_analysis_result.dart';

class MediaPipeAnalysisService {
  static Future<FaceAnalysisResult> analyzeFace(String imagePath) async {
    /** 
      Web fallback - ML Kit doesn't support web
    */
    if (kIsWeb) {
      return _analyzeFaceWeb(imagePath);
    }

    try {
      /** 
        Face Detection
      */
      final inputImage = InputImage.fromFilePath(imagePath);
      final faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableContours: true,
          enableLandmarks: true,
          enableClassification: true,
          minFaceSize: 0.15,
        ),
      );

      final faces = await faceDetector.processImage(inputImage);
      if (faces.isEmpty) {
        throw Exception('No face detected. Please ensure your face is clearly visible.');
      }

      final face = faces.first;
      faceDetector.close();

      /** 
        Load image for color extraction
      */
      final imageBytes = await File(imagePath).readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      /** 
        Extract colors
      */
      final skinTone = await _extractSkinTone(imagePath, face.boundingBox);
      final hairColor = await _extractHairColor(imagePath, face.boundingBox);
      final eyeColor = await _extractEyeColor(imagePath, face);

      /** 
        Calculate face shape
      */
      final faceShape = _calculateFaceShape(face);

      /** 
        Determine seasonal type
      */
      final seasonalType = _determineSeasonalType(skinTone, hairColor, eyeColor);

      return FaceAnalysisResult(
        skinTone: skinTone,
        hairColor: hairColor,
        eyeColor: eyeColor,
        faceShape: faceShape,
        seasonalType: seasonalType,
      );
    } catch (e) {
      /** 
        If ML Kit fails, try web fallback or return default
      */
      if (kIsWeb) {
        return _analyzeFaceWeb(imagePath);
      }
      rethrow;
    }
  }

  /** 
    Web fallback analysis
  */
  static Future<FaceAnalysisResult> _analyzeFaceWeb(String imagePath) async {
    try {
      print('Web analysis: Using fallback color analysis');
      
      /** 
      For web, we can't use File I/O or ML Kit
      We'll need to analyze the image bytes from AppController
      For now, return reasonable default values
      */
      return FaceAnalysisResult(
        skinTone: '#D2A679', 
        hairColor: '#4A4A4A', 
        eyeColor: '#4A4A4A', 
        faceShape: 'oval',
        seasonalType: 'spring', 
      );
    } catch (e) {
      /** 
        Return default values
      */
      return FaceAnalysisResult(
        skinTone: '#D2A679',
        hairColor: '#4A4A4A',
        eyeColor: '#4A4A4A',
        faceShape: 'oval',
        seasonalType: 'spring',
      );
    }
  }

  static Future<String> _extractSkinTone(
      String imagePath, Rect faceBox) async {
    try {
      final paletteGen = await PaletteGenerator.fromImageProvider(
        FileImage(File(imagePath)),
        region: Rect.fromLTWH(
          faceBox.left + faceBox.width * 0.3, // Cheek area
          faceBox.top + faceBox.height * 0.4,
          faceBox.width * 0.4,
          faceBox.height * 0.2,
        ),
      );

      final dominantColor = paletteGen.dominantColor?.color;
      if (dominantColor != null) {
        final argb = dominantColor.value;
        final hex = argb.toRadixString(16).substring(2).toUpperCase().padLeft(6, '0');
        return '#$hex';
      }
    } catch (e) {
      print('Error extracting skin tone: $e');
    }
    return '#D2A679'; 
  }

  static Future<String> _extractHairColor(
      String imagePath, Rect faceBox) async {
    try {
      final paletteGen = await PaletteGenerator.fromImageProvider(
        FileImage(File(imagePath)),
        region: Rect.fromLTWH(
          faceBox.left + faceBox.width * 0.2, 
          faceBox.top - faceBox.height * 0.3,
          faceBox.width * 0.6,
          faceBox.height * 0.3,
        ),
      );

      final dominantColor = paletteGen.dominantColor?.color;
      if (dominantColor != null) {
        final argb = dominantColor.value;
        final hex = argb.toRadixString(16).substring(2).toUpperCase().padLeft(6, '0');
        return '#$hex';
      }
    } catch (e) {
      print('Error extracting hair color: $e');
    }
    return '#4A4A4A'; 
  }

  static Future<String> _extractEyeColor(
      String imagePath, Face face) async {
    try {
      /** 
        Approximate eye area using landmarks
      */
      final leftEye = face.landmarks[FaceLandmarkType.leftEye];
      final rightEye = face.landmarks[FaceLandmarkType.rightEye];

      if (leftEye != null && rightEye != null) {
        final eyeRegion = Rect.fromLTRB(
          leftEye.position.x.toDouble(),
          ((leftEye.position.y + rightEye.position.y) / 2 - 20).toDouble(),
          rightEye.position.x.toDouble(),
          ((leftEye.position.y + rightEye.position.y) / 2 + 20).toDouble(),
        );

        /** 
          Extract eye color
        */
        final paletteGen = await PaletteGenerator.fromImageProvider(
          FileImage(File(imagePath)),
          region: eyeRegion,
        );

        final dominantColor = paletteGen.dominantColor?.color;
        if (dominantColor != null) {
          return '#${dominantColor.value.toRadixString(16).substring(2).toUpperCase()}';
        }
      }
    } catch (e) {
      print('Error extracting eye color: $e');
    }
    return '#4A4A4A'; 
  }

  static String _calculateFaceShape(Face face) {
    /** 
      Simple face shape calculation based on face dimensions
    */
    final width = face.boundingBox.width;
    final height = face.boundingBox.height;
    final ratio = width / height;

    if (ratio > 0.85) {
      return 'round';
    } else if (ratio < 0.75) {
      return 'oval';
    } else {
      return 'square';
    }
  }

  static String _determineSeasonalType(
      String skinTone, String hairColor, String eyeColor) {
    /** 
      Convert hex to RGB
    */
    final skinHex = skinTone.replaceAll('#', '');
    final r = int.parse(skinHex.substring(0, 2), radix: 16);
    final g = int.parse(skinHex.substring(2, 4), radix: 16);
    final b = int.parse(skinHex.substring(4, 6), radix: 16);

    /** 
      Warm undertones (more red/yellow)
    */
    if (r > g && r > b) {
      /** 
        Determine if spring or autumn based on brightness
      */
      final brightness = (r + g + b) / 3;
      return brightness > 180 ? 'spring' : 'autumn';
    }
    else {
      final brightness = (r + g + b) / 3;
      return brightness > 150 ? 'summer' : 'winter';
    }
  }

}

