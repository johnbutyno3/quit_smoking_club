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

  Future<List<ContentItem>> getReadingContents({String? language}) async {
    final books = await _readingService.listBooks(language: language);
    return books.map(_fromReadingBook).toList(growable: false);
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
