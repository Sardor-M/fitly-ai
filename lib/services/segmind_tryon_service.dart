import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SegmindTryOnService {
  /** 
    Using Segmind's Virtual Try-On model
  */
  static Future<String> virtualTryOn({
    required String personImage,
    required String garmentImage,
    required int index,
  }) async {
    try {
      final apiKey = dotenv.env['SEGMIND_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        throw Exception('SEGMIND_API_KEY not configured');
      }
      
      final response = await Dio().post(
        'https://api.segmind.com/v1/try-on-diffusion',
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'person_image': personImage, // Base64
          'garment_image': garmentImage, // Base64 or URL
          'category': 'upper_body',
          'seed': index * 100,
          'samples': 1,
        },
      );
      
      if (response.data['image'] != null) {
        return response.data['image'] as String;
      } else if (response.data['url'] != null) {
        return response.data['url'] as String;
      } else if (response.data['output'] != null) {
        final output = response.data['output'];
        return output is String ? output : output[0] as String;
      }
      
      throw Exception('No image URL in Segmind response');
    } catch (e) {
      print('Virtual try-on error: $e');
      rethrow;
    }
  }
}

