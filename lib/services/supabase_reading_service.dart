import '../models/reading_book.dart';
import '../models/reading_chapter.dart';
import 'supabase_service.dart';

class SupabaseReadingService {
  Future<List<ReadingBook>> listBooks({String? language}) async {
    var query = SupabaseService.client
        .from('reading_books')
        .select()
        .eq('status', 'published');
    if (language != null) query = query.eq('language', language);
    final response = await query.order('title');
    return List<Map<String, dynamic>>.from(response)
        .map(ReadingBook.fromJson)
        .toList();
  }

  Future<ReadingBook> loadBook(String bookId) async {
    final response = await SupabaseService.client
        .from('reading_books')
        .select()
        .eq('id', bookId)
        .eq('status', 'published')
        .single();
    final book = ReadingBook.fromJson(Map<String, dynamic>.from(response));
    final chapterRows = await SupabaseService.client
        .from('reading_chapters')
        .select()
        .eq('book_id', bookId)
        .order('chapter_order');
    final chapters = List<Map<String, dynamic>>.from(chapterRows)
        .map((row) => ReadingChapter.fromJson(row, bookId: book.id))
        .toList();
    return book.withChapters(chapters);
  }
}
