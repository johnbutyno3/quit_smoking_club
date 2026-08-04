import '../../services/coin_reward_service.dart';

class ClaimDailyRewardUseCase {
  final CoinRewardService _rewardService;

  ClaimDailyRewardUseCase({CoinRewardService? rewardService})
      : _rewardService = rewardService ?? CoinRewardService();

  Future<bool> execute() async {
    return _rewardService.claimDailyReward();
  }
}
