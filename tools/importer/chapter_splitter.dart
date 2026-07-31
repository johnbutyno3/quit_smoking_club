class ImportedChapter {
  const ImportedChapter({
    required this.number,
    required this.title,
    required this.content,
  });

  final int number;
  final String title;
  final String content;
}

class ChapterSplitter {
  static final RegExp _heading = RegExp(
    r'^\s*(?:chapter\s+\d+|第\s*\d+\s*[章回節]|#\s+.+)$',
    caseSensitive: false,
    multiLine: true,
  );

  static List<ImportedChapter> split(String source) {
    final text = source.replaceAll('\r\n', '\n').trim();
    if (text.isEmpty) return const [];
    final matches = _heading.allMatches(text).toList();
    if (matches.isEmpty) {
      return [ImportedChapter(number: 1, title: '正文', content: text)];
    }

    final chapters = <ImportedChapter>[];
    for (var index = 0; index < matches.length; index++) {
      final match = matches[index];
      final end = index + 1 < matches.length ? matches[index + 1].start : text.length;
      final content = text.substring(match.end, end).trim();
      if (content.isNotEmpty) {
        chapters.add(ImportedChapter(
          number: chapters.length + 1,
          title: match.group(0)!.trim(),
          content: content,
        ));
      }
    }
    return chapters.isEmpty
        ? [ImportedChapter(number: 1, title: '正文', content: text)]
        : chapters;
  }
}
