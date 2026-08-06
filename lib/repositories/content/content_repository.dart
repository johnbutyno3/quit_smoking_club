import '../../models/content/content_category.dart';
import '../../models/content/content_item.dart';
import '../../models/reading_book.dart';
import '../../services/supabase_content_service.dart';
import '../../services/supabase_reading_service.dart';

class ContentRepository {
  ContentRepository({SupabaseReadingService? readingService})
    : _readingService = readingService ?? SupabaseReadingService();

  final SupabaseReadingService _readingService;

  Future<List<ContentItem>> getContents({
    String? language,
    ContentCategory? category,
  }) async {
    final rows = await SupabaseContentService.getContents(
      language: language,
      category: category?.name,
    );

    return rows.map(ContentItem.fromMap).toList(growable: false);
  }

  Future<ContentItem?> getContentById(String id) async {
    final row = await SupabaseContentService.getContentById(id);
    if (row == null) {
      return null;
    }

    return ContentItem.fromMap(row);
  }

  Future<void> saveContent(ContentItem item) async {
    final existing = await getContentById(item.uniqueId);
    final payload = item.toMap();

    if (existing == null) {
      await SupabaseContentService.createContent(payload);
      return;
    }

    await SupabaseContentService.updateContent(item.uniqueId, payload);
  }

  Future<void> deleteContent(String id) {
    return SupabaseContentService.deleteContent(id);
  }

  Future<List<ContentItem>> getReadingContents({String? language}) async {
    final books = await _readingService.listBooks(language: language);
    return books.map(_fromReadingBook).toList(growable: false);
  }

  Future<List<ContentItem>> getStoryContents() {
    return getContents(category: ContentCategory.stories);
  }

  Future<List<ContentItem>> getMusicContents() {
    return getContents(category: ContentCategory.music);
  }

  Future<List<ContentItem>> getYouTubeContents() {
    return getContents(category: ContentCategory.youtube);
  }

  Future<List<ContentItem>> getMedicalContents() async {
    return getContents(category: ContentCategory.medical);
  }

  Future<ReadingBook> loadReadingBook(String bookId) {
    return _readingService.loadBook(bookId);
  }

  ContentItem _fromReadingBook(ReadingBook book) {
    return ContentItem(
      id: book.id,
      title: book.title,
      category: ContentCategory.reading,
      language: book.language,
      content: book.description,
      link: '',
      author: book.author,
      downloadCoinCost: book.downloadCoinCost,
    );
  }
}
