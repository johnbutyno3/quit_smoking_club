import 'supabase_service.dart';

class SupabaseForumService {
  static Future<List<Map<String, dynamic>>> getPosts({String? category}) async {
    var query = SupabaseService.client.from('forum_posts').select();

    if (category != null) {
      query = query.eq('category', category);
    }

    final response = await query.order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> createPost({
    required String userId,
    required String nickname,
    required String title,
    required String content,
    required String category,
  }) async {
    await SupabaseService.client.from('forum_posts').insert({
      'user_id': userId,
      'nickname': nickname,
      'title': title,
      'content': content,
      'category': category,
      'coin_cost': 0,
    });
  }

  static Future<void> deletePost(String postId) async {
    await SupabaseService.client
        .from('forum_posts')
        .update({'is_deleted': true})
        .eq('id', postId);
  }
}
