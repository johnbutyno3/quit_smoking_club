import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../l10n/app_localizations.dart';
import '../models/content/content_category.dart';
import '../models/content/content_item.dart';
import '../usecases/content/get_content_list_usecase.dart';

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
      final items = await _getContentListUseCase.execute(
        language: localeString,
        category: category,
      );

      if (!mounted) return;

      if (items.isEmpty) {
        final l10n = AppLocalizations.of(context)!;
        if (widget.title == 'Medical') {
          _setError(l10n.medicalLibraryTitle, l10n.medicalLibraryEmpty);
        } else {
          _setError(l10n.downloadFailed, l10n.medicalLibraryLoadFailed);
        }
        return;
      }

      _tips
        ..clear()
        ..addAll(items);
      final index = DateTime.now().millisecondsSinceEpoch % _tips.length;
      final selected = _tips[index];

      setState(() {
        _selectedTitle = selected.title;
        _selectedContent = selected.content;
        _selectedLink = selected.link;
      });
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      _setError(l10n.downloadFailed, l10n.medicalLibraryLoadFailed);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
    final currentIndex = _tips.indexWhere((item) => item.title == _selectedTitle);
    final next = _tips[(currentIndex < 0 ? 0 : currentIndex + 1) % _tips.length];
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

  Future<void> _openExternalLinkOrFallback() async {
    final actualLink = _selectedLink?.trim();
    if (actualLink == null || actualLink.isEmpty) return;

    var finalLink = actualLink;
    if (!actualLink.contains('://')) finalLink = 'https://$actualLink';
    final uri = Uri.tryParse(finalLink);
    if (uri == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.externalLinkInvalidFormat)),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: Colors.amber.shade100, width: 1),
              ),
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
                      if (_selectedTitle != null)
                        Text(
                          _selectedTitle!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      if (_selectedTitle != null) const SizedBox(height: 12),
                      if (_selectedContent != null)
                        Text(
                          _selectedContent!,
                          style: TextStyle(fontSize: 14, height: 1.6, color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                        ),
                      if (_selectedLink != null && _selectedLink!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _MitigateColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: _openExternalLinkOrFallback,
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canSwitchTip ? _MitigateColors.primary : Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: canSwitchTip ? _showNextTip : null,
                    child: Text(l10n.nextTip, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canSwitchTip ? _MitigateColors.primary : Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: canSwitchTip ? _showRandomTip : null,
                    child: Text(l10n.randomTip, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              icon: const Icon(Icons.check_circle_outline),
              label: Text(l10n.successfullySurvivedButton, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              onPressed: Navigator.of(context).pop,
            ),
            const SizedBox(height: 16),
            Text(l10n.cravingTip, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
