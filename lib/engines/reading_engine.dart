import '../models/reading_book.dart';
import '../models/reading_chapter.dart';
import '../models/reading_statistics.dart';
import '../services/reading_progress_service.dart';

enum ChapterCompletionStatus { completed, alreadyCompleted, tooEarly }

class ChapterCompletionResult {
  const ChapterCompletionResult(this.status, {this.remainingSeconds = 0});

  final ChapterCompletionStatus status;
  final int remainingSeconds;
}

/// Applies the anti-farming rules from QSC_READING_SPEC. The screen owns the
/// timer display, but completion is only recorded after manual continuation.
class ReadingEngine {
  ReadingEngine({ReadingProgressService? progressService, DateTime Function()? now})
      : _progressService = progressService ?? ReadingProgressService(),
        _now = now ?? DateTime.now;

  final ReadingProgressService _progressService;
  final DateTime Function() _now;
  final Map<String, DateTime> _openedAt = {};

  void openChapter(ReadingChapter chapter) {
    _openedAt.putIfAbsent(chapter.id, _now);
  }

  int remainingSeconds(ReadingChapter chapter) {
    final openedAt = _openedAt[chapter.id];
    if (openedAt == null) return chapter.effectiveSeconds;
    final elapsed = _now().difference(openedAt).inSeconds;
    return (chapter.effectiveSeconds - elapsed)
        .clamp(0, chapter.effectiveSeconds)
        .toInt();
  }

  Future<ChapterCompletionResult> continueChapter({
    required ReadingBook book,
    required ReadingChapter chapter,
  }) async {
    if (await _progressService.isChapterCompleted(chapter.id)) {
      return const ChapterCompletionResult(ChapterCompletionStatus.alreadyCompleted);
    }
    final remaining = remainingSeconds(chapter);
    if (remaining > 0) {
      return ChapterCompletionResult(ChapterCompletionStatus.tooEarly, remainingSeconds: remaining);
    }
    final recorded = await _progressService.completeChapter(
      chapterId: chapter.id,
      bookId: book.id,
      seconds: chapter.effectiveSeconds,
      words: chapter.wordCount,
      isLastChapter: book.chapters.isNotEmpty && chapter.id == book.chapters.last.id,
      now: _now(),
    );
    _openedAt.remove(chapter.id);
    return ChapterCompletionResult(
      recorded ? ChapterCompletionStatus.completed : ChapterCompletionStatus.alreadyCompleted,
    );
  }

  Future<ReadingStatistics> statistics() => _progressService.loadStatistics();
}
