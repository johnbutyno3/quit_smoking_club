import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/story/story_item.dart';

class StoryCard extends StatelessWidget {
  const StoryCard({super.key, required this.story});

  final StoryItem story;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(story.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              story.summary.isNotEmpty
                  ? story.summary
                  : l10n.storySummaryUnavailable,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
