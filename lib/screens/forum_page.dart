import 'package:flutter/material.dart';
import '../models/forum_post.dart';
import '../repositories/forum_repository.dart';
import '../services/user_service.dart';
import 'forum_detail_page.dart';
import '../repositories/coin/coin_repository.dart';
import '../services/coin_service.dart';
import '../usecases/coin/get_coin_balance_usecase.dart';
import '../usecases/coin/spend_coin_usecase.dart';

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
  final ForumRepository _forumRepository = ForumRepository();

  final CoinRepository _coinRepository = CoinRepository(CoinService());

  late final GetCoinBalanceUseCase _getCoinBalanceUseCase =
      GetCoinBalanceUseCase(_coinRepository);

  late final SpendCoinUseCase _spendCoinUseCase = SpendCoinUseCase(
    _coinRepository,
  );
  final List<ForumPost> _posts = [];
  bool _isLoading = true;
  int _myCoins = 0;
  int _selectedCategory = 0; // 0=全部, 1=菸癮犯了, 2=心得分享, 3=健康交流, 4=互相鼓勵

  static const _categories = ['全部', '菸癮犯了', '戒菸心得', '健康交流', '互相鼓勵'];

  List<ForumPost> get _filteredPosts {
    if (_selectedCategory == 0) return _posts;
    if (_selectedCategory == 1) return _posts.where((p) => p.isSOS).toList();
    return _posts.where((p) => !p.isSOS).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadForumData();
  }

  Future<void> _loadForumData() async {
    setState(() {
      _isLoading = true;
    });

    final coins = await _getCoinBalanceUseCase.execute();
    final posts = await _forumRepository.fetchPosts();

    setState(() {
      _myCoins = coins;
      _posts.clear();
      _posts.addAll(posts);
      _isLoading = false;
    });
  }

  Future<void> _handleLike(int index) async {
    final post = _posts[index];
    await _forumRepository.likePost(post.id);
    setState(() {
      _posts[index] = post.copyWith(likes: post.likes + 1);
    });
  }

  Future<void> _handleSendGift(int index) async {
    if (_myCoins >= 5) {
      final latestCoins = _myCoins - 5;
      final success = await _spendCoinUseCase.execute(5, '論壇送禮');

      if (!success) {
        return;
      }
      final uid = UserService.currentUid;
      if (uid != null) {
        try {
          await UserService().updateCoins(uid, latestCoins);
        } catch (_) {}
      }
      final post = _posts[index];
      await _forumRepository.giftPost(post.id);
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
                if (_myCoins < 30) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('COIN不足，請前往商城購買 COIN')),
                  );
                  return;
                }

                final success = await _spendCoinUseCase.execute(
                  30,
                  'forum_create_post',
                );

                if (!success) {
                  return;
                }

                final latestCoins = await _getCoinBalanceUseCase.execute();
                if (!mounted) return;

                setState(() {
                  _myCoins = latestCoins;
                });
                final newPost = ForumPost(
                  id: '',
                  name: name,
                  createdAt: DateTime.now(),
                  content: content,
                  likes: 0,
                  gifts: 0,
                  isSOS: false,
                );
                await _forumRepository.addPost(newPost);
                if (context.mounted) Navigator.pop(context);
                await _loadForumData();
                _showSnack('✅ 成功扣除 1 金幣，貼文已發佈！');
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
        title: const Text('論壇', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: _showCreatePostDialog,
            tooltip: '創建貼文 (10 金幣)',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final selected = _selectedCategory == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8, bottom: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF1B5E20)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _categories[i],
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.grey,
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
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
                    itemCount: _filteredPosts.length, // 👈 改成用 _filteredPosts
                    itemBuilder: (context, index) {
                      final post =
                          _filteredPosts[index]; // 👈 這裡也改成用 _filteredPosts

                      // 💡 原本只有 return Card(
                      // 🛠️ 請直接手動改成在前面加上 GestureDetector 外殼：
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          // 👈 這裡加上 async
                          final result = await Navigator.push(
                            // 👈 加上 await 接收結果
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForumDetailPage(
                                post: post,
                                currentCoins: _myCoins,
                                currentUserName: post.name,
                                currentUid: UserService.currentUid,
                              ),
                            ),
                          );

                          // 👈 精簡判斷式，把重複或矛盾的 null 判定拿掉，解決 Dead code 警告
                          if (result != null && result is int) {
                            setState(() {
                              _myCoins = result; // 真正把內頁扣完的金幣同步更新回首頁
                            });
                          }
                        },

                        child: Card(
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
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
