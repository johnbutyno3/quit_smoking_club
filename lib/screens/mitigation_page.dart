import 'dart:async';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class MitigationPage extends StatefulWidget {
  final String title;
  const MitigationPage({super.key, required this.title});

  @override
  State<MitigationPage> createState() => _MitigationPageState();
}

class _MitigationPageState extends State<MitigationPage> {
  Timer? _timer;
  int _secondsElapsed = 0;
  int _coinsEarned = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
          _coinsEarned = _secondsElapsed ~/ 5;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const Text(
                      "💎 Bonus Center",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text("Time: $_secondsElapsed s"),
                    Text(
                      "Coins: $_coinsEarned",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "Every 5 seconds rewards you "
              "with free virtual coins!",
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 25),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              // 💡 點擊離開時，把賺到的金幣累加存入硬碟
              onPressed: () async {
                final current = await StorageService.getCoins();
                await StorageService.saveCoins(current + _coinsEarned);
                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text("Claim & Exit"),
            ),
          ],
        ),
      ),
    );
  }
}
