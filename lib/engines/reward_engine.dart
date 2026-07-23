import 'score_engine.dart';
import '../services/smoking_engine.dart';
import '../services/coin_service.dart';

class RewardEngine {
  final ScoreEngine _scoreEngine = ScoreEngine();

  final CoinService coinService;

  RewardEngine(this.coinService);

  int calculateRewardCoins(SmokingEngine engine) {
    final currentScore = _scoreEngine.getDisplayScore(engine);

    if (currentScore > 80) return 10;
    if (currentScore > 50) return 5;

    return 0;
  }

  void rewardDailyScore(SmokingEngine engine) {
    final coins = calculateRewardCoins(engine);

    if (coins > 0) {
      coinService.addCoin(coins, '每日戒菸評分獎勵');
    }
  }
}
