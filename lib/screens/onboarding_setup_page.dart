import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/user_service.dart';
import 'home_page.dart';

/// 首次登入後的完整個人資料設定流程（三步驟）
/// Step 1：帳號暱稱
/// Step 2：基本身份資料（年齡、菸齡）
/// Step 3：戒菸排程設定（每日支數、抽菸時間窗口、戒菸期限）
class OnboardingSetupPage extends StatefulWidget {
  final String uid;
  final UserService userService;
  final String prefillName;

  const OnboardingSetupPage({
    super.key,
    required this.uid,
    required this.userService,
    this.prefillName = '',
  });

  @override
  State<OnboardingSetupPage> createState() => _OnboardingSetupPageState();
}

class _OC {
  static const primary = Color(0xFF1B5E20);

  static const bg = Color(0xFFE8F5E9);
  static const cardBg = Colors.white;
}

class _OnboardingSetupPageState extends State<OnboardingSetupPage> {
  final _pageController = PageController();
  int _currentStep = 0;
  bool _isSaving = false;

  // Step 1：暱稱
  final _nameCtrl = TextEditingController();
  String? _nameError;

  // Step 2：基本資料
  final _ageCtrl = TextEditingController(text: '30');
  final _yearsCtrl = TextEditingController(text: '5');

  // Step 3：排程
  final _countCtrl = TextEditingController(text: '10');
  TimeOfDay _firstTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _lastTime = const TimeOfDay(hour: 22, minute: 0);
  double _months = 3;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.prefillName;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _yearsCtrl.dispose();
    _countCtrl.dispose();
    super.dispose();
  }

  // ── 步驟導航 ─────────────────────────────────────────────────────
  Future<void> _nextStep() async {
    if (_currentStep == 0) {
      // 格式驗證
      final fmtErr = UserService.validateNameFormat(_nameCtrl.text.trim());
      if (fmtErr != null) {
        setState(() => _nameError = fmtErr);
        return;
      }
      // 即時重複名稱檢查（在前進前就告知，不用走到最後才退回）
      setState(() {
        _nameError = null;
        _isSaving = true;
      });
      final available = await widget.userService.isNameAvailable(
        _nameCtrl.text.trim(),
        excludeUid: widget.uid,
      );
      setState(() => _isSaving = false);
      if (!available) {
        setState(() => _nameError = '「${_nameCtrl.text.trim()}」已被使用，請換一個');
        return;
      }
    }
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  void _prevStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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

  // ── 最終送出 ─────────────────────────────────────────────────────
  Future<void> _submit() async {
    setState(() => _isSaving = true);

    final name = _nameCtrl.text.trim();
    final age = int.tryParse(_ageCtrl.text) ?? 30;
    final years = int.tryParse(_yearsCtrl.text) ?? 5;
    final count = int.tryParse(_countCtrl.text) ?? 10;
    final fh = _firstTime.hour.toString().padLeft(2, '0');
    final fm = _firstTime.minute.toString().padLeft(2, '0');
    final lh = _lastTime.hour.toString().padLeft(2, '0');
    final lm = _lastTime.minute.toString().padLeft(2, '0');

    // 重複名稱檢查（附 excludeUid 防止同用戶誤報）
    final available = await widget.userService.isNameAvailable(
      name,
      excludeUid: widget.uid,
    );
    if (!available) {
      setState(() {
        _isSaving = false;
        _nameError = '「$name」已被使用，請返回修改';
      });
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      return;
    }

    // 儲存到本機
    await StorageService.saveUserName(name);
    await StorageService.saveUserAge(age);
    await StorageService.saveUserYears(years);
    await StorageService.saveDailyCount(count);
    await StorageService.saveFirstSmokeTime('$fh:$fm');
    await StorageService.saveLastSmokeTime('$lh:$lm');
    await StorageService.saveCoins(20);
    await StorageService.savePremium(false);

    // 預訂暱稱 + 同步到 Firestore
    await widget.userService.reserveName(widget.uid, name);
    await widget.userService.saveProfile(widget.uid, {
      'name': name,
      'user_age': age,
      'user_years': years,
      'daily_count': count,
      'first_smoke_time': '$fh:$fm',
      'last_smoke_time': '$lh:$lm',
      'coins': 20,
      'is_premium': false,
      'created_at': DateTime.now().toIso8601String(),
    });

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  // ── 共用 UI ──────────────────────────────────────────────────────
  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _OC.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStepIndicator() {
    const steps = ['帳號', '身份', '排程'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(steps.length, (i) {
        final active = i == _currentStep;
        final done = i < _currentStep;
        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: active ? 36 : 28,
              height: 28,
              decoration: BoxDecoration(
                color: done || active ? _OC.primary : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: done
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: active ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
              ),
            ),
            if (i < steps.length - 1)
              Container(
                width: 40,
                height: 2,
                color: i < _currentStep ? _OC.primary : Colors.grey.shade200,
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),
          ],
        );
      }),
    );
  }

  // ── Step 1：暱稱 ─────────────────────────────────────────────────
  Widget _buildStep1() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '👤 設定您的暱稱',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _OC.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '暱稱將顯示在論壇與排行榜上。\n2～15 字，可含中文、英文、數字、底線。',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameCtrl,
            maxLength: 15,
            decoration: InputDecoration(
              labelText: '暱稱',
              counterText: '',
              errorText: _nameError,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person_outline),
            ),
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
        ],
      ),
    );
  }

  // ── Step 2：基本資料 ─────────────────────────────────────────────
  Widget _buildStep2() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📋 基本身份資料',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _OC.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '用於計算健康風險與個人化戒菸建議。',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ageCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '年齡（歲）',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.cake_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _yearsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '菸齡（年）',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.smoke_free),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            '💡 這些資料僅用於個人化設定，不會公開顯示。',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ── Step 3：戒菸排程 ─────────────────────────────────────────────
  Widget _buildStep3() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🗓️ 設定戒菸排程',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _OC.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '系統將依此動態計算每支菸的允許時間窗口。',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // 每日允許支數
          TextField(
            controller: _countCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '目前每日抽菸數',
              hintText: '例如：10',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.format_list_numbered),
              suffixText: '支／天',
              helperText: '設定後可在排程頁面隨時調整',
            ),
          ),
          const SizedBox(height: 16),

          // 抽菸時間窗口
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.wb_sunny_outlined, size: 18),
                  label: Text('第一支：${_firstTime.format(context)}'),
                  onPressed: () => _selectTime(true),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.nightlight_outlined, size: 18),
                  label: Text('最後：${_lastTime.format(context)}'),
                  onPressed: () => _selectTime(false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 戒菸期限
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '戒菸計劃期限',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${_months.round()} 個月',
                style: const TextStyle(
                  color: _OC.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: _months,
            min: 1,
            max: 12,
            divisions: 11,
            activeColor: _OC.primary,
            label: '${_months.round()} 個月',
            onChanged: (v) => setState(() => _months = v),
          ),
          const SizedBox(height: 4),
          const Text(
            '💡 建議 3～6 個月，系統會逐步降低每日允許支數。',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = [_buildStep1, _buildStep2, _buildStep3];
    final isLast = _currentStep == 2;

    return Scaffold(
      backgroundColor: _OC.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          '建立戒菸個人檔案',
          style: TextStyle(
            color: _OC.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildStepIndicator(),
            const SizedBox(height: 24),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentStep = i),
                children: steps
                    .map(
                      (b) => SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: b(),
                      ),
                    )
                    .toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _prevStep,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: _OC.primary),
                        ),
                        child: const Text(
                          '上一步',
                          style: TextStyle(color: _OC.primary),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _OC.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              isLast ? '開始戒菸之旅 🚀' : '下一步',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
