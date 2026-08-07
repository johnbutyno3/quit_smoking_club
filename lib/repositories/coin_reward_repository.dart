import '../services/coin_reward_service.dart';

class CoinRewardRepository {
  final CoinRewardService _service;

  CoinRewardRepository({CoinRewardService? service})
    : _service = service ?? CoinRewardService();

  Future<void> rewardDailyLogin() async {
    await _service.rewardDailyLogin();
  }

  Future<void> rewardDailyPlan() async {
    await _service.rewardDailyPlan();
  }
}
