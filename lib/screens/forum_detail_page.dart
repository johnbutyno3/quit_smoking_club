import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/forum_post.dart';
import '../services/storage_service.dart';
import '../services/user_service.dart';

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

  List<dynamic> _comments = [];
  bool _isLoadingComments = true;
  late int _coins; // 本地追蹤金幣，避免每次都重讀

  @override
  void initState() {
    super.initState();
    _coins = widget.currentCoins;
    _loadComments();
  }

  // 扣除 1 金幣並同步到本機與 Firebase
  Future<void> _deductOneCoin() async {
    final newCoins = (_coins - 1).clamp(0, 999999);
    setState(() => _coins = newCoins);
    await StorageService.saveCoins(newCoins);
    final uid = widget.currentUid ?? UserService.currentUid;
    if (uid != null) {
      try {
        await UserService().updateCoins(uid, newCoins);
      } catch (e) {
        debugPrint('扣幣同步 Firebase 失敗: $e');
      }
    }
  }

  // 核心：從 Firebase 撈取歷史留言
  Future<void> _loadComments() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('forum_posts')
          .doc(widget.post.id)
          .collection('comments')
          .orderBy('created_at', descending: false)
          .get();

      setState(() {
        _comments = snapshot.docs.map((doc) => doc.data()).toList();

        _isLoadingComments = false;
      });
    } catch (e) {
      setState(() => _isLoadingComments = false);
      debugPrint("撈取留言失敗: $e");
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
        elevation: 0,
      ),
      body: Column(
        children: [
          // 上半部：文章主體與留言列表
          Expanded(
            child: _isLoadingComments
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // 使用者頭像與名稱
                      Row(
                        children: [
                          const Icon(
                            Icons.account_circle,
                            size: 40,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const Text(
                                '剛剛',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 文章內文
                      Text(
                        post.content,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),

                      // 留言標題
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          '熱門留言',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      // 留言卡片列表（自動讀取 Firebase 資料）
                      _comments.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: Text(
                                  '目前尚無留言，快來搶沙發吧！',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _comments.length,
                              itemBuilder: (context, commentIndex) {
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.account_circle,
                                          size: 28,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _comments[commentIndex]['userName'] ??
                                                    '熱心朋友',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _comments[commentIndex]['content'] ??
                                                    '',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
          ),

          // 下半部：固定在底部的輸入留言欄位
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: '說點什麼來鼓勵他吧...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () async {
                    String commentText = _commentController.text.trim();
                    if (commentText.isEmpty) return;

                    if (_coins >= 1) {
                      try {
                        final messenger = ScaffoldMessenger.of(context);
                        // 1. 寫入留言到 Firebase
                        await FirebaseFirestore.instance
                            .collection('forum_posts')
                            .doc(widget.post.id)
                            .collection('comments')
                            .add({
                              'content': commentText,
                              'created_at': DateTime.now().toIso8601String(),
                              'userName': widget.currentUserName,
                            });

                        // 2. 扣除 1 金幣並同步
                        await _deductOneCoin();

                        _loadComments();
                        _commentController.clear();

                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('💬 留言成功！已扣除 1 金幣'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        debugPrint('❌ Firebase 儲存失敗: $e');
                      }
                    } else {
                      // 金幣不足跳出彈窗
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.orange,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '金幣餘額不足',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            content: const Text('留言需要花費 1 金幣。您可以透過以下方式繼續：'),
                            actionsAlignment: MainAxisAlignment.spaceBetween,
                            actions: [
                              TextButton.icon(
                                icon: const Icon(
                                  Icons.ondemand_video,
                                  color: Colors.green,
                                ),
                                label: const Text(
                                  '看廣告免費留言',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  final messenger = ScaffoldMessenger.of(context);
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('🎬 廣告播放中...（請等待2秒）'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  Future.delayed(
                                    const Duration(seconds: 2),
                                    () async {
                                      if (!mounted) return;
                                      try {
                                        // 2. 看廣告留言：免扣幣，但也正式寫入真實姓名與內容到 Firebase
                                        await FirebaseFirestore.instance
                                            .collection('forum_posts')
                                            .doc(widget.post.id)
                                            .collection('comments')
                                            .add({
                                              'content': commentText,
                                              'created_at': DateTime.now()
                                                  .toIso8601String(),
                                              'userName': widget
                                                  .currentUserName, // 使用真實登入名字
                                            });

                                        // 看完廣告也秒速重新整理
                                        _loadComments();
                                        _commentController.clear();

                                        messenger.showSnackBar(
                                          const SnackBar(
                                            content: Text('🎉 廣告觀看完成！留言已儲存'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } catch (e) {
                                        debugPrint('廣告留言寫入失敗: $e');
                                      }
                                    },
                                  );
                                },
                              ),
                              TextButton.icon(
                                icon: const Icon(
                                  Icons.add_shopping_cart,
                                  color: Colors.blue,
                                ),
                                label: const Text(
                                  '前往購買金幣',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('🛒 正在前往金幣商城...'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
