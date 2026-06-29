class SocialEngine {
  final List<String> _feed = [];

  // =========================
  // 🚨 SOS 求救 (對應大綱 3.2.6.1)
  // =========================
  /// 當使用者菸癮犯了按下 SOS 鈕時觸發
  void sendSOS(String userName) {
    _feed.add("🚨 $userName 正在犯菸癮，需要支援！");
  }

  // =========================
  // 💬 朋友支援留言與送禮 (對應大綱 3.2.6.1)
  // =========================
  /// 好友主動留言或送禮物鼓勵
  void support(String from, String message, {String? giftName}) {
    if (giftName != null) {
      _feed.add("🎁 $from 送給了你 [$giftName]！並說：$message");
    } else {
      _feed.add("💬 $from：$message");
    }
  }

  // =========================
  // 🎯 自動鼓勵訊息 (對應大綱 3.2.6.2.1)
  // =========================
  /// 結合干預引擎撈出的不重複鼓勵金句，直接塞入主頁文字框
  void addAutoMotivation(String message) {
    _feed.add("💡 系統：「$message」");
  }

  // =========================
  // 📊 社群壓力與訊息判定
  // =========================
  bool get hasSocialPressure => _feed.isNotEmpty;

  int get messageCount => _feed.length;

  // =========================
  // 🧹 清理（未來用）
  // =========================
  void clear() {
    _feed.clear();
  }

  // =========================
  // 📡 讀取 feed（UI 用）
  // =========================
  /// 倒序排列，讓最新收到的求救、留言或系統訊息顯示在最上方
  List<String> get feed => List.unmodifiable(_feed.reversed);
}
