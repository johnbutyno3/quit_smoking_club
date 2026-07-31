import 'reading_chapter.dart';

class ReadingBook {
  const ReadingBook({
    required this.id,
    required this.title,
    required this.chapters,
    this.author = '',
    this.language = 'zh-TW',
    this.description = '',
    this.downloadCoinCost = 0,
  });

  final String id;
  final String title;
  final String author;
  final String language;
  final String description;
  final int downloadCoinCost;
  final List<ReadingChapter> chapters;

  int get wordCount => chapters.fold(0, (sum, chapter) => sum + chapter.wordCount);

  factory ReadingBook.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final rawChapters = json['chapters'];
    return ReadingBook(
      id: id,
      title: json['title']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      language: json['language']?.toString() ?? 'zh-TW',
      description: json['description']?.toString() ?? '',
      downloadCoinCost: ((json['download_coin_cost'] ?? json['downloadCoinCost']) as num?)?.toInt() ?? 0,
      chapters: rawChapters is List
          ? rawChapters.whereType<Map>().map((item) => ReadingChapter.fromJson(Map<String, dynamic>.from(item), bookId: id)).toList()
          : const [],
    );
  }

  ReadingBook withChapters(List<ReadingChapter> value) => ReadingBook(
        id: id,
        title: title,
        author: author,
        language: language,
        description: description,
        downloadCoinCost: downloadCoinCost,
        chapters: value,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'language': language,
        'description': description,
        'download_coin_cost': downloadCoinCost,
        'chapters': chapters.map((chapter) => chapter.toJson()).toList(),
      };
}
