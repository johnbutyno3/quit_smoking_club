import 'dart:convert';

class JsonExporter {
  static String export({
    required String title,
    required List<Map<String, dynamic>> chapters,
  }) {
    final totalWords = chapters.fold<int>(
      0,
      (sum, chapter) => sum + (chapter['wordCount'] as int),
    );
    return const JsonEncoder.withIndent('  ').convert({
      'title': title,
      'wordCount': totalWords,
      'chapters': chapters,
    });
  }
}
