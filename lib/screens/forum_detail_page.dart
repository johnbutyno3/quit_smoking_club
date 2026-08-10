import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/forum_post.dart';
import '../repositories/coin/coin_repository.dart';
import '../repositories/forum_repository.dart';
import '../usecases/coin/spend_coin_usecase.dart';
import '../usecases/forum/create_forum_comment_usecase.dart';
import '../usecases/forum/get_forum_comments_usecase.dart';

class ForumDetailPage extends StatefulWidget {
  final ForumPost post;
  final int currentCoins;
  final String currentUserName;
  final String? currentUid;

  const ForumDetailPage({
    super.key,
    required this.post,
    required this.currentCoins,
    required this.currentUserName,
    this.currentUid,
  });

  @override
  State<ForumDetailPage> createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage> {
  late final GetForumCommentsUseCase _getForumCommentsUseCase;
  late final CreateForumCommentUseCase _createForumCommentUseCase;

  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    final forumRepository = ForumRepository();
    final spendCoinUseCase = SpendCoinUseCase(CoinRepository());

    _getForumCommentsUseCase = GetForumCommentsUseCase(
      repository: forumRepository,
    );
    _createForumCommentUseCase = CreateForumCommentUseCase(
      forumRepository: forumRepository,
      spendCoinUseCase: spendCoinUseCase,
    );

    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      final comments = await _getForumCommentsUseCase.execute(widget.post.id);

      if (!mounted) return;

      setState(() {
        _comments = comments;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Failed to load forum comments: $e');

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _sendComment() async {
    final l10n = AppLocalizations.of(context)!;
    final text = _commentController.text.trim();

    if (text.isEmpty) return;

    try {
      await _createForumCommentUseCase.execute(
        postId: widget.post.id,
        userId: widget.currentUid ?? '',
        nickname: widget.currentUserName,
        content: text,
      );

      await _loadComments();

      if (!mounted) return;

      _commentController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.forumCommentSuccessCostOneCoin),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      if (e.toString().contains('insufficient_coin')) {
        _showCoinDialog(text);
        return;
      }

      debugPrint('Failed to create forum comment: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.forumCommentFailed)));
    }
  }

  void _showCoinDialog(String text) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.insufficientCoins),
          content: Text(
            AppLocalizations.of(context)!.forumCommentNeedsOneCoin,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _watchAdComment(text);
              },
              child: Text(AppLocalizations.of(context)!.forumWatchAdComment),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.forumGoToCoinShop,
                    ),
                  ),
                );
              },
              child: Text(AppLocalizations.of(context)!.forumBuyCoin),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        );
      },
    );
  }

  Future<void> _watchAdComment(String text) async {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.forumWatchingAd),
        duration: const Duration(seconds: 2),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      final forumRepository = ForumRepository();
      await forumRepository.addComment(
        userId: widget.currentUid ?? '',
        nickname: widget.currentUserName,
        postId: widget.post.id,
        content: text,
      );

      await _loadComments();
      _commentController.clear();
    } catch (e) {
      debugPrint('Failed to create ad-sponsored forum comment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final post = widget.post;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.forumPostDetailTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.account_circle,
                            size: 40,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            post.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        post.content,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 25),
                      const Divider(),
                      Text(
                        l10n.forumComments,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_comments.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              l10n.forumNoComments,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _comments.length,
                          itemBuilder: (context, index) {
                            final comment = _comments[index];
                            return Card(
                              child: ListTile(
                                leading: const Icon(
                                  Icons.account_circle,
                                  color: Colors.grey,
                                ),
                                title: Text(
                                  comment['userName'] ?? l10n.anonymousUser,
                                ),
                                subtitle: Text(comment['content'] ?? ''),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: l10n.forumCommentHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
