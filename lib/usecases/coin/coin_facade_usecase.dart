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
}
