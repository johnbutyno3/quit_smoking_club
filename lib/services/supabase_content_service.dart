import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class SupabaseContentService {
  SupabaseContentService({SupabaseClient? client})
    : _client = client ?? SupabaseService.client;

  final SupabaseClient _client;

  static const String _table = 'content_items';

  Future<List<Map<String, dynamic>>> getContents({
    String? language,
    String? category,
  }) async {
    var query = _client.from(_table).select();

    if (language != null && language.isNotEmpty) {
      query = query.eq('language', language);
    }

    if (category != null && category.isNotEmpty) {
      query = query.eq('category', category);
    }

    final response = await query.order('unique_id');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createContent(Map<String, dynamic> data) async {
    await _client.from(_table).insert(data);
  }

  Future<void> updateContent(
    String uniqueId,
    Map<String, dynamic> data,
  ) async {
    await _client.from(_table).update(data).eq('unique_id', uniqueId);
  }

  Future<void> deleteContent(String uniqueId) async {
    await _client.from(_table).delete().eq('unique_id', uniqueId);
  }

  Future<Map<String, dynamic>?> getContentById(String uniqueId) async {
    final response = await _client
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
