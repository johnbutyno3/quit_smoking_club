import 'dart:async';
import 'package:flutter/material.dart';
import '../models/smoking_state.dart';
import '../services/smoking_engine.dart';
import 'forum_page.dart';
import 'shop_page.dart';
import 'setup_page.dart';
import '../services/storage_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SmokingEngine engine;
  String _noticeText = "歡迎來到戒菸俱樂部！挑戰正在進行中。";

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // 1. 初始化一個基本計時器，防禦任何變數卡死
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });

    // 2. 觸發非同步讀取
    _loadStoredData();
  }

  // 3. 獨立的撈資料方法 (獨立出來絕不干擾 initState 結構)
  Future<void> _loadStoredData() async {
    final now = DateTime.now();
    // 1. 去硬碟撈出最新修改的數量和名字
    final sCount = await StorageService.getDailyCount();
    final sName = await StorageService.getUserName();

    if (mounted) {
      setState(() {
        // 2. 建立新狀態並指回給 engine 核心
        final state = SmokingState(
          startTime: DateTime(now.year, now.month, now.day, 8, 0),
          endTime: DateTime(now.year, now.month, now.day, 22, 0),
          plannedCount: sCount,
        );
        engine = SmokingEngine(state);

        // 3. 大綱3.2.2：動態更新頂部標準文字框的名字
        _noticeText = "Welcome back, $sName!";
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _smoke() {
    setState(() {
      engine.state = engine.state.addSmoke(DateTime.now());
      // 💡 真正去覆寫它，提示就會消失！
      _noticeText = "You recorded a smoke.";
    });
  }

  void _triggerSOS() {
    setState(() {
      // 💡 真正去覆寫它，提示就會消失！
      _noticeText = "🚨 SOS Mode Triggered!";
    });
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 180,
          child: Column(
            children: [
              const Text("🚨 SOS Mode"),
              const SizedBox(height: 10),
              const Text("Keep going!"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        );
      },
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
    if (engine.totalSmoked >= engine.plannedCount) {
      return false;
    }
    final next = nextSmokeTime;
    if (next == null) return true;
    return now.isAfter(next);
  }

  // ⏱️ 精確計算倒數時分秒的文字
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

  @override
  Widget build(BuildContext context) {
    final next = nextSmokeTime;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quit Smoking"),
        actions: [
          // 3.2.7 設定鈕：點擊開啟基本資料與計畫設定
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SetupPage()),
              );
            },
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 貼在 ListView( children: [ 的正下方
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(_noticeText, style: const TextStyle(fontSize: 13)),
          ),

          Text("Smoked: ${engine.totalSmoked}"),
          Text("Remaining: ${engine.remaining}"),
          const Divider(),
          const SizedBox(height: 15),

          // ⏱️ 倒數計時表文字區塊
          Center(
            child: Column(
              children: [
                Text(
                  countdownString,
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  next == null ? "End" : "Next: ${next.hour}:${next.minute}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),

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
          const SizedBox(height: 20),
          const Text("Schedule:"),
          ...engine.schedule.map((t) => Text("${t.hour}:${t.minute}")),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            icon: const Icon(Icons.chat, color: Colors.white),
            label: const Text(
              "Go to Forums",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ForumPage()),
              );
            },
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            label: const Text(
              "Go to Store",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShopPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
