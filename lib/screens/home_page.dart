import 'dart:async';

import 'package:flutter/material.dart';

import '../engines/smoking_engine.dart';
import '../engines/recovery_engine.dart';
import '../engines/achievement_engine.dart';
import '../l10n/app_localizations.dart';
import '../models/smoking_plan.dart';
import '../models/smoking_state.dart';
import '../usecases/coin/coin_facade_usecase.dart';
import '../usecases/storage/storage_facade_usecase.dart';
import 'coin_page.dart';

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
  final List<String> _messages = [];

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

    final plan = SmokingPlan(
      startTime: state.startTime,
      endTime: state.endTime,
      plannedCount: state.plannedCount,
    );
    engine = SmokingEngine(state, plan);
    recovery = RecoveryEngine(state);
    achievement = AchievementEngine(smoking: engine, recovery: recovery);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_isLoaded) return;
      setState(() {});
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
    final loadedPlan = SmokingPlan(
      startTime: loadedState.startTime,
      endTime: loadedState.endTime,
      plannedCount: loadedState.plannedCount,
    );

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
    if (canSmoke) return 1.0;
    final next = engine.nextUnlockTime;
    if (next == null) return 1.0;
    final interval = Duration(minutes: engine.intervalMinutes);
    if (interval.inSeconds <= 0) return 0.0;
    final start = next.subtract(interval);
    final total = interval.inMilliseconds;
    final elapsed = DateTime.now().difference(start).inMilliseconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  String get countdownString {
    final next = engine.nextUnlockTime;
    if (next == null || !DateTime.now().isBefore(next)) return '00:00:00';
    final remaining = next.difference(DateTime.now());
    final hours = remaining.inHours.toString().padLeft(2, '0');
    final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  Future<void> _recordSmoke() async {
    if (!canSmoke || engine.remaining <= 0) return;
    final now = DateTime.now();
    final records = List<DateTime>.from(state.smokeRecords)..add(now);
    final updatedState = SmokingState(
      planStartDate: state.planStartDate,
      startTime: state.startTime,
      endTime: state.endTime,
      plannedCount: state.plannedCount,
      smokeRecords: records,
      lastSmokeTime: now,
    );
    final updatedPlan = SmokingPlan(
      startTime: updatedState.startTime,
      endTime: updatedState.endTime,
      plannedCount: updatedState.plannedCount,
      durationDays: engine.plan.durationDays,
    );

    await StorageFacadeUseCase.saveSmokeRecords(records);
    await StorageFacadeUseCase.saveLastSmokeTime(
      '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
    );

    if (!mounted) return;
    setState(() {
      state = updatedState;
      engine = SmokingEngine(updatedState, updatedPlan);
      recovery = RecoveryEngine(updatedState);
      achievement = AchievementEngine(smoking: engine, recovery: recovery);
    });
  }

  void _showMessageHistory() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * .55,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Text(l10n.welcomeMessage, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(18),
                  itemCount: _messages.length,
                  itemBuilder: (_, index) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16)),
                    child: Text(_messages[index], style: const TextStyle(fontSize: 17, height: 1.5)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSchedule() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * .68,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.todaySmokingSchedule, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    itemCount: engine.schedule.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final time = engine.schedule[index];
                      final now = DateTime.now();
                      final scheduled = DateTime(now.year, now.month, now.day, time.hour, time.minute);
                      final smoked = index < engine.totalSmoked;
                      final past = now.isAfter(scheduled);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          smoked ? Icons.check_circle : past ? Icons.cancel_outlined : Icons.lock_clock,
                          color: smoked ? Colors.green : past ? Colors.grey : _ThemeColors.accent,
                        ),
                        title: Text('${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        trailing: Text(smoked ? l10n.smoked : past ? l10n.notRecorded : l10n.notUnlocked, style: const TextStyle(fontSize: 14)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConversationCard() {
    final l10n = AppLocalizations.of(context)!;
    final message = _messages.isEmpty ? l10n.welcomeMessage : _messages.last;
    return InkWell(
      onTap: _showMessageHistory,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4))]),
        child: Row(
          children: [
            Container(width: 48, height: 48, decoration: const BoxDecoration(color: _ThemeColors.bgTop, shape: BoxShape.circle), child: const Icon(Icons.forum_outlined, color: _ThemeColors.primary)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_userName.isEmpty ? l10n.welcomeMessage : '${l10n.hello}, $_userName', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(message, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, height: 1.35, color: Colors.black87)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildUnlockCard() {
    final l10n = AppLocalizations.of(context)!;
    final unlocked = canSmoke;
    final remaining = engine.remaining;
    return InkWell(
      onTap: unlocked ? _recordSmoke : null,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 265,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4))]),
        child: Column(
          children: [
            Text(unlocked ? l10n.recordSmoking : l10n.nextSmokeCountdown, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: unlocked ? _ThemeColors.primary : Colors.grey.shade700)),
            const SizedBox(height: 8),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(width: 178, height: 178, child: CircularProgressIndicator(value: unlockProgress, strokeWidth: 13, backgroundColor: Colors.grey.shade200, color: unlocked ? _ThemeColors.accent : _ThemeColors.primary)),
                  Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(countdownString, style: const TextStyle(fontSize: 29, fontWeight: FontWeight.bold, fontFamily: 'monospace', letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(unlocked ? l10n.recordSmoking : l10n.notUnlocked, style: TextStyle(fontSize: 13, color: unlocked ? _ThemeColors.primary : Colors.grey, fontWeight: FontWeight.w600)),
                  ]),
                ],
              ),
            ),
            Text(remaining > 0 ? l10n.cigarettesCount(remaining) : l10n.smoked, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayCard() {
    final l10n = AppLocalizations.of(context)!;
    final currentDay = DateTime.now().difference(engine.state.planStartDate).inDays + 1;
    final totalDays = engine.plan.durationDays;
    final progress = totalDays <= 0 ? 0.0 : (currentDay / totalDays).clamp(0.0, 1.0);
    return Container(
      height: 265,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.todaySmokingSchedule, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _todayRow(Icons.emoji_events_outlined, l10n.smokedCount, '${engine.totalSmoked}/${engine.todayPlannedCount}'),
          const SizedBox(height: 10),
          _todayRow(Icons.flag_outlined, l10n.remaining, '${engine.remaining}'),
          const SizedBox(height: 10),
          _todayRow(Icons.calendar_today_outlined, l10n.todaySmokingSchedule, 'Day $currentDay/$totalDays'),
          const Spacer(),
          ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: progress, minHeight: 9, backgroundColor: Colors.grey.shade200, color: _ThemeColors.accent)),
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _showSchedule, child: Text(l10n.todaySmokingSchedule))),
        ],
      ),
    );
  }

  Widget _todayRow(IconData icon, String label, String value) => Row(children: [Icon(icon, size: 21, color: _ThemeColors.primary), const SizedBox(width: 9), Expanded(child: Text(label, style: const TextStyle(fontSize: 14))), Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))]);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_ThemeColors.bgTop, _ThemeColors.bgBottom])),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(l10n.appTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white.withAlpha(220),
          elevation: 0,
          actions: [
            InkWell(
              onTap: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const CoinPage()));
                await _loadStoredData();
              },
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber, size: 27),
                    const SizedBox(width: 5),
                    Text('$_coinBalance', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: SafeArea(
          top: false,
          child: !_isLoaded
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  children: [
                    _buildConversationCard(),
                    const SizedBox(height: 14),
                    _buildUnlockCard(),
                    const SizedBox(height: 14),
                    _buildTodayCard(),
                  ],
                ),
        ),
      ),
    );
  }
}
