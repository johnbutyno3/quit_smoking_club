import '../../models/coin_transaction.dart';
import '../../services/coin_service.dart';
import '../../usecases/storage/storage_facade_usecase.dart';

class CoinRepository {
  final CoinService _coinService;

  CoinRepository({CoinService? coinService})
    : _coinService = coinService ?? CoinService();

  Future<int> getBalance() async {
    await _coinService.loadBalance();
    return _coinService.balance;
  }

  Future<int> getTotalSpentCoins() async {
    await _coinService.loadBalance();
    return _coinService.totalSpentCoins;
  }

  Future<bool> claimDailyLogin() async {
    return await _coinService.claimDailyLogin();
  }

  Future<bool> claimDailyPlanReward() async {
    return await _coinService.claimDailyPlanReward();
  }

  Future<int> getCoins() async {
    return await getBalance();
  }

  Future<bool> spendCoin(int amount, String reason) async {
    return await _coinService.spendCoin(amount, reason);
  }

  Future<void> addCoin(int amount, String reason) async {
    await _coinService.addCoin(amount, reason);
  }

  Future<List<CoinTransaction>> getHistory() async {
    return await StorageFacadeUseCase.getCoinHistory();
  }
}
