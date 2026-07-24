import 'package:quit_smoking_club/repositories/coin/coin_repository.dart';

class SpendCoinUseCase {
  final CoinRepository repository;

  SpendCoinUseCase(this.repository);

  Future<bool> execute(int amount, String reason) async {
    return await repository.spendCoin(amount, reason);
  }
}
