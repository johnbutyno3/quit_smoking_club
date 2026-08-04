import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/youtube/youtube_item.dart';
import '../repositories/youtube_repository.dart';
import '../widgets/youtube/youtube_card.dart';
import 'youtube_detail_page.dart';

class YouTubeLibraryPage extends StatefulWidget {
  const YouTubeLibraryPage({super.key});

  @override
  State<YouTubeLibraryPage> createState() => _YouTubeLibraryPageState();
}

class _YouTubeLibraryPageState extends State<YouTubeLibraryPage> {
  final YouTubeRepository _repository = YouTubeRepository();

  late Future<List<YouTubeItem>> _items;

  @override
  void initState() {
    super.initState();
    _items = _repository.getYouTubeItems();
  }

  void _reload() {
    setState(() {
      _items = _repository.getYouTubeItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: const Text('YouTube')),
      body: FutureBuilder<List<YouTubeItem>>(
        future: _items,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    const Text('Failed to load YouTube content.'),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _reload,
                      child: Text(l10n.refresh),
                    ),
                  ],
                ),
              ),
            );
          }

          final items = snapshot.data ?? const <YouTubeItem>[];

          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.smart_display_outlined, size: 48),
                    const SizedBox(height: 12),
                    const Text('No YouTube content available.'),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _reload,
                      child: Text(l10n.refresh),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => YouTubeDetailPage(item: item),
                    ),
                  ),
                  child: YouTubeCard(item: item),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
