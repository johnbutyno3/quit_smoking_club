import 'package:flutter/material.dart';
import '../models/forum_post.dart';
import '../services/forum_service.dart';
import '../services/storage_service.dart';
import '../services/user_service.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

// 🎨 論壇專用美工色彩：引入社群媒體簡約色調
class _ForumColors {
  static const bg = Color(0xFFF5F7F6); // 高級極簡灰白背景
  static const cardBg = Colors.white; // 純白懸浮卡片
  static const heart = Color(0xFFFF5252); // 亮粉紅按讚
  static const gift = Color(0xFFFF9100); // 暖橘送禮
}

class _ForumPageState extends State<ForumPage> {
  final ForumService _forumService = ForumService();
  final List<ForumPost> _posts = [];
  bool _isLoading = true;
  int _myCoins = 0;

  @override
  void initState() {
    super.initState();
    _loadForumData();
  }

  Future<void> _loadForumData() async {
    setState(() {
      _isLoading = true;
    });

    final coins = await StorageService.getCoins();
    final posts = await _forumService.fetchPosts();

    setState(() {
      _myCoins = coins;
      _posts.clear();
      _posts.addAll(posts);
      _isLoading = false;
    });
  }

  Future<void> _handleLike(int index) async {
    final post = _posts[index];
    await _forumService.likePost(post.id);
    setState(() {
      _posts[index] = post.copyWith(likes: post.likes + 1);
    });
  }

  Future<void> _handleSendGift(int index) async {
    if (_myCoins >= 5) {
      final latestCoins = _myCoins - 5;
      await StorageService.saveCoins(latestCoins);
      final uid = UserService.currentUid;
      if (uid != null) {
        try {
          await UserService().updateCoins(uid, latestCoins);
        } catch (_) {}
      }
      final post = _posts[index];
      await _forumService.giftPost(post.id);

      setState(() {
        _myCoins = latestCoins;
        _posts[index] = post.copyWith(gifts: post.gifts + 1);
      });
      _showSnack('🎁 成功花費 5 金幣送出冰鎮薄荷糖！');
    } else {
      _showSnack('❌ 金幣不足！請前往金幣商城儲值包！');
    }
  }

  Future<void> _showCreatePostDialog() async {
    final nameController = TextEditingController();
    final contentController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('創建新貼文'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '暱稱'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: '貼文內容'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim().isEmpty
                    ? '匿名朋友'
                    : nameController.text.trim();
                final content = contentController.text.trim();
                if (content.isEmpty) {
                  return;
                }

                if (_myCoins < 20) {
                  Navigator.pop(context);
                  _showSnack('❌ 金幣不足，創建貼文需要 20 金幣。');
                  return;
                }

                final latestCoins = _myCoins - 20;
                await StorageService.saveCoins(latestCoins);
                final uid = UserService.currentUid;
                if (uid != null) {
                  try {
                    await UserService().updateCoins(uid, latestCoins);
                  } catch (_) {}
                }
                final newPost = ForumPost(
                  id: '',
                  name: name,
                  createdAt: DateTime.now(),
                  content: content,
                  likes: 0,
                  gifts: 0,
                  isSOS: false,
                );

                await _forumService.addPost(newPost);
                if (context.mounted) Navigator.pop(context);
                await _loadForumData();
                _showSnack('✅ 成功扣除 20 金幣，貼文已發佈！');
              },
              child: const Text('發佈'),
            ),
          ],
        );
      },
    );
  }

  void _showSnack(String txt) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(txt)));
  }

  String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return '剛剛';
    if (diff.inHours < 1) return '${diff.inMinutes}分鐘前';
    if (diff.inDays < 1) return '${diff.inHours}小時前';
    return '${diff.inDays}天前';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ForumColors.bg,
      appBar: AppBar(
        title: const Text(
          '交流論壇',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: _showCreatePostDialog,
            tooltip: '創建貼文 (20 金幣)',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '我的剩餘金幣',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(
                    '$_myCoins 💎',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _posts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('目前尚無論壇貼文，快按右上角新增吧！'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _showCreatePostDialog,
                          child: const Text('建立第一則貼文'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      return Card(
                        color: _ForumColors.cardBg,
                        elevation: post.isSOS ? 4 : 2,
                        shadowColor: post.isSOS
                            ? Colors.redAccent.withAlpha(51)
                            : Colors.black12,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: post.isSOS
                                ? Colors.redAccent.withAlpha(77)
                                : Colors.grey.shade100,
                            width: post.isSOS ? 1.5 : 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.account_circle,
                                    size: 36,
                                    color: post.isSOS
                                        ? Colors.redAccent
                                        : Colors.grey.shade400,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          post.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: post.isSOS
                                                ? Colors.redAccent
                                                : Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          _getRelativeTime(post.createdAt),
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (post.isSOS)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        '🚨 求助文',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                post.content,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: Colors.grey.shade800,
                                  fontWeight: post.isSOS
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Divider(height: 1),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      foregroundColor: _ForumColors.heart,
                                    ),
                                    icon: const Icon(
                                      Icons.favorite_border,
                                      size: 18,
                                    ),
                                    label: Text(
                                      '${post.likes} 讚',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () => _handleLike(index),
                                  ),
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      foregroundColor: _ForumColors.gift,
                                    ),
                                    icon: const Icon(
                                      Icons.card_giftcard,
                                      size: 18,
                                    ),
                                    label: Text(
                                      '${post.gifts} 禮物',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () => _handleSendGift(index),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
