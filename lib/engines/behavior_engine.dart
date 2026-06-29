import '../services/smoking_engine.dart';

class BehaviorEngine {
  final SmokingEngine engine;

  BehaviorEngine(this.engine);

  /// 獲取超抽的數量
  int get overCount => engine.overCount;

  /// 戒菸成功率 (改為以「少抽的比例」或「控制率」來計算，對戒菸者更具正面鼓勵)
  /// 如果計畫 5 支，抽了 2 支，代表成功控制了 60% 的菸癮
  double get controlRate {
    if (engine.plannedCount == 0) return 1.0; // 如果計畫抽0支，且沒抽，就是100%控制

    // 計算剩餘/少抽的比例
    double rate =
        (engine.plannedCount - engine.totalSmoked) / engine.plannedCount;
    return rate < 0 ? 0.0 : rate; // 負數則歸零
  }

  /// 根據目前的抽菸數據與計畫，判定目前的克制狀態
  String get statusText {
    // 1. 如果已經超過當日計畫總數
    if (engine.isOverLimit) return "失控";

    // 2. 如果實際抽菸數已經快接近上限（例如達到計畫數的 80% 以上）
    if (engine.plannedCount > 0 &&
        (engine.totalSmoked / engine.plannedCount) >= 0.8) {
      return "危險";
    }

    // 3. 其他安全範圍
    return "穩定";
  }

  /// 對應大綱 3.2.5：根據當前時間與按鈕解鎖狀態，獲取主頁面標準文字框的提示語
  /// [isTimeUp]: 倒計時是否已經歸零 (可抽菸時間是否到了)
  /// [hasMissedLastWindow]: 是否錯過了上一支菸的時間（代表少抽了一支）
  String getNoticeText({
    required bool isTimeUp,
    required bool hasMissedLastWindow,
  }) {
    if (hasMissedLastWindow) {
      return "恭喜您，少抽 1 支菸。";
    }
    if (isTimeUp) {
      return "現在可以抽菸了，但如果忍住不抽，那就太棒了。";
    }
    return "正在戒菸挑戰中，繼續堅持！";
  }
}
