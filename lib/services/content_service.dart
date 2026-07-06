import 'dart:convert';
import 'package:flutter/services.dart';
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
      'unique_id': uniqueId,
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

  Future<void> _saveOverrideItemsLocally(List<ContentItem> items) async {
    final prefs = await _prefs;
    final jsonList = items.map((item) => item.toJson()).toList();
    await prefs.setString(_contentOverridesKey, json.encode(jsonList));
  }

  Future<List<ContentItem>> getContentItems(String category) async {
    final assetItems = await _loadAssetItems(category);
    final backendItems = await _loadBackendMockItems();
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
    final merged = <String, ContentItem>{};
    for (final item in overrideItems) {
      merged[item.uniqueId] = item;
    }
    return merged.values.toList();
  }

  Future<void> saveOverrideItems(List<ContentItem> items) async {
    await _saveOverrideItemsLocally(items);
  }

  Future<void> deleteOverrideItem(String uniqueId) async {
    final items = await _loadOverrideItems();
    final updated = items.where((item) => item.uniqueId != uniqueId).toList();
    await saveOverrideItems(updated);
  }

  Future<void> saveOverrideItem(ContentItem item) async {
    final items = await _loadOverrideItems();
    final updated = <String, ContentItem>{
      for (final existing in items) existing.uniqueId: existing,
    };
    updated[item.uniqueId] = item;
    await saveOverrideItems(updated.values.toList());
  }
}
