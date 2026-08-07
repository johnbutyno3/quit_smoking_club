import '../models/reading_book.dart';
import '../services/reading_cache_service.dart';

class ReadingCacheRepository {
  final ReadingCacheService _service;

  ReadingCacheRepository({ReadingCacheService? service})
    : _service = service ?? ReadingCacheService();

  Future<bool> contains(String bookId) => _service.contains(bookId);

  Future<ReadingBook?> loadBook(String bookId) => _service.loadBook(bookId);

  Future<List<ReadingBook>> loadCachedBooks() => _service.loadCachedBooks();

  Future<void> saveBook(ReadingBook book) => _service.saveBook(book);
}
