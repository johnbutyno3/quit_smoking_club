import 'package:flutter/material.dart';
import '../engines/plan_generator.dart';
import '../models/smoking_plan.dart';

class QuitPlanPage extends StatefulWidget {
  const QuitPlanPage({super.key});

  @override
  State<QuitPlanPage> createState() => _QuitPlanPageState();
}

class _QuitPlanPageState extends State<QuitPlanPage> {
  final dailyController = TextEditingController(text: "20");

  final priceController = TextEditingController(text: "120");

  final packController = TextEditingController(text: "20");

  final daysController = TextEditingController(text: "90");

  List<DailyPlan> plans = [];

  int saving = 0;

  void generatePlan() {
    final daily = int.tryParse(dailyController.text) ?? 0;

    final price = int.tryParse(priceController.text) ?? 0;

    final pack = int.tryParse(packController.text) ?? 20;

    final days = int.tryParse(daysController.text) ?? 90;

    final now = DateTime.now();

    final tempPlan = SmokingPlan(
      startTime: DateTime(now.year, now.month, now.day, 8, 0),

      endTime: DateTime(now.year, now.month, now.day, 22, 0),

      plannedCount: daily,

      durationDays: days,
    );
    plans = PlanGenerator(tempPlan).generate();
    final totalCigarettes = daily * days;

    final packs = (totalCigarettes / pack).ceil();

    saving = packs * price;

    setState(() {});

    Navigator.pop(context, tempPlan);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("戒菸計畫")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            TextField(
              controller: dailyController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(labelText: "每日抽菸數"),
            ),

            TextField(
              controller: priceController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(labelText: "每包價格"),
            ),

            TextField(
              controller: packController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(labelText: "每包支數"),
            ),

            TextField(
              controller: daysController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(labelText: "戒菸天數"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: generatePlan,

              child: const Text("產生戒菸計畫"),
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
                              "預估節省：$saving 元",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            ...plans.map(
                              (p) => ListTile(
                                title: Text("第 ${p.day} 天"),

                                trailing: Text("🚬 ${p.plannedCount} 支"),
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
