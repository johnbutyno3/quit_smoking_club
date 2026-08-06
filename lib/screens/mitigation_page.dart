import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../models/content/content_category.dart';
import '../models/content/content_item.dart';
import '../repositories/content/content_repository.dart';

import 'game_hub_page.dart';

class MitigationPage extends StatefulWidget {
  final String title;
  const MitigationPage({super.key, required this.title});

  @override
  State<MitigationPage> createState() => _MitigationPageState();
}

// 🎨 舒壓專用美工色彩：引入琥珀溫暖調性，洗去單調太空虛
class _MitigateColors {
  static const bgTop = Color(0xFFFFF8E1);
  static const bgBot = Color(0xFFFAFAFA);
  static const primary = Color(0xFFE65100);
  static const cardBg = Colors.white;
}

class _MitigationPageState extends State<MitigationPage> {
  final List<ContentItem> _tips = [];
  final ContentRepository _contentRepository = ContentRepository();

  String? _selectedTitle;
  String? _selectedContent;
  String? _selectedLink;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadCategoryData();
  }

  Future<void> _loadCategoryData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final localeString = WidgetsBinding.instance.platformDispatcher.locale
          .toString()
          .toLowerCase()
          .replaceAll('_', '-');
      final category = ContentCategoryParser.fromValue(widget.title);
      final items = await _contentRepository.getContents(
        language: localeString,
        category: category,
      );

      if (items.isEmpty) {
        if (widget.title == 'Medical') {
          _setError('醫學常識暫無資料', '請稍後更新或切換語言，並確保資料中包含 link。');
        } else {
          _setError(
            '資料讀取失敗',
            '未能找到「${widget.title}」的對應內容，請確認 Firebase 或本地資料是否完整。',
          );
        }
        return;
      }

      _tips.clear();
      _tips.addAll(items);
      final index = DateTime.now().millisecondsSinceEpoch % _tips.length;
      final selected = _tips[index];

      setState(() {
        _selectedTitle = selected.title;
        _selectedContent = selected.content;
        _selectedLink = selected.link;
      });
    } catch (error) {
      _setError('資料載入失敗', 'Firebase 讀取資料時發生錯誤：$error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setError(String title, String message) {
    setState(() {
      _hasError = true;
      _selectedTitle = title;
      _selectedContent = message;
      _selectedLink = null;
      _tips.clear();
      _isLoading = false;
    });
  }

  void _showNextTip() {
    if (_tips.isEmpty) return;
    final current = _selectedTitle;
    var currentIndex = _tips.indexWhere((item) => item.title == current);
    if (currentIndex < 0) {
      currentIndex = 0;
    }
    final next = _tips[(currentIndex + 1) % _tips.length];
    setState(() {
      _selectedTitle = next.title;
      _selectedContent = next.content;
      _selectedLink = next.link;
    });
  }

  void _showRandomTip() {
    if (_tips.isEmpty) return;
    final random = Random().nextInt(_tips.length);
    final selected = _tips[random];
    setState(() {
      _selectedTitle = selected.title;
      _selectedContent = selected.content;
      _selectedLink = selected.link;
    });
  }

  Future<void> _openExternalLinkOrFallback() async {
    if (_selectedLink == null || _selectedLink!.isEmpty) {
      return;
    }

    final uri = Uri.tryParse(_selectedLink!);
    if (uri == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('連結格式錯誤，已讀取內部資料。')));
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final actualLink = _selectedLink!.trim();
      var finalLink = actualLink;
      if (!actualLink.contains('://')) {
        finalLink = 'https://$actualLink';
      }
      final uri = Uri.tryParse(finalLink);
      if (uri == null) {
        throw Exception('連結格式無效。');
      }

      final launched = await launchUrlString(
        finalLink,
        mode: LaunchMode.externalApplication,
      ).timeout(const Duration(seconds: 10), onTimeout: () => false);

      if (!launched) {
        final fallbackLaunched = await launchUrlString(
          finalLink,
          mode: LaunchMode.platformDefault,
        ).timeout(const Duration(seconds: 10), onTimeout: () => false);

        if (!fallbackLaunched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('外部連結無法在 10 秒內開啟，已改為顯示內部內容。')),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('外部連結開啟失敗，已顯示內部資料。\n$error')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSwitchTip = !_isLoading && !_hasError && _tips.isNotEmpty;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_MitigateColors.bgTop, _MitigateColors.bgBot],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            '${widget.title} 危機緩解中',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white.withAlpha(204),
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // 遊戲大廳：頂部加入內建 2048 快捷卡片
            if (widget.title == 'Games') ...[
              _BuiltInGameCard(
                emoji: '🧩',
                title: '2048',
                subtitle: '滑動合併數字，挑戰 2048！離線可玩',
                color: const Color(0xFFEDC22E),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GameHubPage()),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  '🌐 線上遊戲推薦',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFFE65100),
                  ),
                ),
              ),
            ],
            Card(
              color: _MitigateColors.cardBg,
              elevation: 6,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: Colors.amber.shade100, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Icon(
                        Icons.spa,
                        size: 48,
                        color: _MitigateColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      if (_selectedTitle != null)
                        Text(
                          _selectedTitle!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (_selectedTitle != null) const SizedBox(height: 12),
                      if (widget.title != 'Stories' && _selectedContent != null)
                        Text(
                          _selectedContent!,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (_selectedLink != null &&
                          _selectedLink!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _MitigateColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _openExternalLinkOrFallback,
                            child: Text(
                              _selectedLink!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canSwitchTip
                          ? _MitigateColors.primary
                          : Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: canSwitchTip ? _showNextTip : null,
                    child: const Text(
                      '下一則',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canSwitchTip
                          ? _MitigateColors.primary
                          : Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: canSwitchTip ? _showRandomTip : null,
                    child: const Text(
                      '隨機',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _MitigateColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text(
                '🟢 我成功撐過去了！',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            const Text(
              '💡 提示：菸癮犯了時，深呼吸 3 次可以大幅緩解不適喔！',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 內建遊戲快捷卡片 ──────────────────────────────────────

class _BuiltInGameCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _BuiltInGameCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: color.withAlpha(80),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withAlpha(40), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withAlpha(50),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withAlpha(100), width: 1.5),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5E20).withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '✅ 完全內建 · 離線可玩',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF1B5E20),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
