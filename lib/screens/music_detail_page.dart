import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../l10n/app_localizations.dart';
import '../models/music/music_item.dart';

class MusicDetailPage extends StatelessWidget {
  const MusicDetailPage({super.key, required this.item});

  final MusicItem item;

  Future<void> _openMusic(BuildContext context) async {
    final link = item.link.trim();
    if (link.isEmpty) return;
    final url = link.contains('://') ? link : 'https://$link';
    try {
      final opened = await launchUrlString(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.externalLinkOpenFailed)),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.externalLinkOpenFailed)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.summary.isNotEmpty
                    ? item.summary
                    : l10n.musicSummaryUnavailable,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Divider(height: 28),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    item.description.isNotEmpty
                        ? item.description
                        : l10n.musicSummaryUnavailable,
                    style: const TextStyle(fontSize: 18, height: 1.8),
                  ),
                ),
              ),
              if (item.link.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.musicSourceLink,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                SelectableText(
                  item.link,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _openMusic(context),
                    icon: const Icon(Icons.play_arrow),
                    label: Text(l10n.musicLinkLabel),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
