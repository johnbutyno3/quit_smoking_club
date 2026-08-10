import '../models/forum_post.dart';
import '../services/supabase_forum_service.dart';
import '../services/supabase_service.dart';

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

  Future<List<Map<String, dynamic>>> fetchComments(String postId) {
    return SupabaseForumService.getComments(postId);
  }

  Future<void> addComment({
    required String postId,
    required String userId,
    required String nickname,
    required String content,
  }) {
    return SupabaseForumService.createComment(
      postId: postId,
      userId: userId,
      nickname: nickname,
      content: content,
    );
  }

  Future<void> deleteComment(String commentId) {
    return SupabaseForumService.deleteComment(commentId);
  }

  Future<void> likePost(String postId, {String? userId}) {
    final resolvedUserId = userId ?? SupabaseService.userId;
    if (resolvedUserId == null || resolvedUserId.isEmpty) {
      throw Exception('user_not_authenticated');
    }

    return SupabaseForumService.likePost(
      postId: postId,
      userId: resolvedUserId,
    );
  }

  /// Gift persistence is intentionally unavailable until the forum_gifts
  /// table is defined. Keep the repository API for existing UI compatibility.
  Future<void> giftPost(String postId, {String? userId}) async {
    return;
  }
}
