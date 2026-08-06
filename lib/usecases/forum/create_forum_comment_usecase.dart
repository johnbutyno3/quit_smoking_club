import '../../repositories/forum_repository.dart';
import '../coin/spend_coin_usecase.dart';

class CreateForumCommentUseCase {
  final ForumRepository forumRepository;
  final SpendCoinUseCase spendCoinUseCase;

  CreateForumCommentUseCase({
    required this.forumRepository,
    required this.spendCoinUseCase,
  });

  Future<void> execute({
    required String postId,
    required String userId,
    required String nickname,
    required String content,
    int cost = 1,
  }) async {
    if (content.trim().isEmpty) {
      throw Exception('comment_content_empty');
    }

    final spent = await spendCoinUseCase.execute(cost, 'forum_comment');

    if (!spent) {
      throw Exception('insufficient_coin');
    }

    await forumRepository.addComment(
      postId: postId,
      userId: userId,
      nickname: nickname,
      content: content,
    );
  }
}
