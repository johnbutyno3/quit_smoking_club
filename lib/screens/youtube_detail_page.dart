import 'package:flutter/material.dart';

import '../models/youtube/youtube_item.dart';

class YouTubeDetailPage extends StatelessWidget {
  const YouTubeDetailPage({super.key, required this.item});

  final YouTubeItem item;

  @override
  Widget build(BuildContext context) {
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
                    : 'No summary available.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Divider(height: 28),
              Text('Video link', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 6),
              SelectableText(
                item.videoUrl,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
