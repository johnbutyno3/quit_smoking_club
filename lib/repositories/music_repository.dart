import '../models/content/content_item.dart';
import '../models/music/music_item.dart';
import 'content/content_repository.dart';

class MusicRepository {
  MusicRepository({ContentRepository? contentRepository})
    : _contentRepository = contentRepository ?? ContentRepository();

  final ContentRepository _contentRepository;

  Future<List<MusicItem>> getMusicItems() async {
    final items = await _contentRepository.getMusicContents();
    return items.map(_toMusicItem).toList(growable: false);
  }

  MusicItem _toMusicItem(ContentItem item) {
    final resolvedId = item.id.isNotEmpty ? item.id : item.uniqueId;
    return MusicItem(
      id: resolvedId,
      title: item.title,
      summary: item.content,
      category: item.category.name,
      language: item.language,
      description: item.content,
      link: item.link,
    );
  }
}
