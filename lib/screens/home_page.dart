import 'dart:async';

import 'package:flutter/material.dart';

import '../engines/achievement_engine.dart';
import '../engines/recovery_engine.dart';
import '../engines/smoking_engine.dart';
import '../l10n/app_localizations.dart';
import '../models/smoking_plan.dart';
import '../models/smoking_state.dart';
import '../usecases/coin/coin_facade_usecase.dart';
import '../usecases/storage/storage_facade_usecase.dart';
import 'profile_page.dart';
import 'shop_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _ThemeColors {
  static const primary = Color(0xFF1B5E20);
  static const accent = Color(0xFF4CAF50);
  static const bgTop = Color(0xFFE8F5E9);
  static const bgBottom = Color(0xFFF7F9F8);
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late final CoinFacadeUseCase _coinFacade;
  late SmokingEngine engine;
  late RecoveryEngine recovery;
  late AchievementEngine achievement;
  late SmokingState state;
  Timer? _timer;
  bool _isLoaded = false;
  String _userName = '';
  int _coinBalance = 0;

  @override
  void initState() {
    super.initState();
    _coinFacade = CoinFacadeUseCase();
    WidgetsBinding.instance.addObserver(this);
    final now = DateTime.now();
    state = SmokingState(
      planStartDate: now,
      startTime: DateTime(now.year, now.month, now.day, 8),
      endTime: DateTime(now.year, now.month, now.day, 22),
      plannedCount: 5,
    );
    final plan = SmokingPlan(startTime: state.startTime, endTime: state.endTime, plannedCount: state.plannedCount);
    engine = SmokingEngine(state, plan);
    recovery = RecoveryEngine(state);
    achievement = AchievementEngine(smoking: engine, recovery: recovery);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _isLoaded) setState(() {});
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
    if (appState == AppLifecycleState.resumed) _loadStoredData();
  }

  Future<void> _loadStoredData() async {
    final now = DateTime.now();
    final count = await StorageFacadeUseCase.getDailyCount();
    final name = await StorageFacadeUseCase.getUserName();
    final planStart = await StorageFacadeUseCase.getPlanStartDate();
    final records = await StorageFacadeUseCase.getSmokeRecordsForToday();
    final first = await StorageFacadeUseCase.getFirstSmokeTime();
    final last = await StorageFacadeUseCase.getLastSmokeTime();
    final balance = await _coinFacade.getBalance();
    final firstParts = first.split(':');
    final lastParts = last.split(':');
    final firstHour = int.tryParse(firstParts.first) ?? 8;
    final firstMinute = int.tryParse(firstParts.length > 1 ? firstParts[1] : '0') ?? 0;
    final lastHour = int.tryParse(lastParts.first) ?? 22;
    final lastMinute = int.tryParse(lastParts.length > 1 ? lastParts[1] : '0') ?? 0;
    if (!mounted) return;
    final loadedState = SmokingState(
      planStartDate: planStart.isNotEmpty ? DateTime.parse(planStart) : now,
      startTime: DateTime(now.year, now.month, now.day, firstHour, firstMinute),
      endTime: DateTime(now.year, now.month, now.day, lastHour, lastMinute),
      plannedCount: count,
      smokeRecords: records,
      lastSmokeTime: records.isNotEmpty ? records.last : null,
    );
    final loadedPlan = SmokingPlan(startTime: loadedState.startTime, endTime: loadedState.endTime, plannedCount: loadedState.plannedCount);
    setState(() {
      state = loadedState;
      engine = SmokingEngine(state, loadedPlan);
      recovery = RecoveryEngine(state);
      achievement = AchievementEngine(smoking: engine, recovery: recovery);
      _userName = name;
      _coinBalance = balance;
      _isLoaded = true;
    });
  }

  bool get canSmoke {
    final next = engine.nextUnlockTime;
    return next == null || !DateTime.now().isBefore(next);
  }

  double get unlockProgress {
    if (canSmoke) return 1;
    final next = engine.nextUnlockTime;
    if (next == null) return 1;
    final interval = Duration(minutes: engine.intervalMinutes);
    if (interval.inSeconds <= 0) return 0;
    final start = next.subtract(interval);
    return (DateTime.now().difference(start).inMilliseconds / interval.inMilliseconds).clamp(0.0, 1.0);
  }

  String get countdownString {
    final next = engine.nextUnlockTime;
    if (next == null || !DateTime.now().isBefore(next)) return '00:00:00';
    final remaining = next.difference(DateTime.now());
    return '${remaining.inHours.toString().padLeft(2, '0')}:${(remaining.inMinutes % 60).toString().padLeft(2, '0')}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  Future<void> _recordSmoke() async {
    if (!canSmoke || engine.remaining <= 0) return;
    final now = DateTime.now();
    final records = List<DateTime>.from(state.smokeRecords)..add(now);
    final updatedState = SmokingState(planStartDate: state.planStartDate, startTime: state.startTime, endTime: state.endTime, plannedCount: state.plannedCount, smokeRecords: records, lastSmokeTime: now);
    final updatedPlan = SmokingPlan(startTime: updatedState.startTime, endTime: updatedState.endTime, plannedCount: updatedState.plannedCount, durationDays: engine.plan.durationDays);
    await StorageFacadeUseCase.saveSmokeRecords(records);
    await StorageFacadeUseCase.saveLastSmokeTime('${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}');
    if (!mounted) return;
    setState(() {
      state = updatedState;
      engine = SmokingEngine(updatedState, updatedPlan);
      recovery = RecoveryEngine(updatedState);
      achievement = AchievementEngine(smoking: engine, recovery: recovery);
    });
  }

  Widget _card({required Widget child}) => Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3))]),
        child: child,
      );

  Widget _buildCountdownCard() {
    final t = AppLocalizations.of(context)!;
    final unlocked = canSmoke;
    return _card(
      child: InkWell(
        onTap: unlocked ? _recordSmoke : null,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(unlocked ? t.recordSmoking : t.nextSmokeCountdown, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: unlocked ? _ThemeColors.primary : Colors.grey.shade700)),
              const SizedBox(height: 8),
              SizedBox(
                width: 118,
                height: 118,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(value: unlockProgress, strokeWidth: 10, backgroundColor: Colors.grey.shade200, color: unlocked ? _ThemeColors.accent : _ThemeColors.primary),
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(countdownString, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                      const SizedBox(height: 3),
                      Text(unlocked ? t.recordSmoking : t.notUnlocked, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 7),
              Text(t.cigarettesCount(engine.remaining), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuitProgressCard() {
    final t = AppLocalizations.of(context)!;
    final day = DateTime.now().difference(engine.state.planStartDate).inDays + 1;
    final total = engine.plan.durationDays;
    final progress = total <= 0 ? 0.0 : (day / total).clamp(0.0, 1.0);
    return _card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.quitProgress, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 13),
            _statRow(Icons.emoji_events_outlined, t.smokedCount, '${engine.totalSmoked}/${engine.todayPlannedCount}'),
            const SizedBox(height: 9),
            _statRow(Icons.flag_outlined, t.remaining, '${engine.remaining}'),
            const SizedBox(height: 9),
            _statRow(Icons.calendar_today_outlined, t.todaySmokingSchedule, '$day/$total'),
            const Spacer(),
            ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: Colors.grey.shade200, color: _ThemeColors.accent)),
          ],
        ),
      ),
    );
  }

  Widget _statRow(IconData icon, String label, String value) => Row(children: [Icon(icon, size: 18, color: _ThemeColors.primary), const SizedBox(width: 7), Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11))), Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]);

  Widget _buildWelcomeCard() {
    final t = AppLocalizations.of(context)!;
    return _card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          const CircleAvatar(radius: 24, child: Icon(Icons.forum_outlined)),
          const SizedBox(width: 12),
          Expanded(child: Text(_userName.isEmpty ? t.welcomeMessage : '${t.hello}, $_userName', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_ThemeColors.bgTop, _ThemeColors.bgBottom])),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white.withAlpha(225),
          elevation: 0,
          centerTitle: true,
          leading: InkWell(
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopPage()));
              await _loadStoredData();
            },
            child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.monetization_on, color: Colors.amber, size: 25), const SizedBox(width: 3), Text('$_coinBalance', style: const TextStyle(fontWeight: FontWeight.bold))]),
          ),
          title: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
            child: CircleAvatar(
              radius: 19,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(Icons.person, size: 22, color: Theme.of(context).colorScheme.primary),
            ),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.settings_outlined), tooltip: t.settings, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()))),
          ],
        ),
        body: SafeArea(
          top: false,
          child: !_isLoaded
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                  children: [
                    _buildWelcomeCard(),
                    const SizedBox(height: 12),
                    SizedBox(height: 215, child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(child: _buildCountdownCard()), const SizedBox(width: 12), Expanded(child: _buildQuitProgressCard())])),
                  ],
                ),
        ),
      ),
    );
  }
}
