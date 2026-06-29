import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});
  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController(text: "28");
  final _yearsCtrl = TextEditingController(text: "8");
  final _countCtrl = TextEditingController();

  double _days = 90.0;
  TimeOfDay _firstTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _lastTime = const TimeOfDay(hour: 22, minute: 0);
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadStoredSettings(); // 💡 進入設定頁時，自動回填歷史資料
  }

  // 📡 回填歷史紀錄，防止一進來就被預設值洗掉
  Future<void> _loadStoredSettings() async {
    final name = await StorageService.getUserName();
    final count = await StorageService.getDailyCount();
    setState(() {
      _nameCtrl.text = name;
      _countCtrl.text = count.toString();
    });
  }

  Future<void> _selectTime(bool isFirst) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isFirst ? _firstTime : _lastTime,
    );
    if (picked != null) {
      setState(() {
        if (isFirst) {
          _firstTime = picked;
        } else {
          _lastTime = picked;
        }
      });
    }
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
            },
          ),
        ],
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            const Text(
              "1. Basic Profile (1.3)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ageCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Age"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _yearsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Years Smoking",
                    ),
                  ),
                ),
              ],
            ),
            TextField(
              controller: _countCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Daily Allowed"),
            ),
            const SizedBox(height: 20),

            Text("2. Plan Duration: ${_days.round()} Days (2.2.1)"),
            Slider(
              value: _days,
              min: 10,
              max: 360,
              divisions: 350,
              onChanged: (val) => setState(() => _days = val),
            ),
            const SizedBox(height: 10),

            const Text(
              "3. Smoke Time Window (2.2.2)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ListTile(
              dense: true,
              title: Text("First Smoke: ${_firstTime.format(context)}"),
              trailing: const Icon(Icons.access_time, size: 20),
              onTap: () => _selectTime(true),
            ),
            ListTile(
              dense: true,
              title: Text("Last Smoke: ${_lastTime.format(context)}"),
              trailing: const Icon(Icons.access_time, size: 20),
              onTap: () => _selectTime(false),
            ),
            const Divider(),

            const Text(
              "4. Schedule Views (2.3.4)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => _tabIndex = 0),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _tabIndex == 0
                        ? Colors.green
                        : Colors.grey,
                  ),
                  child: const Text("Day"),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _tabIndex = 1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _tabIndex == 1 ? Colors.blue : Colors.grey,
                  ),
                  child: const Text("Week"),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _tabIndex = 2),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _tabIndex == 2
                        ? Colors.purple
                        : Colors.grey,
                  ),
                  child: const Text("Month"),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IndexedStack(
                index: _tabIndex,
                children: [
                  const Text("📋 Day Schedule:\nPlanned: 5 | Actual: 0"),
                  const Text("📊 Week Report:\nPlanned: 35 | Actual: 0"),
                  const Text("📅 Month Progress:\nPlanned: 150 | Actual: 0"),
                ],
              ),
            ),
            const SizedBox(height: 25),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                final name = _nameCtrl.text;
                final count = int.tryParse(_countCtrl.text) ?? 5;
                await StorageService.saveUserName(name);
                await StorageService.saveDailyCount(count);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text(
                "Save and Apply Settings",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
