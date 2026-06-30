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
  static const primary = Color(0xFF1B5E20);
  static const accent = Color(0xFF4CAF50);
  static const bgTop = Color(0xFFE8F5E9);
  static const bgBot = Color(0xFFF5F7F6);
  static const glassBorder = Color(0x33FFFFFF);
  static const cardBg = Colors.white;
}

class _HomePageState extends State<HomePage> {
  // 💡 核心修復：把不小心被覆蓋掉的變數宣告安全鎖在最上方！
  late SmokingEngine engine;
  Timer? _timer;
  int _myCoins = 0;

  final List<String> _messages = ["歡迎來到戒菸俱樂部！挑戰正在進行中。"];

  final List<String> _quotes = [
    "每少抽一支菸都是勝利，你正在奪回生命的掌控權！",
    "深呼吸！這口新鮮空氣比尼古丁更有力量！",
    "菸癮每次只會持續3分鐘，撐過去你就贏了！",
    "省下的不時候菸錢，更是與家人相處的幸福時光！",
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
    final now = DateTime.now();

    // 💡 智慧配額區間劃分：尋找這支菸屬於哪一個格子的區間
    int matchedIndex = 0;
    for (int i = 0; i < engine.schedule.length; i++) {
      final sTime = engine.schedule[i];
      if (now.hour > sTime.hour ||
          (now.hour == sTime.hour && now.minute >= sTime.minute)) {
        matchedIndex = i;
      }
    }

    // 💡 跨輪勵志讚美檢查
    if (matchedIndex > engine.totalSmoked) {
      _messages.add("🎉 你太棒了，少抽一支菸！");
    }

    setState(() {
      engine.state = engine.state.addSmoke(now);
      _messages.add(
        "Recorded smoke at "
        "${now.hour.toString().padLeft(2, '0')}:"
        "${now.minute.toString().padLeft(2, '0')}.",
      );
    });
  }

  void _triggerSOS() {
    setState(() {
      _messages.add("🚨 警告：使用者菸瘾犯了！已通知好友！");
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
            color: _ThemeColors.bgBot,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                "🚨 菸瘾危機緩解艙",
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
        leading: Icon(icon, color: _ThemeColors.accent),
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_ThemeColors.bgTop, _ThemeColors.bgBot],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            "戒菸俱樂部",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white.withOpacity(0.8),
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Card(
              color: Colors.white.withOpacity(0.9),
              elevation: 4,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(
                  color: _ThemeColors.glassBorder,
                  width: 1.5,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
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
            const SizedBox(height: 16),
            Container(
              height: 95,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _ThemeColors.cardBg.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) => Text(
                  _messages[index],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    "已抽支數",
                    "${engine.totalSmoked} 支",
                    Colors.red.shade400,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildStatCard(
                    "剩餘額度",
                    "${engine.remaining} 支",
                    _ThemeColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_ThemeColors.primary, Color(0xFF0D3211)],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: _ThemeColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "距離下一次解鎖抽菸倒數",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFFE8F5E9),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    countdownString,
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
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
                      elevation: 4,
                      shadowColor: Colors.red.withOpacity(0.2),
                    ),
                    icon: const Icon(Icons.gpp_bad),
                    label: const Text(
                      "🚨 SOS 求協助",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: _triggerSOS,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canSmoke
                          ? _ThemeColors.accent
                          : Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: canSmoke ? 4 : 0,
                      shadowColor: _ThemeColors.accent.withOpacity(0.3),
                    ),
                    icon: Icon(
                      canSmoke
                          ? Icons.check_circle_outline
                          : Icons.lock_outline,
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForumPage(),
                      ),
                    ),
                    child: const Text("交流論壇"),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
            const SizedBox(height: 28),
            const Text(
              "📋 控菸今日排程表:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),

            // 💡 智慧型區間比對排程：過期自動褪色變暗，且右側精準按區間點亮已抽 ✓ 狀態
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(engine.schedule.length, (index) {
                final t = engine.schedule[index];
                final now = DateTime.now();
                final cellTime = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  t.hour,
                  t.minute,
                );

                // 智慧區間判定：檢查使用者的抽菸時間是否落在這格與下一格之間
                bool thisCellIsSmoked = false;
                if (engine.state.smokeRecords.isNotEmpty) {
                  if (index == engine.schedule.length - 1) {
                    thisCellIsSmoked =
                        now.isAfter(cellTime) && engine.totalSmoked > index;
                  } else {
                    final nextT = engine.schedule[index + 1];
                    final nextCellTime = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      nextT.hour,
                      nextT.minute,
                    );
                    thisCellIsSmoked = engine.state.smokeRecords.any(
                      (rec) =>
                          (rec.isAfter(cellTime) ||
                              rec.isAtSameMomentAs(cellTime)) &&
                          rec.isBefore(nextCellTime),
                    );
                  }
                }

                final isPast = now.isAfter(cellTime);
                final hasSmoked = thisCellIsSmoked;

                final chipBg = hasSmoked
                    ? Colors.green.shade50
                    : (isPast ? Colors.grey.shade200 : Colors.green.shade50);
                final chipBorder = hasSmoked
                    ? Colors.green.shade100
                    : (isPast ? Colors.grey.shade300 : Colors.green.shade100);
                final textColor = isPast && !hasSmoked
                    ? Colors.grey.shade600
                    : _ThemeColors.primary;

                final timeStr =
                    "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: chipBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        hasSmoked
                            ? Icons.check_circle
                            : (isPast
                                  ? Icons.cancel_outlined
                                  : Icons.lock_clock),
                        size: 14,
                        color: hasSmoked
                            ? Colors.green
                            : (isPast ? Colors.grey : Colors.grey.shade400),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hasSmoked ? "已抽 ✓" : (isPast ? "未記錄" : "待解鎖"),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: hasSmoked
                              ? Colors.green
                              : (isPast ? Colors.grey : Colors.grey.shade400),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _ThemeColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
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
    if (engine.totalSmoked >= engine.state.plannedCount) return false;
    final unlockTime = engine.nextUnlockTime;
    if (unlockTime == null) return true;
    return now.isAfter(unlockTime);
  }

  String get countdownString {
    final unlockTime = engine.nextUnlockTime;
    if (unlockTime == null) return "00:00:00";
    final now = DateTime.now();
    final diff = unlockTime.difference(now);
    if (diff.isNegative) return "00:00:00";
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }
}
