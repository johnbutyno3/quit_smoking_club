import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/forum_post.dart';
import '../repositories/forum_repository.dart';
import '../usecases/coin/coin_facade_usecase.dart';
import '../usecases/forum/create_forum_post_usecase.dart';
import '../usecases/forum/get_forum_posts_usecase.dart';
import '../usecases/user/get_current_user_usecase.dart';
import 'forum_detail_page.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumColors {
  static const bg = Color(0xFFF5F7F6);
  static const cardBg = Colors.white;
  static const heart = Color(0xFFFF5252);
  static const gift = Color(0xFFFF9100);
}

class _ForumPageState extends State<ForumPage> {
  final ForumRepository _forumRepository = ForumRepository();
  final GetForumPostsUseCase _getForumPostsUseCase = GetForumPostsUseCase();
  final CoinFacadeUseCase _coinFacadeUseCase = CoinFacadeUseCase();
  final GetCurrentUserUseCase _getCurrentUser = GetCurrentUserUseCase();
  final List<ForumPost> _posts = [];

  late final CreateForumPostUseCase _createForumPostUseCase =
      CreateForumPostUseCase(
        forumRepository: _forumRepository,
        coinFacadeUseCase: _coinFacadeUseCase,
      );

  bool _isLoading = true;
  int _myCoins = 0;
  int _selectedCategory = 0;

  static const _categories = [0, 1, 2, 3, 4];

  List<ForumPost> get _filteredPosts {
    if (_selectedCategory == 0) return _posts;
    if (_selectedCategory == 1) {
      return _posts.where((post) => post.isSOS).toList();
    }
    return _posts.where((post) => !post.isSOS).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadForumData();
  }

  Future<void> _loadForumData() async {
    if (mounted) setState(() => _isLoading = true);
    final coins = await _coinFacadeUseCase.getBalance();
    final posts = await _getForumPostsUseCase.execute();
    if (!mounted) return;
    setState(() {
      _myCoins = coins;
      _posts..clear()..addAll(posts);
      _isLoading = false;
    });
  }

  Future<void> _handleLike(ForumPost post) async {
    await _forumRepository.likePost(post.id);
    if (!mounted) return;
    final index = _posts.indexWhere((item) => item.id == post.id);
    if (index == -1) return;
    setState(() => _posts[index] = post.copyWith(likes: post.likes + 1));
  }

  Future<void> _handleSendGift(ForumPost post) async {
    final l10n = AppLocalizations.of(context)!;
    final success = await _coinFacadeUseCase.spend(5, '論壇送禮');
    if (!success) {
      if (mounted) _showSnack(l10n.forumInsufficientCoinsToGift);
      return;
    }
    await _forumRepository.giftPost(post.id);
    final latestCoins = await _coinFacadeUseCase.getBalance();
    if (!mounted) return;
    final index = _posts.indexWhere((item) => item.id == post.id);
    setState(() {
      _myCoins = latestCoins;
      if (index != -1) {
        _posts[index] = post.copyWith(gifts: post.gifts + 1);
      }
    });
    _showSnack(l10n.giftSent);
  }

  Future<void> _showCreatePostDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final contentController = TextEditingController();
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
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
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim().isEmpty
                    ? l10n.anonymousUser
                    : nameController.text.trim();
                final content = contentController.text.trim();
                if (content.isEmpty) return;
                final post = ForumPost(
                  id: '',
                  userId: _getCurrentUser.executeUid() ?? '',
                  name: name,
                  title: name,
                  category: '',
                  createdAt: DateTime.now(),
                  content: content,
                  likes: 0,
                  gifts: 0,
                  isSOS: false,
                );
                try {
                  await _createForumPostUseCase.execute(post: post);
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                  await _loadForumData();
                  if (mounted) _showSnack(l10n.postCreated);
                } catch (error) {
                  if (!dialogContext.mounted) return;
                  final message = error.toString().contains('insufficient_coin')
                      ? l10n.forumNeedCoinsToCreatePost
                      : error.toString();
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                }
              },
              child: Text(l10n.publish),
            ),
          ],
        ),
      );
    } finally {
      nameController.dispose();
      contentController.dispose();
    }
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  String _getRelativeTime(DateTime dateTime) {
    final l10n = AppLocalizations.of(context)!;
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return l10n.now;
    if (diff.inHours < 1) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return l10n.hoursAgo(diff.inHours);
    return l10n.daysAgo(diff.inDays);
  }

  String _categoryLabel(int categoryId) {
    final l10n = AppLocalizations.of(context)!;
    switch (categoryId) {
      case 0: return l10n.forumCategoryAll;
      case 1: return l10n.forumCategoryCraving;
      case 2: return l10n.forumCategoryStory;
      case 3: return l10n.forumCategoryHealth;
      case 4: return l10n.forumCategorySupport;
      default: return l10n.forumCategoryAll;
    }
  }

  Future<void> _openPost(ForumPost post) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ForumDetailPage(
          post: post,
          currentCoins: _myCoins,
          currentUserName: post.name,
          currentUid: _getCurrentUser.executeUid(),
        ),
      ),
    );
    if (!mounted) return;
    if (result is int) setState(() => _myCoins = result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final posts = _filteredPosts;
    return Scaffold(
      backgroundColor: _ForumColors.bg,
      appBar: AppBar(
        title: Text(l10n.forum, style: const TextStyle(fontWeight: FontWeight.bold)),
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
              itemBuilder: (_, index) {
                final category = _categories[index];
                final selected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8, bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF1B5E20) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _categoryLabel(category),
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.grey,
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
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
                  Text(l10n.myCoins, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text('$_myCoins 💎', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blue)),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : posts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.emptyForum),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: _showCreatePostDialog, child: Text(l10n.createPost)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _openPost(post),
                        child: Card(
                          color: _ForumColors.cardBg,
                          elevation: post.isSOS ? 4 : 2,
                          shadowColor: post.isSOS ? Colors.redAccent.withAlpha(51) : Colors.black12,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: post.isSOS ? Colors.redAccent.withAlpha(77) : Colors.grey.shade100,
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
                                    Icon(Icons.account_circle, size: 36, color: post.isSOS ? Colors.redAccent : Colors.grey.shade400),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(post.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: post.isSOS ? Colors.redAccent : Colors.black87)),
                                          Text(_getRelativeTime(post.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                    if (post.isSOS)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                                        child: Text('🚨 ${l10n.sosPost}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  post.content,
                                  style: TextStyle(fontSize: 13, height: 1.4, color: Colors.grey.shade800, fontWeight: post.isSOS ? FontWeight.w500 : FontWeight.normal),
                                ),
                                const SizedBox(height: 14),
                                const Divider(height: 1),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    TextButton.icon(
                                      style: TextButton.styleFrom(foregroundColor: _ForumColors.heart),
                                      icon: const Icon(Icons.favorite_border, size: 18),
                                      label: Text('${post.likes} ${l10n.like}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      onPressed: () => _handleLike(post),
                                    ),
                                    TextButton.icon(
                                      style: TextButton.styleFrom(foregroundColor: _ForumColors.gift),
                                      icon: const Icon(Icons.card_giftcard, size: 18),
                                      label: Text('${post.gifts} ${l10n.gift}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      onPressed: () => _handleSendGift(post),
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
