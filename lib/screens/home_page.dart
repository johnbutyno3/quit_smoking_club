import 'dart:async';
import 'package:flutter/material.dart';
import '../models/smoking_state.dart';
import '../services/smoking_engine.dart';
import '../services/storage_service.dart';
import 'forum_page.dart';
import 'shop_page.dart';
import 'setup_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SmokingEngine engine;
  Timer? _timer;

  // 3.2.2 & 3.2.6.1 訊息牆列表
  final List<String> _messages = ["歡迎來到戒菸俱樂部！挑戰正在進行中。"];

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

    if (mounted) {
      setState(() {
        final state = SmokingState(
          startTime: DateTime(now.year, now.month, now.day, 8, 0),
          endTime: DateTime(now.year, now.month, now.day, 22, 0),
          plannedCount: sCount,
        );
        engine = SmokingEngine(state);
        _messages.add("Welcome back, $sName!");
      });
    }
  }

  void _smoke() {
    setState(() {
      engine.state = engine.state.addSmoke(DateTime.now());
      _messages.add("You recorded a smoke.");
    });
  }

  void _triggerSOS() {
    setState(() {
      _messages.add("🚨 系統：您正在犯菸癮，已通知好友！");
      _messages.add("💬 朋友小明：加油！想想你的健康！");
      _messages.add("🎁 朋友小華送給了你 [冰鎮薄荷糖]！");
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
          // 3.2.2 標準文字框訊息牆
          Container(
            height: 90,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 15),
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
                  child: Text(_messages[index]),
                );
              },
            ),
          ),

          Text("Smoked: ${engine.totalSmoked}"),
          Text("Remaining: ${engine.remaining}"),
          const Divider(),
          const SizedBox(height: 10),

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
          const SizedBox(height: 20),

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

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            icon: const Icon(Icons.chat, color: Colors.white),
            label: const Text("Go to Forums"),
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
            label: const Text("Go to Store"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShopPage()),
              );
            },
          ),
          const SizedBox(height: 20),

          const Text("Schedule:"),
          ...engine.schedule.map((t) => Text("${t.hour}:${t.minute}")),
        ],
      ),
    );
  }
}
