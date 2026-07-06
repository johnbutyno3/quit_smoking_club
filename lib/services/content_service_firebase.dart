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
    final sample = ContentItem(
      category: 'Medical',
      language: 'all',
      title: 'Firebase Test Item',
      content: 'This item was created to verify Firebase connectivity.',
      link: 'https://firebase.google.com',
    );
    await _upsertRemoteItem(sample);
  }
}
