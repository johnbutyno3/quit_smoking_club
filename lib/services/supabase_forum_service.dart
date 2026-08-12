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

  static Future<List<Map<String, dynamic>>> getComments(
    String postId,
  ) async {
    final response = await SupabaseService.client
        .from('forum_comments')
        .select()
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> createComment({
    required String postId,
    required String userId,
    required String nickname,
    required String content,
  }) async {
    await SupabaseService.client.from('forum_comments').insert({
      'post_id': postId,
      'user_id': userId,
      'nickname': nickname,
      'content': content,
    });
  }

  static Future<void> deleteComment(String commentId) async {
    await SupabaseService.client
        .from('forum_comments')
        .delete()
        .eq('id', commentId);
  }

  /// Toggles the current user's like and returns true when the post is liked
  /// after the operation, or false when the like was removed.
  static Future<bool> likePost({
    required String postId,
    required String userId,
  }) async {
    final existing = await SupabaseService.client
        .from('forum_likes')
        .select('id')
        .eq('post_id', postId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) {
      await SupabaseService.client
          .from('forum_likes')
          .delete()
          .eq('id', existing['id']);
      return false;
    }

    await SupabaseService.client.from('forum_likes').insert({
      'post_id': postId,
      'user_id': userId,
    });
    return true;
  }
}
