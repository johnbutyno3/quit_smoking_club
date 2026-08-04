import '../../services/coin_reward_service.dart';

class ClaimDailyRewardUseCase {
  final CoinRewardService rewardService;

  ClaimDailyRewardUseCase({CoinRewardService? rewardService})
    : rewardService = rewardService ?? CoinRewardService();

  Future<void> claimDailyLogin() async {
    await rewardService.rewardDailyLogin();
  }

  Future<void> claimDailyPlan() async {
    await rewardService.rewardDailyPlan();
  }
}
