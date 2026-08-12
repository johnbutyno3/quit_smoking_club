import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../services/content_service.dart';
import '../services/content_service_firebase.dart';
import 'package:quit_smoking_club/firebase_config.dart';
import 'game_hub_page.dart';

class MitigationPage extends StatefulWidget {
  final String title;
  const MitigationPage({super.key, required this.title});

  @override
  State<MitigationPage> createState() => _MitigationPageState();
}

class _MitigateColors {
  static const bgTop = Color(0xFFFFF8E1);
  static const bgBot = Color(0xFFFAFAFA);
  static const primary = Color(0xFFE65100);
  static const cardBg = Colors.white;
}

class _MitigationPageState extends State<MitigationPage> {
  final List<ContentItem> _tips = [];
  final dynamic _contentService = firebaseEnabled ? ContentServiceFirebase() : ContentService();
  String? _selectedTitle;
  String? _selectedContent;
  String? _selectedLink;
  bool _isLoading = false;
  bool _hasError = false;

  bool get _isGameHub => widget.title == 'Games' || widget.title == 'GameHub';

  @override
  void initState() {
    super.initState();
    if (!_isGameHub) {
      _loadCategoryData();
    }
  }

  Future<void> _loadCategoryData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final localeString = WidgetsBinding.instance.platformDispatcher.locale.toString().toLowerCase().replaceAll('_', '-');
      final items = await _contentService.getContentForCategoryAndLocale(widget.title, localeString);

      if (items.isEmpty) {
        if (widget.title == 'Medical') {
          _setError('醫學常識暫無資料', '請稍後更新或切換語言，並確保資料中包含內容。');
        } else {
          _setError('資料讀取失敗', '未能找到「${widget.title}」的對應內容，請確認內容資料是否完整。');
        }
        return;
      }

      _tips
        ..clear()
        ..addAll(items);
      final index = DateTime.now().millisecondsSinceEpoch % _tips.length;
      final selected = _tips[index];
      if (!mounted) return;
      setState(() {
        _selectedTitle = selected.title;
        _selectedContent = selected.content;
        _selectedLink = selected.link;
      });
    } catch (error) {
      if (mounted) _setError('資料載入失敗', '讀取資料時發生錯誤：$error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    var currentIndex = _tips.indexWhere((item) => item.title == _selectedTitle);
    if (currentIndex < 0) currentIndex = 0;
    final next = _tips[(currentIndex + 1) % _tips.length];
    setState(() {
      _selectedTitle = next.title;
      _selectedContent = next.content;
      _selectedLink = next.link;
    });
  }

  void _showRandomTip() {
    if (_tips.isEmpty) return;
    final selected = _tips[Random().nextInt(_tips.length)];
    setState(() {
      _selectedTitle = selected.title;
      _selectedContent = selected.content;
      _selectedLink = selected.link;
    });
  }

  Future<void> _openExternalLink() async {
    final actualLink = _selectedLink?.trim();
    if (actualLink == null || actualLink.isEmpty) return;
    final finalLink = actualLink.contains('://') ? actualLink : 'https://$actualLink';
    final uri = Uri.tryParse(finalLink);
    if (uri == null) return;

    try {
      final launched = await launchUrlString(finalLink, mode: LaunchMode.externalApplication).timeout(const Duration(seconds: 10), onTimeout: () => false);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('外部連結無法開啟。')));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('外部連結開啟失敗。')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isGameHub) {
      return const GameHubPage();
    }

    final canSwitchTip = !_isLoading && !_hasError && _tips.isNotEmpty;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_MitigateColors.bgTop, _MitigateColors.bgBot]),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('${widget.title} 危機緩解中', style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white.withAlpha(204),
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Card(
              color: _MitigateColors.cardBg,
              elevation: 6,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.amber.shade100)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Icon(Icons.spa, size: 48, color: _MitigateColors.primary)),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      if (_selectedTitle != null) Text(_selectedTitle!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      if (_selectedTitle != null) const SizedBox(height: 12),
                      if (_selectedContent != null) Text(_selectedContent!, style: TextStyle(fontSize: 14, height: 1.6, color: Colors.grey.shade800, fontWeight: FontWeight.w500)),
                      if (_selectedLink != null && _selectedLink!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: _MitigateColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                            onPressed: _openExternalLink,
                            child: Text(_selectedLink!, overflow: TextOverflow.ellipsis, maxLines: 1),
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
                    style: ElevatedButton.styleFrom(backgroundColor: canSwitchTip ? _MitigateColors.primary : Colors.grey.shade400, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    onPressed: canSwitchTip ? _showNextTip : null,
                    child: const Text('下一則', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: canSwitchTip ? _MitigateColors.primary : Colors.grey.shade400, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    onPressed: canSwitchTip ? _showRandomTip : null,
                    child: const Text('隨機', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: _MitigateColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 4),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('🟢 我成功撐過去了！', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
            const Text('💡 提示：菸癮犯了時，深呼吸 3 次可以大幅緩解不適喔！', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
