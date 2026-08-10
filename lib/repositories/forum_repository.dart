import '../models/forum_post.dart';
import '../services/supabase_comment_service.dart';
import '../services/supabase_forum_service.dart';
import '../services/supabase_like_service.dart';

class ForumRepository {
  Future<List<ForumPost>> fetchPosts() async {
    final data = await SupabaseForumService.getPosts();

    return data
        .map((item) => ForumPost.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
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
    return SupabaseCommentService.getComments(postId);
  }

  Future<void> addComment({
    required String postId,
    required String userId,
    required String nickname,
    required String content,
  }) {
    return SupabaseCommentService.createComment(
      userId: userId,
      nickname: nickname,
      postId: postId,
      content: content,
    );
  }

  Future<void> deleteComment(String commentId) {
    return SupabaseCommentService.deleteComment(commentId);
  }

  Future<bool> likePost({required String postId, required String userId}) async {
    final alreadyLiked = await SupabaseLikeService.hasLiked(
      userId: userId,
      postId: postId,
    );
    if (alreadyLiked) {
      return false;
    }

    await SupabaseLikeService.likePost(userId: userId, postId: postId);
    return true;
  }

  Future<void> giftPost(String postId) {
    return SupabaseForumService.giftPost(postId);
  }
}
