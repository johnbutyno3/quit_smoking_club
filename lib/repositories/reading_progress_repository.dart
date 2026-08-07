import '../models/reading_statistics.dart';
import '../services/reading_progress_service.dart';

class ReadingProgressRepository {
  final ReadingProgressService _service;

  ReadingProgressRepository({ReadingProgressService? service})
    : _service = service ?? ReadingProgressService();

  Future<ReadingStatistics> loadStatistics() => _service.loadStatistics();

  Future<bool> isChapterCompleted(String chapterId) =>
      _service.isChapterCompleted(chapterId);

  Future<bool> completeChapter({
    required String chapterId,
    required String bookId,
    required int seconds,
    required int words,
    required bool isLastChapter,
    required DateTime now,
  }) => _service.completeChapter(
    chapterId: chapterId,
    bookId: bookId,
    seconds: seconds,
    words: words,
    isLastChapter: isLastChapter,
    now: now,
  );
}
