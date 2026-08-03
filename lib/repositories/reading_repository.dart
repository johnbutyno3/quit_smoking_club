import '../models/content/content_item.dart';
import '../models/reading_book.dart';
import '../repositories/content/content_repository.dart';
import '../repositories/coin/coin_repository.dart';
import '../services/reading_cache_service.dart';

enum ReadingDownloadStatus { downloaded, alreadyCached, insufficientCoins }

class ReadingDownloadResult {
  const ReadingDownloadResult(this.status, {this.book});

  final ReadingDownloadStatus status;
  final ReadingBook? book;

  bool get isAvailable => book != null;
}

class ReadingRepository {
  ReadingRepository({
    ContentRepository? contentRepository,
    ReadingCacheService? cache,
    CoinRepository? coinRepository,
  }) : _contentRepository = contentRepository ?? ContentRepository(),
       _cache = cache ?? ReadingCacheService(),
       _coinRepository = coinRepository ?? CoinRepository();

  final ContentRepository _contentRepository;
  final ReadingCacheService _cache;
  final CoinRepository _coinRepository;
  final Map<String, Future<ReadingDownloadResult>> _downloads = {};

  Future<List<ReadingBook>> listBooks({String? language}) async {
    final cachedBooks = await _cache.loadCachedBooks();
    try {
      final contentItems = await _contentRepository.getReadingContents(
        language: language,
      );
      final remoteBooks = contentItems
          .map(_toReadingBook)
          .toList(growable: false);
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
          return ReadingDownloadResult(
            ReadingDownloadStatus.alreadyCached,
            book: cached,
          );
        }
        final book = await _contentRepository.loadReadingBook(summary.id);
        if (book.chapters.isEmpty) {
          throw StateError('Reading book ${summary.id} has no chapters.');
        }
        if (book.downloadCoinCost > 0 &&
            !await _coinRepository.spendCoin(
              book.downloadCoinCost,
              'reading_download:${book.id}',
            )) {
          return const ReadingDownloadResult(
            ReadingDownloadStatus.insufficientCoins,
          );
        }
        try {
          await _cache.saveBook(book);
        } catch (_) {
          // A failed cache write must not leave the user charged for an unusable book.
          if (book.downloadCoinCost > 0) {
            await _coinRepository.addCoin(
              book.downloadCoinCost,
              'reading_download_refund:${book.id}',
            );
          }
          rethrow;
        }
        return ReadingDownloadResult(
          ReadingDownloadStatus.downloaded,
          book: book,
        );
      } finally {
        _downloads.remove(summary.id);
      }
    });
  }

  ReadingBook _toReadingBook(ContentItem item) {
    final resolvedId = item.id.isNotEmpty ? item.id : item.uniqueId;
    return ReadingBook(
      id: resolvedId,
      title: item.title,
      author: item.author,
      language: item.language,
      description: item.content,
      downloadCoinCost: item.downloadCoinCost,
      chapters: const [],
    );
  }
}
