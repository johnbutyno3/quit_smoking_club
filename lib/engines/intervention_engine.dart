import 'dart:math';
import '../services/smoking_engine.dart';

class InterventionEngine {
  final SmokingEngine engine;
  final Random _random = Random();

  InterventionEngine(this.engine);

  /// 判定是否處於高風險狀態 (無剩餘額度、已超支)
  bool get isHighRisk {
    return engine.remaining <= 0 || engine.overCount > 0;
  }

  /// 根據目前的超額狀況，獲取對應的基礎警告訊息
  String get sosMessage {
    if (engine.overCount > 0) {
      return "你已經超出計畫了，現在是關鍵時刻。";
    }
    return "撐住，這一支可以不用抽。";
  }

  /// 對應大綱 3.2.6.2.1：按下 SOS 鈕時，隨機挑選一則鼓勵字句（不重複原則）
  /// 實務上 3000 筆資料建議放在資產檔(Asset JSON)或本地資料庫，此處先建立核心篩選邏輯
  String getRandomEncouragement() {
    // 這裡先建立基礎字句庫作為示範，後續可透過方法載入 3000 則資料
    List<String> textPool = [
      "每少抽一支菸都是勝利，你正在奪回生命的掌控權！",
      "深呼吸，這陣菸癮通常只會持續3到5分鐘，你一定能熬過去！",
      "想想你的家人與你的健康，為了他們，再堅持一下下。",
      "你已經成功堅持了這麼多天，別讓這短短的幾分鐘打破你的紀錄！",
      "按下緩解配方，聽首歌或玩個小遊戲，轉移注意力吧！",
    ];

    if (textPool.isEmpty) return "堅持住，你可以的！";

    // 隨機回傳一則
    int randomIndex = _random.nextInt(textPool.length);
    return textPool[randomIndex];
  }

  /// 對應大綱 3.2.6.2.2：獲取緩解配方選單列表
  List<Map<String, String>> getMitigationMenu() {
    return [
      {"type": "medical", "title": "醫學常識 (看文章賺金幣)"},
      {"type": "short_story", "title": "極短篇 (3分鐘故事笑話)"},
      {"type": "youtube", "title": "看一下影片如何 (YouTube)"},
      {"type": "music", "title": "聽一下音樂"},
      {"type": "game", "title": "遊戲大廳 (內建多款小遊戲)"},
      {"type": "forum", "title": "前往求救論壇"},
    ];
  }
}
