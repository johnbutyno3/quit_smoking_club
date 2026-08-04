import '../models/content/content_category.dart';
import '../models/content/content_item.dart';
import '../models/reading_book.dart';
import 'content/content_repository.dart' as source;

class ContentRepository {
  ContentRepository({source.ContentRepository? delegate})
    : _delegate = delegate ?? source.ContentRepository();

  final source.ContentRepository _delegate;

  Future<List<ContentItem>> getContents({
    String? language,
    ContentCategory? category,
  }) {
    return _delegate.getContents(language: language, category: category);
  }

  Future<List<ContentItem>> getReadingContents({String? language}) {
    return _delegate.getReadingContents(language: language);
  }

  Future<List<ContentItem>> getMusicContents() {
    return _delegate.getMusicContents();
  }

  Future<List<ContentItem>> getStoryContents() async {
    return getContents(category: ContentCategory.stories);
  }

  Future<List<ContentItem>> getMedicalContents() {
    return _delegate.getMedicalContents();
  }

  Future<List<ContentItem>> getYouTubeContents() {
    return getContents(category: ContentCategory.youtube);
  }

  Future<ReadingBook> loadReadingBook(String bookId) {
    return _delegate.loadReadingBook(bookId);
  }
}
