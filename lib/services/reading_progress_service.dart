import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/reading_statistics.dart';

class ReadingProgressService {
  static const _statisticsKey = 'reading_statistics_v1';
  static const _completedChaptersKey = 'reading_completed_chapters_v1';
  static const _completedBooksKey = 'reading_completed_books_v1';
  static const _dailyKey = 'reading_statistics_day_v1';
  static const _monthlyKey = 'reading_statistics_month_v1';

  Future<ReadingStatistics> loadStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_statisticsKey);
    if (raw == null) return const ReadingStatistics();
    try {
      return ReadingStatistics.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } on FormatException {
      return const ReadingStatistics();
    }
  }

  Future<bool> isChapterCompleted(String chapterId) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_completedChaptersKey) ?? const []).contains(
      chapterId,
    );
  }

  Future<bool> completeChapter({
    required String chapterId,
    required String bookId,
    required int seconds,
    required int words,
    required bool isLastChapter,
    required DateTime now,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final completedChapters =
        prefs.getStringList(_completedChaptersKey) ?? <String>[];
    if (completedChapters.contains(chapterId)) return false;

    var stats = await loadStatistics();
    final day = _dayKey(now);
    final month = _monthKey(now);
    if (prefs.getString(_dailyKey) != day) {
      stats = ReadingStatistics(
        dailySeconds: 0,
        monthlySeconds: stats.monthlySeconds,
        totalSeconds: stats.totalSeconds,
        dailyWords: 0,
        monthlyWords: stats.monthlyWords,
        totalWords: stats.totalWords,
        chaptersCompleted: stats.chaptersCompleted,
        booksCompleted: stats.booksCompleted,
      );
    }
    if (prefs.getString(_monthlyKey) != month) {
      stats = ReadingStatistics(
        dailySeconds: stats.dailySeconds,
        monthlySeconds: 0,
        totalSeconds: stats.totalSeconds,
        dailyWords: stats.dailyWords,
        monthlyWords: 0,
        totalWords: stats.totalWords,
        chaptersCompleted: stats.chaptersCompleted,
        booksCompleted: stats.booksCompleted,
      );
    }

    final completedBooks =
        prefs.getStringList(_completedBooksKey) ?? <String>[];
    final bookCompleted = isLastChapter && !completedBooks.contains(bookId);
    if (bookCompleted) completedBooks.add(bookId);
    completedChapters.add(chapterId);
    stats = stats.add(
      seconds: seconds,
      words: words,
      bookCompleted: bookCompleted,
    );
    await prefs.setStringList(_completedChaptersKey, completedChapters);
    await prefs.setStringList(_completedBooksKey, completedBooks);
    await prefs.setString(_statisticsKey, jsonEncode(stats.toJson()));
    await prefs.setString(_dailyKey, day);
    await prefs.setString(_monthlyKey, month);
    return true;
  }

  String _dayKey(DateTime value) => '${value.year}-${value.month}-${value.day}';
  String _monthKey(DateTime value) => '${value.year}-${value.month}';
}
