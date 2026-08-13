import '../../models/forum_post.dart';
import '../../repositories/coin/coin_repository.dart';
import '../../repositories/forum_repository.dart';
import '../coin/spend_coin_usecase.dart';

class CreateForumPostUseCase {
  final ForumRepository forumRepository;
  final SpendCoinUseCase spendCoinUseCase;
  final CoinRepository coinRepository;

  CreateForumPostUseCase({
    required this.forumRepository,
    required this.spendCoinUseCase,
    CoinRepository? coinRepository,
  }) : coinRepository = coinRepository ?? CoinRepository();

  Future<void> execute({required ForumPost post, int cost = 50}) async {
    if (post.content.trim().isEmpty) {
      throw Exception('post_content_empty');
    }

    final spent = await spendCoinUseCase.execute(cost, 'forum_create_post');
    if (!spent) {
      throw Exception('insufficient_coin');
    }

    try {
      await forumRepository.addPost(post);
    } catch (_) {
      await coinRepository.addCoin(cost, 'forum_create_post_refund');
      rethrow;
    }
  }
}
