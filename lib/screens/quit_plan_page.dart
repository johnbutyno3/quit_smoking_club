import 'package:flutter/material.dart';
import '../engines/plan_generator.dart';
import '../l10n/app_localizations.dart';
import '../models/smoking_plan.dart';
import '../usecases/storage/storage_facade_usecase.dart';

class QuitPlanPage extends StatefulWidget {
  const QuitPlanPage({super.key});

  @override
  State<QuitPlanPage> createState() => _QuitPlanPageState();
}

class _QuitPlanPageState extends State<QuitPlanPage> {
  final dailyController = TextEditingController();
  final priceController = TextEditingController();
  final packController = TextEditingController(text: '20');
  final daysController = TextEditingController();

  List<DailyPlan> plans = [];
  int saving = 0;
  TimeOfDay _firstTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _lastTime = const TimeOfDay(hour: 22, minute: 0);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  @override
  void dispose() {
    dailyController.dispose();
    priceController.dispose();
    packController.dispose();
    daysController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentSettings() async {
    final daily = await StorageFacadeUseCase.getDailyCount();
    final price = await StorageFacadeUseCase.getCigarettePrice();
    final days = await StorageFacadeUseCase.getPlanDurationDays();
    final first = await StorageFacadeUseCase.getFirstSmokeTime();
    final last = await StorageFacadeUseCase.getLastSmokeTime();

    final firstParts = first.split(':');
    final lastParts = last.split(':');

    if (!mounted) return;
    setState(() {
      dailyController.text = (daily > 0 ? daily : 5).toString();
      priceController.text = (price > 0 ? price : 120).toString();
      daysController.text = (days > 0 ? days : 90).toString();
      _firstTime = TimeOfDay(
        hour: firstParts.isNotEmpty ? int.tryParse(firstParts[0]) ?? 8 : 8,
        minute: firstParts.length > 1 ? int.tryParse(firstParts[1]) ?? 0 : 0,
      );
      _lastTime = TimeOfDay(
        hour: lastParts.isNotEmpty ? int.tryParse(lastParts[0]) ?? 22 : 22,
        minute: lastParts.length > 1 ? int.tryParse(lastParts[1]) ?? 0 : 0,
      );
      _loading = false;
    });
  }

  Future<void> generatePlan() async {
    final daily = int.tryParse(dailyController.text) ?? 0;
    final price = int.tryParse(priceController.text) ?? 0;
    final pack = int.tryParse(packController.text) ?? 20;
    final days = int.tryParse(daysController.text) ?? 0;

    if (daily <= 0 || price < 0 || pack <= 0 || days <= 0) return;

    final now = DateTime.now();
    final startTime = DateTime(now.year, now.month, now.day, _firstTime.hour, _firstTime.minute);
    final endTime = DateTime(now.year, now.month, now.day, _lastTime.hour, _lastTime.minute);

    final tempPlan = SmokingPlan(
      startTime: startTime,
      endTime: endTime,
      plannedCount: daily,
      durationDays: days,
    );

    final generatedPlans = PlanGenerator(tempPlan).generate();
    final totalCigarettes = daily * days;
    final packs = (totalCigarettes / pack).ceil();

    await StorageFacadeUseCase.saveDailyCount(daily);
    await StorageFacadeUseCase.saveCigarettePrice(price);
    await StorageFacadeUseCase.savePlanDurationDays(days);
    await StorageFacadeUseCase.savePlanStartDate(
      DateTime(now.year, now.month, now.day).toIso8601String(),
    );
    await StorageFacadeUseCase.saveFirstSmokeTime(
      '${_firstTime.hour.toString().padLeft(2, '0')}:${_firstTime.minute.toString().padLeft(2, '0')}',
    );
    await StorageFacadeUseCase.saveLastSmokeTime(
      '${_lastTime.hour.toString().padLeft(2, '0')}:${_lastTime.minute.toString().padLeft(2, '0')}',
    );

    if (!mounted) return;
    setState(() {
      plans = generatedPlans;
      saving = packs * price;
    });

    Navigator.pop(context, tempPlan);
  }

  Future<void> _pickFirstTime() async {
    final picked = await showTimePicker(context: context, initialTime: _firstTime);
    if (picked != null && mounted) setState(() => _firstTime = picked);
  }

  Future<void> _pickLastTime() async {
    final picked = await showTimePicker(context: context, initialTime: _lastTime);
    if (picked != null && mounted) setState(() => _lastTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.quitPlanPageTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: dailyController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.quitPlanDailyCigarettes),
                  ),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.quitPlanPricePerPack),
                  ),
                  TextField(
                    controller: packController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.quitPlanCigarettesPerPack),
                  ),
                  TextField(
                    controller: daysController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.quitPlanDays),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickFirstTime,
                          icon: const Icon(Icons.wb_sunny_outlined),
                          label: Text(_firstTime.format(context)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickLastTime,
                          icon: const Icon(Icons.nightlight_outlined),
                          label: Text(_lastTime.format(context)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: generatePlan,
                    child: Text(l10n.quitPlanGenerateButton),
                  ),
                  const SizedBox(height: 20),
                  if (plans.isNotEmpty)
                    Expanded(
                      child: ListView(
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.quitPlanEstimatedSavings(saving.toString()),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10),
                                  ...plans.map(
                                    (p) => ListTile(
                                      title: Text(l10n.quitPlanDayLabel(p.day.toString())),
                                      trailing: Text(l10n.plannedCigarettes(p.plannedCount.toString())),
                                    ),
                                  ),
                                ],
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
