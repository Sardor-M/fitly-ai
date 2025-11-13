import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';

class SegmindOutfitService {
  /* 
    Generate outfit using Segmind API (fast generation)
  */
  static Future<String> generateOutfit({
    required String selfieBase64,
    required String outfitDescription,
    required String style,
    required int seedIndex,
  }) async {
    try {
      /** 
        we call the Supabase Edge Function which calls Segmind API to generate an outfit
      */
      final dio = Dio();
      final url = '${AppSecrets.supabaseUrl}/functions/v1/generate-outfit';
      
      final session = Supabase.instance.client.auth.currentSession;
      
      if (session == null) {
        throw Exception('User must be authenticated');
      }
      
      final response = await dio.post(
        url,
        data: {
          'selfie_base64': selfieBase64,
          'description': outfitDescription,
          'index': seedIndex,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
            'apikey': AppSecrets.supabaseAnonKey,
            'Content-Type': 'application/json',
          },
        ),
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final imageUrl = data['image_url'] as String?;
        if (imageUrl != null) {
          return imageUrl;
        }
        throw Exception('No image URL in response');
      } else {
        final errorMessage = response.data != null 
            ? (response.data as Map<String, dynamic>)['error'] as String?
            : 'Unknown error';
        throw Exception('Segmind API failed (${response.statusCode}): $errorMessage');
      }
    } catch (e) {
      print('Segmind outfit generation error: $e');
      rethrow;
    }
  }
}

