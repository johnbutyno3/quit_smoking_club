import '../models/content/content_item.dart';
import '../models/content/content_category.dart';
import '../models/youtube/youtube_item.dart';
import 'content/content_repository.dart';

class YouTubeRepository {
  YouTubeRepository({ContentRepository? contentRepository})
    : _contentRepository = contentRepository ?? ContentRepository();

  final ContentRepository _contentRepository;

  Future<List<YouTubeItem>> getYouTubeItems() async {
    final items = await _contentRepository.getContents(
      category: ContentCategory.youtube,
    );
    return items.map(_toYouTubeItem).toList(growable: false);
  }

  YouTubeItem _toYouTubeItem(ContentItem item) {
    final resolvedId = item.id.isNotEmpty ? item.id : item.uniqueId;
    return YouTubeItem(
      id: resolvedId,
      title: item.title,
      summary: item.content,
      videoUrl: item.link,
      thumbnailUrl: _thumbnailFromVideoUrl(item.link),
      category: item.category.name,
      language: item.language,
    );
  }

  String _thumbnailFromVideoUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return '';

    final host = uri.host.toLowerCase();
    String? videoId;

    if (host.contains('youtube.com')) {
      videoId = uri.queryParameters['v'];
      if ((videoId == null || videoId.isEmpty) && uri.pathSegments.isNotEmpty) {
        final index = uri.pathSegments.indexOf('shorts');
        if (index != -1 && index + 1 < uri.pathSegments.length) {
          videoId = uri.pathSegments[index + 1];
        }
      }
    } else if (host == 'youtu.be' && uri.pathSegments.isNotEmpty) {
      videoId = uri.pathSegments.first;
    }

    if (videoId == null || videoId.isEmpty) return '';
    return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
  }
}
