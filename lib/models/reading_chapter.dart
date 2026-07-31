class ReadingChapter {
  const ReadingChapter({
    required this.id,
    required this.bookId,
    required this.order,
    required this.title,
    required this.content,
    required this.wordCount,
  });

  final String id;
  final String bookId;
  final int order;
  final String title;
  final String content;
  final int wordCount;

  int get effectiveSeconds => (wordCount / 4).ceil().clamp(20, 300).toInt();

  factory ReadingChapter.fromJson(Map<String, dynamic> json, {String? bookId}) {
    final content = json['content']?.toString() ?? '';
    final words = (json['word_count'] ?? json['wordCount']) as num?;
    return ReadingChapter(
      id: json['id']?.toString() ?? '${bookId ?? json['book_id']}_${json['chapter'] ?? json['order'] ?? 1}',
      bookId: bookId ?? json['book_id']?.toString() ?? '',
      order: ((json['chapter'] ?? json['chapter_order'] ?? json['order'] ?? 1) as num).toInt(),
      title: json['title']?.toString() ?? '正文',
      content: content,
      wordCount: words?.toInt() ?? _countWords(content),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'book_id': bookId,
        'chapter_order': order,
        'title': title,
        'content': content,
        'word_count': wordCount,
      };

  static int _countWords(String content) =>
      RegExp(r"[A-Za-z0-9]+(?:['’-][A-Za-z0-9]+)*").allMatches(content).length +
      RegExp(r'[\u3400-\u9fff]').allMatches(content).length;
}
