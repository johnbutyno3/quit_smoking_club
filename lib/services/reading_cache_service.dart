import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/reading_book.dart';

class ReadingCacheService {
  static const _bookKeyPrefix = 'reading_book_v1_';
  static const _cachedIdsKey = 'reading_cached_book_ids_v1';

  Future<bool> contains(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('$_bookKeyPrefix$bookId');
  }

  Future<ReadingBook?> loadBook(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_bookKeyPrefix$bookId');
    if (raw == null) return null;
    try {
      return ReadingBook.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } on FormatException {
      return null;
    }
  }

  Future<List<ReadingBook>> loadCachedBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_cachedIdsKey) ?? const <String>[];
    final books = <ReadingBook>[];
    for (final id in ids) {
      final book = await loadBook(id);
      if (book != null) books.add(book);
    }
    return books;
  }

  Future<void> saveBook(ReadingBook book) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_cachedIdsKey) ?? <String>[];
    if (!ids.contains(book.id)) ids.add(book.id);
    await prefs.setString('$_bookKeyPrefix${book.id}', jsonEncode(book.toJson()));
    await prefs.setStringList(_cachedIdsKey, ids);
  }
}
