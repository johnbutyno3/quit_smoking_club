import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/music/music_item.dart';
import '../repositories/music_repository.dart';
import '../widgets/music/music_card.dart';
import 'music_detail_page.dart';

class MusicLibraryPage extends StatefulWidget {
  const MusicLibraryPage({super.key});

  @override
  State<MusicLibraryPage> createState() => _MusicLibraryPageState();
}

class _MusicLibraryPageState extends State<MusicLibraryPage> {
  final MusicRepository _repository = MusicRepository();

  late Future<List<MusicItem>> _items;

  @override
  void initState() {
    super.initState();
    _items = _repository.getMusicItems();
  }

  void _reload() {
    setState(() {
      _items = _repository.getMusicItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.musicLibraryTitle)),
      body: FutureBuilder<List<MusicItem>>(
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
                    Text(l10n.musicLibraryLoadFailed),
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

          final items = snapshot.data ?? const <MusicItem>[];

          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.music_note_outlined, size: 48),
                    const SizedBox(height: 12),
                    Text(l10n.musicLibraryEmpty),
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
                      builder: (_) => MusicDetailPage(item: item),
                    ),
                  ),
                  child: MusicCard(item: item),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
