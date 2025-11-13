import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/outfit_history.dart';
import '../utils/constants.dart';

class SupabaseOutfitService {
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<String> generateOutfitViaEdgeFunction({
    required String selfieBase64,
    required String description,
    required int index,
  }) async {
    try {
      /** 
        Ensure user is authenticated and refresh session if needed
      */
      var session = _client.auth.currentSession;
      if (session == null) {
        /** 
          Check if user exists
        */
        final user = _client.auth.currentUser;
        if (user == null) {
          throw Exception('User must be authenticated to generate outfits');
        }
        /** 
          If user exists but no session, try to get it
        */
        session = _client.auth.currentSession;
        if (session == null) {
          throw Exception('Session not found. Please log in again.');
        }
      }

      /** 
        Ensure token is valid (refresh if expired)
      */
      if (session.isExpired) {
        final authResponse = await _client.auth.refreshSession();
        if (authResponse.session == null) {
          throw Exception('Session expired. Please log in again.');
        }
        session = authResponse.session!;
      }

      /** 
        Calling edge function with session: ${session.user.id}
        Access token present: ${session.accessToken.isNotEmpty}
      */
      final dio = Dio();
      final url = '${AppSecrets.supabaseUrl}/functions/v1/generate-outfit';
      
      final response = await dio.post(
        url,
        data: {
          'selfie_base64': selfieBase64,
          'description': description,
          'index': index,
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
        throw Exception('Edge function failed (${response.statusCode}): $errorMessage');
      }

    } catch (e) {
      print('Error calling edge function: $e');
      rethrow;
    }
  }

  /** 
    Save generated outfit to database
  */
  static Future<void> saveOutfit({
    required String userId,
    required String imageUrl,
    required String style,
    String? selfieUrl,
    String? paletteName,
    List<String>? paletteColors,
  }) async {
    try {
      await _client.from('outfits').insert({
        'user_id': userId,
        'image_url': imageUrl,
        'style': style,
        'selfie_url': selfieUrl,
        'palette_name': paletteName,
        'palette_colors': paletteColors,
      });
    } catch (e) {
      print('Error saving outfit: $e');
      rethrow;
    }
  }

  /** 
    Fetch user's outfit history
  */
  static Future<List<OutfitHistory>> getUserOutfits(String userId) async {
    try {
      final response = await _client
          .from('outfits')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => OutfitHistory.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching outfits: $e');
      return [];
    }
  }

  /** 
    Check if outfit already exists for this user/style combination
  */
  static Future<List<OutfitHistory>> getExistingOutfits({
    required String userId,
    required String style,
    String? paletteName,
  }) async {
    try {
      /** 
        Query the outfits table
      */
      var query = _client
          .from('outfits')
          .select()
          .eq('user_id', userId)
          .eq('style', style);

      if (paletteName != null) {
        query = query.eq('palette_name', paletteName);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => OutfitHistory.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error checking existing outfits: $e');
      return [];
    }
  }
}

