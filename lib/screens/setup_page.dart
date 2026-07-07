import 'package:flutter/material.dart';
import '../screens/content_management_page.dart';
import '../services/storage_service.dart';
import '../services/user_service.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});
  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _yearsCtrl = TextEditingController();
  final _countCtrl = TextEditingController();
  final _monthCtrl = TextEditingController(text: "3");

  double _days = 90.0;
  TimeOfDay _firstTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _lastTime = const TimeOfDay(hour: 22, minute: 0);
  int _tabIndex = 0;

  // 💡 即時同步更新 Planned 字串的核心變數
  int _currentPlanned = 5;

  @override
  void initState() {
    super.initState();
    _loadStoredSettings();
  }

  Future<void> _loadStoredSettings() async {
    final name = await StorageService.getUserName();
    final count = await StorageService.getDailyCount();
    final age = await StorageService.getUserAge();
    final years = await StorageService.getUserYears();
    final firstTimeStr = await StorageService.getFirstSmokeTime();
    final lastTimeStr = await StorageService.getLastSmokeTime();

    final fParts = firstTimeStr.split(':');
    final lParts = lastTimeStr.split(':');

    setState(() {
      _nameCtrl.text = name;
      _countCtrl.text = count.toString();
      _ageCtrl.text = age.toString();
      _yearsCtrl.text = years.toString();
      _currentPlanned = count;
      _firstTime = TimeOfDay(
        hour: int.tryParse(fParts[0]) ?? 8,
        minute: int.tryParse(fParts[1]) ?? 0,
      );
      _lastTime = TimeOfDay(
        hour: int.tryParse(lParts[0]) ?? 22,
        minute: int.tryParse(lParts[1]) ?? 0,
      );
    });
  }

  void _onMonthTextChanged(String text) {
    final months = int.tryParse(text) ?? 0;
    if (months >= 1 && months <= 12) {
      setState(() {
        _days = (months * 30).toDouble();
      });
    }
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
      appBar: AppBar(title: const Text("Plan Settings")),
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
            // 💡 當你在這裡打字輸入 15 的時候，下方的看板會當場「即時連動」
            TextField(
              controller: _countCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Daily Allowed"),
              onChanged: (val) {
                setState(() {
                  _currentPlanned = int.tryParse(val) ?? 5;
                });
              },
            ),
            const SizedBox(height: 20),

            const Text(
              "2. Plan Duration (2.2.1)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _monthCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Months (1-12)",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _onMonthTextChanged,
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  "= ${_days.round()} Days",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Slider(
              value: _days,
              min: 30,
              max: 360,
              divisions: 11,
              onChanged: (val) {
                setState(() {
                  _days = val;
                  _monthCtrl.text = (val ~/ 30).toString();
                });
              },
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

            // === 📋 大綱 2.3.4 日/週/月多階層展開比對區 ===
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

            // 💡 透過最直觀的動態條件式判斷，徹底瓦解卡死快取！
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Builder(
                builder: (context) {
                  if (_tabIndex == 0) {
                    return Text(
                      "📋 Day Schedule:\nPlanned: $_currentPlanned | Actual: 0",
                    );
                  } else if (_tabIndex == 1) {
                    return Text(
                      "📊 Week Report:\nPlanned: ${_currentPlanned * 7} | Actual: 0",
                    );
                  } else {
                    return Text(
                      "📅 Month Progress:\nPlanned: ${_currentPlanned * 30} | Actual: 0",
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 25),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                final name = _nameCtrl.text.trim();
                final count = int.tryParse(_countCtrl.text) ?? 5;
                final age = int.tryParse(_ageCtrl.text) ?? 28;
                final years = int.tryParse(_yearsCtrl.text) ?? 8;

                // ── 格式驗證 ──────────────────────────────────────
                final fmtErr = UserService.validateNameFormat(name);
                if (fmtErr != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('⚠️ $fmtErr'),
                      backgroundColor: Colors.red.shade700,
                    ),
                  );
                  return;
                }

                // ── 重複名稱檢查 ──────────────────────────────────
                final uid = UserService.currentUid;
                if (uid != null) {
                  final service = UserService();
                  final oldName = await StorageService.getUserName();
                  if (name != oldName) {
                    final available = await service.isNameAvailable(
                      name,
                      excludeUid: uid,
                    );
                    if (!available) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('⚠️ 「$name」已被使用，請換一個暱稱'),
                            backgroundColor: Colors.red.shade700,
                          ),
                        );
                      }
                      return;
                    }
                    // 預訂新暱稱（釋放舊的）
                    await service.reserveName(uid, name, oldName: oldName);
                  }
                }

                // ── 儲存本機 ──────────────────────────────────────
                await StorageService.saveUserName(name);
                await StorageService.saveDailyCount(count);
                await StorageService.saveUserAge(age);
                await StorageService.saveUserYears(years);
                final fh = _firstTime.hour.toString().padLeft(2, '0');
                final fm = _firstTime.minute.toString().padLeft(2, '0');
                final lh = _lastTime.hour.toString().padLeft(2, '0');
                final lm = _lastTime.minute.toString().padLeft(2, '0');
                await StorageService.saveFirstSmokeTime('$fh:$fm');
                await StorageService.saveLastSmokeTime('$lh:$lm');

                // ── 同步到 Firestore ──────────────────────────────
                if (uid != null) {
                  try {
                    await UserService().saveProfile(uid, {
                      'name': name,
                      'daily_count': count,
                      'user_age': age,
                      'user_years': years,
                      'first_smoke_time': '$fh:$fm',
                      'last_smoke_time': '$lh:$lm',
                    });
                  } catch (_) {}
                }

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text(
                "Save and Apply Settings",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContentManagementPage(),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
              child: const Text(
                "內容管理後台",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
