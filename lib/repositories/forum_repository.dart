import '../models/forum_post.dart';
import '../services/supabase_comment_service.dart';
import '../services/supabase_forum_service.dart';

class ForumRepository {
  Future<List<ForumPost>> fetchPosts() async {
    final rows = await SupabaseForumService.getPosts();

    return rows.map((row) {
      return ForumPost(
        id: row['id'] ?? '',
        name: row['nickname'] ?? '',
        content: row['content'] ?? '',
        createdAt:
            DateTime.tryParse(row['created_at']?.toString() ?? '') ??
            DateTime.now(),
        likes: row['likes'] ?? 0,
        gifts: row['gifts'] ?? 0,
        isSOS: row['is_sos'] ?? false,
      );
    }).toList();
  }

  Future<void> addPost(ForumPost post) async {
    // V3 後續接 Supabase 發文
  }

  Future<void> likePost(String id) async {
    // V3 後續接 Supabase like
  }

  Future<void> giftPost(String id) async {
    // V3 後續接 coin gift
  }

  Future<List<Map<String, dynamic>>> fetchComments(String postId) async {
    return SupabaseCommentService.getComments(postId);
  }

  Future<void> addComment({
    required String userId,
    required String nickname,
    required String postId,
    required String content,
  }) async {
    await SupabaseCommentService.createComment(
      userId: userId,
      nickname: nickname,
      postId: postId,
      content: content,
    );
  }

  Future<void> deleteComment(String commentId) async {
    await SupabaseCommentService.deleteComment(commentId);
  }
}
