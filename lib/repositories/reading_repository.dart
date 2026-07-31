import '../models/reading_book.dart';
import '../repositories/coin/coin_repository.dart';
import '../services/reading_cache_service.dart';
import '../services/supabase_reading_service.dart';

enum ReadingDownloadStatus { downloaded, alreadyCached, insufficientCoins }

class ReadingDownloadResult {
  const ReadingDownloadResult(this.status, {this.book});

  final ReadingDownloadStatus status;
  final ReadingBook? book;

  bool get isAvailable => book != null;
}

class ReadingRepository {
  ReadingRepository({
    SupabaseReadingService? remote,
    ReadingCacheService? cache,
    CoinRepository? coinRepository,
  })  : _remote = remote ?? SupabaseReadingService(),
        _cache = cache ?? ReadingCacheService(),
        _coinRepository = coinRepository ?? CoinRepository();

  final SupabaseReadingService _remote;
  final ReadingCacheService _cache;
  final CoinRepository _coinRepository;
  final Map<String, Future<ReadingDownloadResult>> _downloads = {};

  Future<List<ReadingBook>> listBooks({String? language}) async {
    final cachedBooks = await _cache.loadCachedBooks();
    try {
      final remoteBooks = await _remote.listBooks(language: language);
      final merged = <String, ReadingBook>{
        for (final book in cachedBooks) book.id: book,
        for (final book in remoteBooks) book.id: book,
      };
      return merged.values.toList();
    } catch (_) {
      return cachedBooks;
    }
  }

  Future<ReadingBook?> loadCachedBook(String bookId) => _cache.loadBook(bookId);

  Future<ReadingDownloadResult> downloadBook(ReadingBook summary) {
    return _downloads.putIfAbsent(summary.id, () async {
      try {
        final cached = await _cache.loadBook(summary.id);
        if (cached != null) {
          return ReadingDownloadResult(ReadingDownloadStatus.alreadyCached, book: cached);
        }
        final book = await _remote.loadBook(summary.id);
        if (book.chapters.isEmpty) {
          throw StateError('Reading book ${summary.id} has no chapters.');
        }
        if (book.downloadCoinCost > 0 &&
            !await _coinRepository.spendCoin(book.downloadCoinCost, 'reading_download:${book.id}')) {
          return const ReadingDownloadResult(ReadingDownloadStatus.insufficientCoins);
        }
        try {
          await _cache.saveBook(book);
        } catch (_) {
          // A failed cache write must not leave the user charged for an unusable book.
          if (book.downloadCoinCost > 0) {
            await _coinRepository.addCoin(book.downloadCoinCost, 'reading_download_refund:${book.id}');
          }
          rethrow;
        }
        return ReadingDownloadResult(ReadingDownloadStatus.downloaded, book: book);
      } finally {
        _downloads.remove(summary.id);
      }
    });
  }
}
