import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../l10n/app_localizations.dart';
import '../models/content/content_category.dart';
import '../models/content/content_item.dart';
import '../usecases/content/get_content_list_usecase.dart';
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
  final GetContentListUseCase _getContentListUseCase = GetContentListUseCase();
  String? _selectedTitle;
  String? _selectedContent;
  String? _selectedLink;
  bool _isLoading = false;
  bool _hasError = false;

  bool get _isGameHub =>
      widget.title.trim().toLowerCase() == 'games' ||
      widget.title.trim().toLowerCase() == 'gamehub';

  @override
  void initState() {
    super.initState();
    if (!_isGameHub) _loadCategoryData();
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
      final items = await _getContentListUseCase.execute(
        language: localeString,
        category: category,
      );

      if (!mounted) return;
      if (items.isEmpty) {
        final l10n = AppLocalizations.of(context)!;
        _setError(l10n.medicalLibraryTitle, l10n.medicalLibraryEmpty);
        return;
      }

      _tips
        ..clear()
        ..addAll(items);
      _pickRandomTip();
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      _setError(l10n.medicalLibraryTitle, l10n.medicalLibraryLoadFailed);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _setError(String title, String content) {
    setState(() {
      _hasError = true;
      _selectedTitle = title;
      _selectedContent = content;
      _selectedLink = null;
    });
  }

  void _pickRandomTip() {
    if (_tips.isEmpty) return;
    final tip = _tips[Random().nextInt(_tips.length)];
    setState(() {
      _selectedTitle = tip.title;
      _selectedContent = tip.content;
      _selectedLink = tip.link;
    });
  }

  Future<void> _openExternalLinkOrFallback() async {
    final finalLink = _selectedLink;
    if (finalLink == null || finalLink.isEmpty) return;
    try {
      final launched = await launchUrlString(
        finalLink,
        mode: LaunchMode.externalApplication,
      ).timeout(const Duration(seconds: 10), onTimeout: () => false);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.externalLinkOpenFailed)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.externalLinkOpenFailed)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isGameHub) return const GameHubPage();

    final l10n = AppLocalizations.of(context)!;
    final displayTitle = widget.title == 'Medical'
        ? l10n.healthKnowledge
        : widget.title;

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
          title: Text(displayTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Icon(Icons.health_and_safety_outlined, size: 48, color: _MitigateColors.primary)),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      if (_selectedTitle != null)
                        Text(_selectedTitle!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      if (_selectedTitle != null) const SizedBox(height: 12),
                      if (_selectedContent != null)
                        Text(_selectedContent!, style: TextStyle(fontSize: 14, height: 1.6, color: Colors.grey.shade800)),
                      if (_selectedLink != null && _selectedLink!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: ElevatedButton(
                            onPressed: _openExternalLinkOrFallback,
                            child: Text(_selectedLink!, overflow: TextOverflow.ellipsis, maxLines: 1),
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(child: OutlinedButton.icon(onPressed: _hasError ? _loadCategoryData : _pickRandomTip, icon: const Icon(Icons.refresh), label: Text(l10n.randomTip))),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
