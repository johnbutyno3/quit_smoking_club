import 'score_engine.dart';

class RewardEngine {
  final ScoreEngine scoreEngine;

  RewardEngine(this.scoreEngine);

  /// 依據 ScoreEngine 的分數判定目前的文字回饋
  String get message {
    if (scoreEngine.score >= 80) {
      return "很好，你正在控制自己。";
    } else if (scoreEngine.score >= 60) {
      return "有進步，但還可以更穩。";
    } else if (scoreEngine.score >= 40) {
      return "注意，你開始偏離計畫了。";
    } else {
      return "警告：你正在失控邊緣。";
    }
  }

  /// 對應大綱 3.2.5.2：當使用者成功少抽一支菸時，計算可獲得的金幣獎勵
  /// [isStreak]: 是否為連續少抽，如果是可以給予額外加成
  int calculateMissedSmokeReward({bool isStreak = false}) {
    int baseCoin = 5; // 少抽一支菸基礎獎勵 5 金幣
    return isStreak ? baseCoin + 3 : baseCoin;
  }

  /// 对應大綱 3.2.6.2.2.1：觀看緩解配方（醫學常識/極短篇）累積時間兌換的金幣
  /// [readingSeconds]: 使用者觀看或停留的秒數
  int calculateReadingReward(int readingSeconds) {
    if (readingSeconds < 60) return 0; // 不滿一分鐘不發放

    // 假設每閱讀 1 分鐘 (60秒) 可獲得 1 個金幣
    return readingSeconds ~/ 60;
  }
}
