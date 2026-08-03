import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/music/music_item.dart';

class MusicCard extends StatelessWidget {
  const MusicCard({super.key, required this.item});

  final MusicItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              item.summary.isNotEmpty
                  ? item.summary
                  : l10n.musicSummaryUnavailable,
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
