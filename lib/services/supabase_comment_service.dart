import 'supabase_service.dart';

class SupabaseCommentService {
  static Future<List<Map<String, dynamic>>> getComments(String postId) async {
    final response = await SupabaseService.client
        .from('forum_comments')
        .select()
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> createComment({
    required String userId,
    required String nickname,
    required String postId,
    required String content,
  }) async {
    await SupabaseService.client.from('forum_comments').insert({
      'user_id': userId,
      'nickname': nickname,
      'post_id': postId,
      'content': content,
    });
  }

  static Future<void> deleteComment(String commentId) async {
    await SupabaseService.client
        .from('forum_comments')
        .delete()
        .eq('id', commentId);
  }
}
