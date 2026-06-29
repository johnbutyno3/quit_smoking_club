import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/smoking_state.dart';
import '../services/smoking_engine.dart';
import '../services/storage_service.dart';
import 'forum_page.dart';
import 'shop_page.dart';
import 'setup_page.dart';
import 'mitigation_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SmokingEngine engine;
  Timer? _timer;
  int _myCoins = 0;

  final List<String> _messages = ["歡迎來到戒菸俱樂部！挑戰正在進行中。"];

  final List<String> _quotes = [
    "每少抽一支菸都是勝利，你正在奪回生命的掌控權！",
    "深呼吸！這口新鮮空氣比尼古丁更有力量！",
    "菸癮每次只會持續3分鐘，撐過去你就贏了！",
    "省下的不只是菸錢，更是與家人相處的幸福時光！",
    "你比自己想像的更強大！",
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    _loadStoredData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadStoredData() async {
    final now = DateTime.now();
    final sCount = await StorageService.getDailyCount();
    final sName = await StorageService.getUserName();
    var sCoins = await StorageService.getCoins();

    // 💡 讀取會員等級與上次重置日期
    final isPremium = await StorageService.getPremium();
    final lastDate = await StorageService.getLastResetDate();

    // 取得今天日期的純字串格式 (例如 "2026-06-29")
    final todayStr = "${now.year}-${now.month}-${now.day}";

    // 📆 核心跨天 00:00 檢查邏輯
    if (lastDate != todayStr) {
      // 根據大綱規則發放金幣：高級會員 100, 一般會員 20
      final reward = isPremium ? 100 : 20;
      sCoins += reward;

      // 儲存最新的金幣總數與今天日期到硬碟
      await StorageService.saveCoins(sCoins);
      await StorageService.saveLastResetDate(todayStr);

      // 在訊息牆頂部發布喜訊推播
      final rankStr = isPremium ? "高級會員" : "一般會員";
      _messages.add("📆 跨天簽到：您目前為 [$rankStr]");
      _messages.add("💰 系統已自動發放今日福利 $reward 金幣！");
    }

    if (mounted) {
      setState(() {
        final state = SmokingState(
          startTime: DateTime(now.year, now.month, now.day, 8, 0),
          endTime: DateTime(now.year, now.month, now.day, 22, 0),
          plannedCount: sCount,
        );
        engine = SmokingEngine(state);
        _myCoins = sCoins;
        _messages.add("Hi, $sName!");
      });
    }
  }

  void _smoke() {
    setState(() {
      engine.state = engine.state.addSmoke(DateTime.now());
      _messages.add("Recorded smoke.");
    });
  }

  void _triggerSOS() {
    setState(() {
      _messages.add("🚨 警告：使用者菸癮犯了！已自動廣播通知好友！");
      _messages.add("💬 好友小明：堅持住！快進入下方的緩解艙！");
      _messages.add("🎁 好友小華送了你一個 [冰鎮薄荷糖] 貼圖支持！");
    });

    final randomQuote = _quotes[Random().nextInt(_quotes.length)];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.55,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const Text(
                "🚨 菸癮危機緩解艙",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.red.shade50,
                width: double.infinity,
                child: Text(
                  "「$randomQuote」",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: [
                    _buildTile("1. 醫學常識 (內建戒菸文章)", "Medical"),
                    _buildTile("2. 極短篇笑話 (短文小故事)", "Stories"),
                    _buildTile("3. YouTube影片 (看一下影片如何)", "YouTube"),
                    _buildTile("4. 音樂連結 (聽一下音樂)", "Music"),
                    _buildTile("5. 遊戲大廳 (內建小遊戲)", "Games"),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.forum, color: Colors.blue),
                      title: const Text(
                        "6. 前往論壇大廳",
                        style: TextStyle(fontSize: 12),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForumPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      _loadStoredData();
    });
  }

  Widget _buildTile(String label, String page) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.star, color: Colors.red),
      title: Text(label, style: const TextStyle(fontSize: 12)),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MitigationPage(title: page)),
        );
        _loadStoredData();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quit Smoking"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SetupPage()),
              );
              _loadStoredData();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 💡 頂部核心金幣錢包看板
          // === 💡 點擊頂部金幣看板，可直接一鍵按進 STORE ===
          Card(
            color: Colors.orange.shade50,
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () async {
                // 1. 一鍵流暢切換進去商城頁面
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShopPage()),
                );
                // 2. 從商城充值或消費返回時，自動同步刷新首頁頂部金幣庫存
                _loadStoredData();
              },
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.wallet, color: Colors.orange),
                title: const Text(
                  "目前擁有金幣庫存",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "$_myCoins 💎",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3.2.2 標準滾動文字框
          Container(
            height: 90,
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(
                    _messages[index],
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          Text("Smoked: ${engine.totalSmoked}"),
          Text("Remaining: ${engine.remaining}"),
          const Divider(),

          Center(
            child: Text(
              countdownString,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: _triggerSOS,
                  child: const Text("🚨 SOS"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canSmoke ? Colors.green : Colors.grey,
                  ),
                  onPressed: canSmoke ? _smoke : null,
                  child: Text(canSmoke ? "🟢 Smoke" : "🔒 Lock"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          ElevatedButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ForumPage()),
              );
              _loadStoredData();
            },
            child: const Text("Forums"),
          ),
          const SizedBox(height: 8),

          ElevatedButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShopPage()),
              );
              _loadStoredData();
            },
            child: const Text("Store"),
          ),
          const SizedBox(height: 15),

          const Text("Schedule:"),
          ...engine.schedule.map((t) => Text("${t.hour}:${t.minute}")),
        ],
      ),
    );
  }

  DateTime? get nextSmokeTime {
    final now = DateTime.now();
    for (final t in engine.schedule) {
      if (t.isAfter(now)) return t;
    }
    return null;
  }

  bool get canSmoke {
    final now = DateTime.now();
    if (engine.totalSmoked >= engine.plannedCount) return false;
    final next = nextSmokeTime;
    if (next == null) return true;
    return now.isAfter(next);
  }

  String get countdownString {
    final next = nextSmokeTime;
    if (next == null) return "00:00:00";
    final diff = next.difference(DateTime.now());
    if (diff.isNegative) return "00:00:00";
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }
}
