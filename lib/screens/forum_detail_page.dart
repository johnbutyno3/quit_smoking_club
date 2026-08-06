import 'package:flutter/material.dart';
import '../repositories/forum_repository.dart';
import '../l10n/app_localizations.dart';
import '../models/forum_post.dart';
import '../services/coin_service.dart';
import '../repositories/coin/coin_repository.dart';

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
  final ForumRepository _forumRepository = ForumRepository();

  final TextEditingController _commentController = TextEditingController();

  final CoinRepository _coinRepository = CoinRepository(
    coinService: CoinService(),
  );
  List<Map<String, dynamic>> _comments = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      final comments = await _forumRepository.fetchComments(widget.post.id);

      if (!mounted) return;

      setState(() {
        _comments = comments;
        _loading = false;
      });
    } catch (e) {
      debugPrint('讀取留言失敗: $e');

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  Future<bool> _payComment() async {
    return await _coinRepository.spendCoin(1, 'forum_comment');
  }

  Future<void> _sendComment() async {
    final l10n = AppLocalizations.of(context)!;
    final text = _commentController.text.trim();

    if (text.isEmpty) return;

    final success = await _payComment();

    if (!mounted) return;

    if (!success) {
      _showCoinDialog(text);
      return;
    }

    try {
      await _forumRepository.addComment(
        userId: widget.currentUid ?? '',
        nickname: widget.currentUserName,
        postId: widget.post.id,
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
      debugPrint('留言寫入失敗: $e');

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

          content: Text(AppLocalizations.of(context)!.forumCommentNeedsOneCoin),

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
              onPressed: () {
                Navigator.pop(dialogContext);
              },

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
      await _forumRepository.addComment(
        userId: widget.currentUid ?? '',
        nickname: widget.currentUserName,
        postId: widget.post.id,
        content: text,
      );

      await _loadComments();

      _commentController.clear();
    } catch (e) {
      debugPrint('廣告留言失敗: $e');
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
          style: TextStyle(fontWeight: FontWeight.bold),
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

                        style: TextStyle(
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
                              style: TextStyle(color: Colors.grey),
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

            decoration: BoxDecoration(
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

                      border: OutlineInputBorder(),
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
