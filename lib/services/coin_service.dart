import '../models/coin_transaction.dart';
import 'storage_service.dart';

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

  Future<void> loadBalance() async {
    _balance = await StorageService.getCoins();
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
  }

  Future<bool> canSpend(int amount) async {
    await loadBalance();
    return _balance >= amount;
  }

  Future<bool> claimDailyLogin() async {
    await addCoin(10, '每日登入');
    return true;
  }

  Future<bool> claimDailyPlanReward() async {
    await addCoin(20, '完成每日戒菸計畫');
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

    return true;
  }

  Future<bool> spendForPost() async {
    return spendCoin(30, '建立論壇貼文');
  }

  void clear() {
    _balance = 0;
    _history.clear();
  }
}
