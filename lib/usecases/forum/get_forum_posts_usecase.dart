import '../../models/forum_post.dart';
import '../../repositories/forum_repository.dart';

class GetForumPostsUseCase {
  GetForumPostsUseCase({ForumRepository? repository})
    : _repository = repository ?? ForumRepository();

  final ForumRepository _repository;

  Future<List<ForumPost>> execute() {
    return _repository.fetchPosts();
  }
}
