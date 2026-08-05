import '../models/content/content_category.dart';
import '../models/content/content_item.dart';
import '../models/story/story_item.dart';
import 'content/content_repository.dart';

class StoryRepository {
  StoryRepository({ContentRepository? contentRepository})
    : _contentRepository = contentRepository ?? ContentRepository();

  final ContentRepository _contentRepository;

  Future<List<StoryItem>> getStories() async {
    final items = await _contentRepository.getContents(
      category: ContentCategory.stories,
    );
    return items.map(_toStoryItem).toList(growable: false);
  }

  StoryItem _toStoryItem(ContentItem item) {
    final resolvedId = item.id.isNotEmpty ? item.id : item.uniqueId;
    return StoryItem(
      id: resolvedId,
      title: item.title,
      summary: item.content,
      category: item.category.name,
      language: item.language,
      content: item.content,
      sourceUrl: item.link,
    );
  }
}
