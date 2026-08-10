import '../../repositories/coin/coin_repository.dart';

class AddCoinUseCase {
  AddCoinUseCase({CoinRepository? repository})
    : _repository = repository ?? CoinRepository();

  final CoinRepository _repository;

  Future<void> execute(int amount, String reason) {
    return _repository.addCoin(amount, reason);
  }
}
