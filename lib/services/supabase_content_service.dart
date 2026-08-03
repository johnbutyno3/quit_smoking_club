import 'supabase_service.dart';

class SupabaseContentService {
  static Future<List<Map<String, dynamic>>> getContents({
    String? language,
    String? category,
  }) async {
    var query = SupabaseService.client.from('content_items').select();

    if (language != null) {
      query = query.eq('language', language);
    }

    if (category != null) {
      query = query.eq('category', category);
    }

    final response = await query.order('unique_id');

    return List<Map<String, dynamic>>.from(response);
  }
}
