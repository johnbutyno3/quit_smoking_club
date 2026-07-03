import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ContentItem {
  final String category;
  final String language;
  final String title;
  final String content;
  final String link;

  const ContentItem({
    required this.category,
    required this.language,
    required this.title,
    required this.content,
    required this.link,
  });

  String get uniqueId => '$category|$language|$title';

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      category: json['category']?.toString() ?? '',
      language: json['language']?.toString().toLowerCase() ?? 'all',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      link: json['link']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'language': language,
      'title': title,
      'content': content,
      'link': link,
    };
  }
}

class ContentService {
  static const _contentOverridesKey = 'content_overrides_v1';
  static const Map<String, String> _assetPaths = {
    'Medical': 'assets/medical_links.json',
    'Stories': 'assets/stories_data.json',
    'YouTube': 'assets/youtube_data.json',
    'Music': 'assets/music_data.json',
    'Games': 'assets/games_data.json',
  };

  static const String _backendMockAsset = 'assets/backend_content.json';
  static const String _remoteBaseUrl = 'https://your-backend.example.com/api';

  static bool get _remoteEnabled =>
      !_remoteBaseUrl.contains('your-backend.example.com');

  static Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  Future<List<ContentItem>> _loadAssetItems(String category) async {
    final assetPath = _assetPaths[category];
    if (assetPath == null) return [];
    final raw = await rootBundle.loadString(assetPath);
    final List<dynamic> data = json.decode(raw);
    return data
        .whereType<Map<String, dynamic>>()
        .map(ContentItem.fromJson)
        .where(
          (item) =>
              item.title.isNotEmpty &&
              item.content.isNotEmpty &&
              item.link.isNotEmpty,
        )
        .toList();
  }

  Future<List<ContentItem>> _loadOverrideItems() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_contentOverridesKey);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> data = json.decode(raw);
    return data
        .whereType<Map<String, dynamic>>()
        .map(ContentItem.fromJson)
        .where(
          (item) =>
              item.title.isNotEmpty &&
              item.content.isNotEmpty &&
              item.link.isNotEmpty,
        )
        .toList();
  }

  Future<List<ContentItem>> _loadBackendMockItems() async {
    try {
      final raw = await rootBundle.loadString(_backendMockAsset);
      final List<dynamic> data = json.decode(raw);
      return data
          .whereType<Map<String, dynamic>>()
          .map(ContentItem.fromJson)
          .where(
            (item) =>
                item.title.isNotEmpty &&
                item.content.isNotEmpty &&
                item.link.isNotEmpty,
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Uri _remoteUri(String path, [Map<String, String>? query]) {
    return Uri.parse('$_remoteBaseUrl$path').replace(queryParameters: query);
  }

  Future<List<ContentItem>> _loadRemoteItems(String category) async {
    if (!_remoteEnabled) return [];
    try {
      final response = await http
          .get(_remoteUri('/content', {'category': category}))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return [];
      final List<dynamic> data = json.decode(response.body);
      return data
          .whereType<Map<String, dynamic>>()
          .map(ContentItem.fromJson)
          .where(
            (item) =>
                item.title.isNotEmpty &&
                item.content.isNotEmpty &&
                item.link.isNotEmpty,
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _upsertRemoteItem(ContentItem item) async {
    if (!_remoteEnabled) return;
    try {
      await http
          .put(
            _remoteUri('/content'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(item.toJson()),
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      // Ignore cloud errors.
    }
  }

  Future<void> _deleteRemoteItem(String uniqueId) async {
    if (!_remoteEnabled) return;
    try {
      await http
          .delete(_remoteUri('/content/$uniqueId'))
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      // Ignore cloud errors.
    }
  }

  Future<List<ContentItem>> _loadAllCloudItems() async {
    if (!_remoteEnabled) return [];
    try {
      final response = await http
          .get(_remoteUri('/content'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return [];
      final List<dynamic> data = json.decode(response.body);
      return data
          .whereType<Map<String, dynamic>>()
          .map(ContentItem.fromJson)
          .where(
            (item) =>
                item.title.isNotEmpty &&
                item.content.isNotEmpty &&
                item.link.isNotEmpty,
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<ContentItem>> getContentItems(String category) async {
    final assetItems = await _loadAssetItems(category);
    final backendItems = await _loadBackendMockItems();
    final remoteItems = await _loadRemoteItems(category);
    final overrideItems = await _loadOverrideItems();
    final merged = <String, ContentItem>{};
    for (final item in assetItems) {
      merged[item.uniqueId] = item;
    }
    for (final item in backendItems.where(
      (item) => item.category == category,
    )) {
      merged[item.uniqueId] = item;
    }
    for (final item in remoteItems) {
      merged[item.uniqueId] = item;
    }
    for (final item in overrideItems.where(
      (item) => item.category == category,
    )) {
      merged[item.uniqueId] = item;
    }
    return merged.values.toList();
  }

  Future<List<ContentItem>> getContentForCategoryAndLocale(
    String category,
    String localeString,
  ) async {
    final items = await getContentItems(category);
    final normalized = localeString.toLowerCase().replaceAll('_', '-');
    final parts = normalized.split('-');
    final candidates = <String>{normalized};
    if (parts.length > 1) {
      candidates.add(parts.sublist(0, 2).join('-'));
    }
    candidates.add(parts.first);
    candidates.add('all');

    final filtered = items.where((item) {
      final language = item.language.toLowerCase();
      return candidates.contains(language);
    }).toList();

    if (filtered.isNotEmpty) {
      return filtered;
    }

    return items.where((item) => item.language.toLowerCase() == 'all').toList();
  }

  Future<List<ContentItem>> getAllOverrideItems() async {
    final overrideItems = await _loadOverrideItems();
    final cloudItems = await _loadAllCloudItems();
    final merged = <String, ContentItem>{};
    for (final item in overrideItems) {
      merged[item.uniqueId] = item;
    }
    for (final item in cloudItems) {
      merged[item.uniqueId] = item;
    }
    return merged.values.toList();
  }

  Future<void> saveOverrideItems(List<ContentItem> items) async {
    final prefs = await _prefs;
    final jsonList = items.map((item) => item.toJson()).toList();
    await prefs.setString(_contentOverridesKey, json.encode(jsonList));
    for (final item in items) {
      await _upsertRemoteItem(item);
    }
  }

  Future<void> deleteOverrideItem(String uniqueId) async {
    final items = await _loadOverrideItems();
    final updated = items.where((item) => item.uniqueId != uniqueId).toList();
    await saveOverrideItems(updated);
    await _deleteRemoteItem(uniqueId);
  }

  Future<void> saveOverrideItem(ContentItem item) async {
    final items = await _loadOverrideItems();
    final updated = <String, ContentItem>{
      for (final existing in items) existing.uniqueId: existing,
    };
    updated[item.uniqueId] = item;
    await saveOverrideItems(updated.values.toList());
    await _upsertRemoteItem(item);
  }
}
