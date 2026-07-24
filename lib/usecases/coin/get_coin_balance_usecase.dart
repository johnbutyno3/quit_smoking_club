import '../../repositories/coin/coin_repository.dart';

class GetCoinBalanceUseCase {
  final CoinRepository repository;

  GetCoinBalanceUseCase(this.repository);

  Future<int> execute() async {
    return await repository.getCoins();
  }
}
