import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/forum_post.dart';
import '../repositories/forum_repository.dart';
import 'forum_detail_page.dart';
import '../usecases/coin/coin_facade_usecase.dart';
import '../usecases/user/get_current_user_usecase.dart';

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

  late final CoinFacadeUseCase _coinFacadeUseCase = CoinFacadeUseCase();
  final GetCurrentUserUseCase _getCurrentUser = GetCurrentUserUseCase();
  final List<ForumPost> _posts = [];
  bool _isLoading = true;
  int _myCoins = 0;
  int _selectedCategory = 0; // 0=全部, 1=菸癮犯了, 2=心得分享, 3=健康交流, 4=互相鼓勵

  static const _categories = [0, 1, 2, 3, 4];
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

    final coins = await _coinFacadeUseCase.getBalance();
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
    final l10n = AppLocalizations.of(context)!;
    if (_myCoins >= 5) {
      final latestCoins = _myCoins - 5;
      final success = await _coinFacadeUseCase.spend(5, '論壇送禮');

      if (!success) {
        return;
      }

      final post = _posts[index];
      await _forumRepository.giftPost(post.id);
      setState(() {
        _myCoins = latestCoins;
        _posts[index] = post.copyWith(gifts: post.gifts + 1);
      });
      _showSnack(l10n.giftSent);
    } else {
      _showSnack(l10n.forumInsufficientCoinsToGift);
    }
  }

  Future<void> _showCreatePostDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final contentController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.forumCreatePostTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: l10n.postName),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 4,
                decoration: InputDecoration(labelText: l10n.postContent),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim().isEmpty
                    ? l10n.anonymousUser
                    : nameController.text.trim();
                final content = contentController.text.trim();
                if (content.isEmpty) {
                  return;
                }
                if (_myCoins < 30) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.forumNeedCoinsToCreatePost)),
                  );
                  return;
                }

                final success = await _coinFacadeUseCase.spend(
                  30,
                  'forum_create_post',
                );

                if (!success) {
                  return;
                }

                final latestCoins = await _coinFacadeUseCase.getBalance();
                if (!mounted) return;

                setState(() {
                  _myCoins = latestCoins;
                });
                final newPost = ForumPost(
                  id: '',
                  userId: _getCurrentUser.executeUid() ?? '',
                  // 新 UI 仍填入使用者輸入的顯示名稱（向下相容 name -> nickname）
                  name: name,
                  // 沒有 title/category 欄位輸入時使用合理預設
                  title: name,
                  category: '',
                  createdAt: DateTime.now(),
                  content: content,
                  likes: 0,
                  gifts: 0,
                  isSOS: false,
                );
                await _forumRepository.addPost(newPost);
                if (context.mounted) Navigator.pop(context);
                await _loadForumData();
                if (!mounted) return;
                _showSnack(l10n.postCreated);
              },
              child: Text(l10n.publish),
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
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return l10n.now;
    if (diff.inHours < 1) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return l10n.hoursAgo(diff.inHours);
    return l10n.daysAgo(diff.inDays);
  }

  String _categoryLabel(int categoryId) {
    final l10n = AppLocalizations.of(context)!;
    switch (categoryId) {
      case 0:
        return l10n.forumCategoryAll;
      case 1:
        return l10n.forumCategoryCraving;
      case 2:
        return l10n.forumCategoryStory;
      case 3:
        return l10n.forumCategoryHealth;
      case 4:
        return l10n.forumCategorySupport;
      default:
        return l10n.forumCategoryAll;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _ForumColors.bg,
      appBar: AppBar(
        title: Text(
          l10n.forum,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: _showCreatePostDialog,
            tooltip: l10n.createPost,
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
                      _categoryLabel(_categories[i]),
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
                  Text(
                    l10n.myCoins,
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
                        Text(l10n.emptyForum),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _showCreatePostDialog,
                          child: Text(l10n.createPost),
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
                                currentUid: _getCurrentUser.executeUid(),
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
                                        child: Text(
                                          '🚨 ${l10n.sosPost}',
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
                                        '${post.likes} ${l10n.like}',
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
                                        '${post.gifts} ${l10n.gift}',
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
