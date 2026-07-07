import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

/// 負責 Firebase Auth（匿名 + Google）與 Firestore 個人檔案同步。
/// 本機快取由 StorageService 負責；雲端主檔由此 service 負責。
class UserService {
  static const _colUsers = 'users';
  static const _colNames = 'usernames'; // 唯一暱稱索引表

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  UserService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = firestore ?? FirebaseFirestore.instance;

  /// 目前登入的 UID（靜態，供其他頁面讀取）
  static String? currentUid;

  // ════════════════════════════════════════════════════════
  // Auth
  // ════════════════════════════════════════════════════════

  /// 已登入直接回傳 uid；否則執行匿名登入。
  Future<String> signInAnonymously() async {
    final existing = _auth.currentUser;
    if (existing != null) {
      currentUid = existing.uid;
      return existing.uid;
    }
    final cred = await _auth.signInAnonymously();
    currentUid = cred.user!.uid;
    return currentUid!;
  }

  /// Email + 密碼註冊新帳號。
  Future<String> registerWithEmail(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    currentUid = cred.user!.uid;
    return currentUid!;
  }

  /// Email + 密碼登入既有帳號。
  Future<String> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    currentUid = cred.user!.uid;
    return currentUid!;
  }

  /// 登出。
  Future<void> signOut() async {
    await _auth.signOut();
    currentUid = null;
  }

  /// Google 登入。Web 用 signInWithPopup，行動端用 signInWithProvider。
  /// 不需要 google_sign_in 套件，Firebase Auth 內建處理 OAuth 流程。
  Future<String> signInWithGoogle() async {
    final provider = GoogleAuthProvider()
      ..addScope('email')
      ..addScope('profile');

    UserCredential result;
    final current = _auth.currentUser;

    if (current != null && current.isAnonymous) {
      // 嘗試把匿名帳號升級（合併到 Google 帳號）
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

  /// 取得目前 Google 顯示名稱（用於自動填入暱稱）
  String? get googleDisplayName => _auth.currentUser?.displayName;

  /// 是否以 Google 帳號登入
  bool get isGoogleUser =>
      _auth.currentUser?.providerData.any(
        (p) => p.providerId == 'google.com',
      ) ??
      false;

  // ════════════════════════════════════════════════════════
  // 名稱驗證
  // ════════════════════════════════════════════════════════

  /// 格式驗證：回傳錯誤訊息，合法則回傳 null。
  static String? validateNameFormat(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '暱稱不能為空';
    if (trimmed.length < 2) return '暱稱至少需要 2 個字元';
    if (trimmed.length > 15) return '暱稱最多 15 個字元';
    // 只允許中文、英文、數字、底線、連字號
    final valid = RegExp(r'^[\u4e00-\u9fa5a-zA-Z0-9_\-]+$');
    if (!valid.hasMatch(trimmed)) return '暱稱只能包含中文、英文、數字、底線或連字號';
    // 不允許全數字（防止偽裝 ID）
    if (RegExp(r'^\d+$').hasMatch(trimmed)) return '暱稱不能全為數字';
    return null;
  }

  /// 雲端重複檢查：若可用回傳 true。
  Future<bool> isNameAvailable(String name, {String? excludeUid}) async {
    final doc = await _db
        .collection(_colNames)
        .doc(name.trim().toLowerCase())
        .get();
    if (!doc.exists) return true;
    // 允許自己保留同一個名字
    if (excludeUid != null && doc.data()?['uid'] == excludeUid) return true;
    return false;
  }

  /// 預訂暱稱（原子操作：刪舊名 + 寫新名）。
  /// [oldName] 為更名前的舊暱稱，首次設定時傳 null。
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

  // ════════════════════════════════════════════════════════
  // Firestore 個人檔案
  // ════════════════════════════════════════════════════════

  Future<Map<String, dynamic>?> loadProfile(String uid) async {
    final doc = await _db.collection(_colUsers).doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> saveProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection(_colUsers).doc(uid).set({
      ...data,
      'last_seen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateCoins(String uid, int coins) async {
    await _db.collection(_colUsers).doc(uid).set({
      'coins': coins,
    }, SetOptions(merge: true));
  }

  // ════════════════════════════════════════════════════════
  // 本機 ↔ 雲端同步
  // ════════════════════════════════════════════════════════

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

  Future<void> syncCloudToLocal(String uid) async {
    final data = await loadProfile(uid);
    if (data == null) return;

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
    debugPrint('[UserService] Cloud → Local sync done for uid=$uid');
  }
}
