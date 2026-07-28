import 'supabase_service.dart';

class SupabaseLikeService {
  static Future<void> likePost({
    required String userId,
    required String postId,
  }) async {
    await SupabaseService.client.from('forum_likes').insert({
      'user_id': userId,
      'post_id': postId,
    });
  }

  static Future<void> unlikePost({
    required String userId,
    required String postId,
  }) async {
    await SupabaseService.client
        .from('forum_likes')
        .delete()
        .eq('user_id', userId)
        .eq('post_id', postId);
  }

  static Future<int> getLikeCount(String postId) async {
    final response = await SupabaseService.client
        .from('forum_likes')
        .select()
        .eq('post_id', postId);

    return response.length;
  }

  static Future<bool> hasLiked({
    required String userId,
    required String postId,
  }) async {
    final response = await SupabaseService.client
        .from('forum_likes')
        .select()
        .eq('user_id', userId)
        .eq('post_id', postId);

    return response.isNotEmpty;
  }
}
