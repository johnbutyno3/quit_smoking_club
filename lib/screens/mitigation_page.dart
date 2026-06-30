import 'package:flutter/material.dart';

class MitigationPage extends StatefulWidget {
  final String title;
  const MitigationPage({super.key, required this.title});

  @override
  State<MitigationPage> createState() => _MitigationPageState();
}

// 🎨 舒壓專用美工色彩：引入琥珀溫暖調性，洗去單調太空虛
class _MitigateColors {
  static const bgTop = Color(0xFFFFF8E1); // 溫暖琥珀金微漸層起點
  static const bgBot = Color(0xFFFAFAFA); // 高級極簡優雅白
  static const primary = Color(0xFFE65100); // 舒壓深橘主色
  static const cardBg = Colors.white; // 純白懸浮卡片
}

class _MitigationPageState extends State<MitigationPage> {
  // 💡 根據傳入的類別，自動對齊大綱 3.2.5 的豐富實用緩解內容庫
  String _getContentText() {
    switch (widget.title) {
      case "Medical":
        return "💡 醫學實證：當菸癮犯了時，人體的尼古丁戒斷症狀其實只會達到巔峰 3 分鐘。此時透過深呼吸三次，或飲用一杯溫開水，就能成功讓血液含氧量回升，菸癮便會自然消退。";
      case "Stories":
        return "😂 舒壓笑話：小明跟上帝說：『主啊，請給我一個能讓我一秒忘記菸癮的超能力！』上帝想了想，給了他一張明天的期末考卷。小明看了一眼，當場嚇得連自己叫什麼都忘了，更別說想抽菸了！";
      case "YouTube":
        return "🎬 精選影片推薦：【5分鐘肺部呼吸淨化冥想導引】。建議您現在戴上耳機，跟著影片節奏深吸氣、深呼氣。新鮮的氧氣正在修復您的細胞，您比自己想像的更強大！";
      case "Music":
        return "🎵 療癒音樂清單：【3D大自然阿爾法腦波森林環境音】。閉上雙眼，想像自己正漫步在翠綠的阿里山森林中，聽著鳥鳴與溪流聲。這口空氣比任何香菸都更加純淨。";
      case "Games":
        return "🎮 內建舒壓小遊戲：【3分鐘手指泡泡糖大作戰】。請動動你的手指，快速點擊畫面上出現的彩色泡泡！透過手指的繁複運動，能完美移轉大腦對尼古丁的注意力！";
      default:
        return "🟢 戒菸艙防護罩已開啟，請跟著我們一起堅持下去！";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // 💡 滿版琥珀金微漸層：洗去單調空虛，一秒撫平菸癮焦慮
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_MitigateColors.bgTop, _MitigateColors.bgBot],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            "${widget.title} 危機緩解中",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white.withOpacity(0.8),
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // 💡 懸浮式磨砂資訊大圖卡
            Card(
              color: _MitigateColors.cardBg,
              elevation: 6,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: Colors.amber.shade100, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.spa, size: 48, color: _MitigateColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      _getContentText(),
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 💡 勵志退出返回按鈕：點擊流暢退出返回
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _MitigateColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text(
                "🟢 我成功撐過去了！",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),

            const Text(
              "💡 提示：菸癮犯了時，深呼吸 3 次可以大幅緩解不適喔！",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
