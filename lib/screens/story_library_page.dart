import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/story/story_item.dart';
import '../repositories/story_repository.dart';
import '../widgets/story/story_card.dart';
import 'story_detail_page.dart';

class StoryLibraryPage extends StatefulWidget {
  const StoryLibraryPage({super.key});

  @override
  State<StoryLibraryPage> createState() => _StoryLibraryPageState();
}

class _StoryLibraryPageState extends State<StoryLibraryPage> {
  final StoryRepository _repository = StoryRepository();

  late Future<List<StoryItem>> _stories;

  @override
  void initState() {
    super.initState();
    _stories = _repository.getStories();
  }

  void _reload() {
    setState(() {
      _stories = _repository.getStories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.storyLibraryTitle)),
      body: FutureBuilder<List<StoryItem>>(
        future: _stories,
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
                    Text(l10n.storyLibraryLoadFailed),
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

          final stories = snapshot.data ?? const <StoryItem>[];

          if (stories.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_stories_outlined, size: 48),
                    const SizedBox(height: 12),
                    Text(l10n.storyLibraryEmpty),
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
              itemCount: stories.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final story = stories[index];
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StoryDetailPage(story: story),
                    ),
                  ),
                  child: StoryCard(story: story),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
