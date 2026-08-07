import '../../repositories/coin/coin_repository.dart';
import 'get_coin_balance_usecase.dart';
import 'spend_coin_usecase.dart';

class CoinFacadeUseCase {
  final CoinRepository _coinRepository = CoinRepository();

  Future<int> getBalance() async {
    return await GetCoinBalanceUseCase(_coinRepository).execute();
  }

  Future<bool> spend(int amount, String reason) async {
    return await SpendCoinUseCase(_coinRepository).execute(amount, reason);
  }

  Future<bool> claimDailyLogin() async {
    return await _coinRepository.claimDailyLogin();
  }

  Future<bool> claimDailyPlanReward() async {
    return await _coinRepository.claimDailyPlanReward();
  }

  Future<void> addCoin(int amount, String reason) async {
    await _coinRepository.addCoin(amount, reason);
  }

  Future<int> getTotalSpentCoins() async {
    return await _coinRepository.getTotalSpentCoins();
  }
}
