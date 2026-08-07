import '../../repositories/coin_reward_repository.dart';

class ClaimDailyRewardUseCase {
  final CoinRewardRepository _repository;

  ClaimDailyRewardUseCase({CoinRewardRepository? repository})
    : _repository = repository ?? CoinRewardRepository();

  Future<void> claimDailyLogin() async {
    await _repository.rewardDailyLogin();
  }

  Future<void> claimDailyPlan() async {
    await _repository.rewardDailyPlan();
  }
}
