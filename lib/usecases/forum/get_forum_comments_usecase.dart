import '../../repositories/forum_repository.dart';

class GetForumCommentsUseCase {
  GetForumCommentsUseCase({ForumRepository? repository})
    : _repository = repository ?? ForumRepository();

  final ForumRepository _repository;

  Future<List<Map<String, dynamic>>> execute(String postId) {
    return _repository.fetchComments(postId);
  }
}
