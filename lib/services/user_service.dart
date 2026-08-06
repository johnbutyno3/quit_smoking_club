import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

/// Handles Firebase Authentication and Firestore user profile sync.
/// Local cache is managed by StorageService.
/// Cloud user data is managed here.
class UserService {
  static const _colUsers = 'users';
  static const _colNames = 'usernames';

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  UserService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = firestore ?? FirebaseFirestore.instance;

  /// Current authenticated user UID.
  static String? currentUid;

  // ========================================================
  // Authentication
  // ========================================================

  /// Returns existing UID or creates anonymous account.
  Future<String> signInAnonymously() async {
    final existing = _auth.currentUser;

    if (existing != null) {
      currentUid = existing.uid;
      return existing.uid;
    }

    final credential = await _auth.signInAnonymously();

    currentUid = credential.user!.uid;

    return currentUid!;
  }

  /// Register account with email and password.
  Future<String> registerWithEmail(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    currentUid = credential.user!.uid;

    return currentUid!;
  }

  /// Sign in with email and password.
  Future<String> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    currentUid = credential.user!.uid;

    return currentUid!;
  }

  /// Sign out current user.
  Future<void> signOut() async {
    await _auth.signOut();
    currentUid = null;
  }

  /// Google OAuth login.
  /// Web uses popup flow, mobile uses provider flow.
  Future<String> signInWithGoogle() async {
    final provider = GoogleAuthProvider()
      ..addScope('email')
      ..addScope('profile');

    UserCredential result;

    final current = _auth.currentUser;

    if (current != null && current.isAnonymous) {
      try {
        result = kIsWeb
            ? await current.linkWithPopup(provider)
            : await current.linkWithProvider(provider);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'credential-already-in-use' ||
            e.code == 'email-already-in-use') {
          result = kIsWeb
              ? await _auth.signInWithPopup(provider)
              : await _auth.signInWithProvider(provider);
        } else {
          rethrow;
        }
      }
    } else {
      result = kIsWeb
          ? await _auth.signInWithPopup(provider)
          : await _auth.signInWithProvider(provider);
    }

    currentUid = result.user!.uid;

    return currentUid!;
  }

  String? get googleDisplayName => _auth.currentUser?.displayName;

  bool get isGoogleUser =>
      _auth.currentUser?.providerData.any(
        (provider) => provider.providerId == 'google.com',
      ) ??
      false;
  // ========================================================
  // Username Validation
  // ========================================================

  /// Validates username format.
  /// Returns localization key when invalid.
  /// Returns null when valid.
  static String? validateNameFormat(String name) {
    final trimmed = name.trim();

    if (trimmed.isEmpty) {
      return 'nickname_empty';
    }

    if (trimmed.length < 2) {
      return 'nickname_too_short';
    }

    if (trimmed.length > 15) {
      return 'nickname_too_long';
    }

    // Supports Unicode letters, numbers, underscore and hyphen.
    final valid = RegExp(r'^[\p{L}\p{N}_\-]+$', unicode: true);

    if (!valid.hasMatch(trimmed)) {
      return 'nickname_invalid_characters';
    }

    // Prevent numeric-only usernames.
    if (RegExp(r'^\d+$').hasMatch(trimmed)) {
      return 'nickname_only_numbers';
    }

    return null;
  }

  /// Checks whether username is available.
  Future<bool> isNameAvailable(String name, {String? excludeUid}) async {
    final doc = await _db
        .collection(_colNames)
        .doc(name.trim().toLowerCase())
        .get();

    if (!doc.exists) {
      return true;
    }

    if (excludeUid != null && doc.data()?['uid'] == excludeUid) {
      return true;
    }

    return false;
  }

  /// Reserves username using atomic batch operation.
  Future<void> reserveName(String uid, String name, {String? oldName}) async {
    final batch = _db.batch();

    if (oldName != null && oldName.isNotEmpty) {
      batch.delete(_db.collection(_colNames).doc(oldName.trim().toLowerCase()));
    }

    batch.set(_db.collection(_colNames).doc(name.trim().toLowerCase()), {
      'uid': uid,
      'display': name.trim(),
    });

    await batch.commit();
  }
  // ========================================================
  // User Profile
  // ========================================================

  /// Loads user profile from Firestore.
  Future<Map<String, dynamic>?> loadProfile(String uid) async {
    final doc = await _db.collection(_colUsers).doc(uid).get();

    return doc.exists ? doc.data() : null;
  }

  /// Saves or updates user profile.
  Future<void> saveProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection(_colUsers).doc(uid).set({
      ...data,
      'last_seen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Updates user coin balance in profile.
  Future<void> updateCoins(String uid, int coins) async {
    await _db.collection(_colUsers).doc(uid).set({
      'coins': coins,
    }, SetOptions(merge: true));
  }

  // ========================================================
  // Local and Cloud Synchronization
  // ========================================================

  /// Uploads local profile data to cloud.
  Future<void> syncLocalToCloud(String uid) async {
    final name = await StorageService.getUserName();
    final count = await StorageService.getDailyCount();
    final coins = await StorageService.getCoins();
    final isPremium = await StorageService.getPremium();
    final age = await StorageService.getUserAge();
    final years = await StorageService.getUserYears();
    final firstTime = await StorageService.getFirstSmokeTime();
    final lastTime = await StorageService.getLastSmokeTime();

    await saveProfile(uid, {
      'name': name,
      'daily_count': count,
      'coins': coins,
      'is_premium': isPremium,
      'user_age': age,
      'user_years': years,
      'first_smoke_time': firstTime,
      'last_smoke_time': lastTime,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  /// Downloads cloud profile data into local storage.
  Future<void> syncCloudToLocal(String uid) async {
    final data = await loadProfile(uid);

    if (data == null) {
      return;
    }

    if (data['name'] != null) {
      await StorageService.saveUserName(data['name'] as String);
    }

    if (data['daily_count'] != null) {
      await StorageService.saveDailyCount(data['daily_count'] as int);
    }

    if (data['coins'] != null) {
      await StorageService.saveCoins(data['coins'] as int);
    }

    if (data['is_premium'] != null) {
      await StorageService.savePremium(data['is_premium'] as bool);
    }

    if (data['user_age'] != null) {
      await StorageService.saveUserAge(data['user_age'] as int);
    }

    if (data['user_years'] != null) {
      await StorageService.saveUserYears(data['user_years'] as int);
    }

    if (data['first_smoke_time'] != null) {
      await StorageService.saveFirstSmokeTime(
        data['first_smoke_time'] as String,
      );
    }

    if (data['last_smoke_time'] != null) {
      await StorageService.saveLastSmokeTime(data['last_smoke_time'] as String);
    }

    debugPrint('[UserService] Cloud to local sync completed: $uid');
  }
}
