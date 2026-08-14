import 'package:flutter/material.dart';

import '../engines/smoking_engine.dart';
import '../l10n/app_localizations.dart';
import '../models/smoking_plan.dart';
import '../models/smoking_state.dart';
import '../usecases/storage/storage_facade_usecase.dart';

class DailySchedulePage extends StatefulWidget {
  const DailySchedulePage({super.key});

  @override
  State<DailySchedulePage> createState() => _DailySchedulePageState();
}

class _DailySchedulePageState extends State<DailySchedulePage> {
  SmokingEngine? _engine;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final now = DateTime.now();
    final count = await StorageFacadeUseCase.getDailyCount();
    final records = await StorageFacadeUseCase.getSmokeRecordsForToday();
    final first = await StorageFacadeUseCase.getFirstSmokeTime();
    final last = await StorageFacadeUseCase.getLastSmokeTime();

    final firstParts = first.split(':');
    final lastParts = last.split(':');
    final firstHour = int.tryParse(firstParts.first) ?? 8;
    final firstMinute = int.tryParse(firstParts.length > 1 ? firstParts[1] : '0') ?? 0;
    final lastHour = int.tryParse(lastParts.first) ?? 22;
    final lastMinute = int.tryParse(lastParts.length > 1 ? lastParts[1] : '0') ?? 0;

    final state = SmokingState(
      planStartDate: now,
      startTime: DateTime(now.year, now.month, now.day, firstHour, firstMinute),
      endTime: DateTime(now.year, now.month, now.day, lastHour, lastMinute),
      plannedCount: count,
      smokeRecords: records,
      lastSmokeTime: records.isEmpty ? null : records.last,
    );
    final plan = SmokingPlan(
      startTime: state.startTime,
      endTime: state.endTime,
      plannedCount: count,
    );

    if (!mounted) return;
    setState(() {
      _engine = SmokingEngine(state, plan);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final engine = _engine;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.todaySmokingSchedule)),
      body: _loading || engine == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: engine.schedule.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final time = engine.schedule[index];
                  final now = DateTime.now();
                  final scheduled = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    time.hour,
                    time.minute,
                  );
                  final smoked = index < engine.totalSmoked;
                  final past = now.isAfter(scheduled);
                  final unlocked = !past || smoked;

                  return ListTile(
                    leading: Icon(
                      smoked
                          ? Icons.check_circle
                          : past
                              ? Icons.cancel_outlined
                              : Icons.lock_clock,
                      color: smoked
                          ? Colors.green
                          : past
                              ? Colors.grey
                              : Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      smoked
                          ? l10n.smoked
                          : unlocked
                              ? l10n.recordSmoking
                              : l10n.notUnlocked,
                    ),
                  );
                },
              ),
            ),
    );
  }
}
