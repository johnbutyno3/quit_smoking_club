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

class _ThemeColors {
  static const primary = Color(0xFF2E7D32);
  static const bg = Color(0xFFF4F9F5);
  static const cardBg = Colors.white;
}

class _HomePageState extends State<HomePage> {
  late SmokingEngine engine;
  Timer? _timer;
  int _myCoins = 0;

  final List<String> _messages = ["歡迎來到戒菸俱樂部！挑戰開始。"];

  final List<String> _quotes = [
    "每少抽一支菸都是勝利！",
    "新鮮空氣比尼古丁更有力量！",
    "菸癮只持續3分鐘，撐過去！",
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

    final isPremium = await StorageService.getPremium();
    final lastDate = await StorageService.getLastResetDate();
    final todayStr = "${now.year}-${now.month}-${now.day}";

    if (lastDate != todayStr) {
      final reward = isPremium ? 100 : 20;
      sCoins += reward;
      await StorageService.saveCoins(sCoins);
      await StorageService.saveLastResetDate(todayStr);

      final rankStr = isPremium ? "高級會員" : "一般會員";
      _messages.add("📆 跨天簽到：您目前為 [$rankStr]");
      _messages.add("💰 已自動發放今日福利 $reward 金幣！");
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
      _messages.add("🚨 警告：使用者菸癮犯了！已通知好友！");
      _messages.add("💬 好友小明：堅持住！快進緩解艙！");
    });

    final randomQuote = _quotes[Random().nextInt(_quotes.length)];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.55,
          decoration: const BoxDecoration(
            color: _ThemeColors.bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                "🚨 菸癮危機緩解艙",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                width: double.infinity,
                child: Text(
                  "「$randomQuote」",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    _buildTile(Icons.menu_book, "1. 醫學常識 (內建文章)", "Medical"),
                    _buildTile(
                      Icons.sentiment_satisfied,
                      "2. 極短篇笑話 (故事)",
                      "Stories",
                    ),
                    _buildTile(Icons.video_library, "3. YouTube影片", "YouTube"),
                    _buildTile(Icons.audiotrack, "4. 音樂連結", "Music"),
                    _buildTile(Icons.sports_esports, "5. 遊戲大廳", "Games"),
                    ListTile(
                      leading: const Icon(Icons.forum, color: Colors.blue),
                      title: const Text(
                        "6. 前往論壇大廳",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
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
    );
  }

  Widget _buildTile(IconData icon, String label, String page) {
    return ListTile(
      leading: Icon(icon, color: _ThemeColors.primary),
      title: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
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
      backgroundColor: _ThemeColors.bg,
      appBar: AppBar(
        title: const Text(
          "戒菸俱樂部",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: _ThemeColors.primary,
            ),
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
          Card(
            color: Colors.orange.shade50,
            child: InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShopPage()),
                );
                _loadStoredData();
              },
              child: ListTile(
                leading: const Icon(Icons.stars, color: Colors.orange),
                title: const Text(
                  "目前擁有金幣庫存",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                trailing: Text(
                  "$_myCoins 💎",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 95,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _ThemeColors.cardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) =>
                  Text(_messages[index], style: const TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "已抽支數: ${engine.totalSmoked} 支 | 剩餘額度: ${engine.remaining} 支",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Divider(),
          Center(
            child: Text(
              countdownString,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: _ThemeColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: _triggerSOS,
                  child: const Text(
                    "🚨 求救協助",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canSmoke
                        ? _ThemeColors.primary
                        : Colors.grey,
                  ),
                  onPressed: canSmoke ? _smoke : null,
                  child: Text(
                    canSmoke ? "🟢 記錄抽菸" : "🔒 尚未解鎖",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ForumPage()),
            ),
            child: const Text("交流論壇"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ShopPage()),
            ),
            child: const Text("金幣商城"),
          ),
          const SizedBox(height: 20),
          const Text(
            "📋 控菸今日排程表:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          ...engine.schedule.map(
            (t) => Text(
              "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}",
            ),
          ),
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
