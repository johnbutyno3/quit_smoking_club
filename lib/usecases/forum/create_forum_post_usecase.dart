import '../../models/forum_post.dart';
import '../../repositories/forum_repository.dart';
import '../coin/coin_facade_usecase.dart';

class CreateForumPostUseCase {
  final ForumRepository forumRepository;
  final CoinFacadeUseCase coinFacadeUseCase;

  CreateForumPostUseCase({
    required this.forumRepository,
    required this.coinFacadeUseCase,
  });

  Future<void> execute({required ForumPost post, int cost = 30}) async {
    if (post.content.trim().isEmpty) {
      throw Exception('post_content_empty');
    }

    final spent = await coinFacadeUseCase.spend(cost, 'forum_create_post');

    if (!spent) {
      throw Exception('insufficient_coin');
    }

    try {
      await forumRepository.addPost(post);
    } catch (error) {
      try {
        await coinFacadeUseCase.addCoin(cost, 'forum_create_post_refund');
      } catch (refundError) {
        throw StateError(
          'forum_post_failed_and_coin_refund_failed: '
          '$error; refund=$refundError',
        );
      }
      rethrow;
    }
  }
}
