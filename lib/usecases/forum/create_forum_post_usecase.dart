import '../../models/forum_post.dart';
import '../../repositories/forum_repository.dart';
import '../coin/spend_coin_usecase.dart';

class CreateForumPostUseCase {
  final ForumRepository forumRepository;
  final SpendCoinUseCase spendCoinUseCase;

  CreateForumPostUseCase({
    required this.forumRepository,
    required this.spendCoinUseCase,
  });

  Future<void> execute({required ForumPost post, int cost = 30}) async {
    if (post.content.trim().isEmpty) {
      throw Exception('post_content_empty');
    }

    final spent = await spendCoinUseCase.execute(cost, 'forum_create_post');

    if (!spent) {
      throw Exception('insufficient_coin');
    }

    await forumRepository.addPost(post);
  }
}
