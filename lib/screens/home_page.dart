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

// 💡 響應式美工專用：品牌核心高質感色彩規範
class _ThemeColors {
  static const primary = Color(0xFF2E7D32); // 森林綠（三端通用主色）
  static const bg = Color(0xFFF4F9F5); // 輕盈極簡背景色
  static const cardBg = Colors.white; // 純白懸浮卡片
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

    final isPremium = await StorageService.getPremium();
    final lastDate = await StorageService.getLastResetDate();
    final todayStr = "${now.year}-${now.month}-${now.day}";

    // 📆 00:00 跨天金幣發放邏輯
    if (lastDate != todayStr) {
      final reward = isPremium ? 100 : 20;
      sCoins += reward;
      await StorageService.saveCoins(sCoins);
      await StorageService.saveLastResetDate(todayStr);

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
      _messages.add("🚨 警告：使用者菸癮犯了！已通知好友！");
      _messages.add("💬 好友小明：堅持住！快進入下方的緩解艙！");
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
                    _buildTile(Icons.menu_book, "1. 醫學常識 (內建戒菸文章)", "Medical"),
                    _buildTile(
                      Icons.sentiment_satisfied,
                      "2. 極短篇笑話 (短文小故事)",
                      "Stories",
                    ),
                    _buildTile(
                      Icons.video_library,
                      "3. YouTube影片 (看一下影片)",
                      "YouTube",
                    ),
                    _buildTile(Icons.audiotrack, "4. 音樂連結 (聽一下音樂)", "Music"),
                    _buildTile(
                      Icons.sports_esports,
                      "5. 遊戲大廳 (內建小遊戲)",
                      "Games",
                    ),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        dense: true,
                        leading: const Icon(Icons.forum, color: Colors.blue),
                        title: const Text(
                          "6. 前往論壇大廳",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 12),
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: _ThemeColors.primary),
        title: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 12,
          color: Colors.grey,
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MitigationPage(title: page),
            ),
          );
          _loadStoredData();
        },
      ),
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
        elevation: 0,
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
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.orange.shade100),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShopPage()),
                );
                _loadStoredData();
              },
              child: ListTile(
                leading: const Icon(
                  Icons.stars,
                  color: Colors.orange,
                  size: 28,
                ),
                title: const Text(
                  "目前擁有金幣庫存",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
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
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.orange,
                    ),
                  ],
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(
                    _messages[index],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "已抽支數",
                  "${engine.totalSmoked} 支",
                  Colors.red.shade400,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  "剩餘額度",
                  "${engine.remaining} 支",
                  _ThemeColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _ThemeColors.cardBg,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  "距離下一次解鎖抽菸倒數",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  countdownString,
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: Color(0xFF1B5E20),
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.gpp_bad),
                  label: const Text(
                    "🚨 SOS 求救",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _triggerSOS,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canSmoke
                        ? _ThemeColors.primary
                        : Colors.grey.shade300,
                    foregroundColor: canSmoke
                        ? Colors.white
                        : Colors.grey.shade500,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  icon: Icon(
                    canSmoke ? Icons.check_circle_outline : Icons.lock_outline,
                  ),
                  label: Text(
                    canSmoke ? "🟢 記錄抽菸" : "🔒 尚未解鎖",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: canSmoke ? _smoke : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ForumPage()),
                  ),
                  child: const Text("交流論壇"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ShopPage()),
                  ),
                  child: const Text("金幣商城"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "📋 控菸今日排程表:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: engine.schedule.map((t) {
              final timeStr =
                  "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade100),
                ),
                child: Text(
                  timeStr,
                  style: const TextStyle(
                    color: _ThemeColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _ThemeColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
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
