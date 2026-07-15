import '../models/forum_post.dart';
import '../services/forum_service.dart';

class ForumRepository {
  final ForumService _service;

  ForumRepository({ForumService? service})
    : _service = service ?? ForumService();

  Future<List<ForumPost>> fetchPosts() async {
    return await _service.fetchPosts();
  }

  Future<void> addPost(ForumPost post) async {
    await _service.addPost(post);
  }

  Future<void> likePost(String id) async {
    await _service.likePost(id);
  }

  Future<void> giftPost(String id) async {
    await _service.giftPost(id);
  }
}
