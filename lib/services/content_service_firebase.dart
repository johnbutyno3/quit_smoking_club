import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'content_service.dart';
import 'package:quit_smoking_club/firebase_config.dart';

class ContentServiceFirebase {
  static const _contentOverridesKey = 'content_overrides_v1';
  static const Map<String, String> _assetPaths = {
    'Medical': 'assets/medical_links.json',
    'Stories': 'assets/stories_data.json',
    'YouTube': 'assets/youtube_data.json',
    'Music': 'assets/music_data.json',
    'Games': 'assets/games_data.json',
  };

  static const String _backendMockAsset = 'assets/backend_content.json';
  static const String _collection = 'content_items';

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

  Future<List<ContentItem>> _loadRemoteItems(String category) async {
    if (!firebaseEnabled) return [];
    try {
      final qs = await FirebaseFirestore.instance
          .collection(_collection)
          .where('category', isEqualTo: category)
          .get();
      return qs.docs
          .map((d) => ContentItem.fromJson(d.data()))
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
    if (!firebaseEnabled) return;
    try {
      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(item.uniqueId)
          .set(item.toJson());
    } catch (_) {
      // ignore
    }
  }

  Future<void> _deleteRemoteItem(String uniqueId) async {
    if (!firebaseEnabled) return;
    try {
      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(uniqueId)
          .delete();
    } catch (_) {
      // ignore
    }
  }

  Future<List<ContentItem>> _loadAllCloudItems() async {
    if (!firebaseEnabled) return [];
    try {
      final qs = await FirebaseFirestore.instance.collection(_collection).get();
      return qs.docs
          .map((d) => ContentItem.fromJson(d.data()))
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

  Future<void> seedSampleContent() async {
    final sampleItems = <ContentItem>[
      ContentItem(
        category: 'Medical',
        language: 'all',
        title: 'Firebase Test Item',
        content: 'This item was created to verify Firebase connectivity.',
        link: 'https://firebase.google.com',
      ),
      ContentItem(
        category: 'Stories',
        language: 'all',
        title: 'Firebase 測試短文：堅持不抽菸的第一天',
        content: '這是一則測試短文，描述戒菸後第一天克服誘惑的真實心情。',
        link: 'https://www.healthline.com/health/how-to-quit-smoking',
      ),
      ContentItem(
        category: 'YouTube',
        language: 'all',
        title: 'Firebase 測試影片：戒菸動力短片',
        content: '請點擊下方連結觀看戒菸勵志影片。',
        link: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      ),
      ContentItem(
        category: 'Music',
        language: 'all',
        title: 'Firebase 測試音樂：放鬆心情的戒菸歌單',
        content: '這是一則測試音樂連結，用於驗證音樂類別是否能正確載入。',
        link: 'https://open.spotify.com/playlist/37i9dQZF1DX4sWSpwq3LiO',
      ),
      ContentItem(
        category: 'Games',
        language: 'all',
        title: 'Firebase 測試遊戲：戒菸小挑戰',
        content: '這是一則測試遊戲項目，讓玩家透過互動分散菸癮注意力。',
        link: 'https://example.com/game',
      ),
    ];

    for (final item in sampleItems) {
      await _upsertRemoteItem(item);
    }
  }
}
