import 'package:firebase_auth/firebase_auth.dart';

import '../models/coin_transaction.dart';
import 'storage_service.dart';
import 'supabase_coin_log_service.dart';
import '../config/coin_rules.dart';

class CoinService {
  CoinService._internal();

  static final CoinService _instance = CoinService._internal();

  factory CoinService() {
    return _instance;
  }

  int _balance = 20;

  final List<CoinTransaction> _history = [];

  int get balance => _balance;

  List<CoinTransaction> get history => List.unmodifiable(_history);

  /// 累積消費 COIN
  int get totalSpentCoins {
    return _history
        .where((item) => item.amount < 0)
        .fold(0, (sum, item) => sum + item.amount.abs());
  }

  Future<void> loadBalance() async {
    _balance = await StorageService.getCoins();

    _history
      ..clear()
      ..addAll(await StorageService.getCoinHistory());
  }

  Future<void> addCoin(int amount, String reason) async {
    await loadBalance();

    if (amount <= 0) return;

    _balance += amount;

    await StorageService.saveCoins(_balance);

    _history.add(
      CoinTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        reason: reason,
        createdAt: DateTime.now(),
      ),
    );

    await StorageService.saveCoinHistory(_history);

    final userId = FirebaseAuth.instance.currentUser?.uid;

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
    await loadBalance();
    return _balance >= amount;
  }

  Future<bool> claimDailyLogin() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final lastLogin = await StorageService.getLastLoginDate();

    // 今天已登入
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
    await loadBalance();

    if (amount <= 0) return false;

    if (_balance < amount) {
      return false;
    }

    _balance -= amount;

    await StorageService.saveCoins(_balance);

    _history.add(
      CoinTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: -amount,
        reason: reason,
        createdAt: DateTime.now(),
      ),
    );

    await StorageService.saveCoinHistory(_history);

    final userId = FirebaseAuth.instance.currentUser?.uid;

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
