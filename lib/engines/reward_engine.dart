import 'score_engine.dart';
import 'smoking_engine.dart';
import '../repositories/coin/coin_repository.dart';

class RewardEngine {
  final ScoreEngine _scoreEngine = ScoreEngine();

  final CoinRepository coinRepository;

  RewardEngine(this.coinRepository);
  int calculateRewardCoins(SmokingEngine engine) {
    final currentScore = _scoreEngine.getDisplayScore(engine);

    if (currentScore > 80) return 10;
    if (currentScore > 50) return 5;

    return 0;
  }

  Future<void> rewardDailyScore(SmokingEngine engine) async {
    final coins = calculateRewardCoins(engine);

    if (coins > 0) {
      await coinRepository.addCoin(coins, 'daily_score_reward');
    }
  }
}
