import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/smoking_plan.dart';
import '../models/smoking_state.dart';
import '../models/user_role.dart';
import '../models/user_smoking_status.dart';
import '../repositories/coin/coin_repository.dart';
import '../services/achievement_engine.dart';
import '../services/coin_service.dart';
import '../services/recovery_engine.dart';
import '../services/smoking_engine.dart';
import '../services/storage_service.dart';
import '../services/user_service.dart';
import '../pages/coin_page.dart';
import '../l10n/app_localizations.dart';
import 'forum_page.dart';
import 'game_hub_page.dart';
import 'mitigation_page.dart';
import 'reading_library_page.dart';
import 'music_library_page.dart';
import 'youtube_library_page.dart';
import 'schedule_page.dart';
import 'setup_page.dart';

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
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final CoinRepository _coinRepository = CoinRepository(
    coinService: CoinService(),
  );
  final CoinService coinService = CoinService();

  late SmokingEngine engine;
  late AchievementEngine achievement;
  late RecoveryEngine recovery;
  late SmokingState state;

  Timer? _timer;
  bool _isLoaded = false;
  int _myCoins = 0;
  int _cigarettePrice = 120;
  bool _isVibrating = false;
  String? _activeNotification;
  bool _hasTriggeredUnlockNotify = false;

  final List<String> _quotes = [
    '深呼吸，撐過這一刻就好。',
    '你正在慢慢把生活拿回來。',
    '先轉移注意力，菸癮會過去。',
    '今天的每一次選擇都很重要。',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final now = DateTime.now();
    state = SmokingState(
      planStartDate: now,
      startTime: DateTime(now.year, now.month, now.day, 8),
      endTime: DateTime(now.year, now.month, now.day, 22),
      plannedCount: 5,
      role: UserRole.quitter,
      smokingStatus: SmokingStatus.smoker,
    );

    final plan = SmokingPlan(
      startTime: state.startTime,
      endTime: state.endTime,
      plannedCount: state.plannedCount,
    );
    engine = SmokingEngine(state, plan);
    recovery = RecoveryEngine(state);
    achievement = AchievementEngine(
      smoking: engine,
      recovery: recovery,
      coinRepository: _coinRepository,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_isLoaded) return;
      setState(() {});
      _checkCountdownUnlock();
    });

    _loadStoredData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    if (appState == AppLifecycleState.resumed) {
      _loadStoredData();
    }
  }

  Future<void> _loadStoredData() async {
    final now = DateTime.now();
    final dailyCount = await StorageService.getDailyCount();
    final price = await StorageService.getCigarettePrice();
    final planStartDateStr = await StorageService.getPlanStartDate();
    final records = await StorageService.getSmokeRecordsForToday();
    final first = await StorageService.getFirstSmokeTime();
    final last = await StorageService.getLastSmokeTime();

    final firstParts = first.split(':');
    final lastParts = last.split(':');
    final firstHour = int.tryParse(firstParts.first) ?? 8;
    final firstMinute = firstParts.length > 1 ? int.tryParse(firstParts[1]) ?? 0 : 0;
    final lastHour = int.tryParse(lastParts.first) ?? 22;
    final lastMinute = lastParts.length > 1 ? int.tryParse(lastParts[1]) ?? 0 : 0;

    final planStartDate = planStartDateStr.isEmpty
        ? now
        : DateTime.tryParse(planStartDateStr) ?? now;

    var coins = await _coinRepository.getBalance();
    final isPremium = await StorageService.getPremium();
    final todayKey = '${now.year}-${now.month}-${now.day}';
    final lastReset = await StorageService.getLastResetDate();
    if (lastReset != todayKey) {
      final reward = isPremium ? 100 : 20;
      await StorageService.saveLastResetDate(todayKey);
      final uid = UserService.currentUid;
      if (uid != null) {
        try {
          await _coinRepository.addCoin(reward, 'daily_login_reward');
          coins = await _coinRepository.getBalance();
        } catch (_) {}
      }
    }

    if (!mounted) return;

    final loadedState = SmokingState(
      planStartDate: planStartDate,
      startTime: DateTime(now.year, now.month, now.day, firstHour, firstMinute),
      endTime: DateTime(now.year, now.month, now.day, lastHour, lastMinute),
      plannedCount: dailyCount,
      smokeRecords: records,
      lastSmokeTime: records.isEmpty ? null : records.last,
      role: UserRole.quitter,
      smokingStatus: SmokingStatus.smoker,
    );
    final loadedPlan = SmokingPlan(
      startTime: loadedState.startTime,
      endTime: loadedState.endTime,
      plannedCount: dailyCount,
    );

    setState(() {
      state = loadedState;
      engine = SmokingEngine(loadedState, loadedPlan);
      recovery = RecoveryEngine(loadedState);
      achievement = AchievementEngine(
        smoking: engine,
        recovery: recovery,
        coinRepository: _coinRepository,
      );
      _myCoins = coins;
      _cigarettePrice = price;
      _isLoaded = true;
    });
    await achievement.loadLoginStreak();
  }

  Future<void> _smoke() async {
    if (!canSmoke) return;
    final now = DateTime.now();
    setState(() {
      engine.state = engine.state.addSmoke(now);
    });
    await StorageService.saveSmokeRecords(engine.state.smokeRecords);
    _triggerVibration();
  }

  void _checkCountdownUnlock() {
    final unlockTime = engine.nextUnlockTime;
    if (unlockTime == null) return;
    final ready = !unlockTime.isAfter(DateTime.now());
    if (ready && !_hasTriggeredUnlockNotify) {
      _hasTriggeredUnlockNotify = true;
      _showTopBanner('時間到了，請按「紀錄抽菸」完成本次紀錄。');
    } else if (!ready) {
      _hasTriggeredUnlockNotify = false;
    }
  }

  void _triggerVibration() {
    setState(() => _isVibrating = true);
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _isVibrating = false);
    });
  }

  void _showTopBanner(String message) {
    _triggerVibration();
    setState(() => _activeNotification = message);
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _activeNotification = null);
    });
  }

  void _triggerSOS() {
    final quote = _quotes[Random().nextInt(_quotes.length)];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * .52,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const Text(
              'SOS 求協助',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
            const SizedBox(height: 12),
            Text('「$quote」', textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.self_improvement),
              title: const Text('進入緩解艙'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MitigationPage(title: 'SOS')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openVideoAudio() {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('影片'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const YouTubeLibraryPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.music_note),
              title: const Text('音樂'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MusicLibraryPage()));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 60),
      padding: EdgeInsets.only(left: _isVibrating ? 5 : 0, right: _isVibrating ? 0 : 5),
      child: Container(
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
            title: Text(l10n.appTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white.withAlpha(220),
            elevation: 0,
            actions: [
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CoinPage())),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Center(
                    child: Text('🪙 $_myCoins', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: _ThemeColors.primary),
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const SetupPage()));
                  _loadStoredData();
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                children: [
                  _buildCurrentProgress(),
                  const SizedBox(height: 14),
                  _buildTimerCard(),
                  const SizedBox(height: 14),
                  _buildSchedulePreview(),
                  const SizedBox(height: 14),
                  _buildBottomOptions(),
                ],
              ),
              if (_activeNotification != null)
                Positioned(
                  top: 10,
                  left: 12,
                  right: 12,
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(14),
                    color: _ThemeColors.primary,
                    child: Padding(
                      padding: const EdgeInsets.all(13),
                      child: Row(
                        children: [
                          const Icon(Icons.notifications_active, color: Colors.amber),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_activeNotification!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentProgress() {
    final day = DateTime.now().difference(engine.state.planStartDate).inDays + 1;
    final total = engine.plan.durationDays;
    final achievementProgress = achievement.totalCount == 0 ? 0.0 : achievement.progress;

    return Card(
      elevation: 2,
      color: Colors.white.withAlpha(235),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('目前進度', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _progressPanel(
                    title: '戒菸進度',
                    value: 'Day $day / $total',
                    detail: '今日 ${engine.totalSmoked} / ${engine.todayPlannedCount}',
                    progress: total == 0 ? 0 : (day / total).clamp(0.0, 1.0),
                    icon: Icons.flag_circle_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _progressPanel(
                    title: '成就項目進度',
                    value: '${achievement.completedCount} / ${achievement.totalCount}',
                    detail: '已完成成就',
                    progress: achievementProgress,
                    icon: Icons.emoji_events_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressPanel({
    required String title,
    required String value,
    required String detail,
    required double progress,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 20, color: _ThemeColors.primary), const SizedBox(width: 6), Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))]),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _ThemeColors.primary)),
          const SizedBox(height: 3),
          Text(detail, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            borderRadius: BorderRadius.circular(6),
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation(_ThemeColors.accent),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard() {
    final unlockTime = engine.nextUnlockTime;
    final isReady = unlockTime == null || !unlockTime.isAfter(DateTime.now());
    final diff = unlockTime == null ? Duration.zero : unlockTime.difference(DateTime.now());
    final remainingSeconds = max(0, diff.inSeconds);
    final totalSeconds = max(1, engine.intervalMinutes * 60);
    final elapsedProgress = isReady ? 1.0 : (1 - remainingSeconds / totalSeconds).clamp(0.0, 1.0);

    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          children: [
            const Text('下一次解鎖', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            SizedBox(
              width: 230,
              height: 230,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: CircularProgressIndicator(
                      value: elapsedProgress,
                      strokeWidth: 14,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(isReady ? Colors.orange : _ThemeColors.accent),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(34),
                    child: isReady
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('時間到了', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _ThemeColors.primary)),
                              const SizedBox(height: 6),
                              const Text('要抽菸請按這裡紀錄', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: canSmoke ? _smoke : null,
                                icon: const Icon(Icons.edit_note, size: 18),
                                label: const Text('紀錄抽菸'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _ThemeColors.accent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(countdownString, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: _ThemeColors.primary)),
                              const SizedBox(height: 7),
                              const Text('等待下一次解鎖', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(canSmoke && isReady ? '請確認後再紀錄本次抽菸' : '尚未到時間', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildSchedulePreview() {
    return Card(
      elevation: 1,
      color: Colors.white.withAlpha(235),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            const Icon(Icons.schedule, color: _ThemeColors.primary),
            const SizedBox(width: 8),
            const Expanded(child: Text('今日抽菸排程', style: TextStyle(fontWeight: FontWeight.bold))),
            Text('${engine.totalSmoked} / ${engine.todayPlannedCount}', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomOptions() {
    final items = <_HomeOption>[
      _HomeOption('SOS', Icons.sos, Colors.redAccent, _triggerSOS),
      _HomeOption('論壇', Icons.forum_outlined, Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForumPage()))),
      _HomeOption('文章', Icons.menu_book_outlined, _ThemeColors.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReadingLibraryPage()))),
      _HomeOption('影音', Icons.video_library_outlined, Colors.deepPurple, _openVideoAudio),
      _HomeOption('遊戲', Icons.sports_esports_outlined, Colors.orange, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GameHubPage()))),
      _HomeOption('今日排程', Icons.calendar_today_outlined, Colors.teal, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SchedulePage()))),
    ];

    return Card(
      elevation: 1,
      color: Colors.white.withAlpha(240),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: items.map((item) => Expanded(child: _buildOption(item))).toList(),
        ),
      ),
    );
  }

  Widget _buildOption(_HomeOption item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, color: item.color, size: 23),
            const SizedBox(height: 5),
            Text(item.label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  bool get canSmoke {
    if (engine.totalSmoked >= engine.state.plannedCount) return false;
    return engine.availableSlots > engine.totalSmoked;
  }

  String get countdownString {
    final unlockTime = engine.nextUnlockTime;
    if (unlockTime == null) return '00:00:00';
    final diff = unlockTime.difference(DateTime.now());
    if (diff.isNegative) return '00:00:00';
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

class _HomeOption {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HomeOption(this.label, this.icon, this.color, this.onTap);
}
