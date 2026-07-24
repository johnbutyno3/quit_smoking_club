import 'package:quit_smoking_club/services/coin_service.dart';

class CoinRepository {
  final CoinService coinService;

  CoinRepository(this.coinService);

  Future<bool> spendCoin(int amount, String reason) async {
    return await coinService.spendCoin(amount, reason);
  }

  Future<void> addCoin(int amount, String reason) async {
    await coinService.addCoin(amount, reason);
  }

  Future<int> getCoins() async {
    await coinService.loadBalance();
    return coinService.balance;
  }
}
