import 'package:flutter/material.dart';
import '../screens/content_management_page.dart';
import '../screens/schedule_page.dart';
import '../screens/login_page.dart';
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

  double _days = 90.0;
  TimeOfDay _firstTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _lastTime = const TimeOfDay(hour: 22, minute: 0);

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
    final durationDays = await StorageService.getPlanDurationDays();
    final fParts = firstTimeStr.split(':');
    final lParts = lastTimeStr.split(':');
    setState(() {
      _nameCtrl.text = name;
      _countCtrl.text = count.toString();
      _ageCtrl.text = age.toString();
      _yearsCtrl.text = years.toString();
      _days = durationDays.toDouble();
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

  @override
  Widget build(BuildContext context) {
    final fh = _firstTime.hour.toString().padLeft(2, '0');
    final fm = _firstTime.minute.toString().padLeft(2, '0');
    final lh = _lastTime.hour.toString().padLeft(2, '0');
    final lm = _lastTime.minute.toString().padLeft(2, '0');
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '設定',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: '基本資料',
            trailing: TextButton(
              onPressed: () => _showEditDialog(context),
              child: const Text(
                '編輯',
                style: TextStyle(color: Color(0xFF1B5E20)),
              ),
            ),
            children: [
              _InfoRow(
                label: '暱稱',
                value: _nameCtrl.text.isEmpty ? '無' : _nameCtrl.text,
              ),
              _InfoRow(label: '年齡', value: '${_ageCtrl.text} 歲'),
              _InfoRow(label: '菸齡', value: '${_yearsCtrl.text} 年'),
              _InfoRow(label: '每日抽菸量', value: '${_countCtrl.text} 支'),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: '戒菸計畫',
            children: [
              _InfoRow(label: '計畫天數', value: '${_days.round()} 天'),
              _InfoRow(label: '第一支菸時間', value: '$fh:$fm'),
              _InfoRow(label: '最後一支菸時間', value: '$lh:$lm'),
            ],
          ),
          const SizedBox(height: 12),
          _ActionTile(
            icon: Icons.calendar_today_outlined,
            label: '查詢戒菸行程',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SchedulePage()),
            ),
          ),
          const SizedBox(height: 8),
          _ActionTile(
            icon: Icons.manage_search,
            label: '內容管理後台',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ContentManagementPage()),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(color: Colors.redAccent),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('確認登出'),
                  content: const Text('登出後資料將保留在雲端，下次登入即可同步回來。'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('取消'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        '登出',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await UserService().signOut();

                // 必須在這裡加上檢查！如果等待結束後畫面已經不存在，就直接結束不執行導頁
                if (!context.mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (_) => false,
                );
              }
            },
            child: const Text(
              '登出帳號',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('編輯基本資料'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(_nameCtrl, '暱稱'),
              const SizedBox(height: 8),
              _dialogField(_ageCtrl, '年齡', type: TextInputType.number),
              const SizedBox(height: 8),
              _dialogField(_yearsCtrl, '菸齡 (年)', type: TextInputType.number),
              const SizedBox(height: 8),
              _dialogField(_countCtrl, '每日吸菸支數', type: TextInputType.number),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.wb_sunny_outlined, size: 16),
                      label: Text(
                        '第一支菸\n${_firstTime.format(ctx)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11),
                      ),
                      onPressed: () async {
                        final p = await showTimePicker(
                          context: ctx,
                          initialTime: _firstTime,
                        );
                        if (p != null) setState(() => _firstTime = p);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.nightlight_outlined, size: 16),
                      label: Text(
                        '最後一支菸\n${_lastTime.format(ctx)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11),
                      ),
                      onPressed: () async {
                        final p = await showTimePicker(
                          context: ctx,
                          initialTime: _lastTime,
                        );
                        if (p != null) setState(() => _lastTime = p);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (ctx2, setS) => Row(
                  children: [
                    const Text('計畫天數：', style: TextStyle(fontSize: 13)),
                    Expanded(
                      child: Slider(
                        value: _days,
                        min: 30,
                        max: 360,
                        divisions: 11,
                        label: '${_days.round()} 天',
                        onChanged: (v) {
                          setState(() => _days = v);
                          setS(() {});
                        },
                      ),
                    ),
                    Text(
                      '${_days.round()}天',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
            ),
            onPressed: () async {
              final name = _nameCtrl.text.trim();
              final count = int.tryParse(_countCtrl.text) ?? 5;
              final age = int.tryParse(_ageCtrl.text) ?? 28;
              final years = int.tryParse(_yearsCtrl.text) ?? 8;
              final fmtErr = UserService.validateNameFormat(name);
              if (fmtErr != null) {
                ScaffoldMessenger.of(
                  ctx,
                ).showSnackBar(SnackBar(content: Text('格式錯誤: $fmtErr')));
                return;
              }
              final uid = UserService.currentUid;
              if (uid != null) {
                final service = UserService();
                await StorageService.saveUserName(name);
                await StorageService.saveDailyCount(count);
                await StorageService.saveUserAge(age);
                await StorageService.saveUserYears(years);
                await StorageService.savePlanDurationDays(_days.round());
                await service.saveProfile(uid, {
                  'name': name,
                  'daily_count': count,
                  'user_age': age,
                  'user_years': years,
                  'plan_days': _days.round(),
                  'first_smoke': '${_firstTime.hour}:${_firstTime.minute}',
                  'last_smoke': '${_lastTime.hour}:${_lastTime.minute}',
                });
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('儲存', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(
    TextEditingController ctrl,
    String label, {
    TextInputType? type,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final List<Widget> children;
  const _SectionCard({
    required this.title,
    this.trailing,
    required this.children,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                ?trailing,
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1B5E20)),
        title: Text(label, style: const TextStyle(fontSize: 14)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
