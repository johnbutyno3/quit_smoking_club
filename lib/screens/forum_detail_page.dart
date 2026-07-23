import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/forum_post.dart';
import '../services/coin_service.dart';

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
  final TextEditingController _commentController = TextEditingController();

  final CoinService coinService = CoinService();

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
      final snapshot = await FirebaseFirestore.instance
          .collection('forum_posts')
          .doc(widget.post.id)
          .collection('comments')
          .orderBy('created_at')
          .get();

      if (!mounted) return;

      setState(() {
        _comments = snapshot.docs.map((doc) => doc.data()).toList();

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
    return await coinService.spendCoin(1, '論壇留言');
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();

    if (text.isEmpty) return;

    final success = await _payComment();

    if (!mounted) return;

    if (!success) {
      _showCoinDialog(text);
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('forum_posts')
          .doc(widget.post.id)
          .collection('comments')
          .add({
            'content': text,
            'created_at': DateTime.now().toIso8601String(),
            'userName': widget.currentUserName,
          });

      await _loadComments();

      if (!mounted) return;

      _commentController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('留言成功，扣除 1 COIN'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('留言寫入失敗: $e');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('留言失敗')));
    }
  }

  void _showCoinDialog(String text) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('COIN不足'),

          content: const Text('留言需要 1 COIN'),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                _watchAdComment(text);
              },

              child: const Text('觀看廣告留言'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('前往 COIN 商城')));
              },

              child: const Text('購買 COIN'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },

              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _watchAdComment(String text) async {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('觀看廣告中...'), duration: Duration(seconds: 2)),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      await FirebaseFirestore.instance
          .collection('forum_posts')
          .doc(widget.post.id)
          .collection('comments')
          .add({
            'content': text,

            'created_at': DateTime.now().toIso8601String(),

            'userName': widget.currentUserName,
          });

      await _loadComments();

      _commentController.clear();
    } catch (e) {
      debugPrint('廣告留言失敗: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '文章詳情',
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

                      const Text(
                        '留言',

                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      if (_comments.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),

                            child: Text(
                              '目前沒有留言',
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

                                title: Text(comment['userName'] ?? '匿名'),

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

                    decoration: const InputDecoration(
                      hintText: '輸入留言...',

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
