import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../config/coin_rules.dart';
import '../models/coin_transaction.dart';
import 'storage_service.dart';
import 'supabase_coin_log_service.dart';

/// Handles COIN business operations.
///
/// Firebase Firestore is the cloud source of truth for the user's balance.
/// StorageService keeps a local cache for offline/startup resilience.
/// Supabase stores transaction logs only and is never used as the balance source.
class CoinService {
  CoinService._internal();

  static final CoinService _instance = CoinService._internal();

  factory CoinService() {
    return _instance;
  }

  static const _usersCollection = 'users';
  static const _coinsField = 'coins';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  int _balance = 20;
  final List<CoinTransaction> _history = [];

  int get balance => _balance;

  List<CoinTransaction> get history => List.unmodifiable(_history);

  int get totalSpentCoins {
    return _history
        .where((item) => item.amount < 0)
        .fold(0, (sum, item) => sum + item.amount.abs());
  }

  DocumentReference<Map<String, dynamic>> _userDocument(String uid) {
    return _db.collection(_usersCollection).doc(uid);
  }

  Future<void> loadBalance() async {
    final localBalance = await StorageService.getCoins();
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      _balance = localBalance;
    } else {
      final snapshot = await _userDocument(userId).get();
      final data = snapshot.data();
      final cloudBalance = data?[_coinsField];

      if (cloudBalance is int) {
        _balance = cloudBalance;
      } else {
        _balance = localBalance;
        await _userDocument(userId).set({
          _coinsField: _balance,
        }, SetOptions(merge: true));
      }
    }

    _history
      ..clear()
      ..addAll(await StorageService.getCoinHistory());

    await StorageService.saveCoins(_balance);
  }

  Future<int?> _changeCloudBalance({required int delta}) async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      return null;
    }

    final reference = _userDocument(userId);

    return _db.runTransaction<int>((transaction) async {
      final snapshot = await transaction.get(reference);
      final data = snapshot.data();
      final current = data?[_coinsField];
      final currentBalance = current is int ? current : _balance;
      final nextBalance = currentBalance + delta;

      if (nextBalance < 0) {
        return -1;
      }

      transaction.set(
        reference,
        {_coinsField: nextBalance},
        SetOptions(merge: true),
      );

      return nextBalance;
    });
  }

  Future<void> addCoin(int amount, String reason) async {
    if (amount <= 0) return;

    await loadBalance();

    final cloudBalance = await _changeCloudBalance(delta: amount);
    final nextBalance = cloudBalance ?? (_balance + amount);
    _balance = nextBalance;

    await StorageService.saveCoins(_balance);

    final transaction = CoinTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      reason: reason,
      createdAt: DateTime.now(),
    );

    _history.add(transaction);
    await StorageService.saveCoinHistory(_history);

    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await SupabaseCoinLogService.addLog(
        userId: userId,
        amount: amount,
        type: 'earn',
        reason: reason,
      );
    }
  }

  Future<bool> canSpend(int amount) async {
    if (amount <= 0) return false;
    await loadBalance();
    return _balance >= amount;
  }

  Future<bool> claimDailyLogin() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastLogin = await StorageService.getLastLoginDate();

    if (lastLogin == today) {
      return false;
    }

    int streak = await StorageService.getLoginStreak();

    if (lastLogin.isEmpty) {
      streak = 1;
    } else {
      final lastDate = DateTime.parse(lastLogin);
      final nowDate = DateTime.parse(today);
      final diff = nowDate.difference(lastDate).inDays;

      if (diff == 1) {
        streak++;
      } else {
        streak = 1;
      }
    }

    await StorageService.saveLastLoginDate(today);
    await StorageService.saveLoginStreak(streak);
    await addCoin(CoinRules.dailyLoginReward, 'daily_login');

    return true;
  }

  Future<bool> claimDailyPlanReward() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastRewardDate = await StorageService.getLastPlanRewardDate();

    if (lastRewardDate == today) {
      return false;
    }

    await addCoin(CoinRules.dailyPlanReward, 'daily_plan_reward');
    await StorageService.saveLastPlanRewardDate(today);

    return true;
  }

  Future<bool> spendCoin(int amount, String reason) async {
    if (amount <= 0) return false;

    await loadBalance();

    final cloudBalance = await _changeCloudBalance(delta: -amount);

    if (cloudBalance == -1) {
      return false;
    }

    final nextBalance = cloudBalance ?? (_balance - amount);
    if (nextBalance < 0) {
      return false;
    }

    _balance = nextBalance;
    await StorageService.saveCoins(_balance);

    final transaction = CoinTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: -amount,
      reason: reason,
      createdAt: DateTime.now(),
    );

    _history.add(transaction);
    await StorageService.saveCoinHistory(_history);

    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await SupabaseCoinLogService.addLog(
        userId: userId,
        amount: -amount,
        type: 'spend',
        reason: reason,
      );
    }

    return true;
  }

  Future<bool> spendForPost() async {
    return spendCoin(CoinRules.createPostCost, 'forum_create_post');
  }

  void clear() {
    _balance = 0;
    _history.clear();
  }
}
