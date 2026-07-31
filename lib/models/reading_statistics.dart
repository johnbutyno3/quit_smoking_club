class ReadingStatistics {
  const ReadingStatistics({
    this.dailySeconds = 0,
    this.monthlySeconds = 0,
    this.totalSeconds = 0,
    this.dailyWords = 0,
    this.monthlyWords = 0,
    this.totalWords = 0,
    this.chaptersCompleted = 0,
    this.booksCompleted = 0,
  });

  final int dailySeconds;
  final int monthlySeconds;
  final int totalSeconds;
  final int dailyWords;
  final int monthlyWords;
  final int totalWords;
  final int chaptersCompleted;
  final int booksCompleted;

  ReadingStatistics add({required int seconds, required int words, required bool bookCompleted}) => ReadingStatistics(
        dailySeconds: dailySeconds + seconds,
        monthlySeconds: monthlySeconds + seconds,
        totalSeconds: totalSeconds + seconds,
        dailyWords: dailyWords + words,
        monthlyWords: monthlyWords + words,
        totalWords: totalWords + words,
        chaptersCompleted: chaptersCompleted + 1,
        booksCompleted: booksCompleted + (bookCompleted ? 1 : 0),
      );

  factory ReadingStatistics.fromJson(Map<String, dynamic> json) => ReadingStatistics(
        dailySeconds: (json['dailySeconds'] as num?)?.toInt() ?? 0,
        monthlySeconds: (json['monthlySeconds'] as num?)?.toInt() ?? 0,
        totalSeconds: (json['totalSeconds'] as num?)?.toInt() ?? 0,
        dailyWords: (json['dailyWords'] as num?)?.toInt() ?? 0,
        monthlyWords: (json['monthlyWords'] as num?)?.toInt() ?? 0,
        totalWords: (json['totalWords'] as num?)?.toInt() ?? 0,
        chaptersCompleted: (json['chaptersCompleted'] as num?)?.toInt() ?? 0,
        booksCompleted: (json['booksCompleted'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'dailySeconds': dailySeconds,
        'monthlySeconds': monthlySeconds,
        'totalSeconds': totalSeconds,
        'dailyWords': dailyWords,
        'monthlyWords': monthlyWords,
        'totalWords': totalWords,
        'chaptersCompleted': chaptersCompleted,
        'booksCompleted': booksCompleted,
      };
}
