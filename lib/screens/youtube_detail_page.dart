import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../l10n/app_localizations.dart';
import '../models/youtube/youtube_item.dart';

class YouTubeDetailPage extends StatelessWidget {
  const YouTubeDetailPage({super.key, required this.item});

  final YouTubeItem item;

  Future<void> _openVideo(BuildContext context) async {
    final link = item.videoUrl.trim();
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
              if (item.thumbnailUrl.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      item.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                item.summary.isNotEmpty
                    ? item.summary
                    : l10n.medicalSummaryUnavailable,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Divider(height: 28),
              Text(l10n.youtubeVideoLabel, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 6),
              SelectableText(
                item.videoUrl,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              if (item.videoUrl.trim().isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _openVideo(context),
                    icon: const Icon(Icons.play_arrow),
                    label: Text(l10n.youtubeVideoLabel),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
