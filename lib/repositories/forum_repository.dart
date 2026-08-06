import '../models/forum_post.dart';
import '../services/supabase_forum_service.dart';

class ForumRepository {
  Future<List<ForumPost>> fetchPosts() async {
    final data = await SupabaseForumService.getPosts();

    return data
        .map((item) => ForumPost.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> addPost(ForumPost post) async {
    await SupabaseForumService.createPost(
      userId: post.userId,
      nickname: post.nickname,
      title: post.title,
      content: post.content,
      category: post.category,
    );
  }

  Future<void> deletePost(String postId) async {
    await SupabaseForumService.deletePost(postId);
  }

  Future<List<Map<String, dynamic>>> fetchComments(String postId) async {
    // SupabaseForumService currently does not implement comments API.
    // Return empty list as a safe fallback to avoid analyze/runtime errors.
    return <Map<String, dynamic>>[];
  }

  Future<void> addComment({
    required String postId,
    required String userId,
    required String nickname,
    required String content,
  }) async {
    // Comments are not yet implemented in SupabaseForumService.
    // Keep as no-op to preserve UI behavior and avoid throwing.
    return;
  }

  Future<void> deleteComment(String commentId) async {
    // Not implemented in SupabaseForumService yet.
    return;
  }

  Future<void> likePost(String postId) async {
    // Like action is not implemented in SupabaseForumService; no-op.
    return;
  }

  Future<void> giftPost(String postId) async {
    // Gift action is not implemented in SupabaseForumService; no-op.
    return;
  }
}
