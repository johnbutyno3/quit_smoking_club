import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/story/story_item.dart';

class StoryDetailPage extends StatelessWidget {
  const StoryDetailPage({super.key, required this.story});

  final StoryItem story;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(story.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                story.summary.isNotEmpty
                    ? story.summary
                    : l10n.storySummaryUnavailable,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Divider(height: 28),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    story.content.isNotEmpty
                        ? story.content
                        : l10n.storySummaryUnavailable,
                    style: const TextStyle(fontSize: 18, height: 1.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
