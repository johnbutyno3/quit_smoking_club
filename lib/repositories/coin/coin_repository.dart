import '../../models/coin_transaction.dart';
import '../../services/coin_service.dart';
import '../../usecases/storage/storage_facade_usecase.dart';

class CoinRepository {
  CoinRepository({CoinService? coinService})
    : _coinService = coinService ?? CoinService();

  final CoinService _coinService;

  Future<int> getBalance() async {
    await _coinService.loadBalance();
    return _coinService.balance;
  }

  Future<int> getCoins() async {
    return getBalance();
  }

  Future<int> getTotalSpentCoins() async {
    await _coinService.loadBalance();
    return _coinService.totalSpentCoins;
  }

  Future<bool> claimDailyLogin() async {
    return _coinService.claimDailyLogin();
  }

  Future<bool> claimDailyPlanReward() async {
    return _coinService.claimDailyPlanReward();
  }

  Future<bool> spendCoin(int amount, String reason) async {
    return _coinService.spendCoin(amount, reason);
  }

  Future<void> addCoin(int amount, String reason) async {
    await _coinService.addCoin(amount, reason);
  }

  Future<List<CoinTransaction>> getHistory() async {
    return StorageFacadeUseCase.getCoinHistory();
  }
}
