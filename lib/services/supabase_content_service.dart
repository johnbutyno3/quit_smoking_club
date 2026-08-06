import 'supabase_service.dart';

class SupabaseContentService {
  static const String _table = 'content_items';

  static Future<List<Map<String, dynamic>>> getContents({
    String? language,
    String? category,
  }) async {
    var query = SupabaseService.client.from(_table).select();

    if (language != null && language.isNotEmpty) {
      query = query.eq('language', language);
    }

    if (category != null && category.isNotEmpty) {
      query = query.eq('category', category);
    }

    final response = await query.order('unique_id');

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> createContent(Map<String, dynamic> data) async {
    await SupabaseService.client.from(_table).insert(data);
  }

  static Future<void> updateContent(
    String uniqueId,
    Map<String, dynamic> data,
  ) async {
    await SupabaseService.client
        .from(_table)
        .update(data)
        .eq('unique_id', uniqueId);
  }

  static Future<void> deleteContent(String uniqueId) async {
    await SupabaseService.client
        .from(_table)
        .delete()
        .eq('unique_id', uniqueId);
  }

  static Future<Map<String, dynamic>?> getContentById(String uniqueId) async {
    final response = await SupabaseService.client
        .from(_table)
        .select()
        .eq('unique_id', uniqueId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Map<String, dynamic>.from(response);
  }
}
